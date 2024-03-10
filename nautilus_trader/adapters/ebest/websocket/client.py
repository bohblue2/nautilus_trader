import asyncio
from typing import Callable

import msgspec.json
from nautilus_trader.common.clock import LiveClock
from nautilus_trader.common.logging import Logger, LoggerAdapter
from nautilus_trader.core.nautilus_pyo3.network import WebSocketClient
from nautilus_trader.core.rust.common import LogColor
from nautilus_trader.model.identifiers import InstrumentId, Symbol

from nautilus_trader.adapters.ebest.common import EBEST_VENUE
from nautilus_trader.adapters.ebest.config import EbestClientConfig, EbestInstrumentProviderConfig
from nautilus_trader.adapters.ebest.http.client import EbestHttpClient
from nautilus_trader.adapters.ebest.providers import EbestInstrumentProvider
from nautilus_trader.model.instruments import Instrument

EXECUTION_SUBSCRIBE = "1"
EXECUTION_UNSUBSCRIBE = "2"
SUBSCRIBE = "3"
UNSUBSCRIBE = "4"


class RequestHeader(msgspec.Struct):
    token: str | None = None
    tr_type: str | None = None


class RequestBody(msgspec.Struct):
    tr_cd: str | None = None
    tr_key: str | None = None


class RequestMessage(msgspec.Struct):
    header: RequestHeader | None = None
    body: RequestBody | None = None


class EbestWebsocketClient:
    def __init__(
        self,
        clock: LiveClock,
        logger: Logger,
        config: EbestClientConfig,
        access_token: str,
        handler: Callable[[bytes], None],
    ):
        self._clock = clock
        self._log = LoggerAdapter(type(self).__name__, logger=logger)
        self._config = config
        self._access_token = access_token
        self._handler = handler

        self._client = None
        self._key = config.app_key
        self._secret = config.app_secret
        self._ws_url = config.websocket_base_url + "/websocket"
        self._topics_connecting = set()
        self._topics = {}
        self._is_connected = False

    def _generate_request_message(self, tr_cd, tr_key):
        return RequestMessage(
            header=RequestHeader(token=self._access_token, tr_type=None),
            body=RequestBody(tr_cd=tr_cd, tr_key=tr_key),
        )

    async def subscribe_orderbook(self, instrument: Instrument):
        tr_cd = "H1_" if instrument.info["market"] == "KOSPI" else "HA_"
        request_message = self._generate_request_message(tr_cd, instrument.symbol.value)
        await self._subscribe(request_message)

    async def subscribe_trade(self, instrument: Instrument):
        tr_cd = "S3_" if instrument.info["market"] == "KOSPI" else "K3_"
        request_message = self._generate_request_message(tr_cd, instrument.symbol.value)
        await self._subscribe(request_message)

    async def subscribe_equity_execution_stream(self):
        streams = [
            "SC0",  # 주식주문접수
            "SC1",  # 주식주문체결
            "SC2",  # 주식주문정정
            "SC3",  # 주식주문취소
            "SC4",  # 주식주문거부
        ]
        request_messages = [self._generate_request_message(stream, "") for stream in streams]
        for request_message in request_messages:
            await self._subscribe(request_message, is_execution=True)

    async def connect(self):
        self._log.debug(f"Connecting to {self._ws_url}...")
        self._client = await WebSocketClient.connect(
            url=self._ws_url, handler=self._handler, heartbeat=60
        )
        if self._client.is_alive:
            self._log.info(f"Connected to {self._ws_url}.", LogColor.BLUE)
            self._is_connected = True

    async def _manage_subscription(
        self, request: RequestMessage, action_type: str, is_execution=False, delay_sec=0.1
    ):
        if not self._is_connected:
            await self.connect()

        action_map = {
            "subscribe": SUBSCRIBE if not is_execution else EXECUTION_SUBSCRIBE,
            "unsubscribe": UNSUBSCRIBE if not is_execution else EXECUTION_UNSUBSCRIBE,
        }

        tr_key = request.body.tr_key
        should_proceed = (action_type == "subscribe" and tr_key not in self._topics_connecting) or (
            action_type == "unsubscribe" and tr_key in self._topics_connecting
        )

        if is_execution:
            should_proceed = True

        if should_proceed:
            request.header.tr_type = action_map[action_type]
            if action_type == "subscribe":
                self._topics_connecting.add(tr_key)
                log_msg = f"Subscribed to {request.body.tr_cd} {tr_key}."
            else:
                self._topics_connecting.remove(tr_key)
                log_msg = f"Unsubscribed from {request.body.tr_cd} {tr_key}."

            await self._send_text(request, delay_sec=delay_sec)
            self._log.info(log_msg, LogColor.BLUE)

    async def _subscribe(self, request: RequestMessage, is_execution=False, delay_sec=0.1):
        await self._manage_subscription(request, "subscribe", is_execution, delay_sec)

    async def _unsubscribe(self, request: RequestMessage, is_execution=False, delay_sec=0.1):
        await self._manage_subscription(request, "unsubscribe", is_execution, delay_sec)

    async def _send_text(self, request: RequestMessage, delay_sec=0.1):
        await self._client.send_text(msgspec.json.encode(request).decode("utf-8"))
        await asyncio.sleep(delay_sec)


def _handle_ws_message(raw: bytes) -> None:
    print(msgspec.json.decode(raw))


async def main():
    clock = LiveClock()
    logger = Logger(clock=clock)
    client_config = EbestClientConfig(
        app_key="PSBn3DRe03RxTPOaedZbSuv5ReRRU0vTvS8C",
        app_secret="InLlGdeX2rD931d2oZDbBBJRSLcCeieG",
    )
    client = EbestHttpClient(clock=clock, logger=logger, config=client_config)
    await client.authenticate()

    provider_config = EbestInstrumentProviderConfig()
    provider = EbestInstrumentProvider(client=client, config=provider_config, logger=logger)
    await provider.load_all_async()

    websocket = EbestWebsocketClient(
        clock=clock,
        logger=logger,
        config=client_config,
        access_token=client.access_token,
        handler=_handle_ws_message,
    )
    await websocket.subscribe_orderbook(provider.find(InstrumentId(Symbol("005930"), EBEST_VENUE)))
    await websocket.subscribe_equity_execution_stream()

    while True:
        await asyncio.sleep(10)


if __name__ == "__main__":
    asyncio.run(main())

import asyncio

import msgspec
from nautilus_trader.common.clock import LiveClock
from nautilus_trader.core.rust.model import OrderSide
from nautilus_trader.model.identifiers import InstrumentId, Symbol, Venue
from nautilus_trader.model.objects import Quantity

from nautilus_trader.adapters.ebest.config import EbestClientConfig
from nautilus_trader.adapters.ebest.http.client import EbestHttpClient
from nautilus_trader.adapters.ebest.websocket.client import EbestWebsocketClient
from nautilus_trader.test_kit.stubs.commands import TestCommandStubs
from nautilus_trader.test_kit.stubs.execution import TestExecStubs


async def main():
    def _handle_ws_message(raw: bytes) -> None:
        print(msgspec.json.decode(raw))

    from nautilus_trader.common.logging import Logger

    clock = LiveClock()
    logger = Logger(clock=clock)
    client_config = EbestClientConfig(
        app_key="",
        app_secret="",
    )
    client = EbestHttpClient(clock=clock, logger=logger, config=client_config)
    await client.authenticate()

    websocket = EbestWebsocketClient(
        clock=clock,
        logger=logger,
        config=client_config,
        access_token=client.access_token,
        handler=_handle_ws_message,
    )
    await websocket.subscribe_equity_execution_stream()
    order = TestExecStubs.market_order(
        instrument_id=InstrumentId(Symbol("250060"), Venue("EBEST")),
        order_side=OrderSide.BUY,
        # price=Price.from_str("692"),
        quantity=Quantity.from_str("1"),
    )

    command = TestCommandStubs.submit_order_command(order)
    print(command)
    response = await client.CSPAT00601(command)

    while True:
        await asyncio.sleep(10)


if __name__ == "__main__":
    asyncio.run(main())

# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2023 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------
import asyncio
import copy
import urllib
from typing import Optional, Any

import msgspec
from nautilus_trader.common.clock import LiveClock
from nautilus_trader.common.logging import Logger
from nautilus_trader.common.logging import LoggerAdapter
from nautilus_trader.core.nautilus_pyo3.network import HttpClient
from nautilus_trader.core.nautilus_pyo3.network import HttpMethod
from nautilus_trader.core.nautilus_pyo3.network import HttpResponse
from nautilus_trader.execution.messages import SubmitOrder, ModifyOrder
from nautilus_trader.model.identifiers import InstrumentId, Venue, Symbol

from nautilus_trader.adapters.ebest.blocks import CSPAT00601InBlock1, t8436InBlock
from nautilus_trader.adapters.ebest.config import EbestClientConfig
from nautilus_trader.adapters.ebest.enums import (
    EbestEnumParser as Parser,
    OrdprcPtnCode,
)
from nautilus_trader.model.orders import LimitOrder, MarketOrder
from nautilus_trader.test_kit.stubs.commands import TestCommandStubs
from nautilus_trader.test_kit.stubs.execution import TestExecStubs


class EbestHttpClient:
    """
    Provides a `Ebest` asynchronous HTTP client.

    Parameters
    ----------
    key : str
        The Ebest API key for requests.
    secret : str
        The Ebest API secret for signed requests.
    base_url : str, optional
    """

    def __init__(
        self,
        clock: LiveClock,
        logger: Logger,
        config: EbestClientConfig,
    ):
        self._clock: LiveClock = clock
        self._log: LoggerAdapter = LoggerAdapter(type(self).__name__, logger=logger)
        self._config: EbestClientConfig = config

        self._client = HttpClient()
        self._key = config.app_key
        self._secret = config.app_secret
        self._base_url = config.rest_base_url
        self._headers = {
            "content-type": "application/json; charset=utf-8",
            "authorization": None,
            "tr_cd": "",
            "tr_cont": "N",
            "tr_cont_key": "",
            "mac_address": "",
        }

        self._auth_done = False
        self._access_token = None

    @property
    def access_token(self) -> str:
        return self._access_token

    def generate_header(self, tr_cd: str) -> dict[str, str]:
        header = copy.deepcopy(self._headers)
        header["tr_cd"] = tr_cd
        return header

    async def t8436(self) -> dict[str, Any]:
        return await self.send_request(
            HttpMethod.POST,
            url_path="/stock/etc",
            header=self.generate_header("t8436"),
            body=t8436InBlock(gubun="0"),
        )

    async def CSPAT00601(self, command: SubmitOrder):
        order = command.order
        if isinstance(order, LimitOrder):
            body = CSPAT00601InBlock1(
                IsuNo=order.symbol.value,
                OrdQty=int(order.quantity.as_double()),
                OrdPrc=order.price.as_double(),
                BnsTpCode=Parser.order_side_to_ebest(order.side),
                OrdprcPtnCode=OrdprcPtnCode.LIMIT_PRICE.value,
                MgntrnCode="000",
                LoanDt="",
                OrdCndiTpCode=Parser.time_in_force_to_ebest(order.time_in_force),
            )
        elif isinstance(order, MarketOrder):
            body = CSPAT00601InBlock1(
                IsuNo=order.symbol.value,
                OrdQty=int(order.quantity.as_double()),
                OrdPrc=0,
                BnsTpCode=Parser.order_side_to_ebest(order.side),
                OrdprcPtnCode=OrdprcPtnCode.MARKET_PRICE.value,
                MgntrnCode="000",
                LoanDt="",
                OrdCndiTpCode=Parser.time_in_force_to_ebest(order.time_in_force),
            )
        else:
            raise Exception("Unsupported order type")

        return await self.send_request(
            HttpMethod.POST,
            url_path="/stock/order",
            header=self.generate_header("CSPAT00601"),
            body=body,
        )

    async def CSPAT00701(self, command: ModifyOrder):
        pass

    async def authenticate(
        self,
    ) -> None:
        response = await self.send_request(
            HttpMethod.POST,
            url_path="/oauth2/token",
            header={"content-type": "application/x-www-form-urlencoded"},
            body={
                "grant_type": "client_credentials",
                "appkey": self._key,
                "appsecretkey": self._secret,
                "scope": "oob",
            },
            url_encoded=True,
        )
        self._headers["authorization"] = f"Bearer {response['access_token']}"
        self._access_token = response["access_token"]
        self._auth_done = True

    async def send_request(
        self,
        http_method: HttpMethod,
        url_path: str,
        header: Optional[dict[str, str]],
        body: Optional[dict[str, Any] | msgspec.Struct] = None,
        url_encoded: bool = False,
    ) -> dict[str, Any]:
        if url_encoded:
            url_path += "?" + urllib.parse.urlencode(body)
        else:
            body = msgspec.json.encode({body.__class__.__name__: body})

        self._log.info(f"Request: {url_path=}, {body=}")
        response: HttpResponse = await self._client.request(
            http_method,
            url=self._base_url + url_path,
            headers=header,
            body=body if not url_encoded else None,
        )

        if 400 <= response.status < 500:
            # TODO: raise ClientError()
            ...
        elif response.status >= 500:
            # TODO: raise ServerError()
            ...

        response_body: dict[str, Any] = msgspec.json.decode(response.body)
        if "rsp_cd" in response_body and response_body["rsp_cd"] != "00000":
            if response_body["rsp_cd"] == "08677":  # 증거금 부족
                raise Exception(f"{response_body['rsp_msg']}")

        self._log.info(f"Response: {response_body=}")

        return response_body


async def main():
    def _handle_ws_message(raw: bytes) -> None:
        print(msgspec.json.decode(raw))

    from nautilus_trader.common.logging import Logger

    clock = LiveClock()
    logger = Logger(clock=clock)
    client_config = EbestClientConfig(
        app_key="PSBn3DRe03RxTPOaedZbSuv5ReRRU0vTvS8C",
        app_secret="InLlGdeX2rD931d2oZDbBBJRSLcCeieG",
    )
    client = EbestHttpClient(clock=clock, logger=logger, config=client_config)
    await client.authenticate()
    order = TestExecStubs.limit_order(instrument_id=InstrumentId(Symbol("A000660"), Venue("EBEST")))
    command = TestCommandStubs.submit_order_command(order)
    print(command)
    response = await client.CSPAT00601(command)

    while True:
        await asyncio.sleep(10)


if __name__ == "__main__":
    asyncio.run(main())

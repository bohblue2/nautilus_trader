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
from typing import Optional

from nautilus_trader.common.logging import Logger
from nautilus_trader.model.identifiers import InstrumentId

from nautilus_trader.adapters.ebest.blocks import t8436OutBlock
from nautilus_trader.adapters.ebest.common import EBEST_VENUE
from nautilus_trader.adapters.ebest.config import EbestInstrumentProviderConfig, EbestClientConfig
from nautilus_trader.adapters.ebest.http.client import EbestHttpClient
from nautilus_trader.adapters.ebest.parsing.instruments import parse_equity_instrument
from nautilus_trader.common.providers import InstrumentProvider


class EbestInstrumentProvider(InstrumentProvider):
    """
    Provides a means of loading `Instrument` objects through the Ebest API.
    """

    def __init__(
        self, client: EbestHttpClient, config: EbestInstrumentProviderConfig, logger: Logger
    ):
        super().__init__(venue=EBEST_VENUE, config=config, logger=logger)

        self._client: EbestHttpClient = client
        self._config = config
        self._logger = logger

    async def load_all_async(self, filters: Optional[dict] = None) -> None:
        data = await self._client.t8436()
        data = data["t8436OutBlock"]
        self._log.info(f"Loaded {len(data)} instruments from Ebest.")
        for row in data:
            row: dict[str, str]
            self.add(parse_equity_instrument(t8436OutBlock(**row)))

    async def load_ids_async(
        self,
        instrument_ids: list[InstrumentId],
        filters: Optional[dict] = None,
    ) -> None:
        raise NotImplementedError("method must be implemented in the subclass")  # pragma: no cover

    async def load_async(self, instrument_id: InstrumentId, filters: Optional[dict] = None):
        raise NotImplementedError("method must be implemented in the subclass")  # pragma: no cover


async def main():
    from nautilus_trader.common.logging import Logger

    from nautilus_trader.common.clock import LiveClock

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

    # print(provider.get_all())


if __name__ == "__main__":
    asyncio.run(main())

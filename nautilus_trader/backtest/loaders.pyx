# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2020 Nautech Systems Pty Ltd. All rights reserved.
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

import pandas as pd
import pytz

from cpython.datetime cimport datetime

from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.model.c_enums.asset_type cimport AssetType
from nautilus_trader.model.currency cimport BTC
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.currency cimport ETH
from nautilus_trader.model.currency cimport USD
from nautilus_trader.model.currency cimport USDT
from nautilus_trader.model.identifiers cimport Symbol
from nautilus_trader.model.identifiers cimport Venue
from nautilus_trader.model.instrument cimport Instrument
from nautilus_trader.model.objects cimport Decimal
from nautilus_trader.model.objects cimport Money
from nautilus_trader.model.objects cimport Quantity

# Unix epoch is the UTC time at 00:00:00 on 1/1/1970
_UNIX_EPOCH = datetime(1970, 1, 1, 0, 0, 0, 0, tzinfo=pytz.utc)

cdef class CSVTickDataLoader:
    """
    Provides a means of loading tick data pandas DataFrames from CSV files.
    """

    @staticmethod
    def load(str file_path) -> pd.DataFrame:
        """
        Return the tick pandas.DataFrame loaded from the given csv file.

        Parameters
        ----------
        file_path : str
            The absolute path to the CSV file.

        Returns
        -------
        pd.DataFrame

        """
        Condition.not_none(file_path, "file_path")

        return pd.read_csv(
            file_path,
            usecols=[1, 2, 3],
            index_col=0,
            header=None,
            parse_dates=True,
        )


cdef class CSVBarDataLoader:
    """
    Provides a means of loading bar data pandas DataFrames from CSV files.
    """

    @staticmethod
    def load(str file_path) -> pd.DataFrame:
        """
        Return the bar pandas.DataFrame loaded from the given csv file.

        Parameters
        ----------
        file_path : str
            The absolute path to the CSV file.

        Returns
        -------
        pd.DataFrame

        """
        Condition.not_none(file_path, "file_path")

        return pd.read_csv(
            file_path,
            index_col="Time (UTC)",
            parse_dates=True,
        )


cdef class InstrumentLoader:
    """
    Provides instrument template methods for backtesting.
    """

    @staticmethod
    def xbtusd_bitmex() -> Instrument:
        """
        Return the BitMEX XBT/USD perpetual contract for backtesting.
        """
        return Instrument(
            symbol=Symbol("XBT/USD", Venue('BITMEX')),
            asset_type=AssetType.CRYPTO,
            base_currency=BTC,
            quote_currency=USD,
            settlement_currency=BTC,
            price_precision=1,
            size_precision=0,
            tick_size=Decimal("0.5"),
            lot_size=Quantity(1),
            min_trade_size=Quantity(1),
            max_trade_size=Quantity(1e7),
            rollover_interest_buy=Decimal(),
            rollover_interest_sell=Decimal(),
            timestamp=_UNIX_EPOCH,
        )

    @staticmethod
    def ethxbt_bitmex() -> Instrument:
        """
        Return the BitMEX ETH/XBT perpetual contract for backtesting.
        """
        return Instrument(
            symbol=Symbol("ETH/XBT", Venue('BITMEX')),
            asset_type=AssetType.CRYPTO,
            base_currency=ETH,
            quote_currency=BTC,
            settlement_currency=BTC,
            price_precision=5,
            size_precision=0,
            tick_size=Decimal("0.00001"),
            lot_size=Quantity(1),
            min_trade_size=Quantity(1),
            max_trade_size=Quantity(1e8),
            rollover_interest_buy=Decimal(),
            rollover_interest_sell=Decimal(),
            timestamp=_UNIX_EPOCH,
        )

    @staticmethod
    def ethusd_bitmex() -> Instrument:
        """
        Return the BitMEX ETH/USD perpetual contract for backtesting.
        """
        return Instrument(
            symbol=Symbol("ETH/USD", Venue('BITMEX')),
            asset_type=AssetType.CRYPTO,
            base_currency=ETH,
            quote_currency=USD,
            settlement_currency=BTC,
            price_precision=2,
            size_precision=0,
            tick_size=Decimal("0.05"),
            lot_size=Quantity(1),
            min_trade_size=Quantity(1),
            max_trade_size=Quantity(1e7),
            rollover_interest_buy=Decimal(),
            rollover_interest_sell=Decimal(),
            timestamp=_UNIX_EPOCH,
        )

    @staticmethod
    def btcusdt_binance() -> Instrument:
        """
        Return the Binance BTC/USDT instrument for backtesting.
        """
        return Instrument(
            symbol=Symbol("BTC/USDT", Venue('BINANCE')),
            asset_type=AssetType.CRYPTO,
            base_currency=BTC,
            quote_currency=USDT,
            settlement_currency=BTC,
            price_precision=2,
            size_precision=6,
            tick_size=Decimal("0.01"),
            lot_size=Quantity(1),
            min_trade_size=Money(10, USDT),
            max_trade_size=Quantity("100"),
            rollover_interest_buy=Decimal(),
            rollover_interest_sell=Decimal(),
            timestamp=_UNIX_EPOCH,
        )

    @staticmethod
    def ethusdt_binance() -> Instrument:
        """
        Return the Binance ETH/USDT instrument for backtesting.
        """
        return Instrument(
            symbol=Symbol("ETH/USDT", Venue('BINANCE')),
            asset_type=AssetType.CRYPTO,
            base_currency=ETH,
            quote_currency=USDT,
            settlement_currency=ETH,
            price_precision=2,
            size_precision=5,
            tick_size=Decimal("0.01"),
            lot_size=Quantity(1),
            min_trade_size=Money(10, USDT),
            max_trade_size=Quantity("100"),
            rollover_interest_buy=Decimal(),
            rollover_interest_sell=Decimal(),
            timestamp=_UNIX_EPOCH,
        )

    @staticmethod
    def default_fx_ccy(Symbol symbol) -> Instrument:
        """
        Return a default FX currency pair instrument from the given arguments.

        Parameters
        ----------
        symbol : Symbol
            The currency pair symbol.

        Raises
        ------
        ValueError
            If the symbol.code length is not in range [6, 7].

        """
        Condition.not_none(symbol, "symbol")
        Condition.in_range_int(len(symbol.code), 6, 7, "len(symbol)")

        cdef str base_currency = symbol.code[:3]
        cdef str quote_currency = symbol.code[-3:]

        # Check tick precision of quote currency
        if quote_currency == 'JPY':
            price_precision = 3
        else:
            price_precision = 5

        return Instrument(
            symbol=symbol,
            asset_type=AssetType.FOREX,
            base_currency=Currency.from_string_c(base_currency),
            quote_currency=Currency.from_string_c(quote_currency),
            settlement_currency=Currency.from_string_c(base_currency),
            price_precision=price_precision,
            size_precision=0,
            tick_size=Decimal.from_float_c(1 / (10 ** price_precision), price_precision),
            lot_size=Quantity("1000"),
            min_trade_size=Quantity("1"),
            max_trade_size=Quantity("50000000"),
            rollover_interest_buy=Decimal(),
            rollover_interest_sell=Decimal(),
            timestamp=_UNIX_EPOCH,
        )

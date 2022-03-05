# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2022 Nautech Systems Pty Ltd. All rights reserved.
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

from nautilus_trader.analysis.statistics.long_ratio import LongRatio
from nautilus_trader.backtest.data.providers import TestInstrumentProvider
from nautilus_trader.common.clock import TestClock
from nautilus_trader.common.factories import OrderFactory
from nautilus_trader.model.enums import OrderSide
from nautilus_trader.model.identifiers import PositionId
from nautilus_trader.model.identifiers import StrategyId
from nautilus_trader.model.identifiers import TraderId
from nautilus_trader.model.objects import Price
from nautilus_trader.model.objects import Quantity
from nautilus_trader.model.position import Position
from tests.test_kit.stubs import TestStubs


ETHUSD_FTX = TestInstrumentProvider.ethusd_ftx()


class TestLongRatioPortfolioStatistics:
    def setup(self):
        # Fixture Setup
        self.order_factory = OrderFactory(
            trader_id=TraderId("TESTER-000"),
            strategy_id=StrategyId("S-001"),
            clock=TestClock(),
        )

    def test_calculate_given_empty_list_returns_none(self):
        # Arrange
        stat = LongRatio()

        # Act
        result = stat.calculate_from_positions([])

        # Assert
        assert result is None

    def test_calculate_given_two_long_returns_expected(self):
        # Arrange
        stat = LongRatio()

        order1 = self.order_factory.market(
            ETHUSD_FTX.id,
            OrderSide.BUY,
            Quantity.from_int(1),
        )

        order2 = self.order_factory.market(
            ETHUSD_FTX.id,
            OrderSide.SELL,
            Quantity.from_int(1),
        )

        fill1 = TestStubs.event_order_filled(
            order1,
            instrument=ETHUSD_FTX,
            position_id=PositionId("P-1"),
            strategy_id=StrategyId("S-001"),
            last_px=Price.from_int(10_000),
        )

        fill2 = TestStubs.event_order_filled(
            order2,
            instrument=ETHUSD_FTX,
            position_id=PositionId("P-2"),
            strategy_id=StrategyId("S-001"),
            last_px=Price.from_int(10_000),
        )

        position1 = Position(instrument=ETHUSD_FTX, fill=fill1)
        position1.apply(fill2)

        position2 = Position(instrument=ETHUSD_FTX, fill=fill1)
        position2.apply(fill2)

        data = [position1, position2]

        # Act
        result = stat.calculate_from_positions(data)

        # Assert
        assert result == "1.00"

    def test_calculate_given_one_long_one_short_returns_expected(self):
        # Arrange
        stat = LongRatio()

        order1 = self.order_factory.market(
            ETHUSD_FTX.id,
            OrderSide.BUY,
            Quantity.from_int(1),
        )

        order2 = self.order_factory.market(
            ETHUSD_FTX.id,
            OrderSide.SELL,
            Quantity.from_int(1),
        )

        fill1 = TestStubs.event_order_filled(
            order1,
            instrument=ETHUSD_FTX,
            position_id=PositionId("P-1"),
            strategy_id=StrategyId("S-001"),
            last_px=Price.from_int(10_000),
        )

        fill2 = TestStubs.event_order_filled(
            order2,
            instrument=ETHUSD_FTX,
            position_id=PositionId("P-2"),
            strategy_id=StrategyId("S-001"),
            last_px=Price.from_int(10_000),
        )

        position1 = Position(instrument=ETHUSD_FTX, fill=fill1)
        position1.apply(fill2)

        position2 = Position(instrument=ETHUSD_FTX, fill=fill2)
        position2.apply(fill1)

        data = [position1, position2]

        # Act
        result = stat.calculate_from_positions(data)

        # Assert
        assert result == "0.50"

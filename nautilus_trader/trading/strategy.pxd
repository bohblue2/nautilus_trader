# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
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

from cpython.datetime cimport datetime

from nautilus_trader.cache.base cimport CacheFacade
from nautilus_trader.common.clock cimport Clock
from nautilus_trader.common.component cimport Component
from nautilus_trader.common.factories cimport OrderFactory
from nautilus_trader.common.logging cimport Logger
from nautilus_trader.common.logging cimport LoggerAdapter
from nautilus_trader.common.uuid cimport UUIDFactory
from nautilus_trader.core.message cimport Event
from nautilus_trader.data.messages cimport DataCommand
from nautilus_trader.data.messages cimport DataRequest
from nautilus_trader.data.messages cimport DataResponse
from nautilus_trader.indicators.base.indicator cimport Indicator
from nautilus_trader.model.c_enums.book_level cimport BookLevel
from nautilus_trader.model.commands.trading cimport TradingCommand
from nautilus_trader.model.data.bar cimport Bar
from nautilus_trader.model.data.bar cimport BarType
from nautilus_trader.model.data.base cimport Data
from nautilus_trader.model.data.base cimport DataType
from nautilus_trader.model.data.tick cimport QuoteTick
from nautilus_trader.model.data.tick cimport TradeTick
from nautilus_trader.model.data.venue cimport InstrumentClosePrice
from nautilus_trader.model.data.venue cimport InstrumentStatusUpdate
from nautilus_trader.model.data.venue cimport VenueStatusUpdate
from nautilus_trader.model.identifiers cimport ClientId
from nautilus_trader.model.identifiers cimport InstrumentId
from nautilus_trader.model.identifiers cimport PositionId
from nautilus_trader.model.identifiers cimport StrategyId
from nautilus_trader.model.identifiers cimport TraderId
from nautilus_trader.model.identifiers cimport Venue
from nautilus_trader.model.instruments.base cimport Instrument
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity
from nautilus_trader.model.orderbook.book cimport OrderBook
from nautilus_trader.model.orderbook.data cimport OrderBookData
from nautilus_trader.model.orders.base cimport Order
from nautilus_trader.model.orders.base cimport PassiveOrder
from nautilus_trader.model.orders.bracket cimport BracketOrder
from nautilus_trader.model.position cimport Position
from nautilus_trader.msgbus.message_bus cimport MessageBus
from nautilus_trader.trading.portfolio cimport PortfolioFacade


cdef class TradingStrategy(Component):
    cdef MessageBus _msgbus
    cdef CacheFacade _cache
    cdef list _indicators
    cdef dict _indicators_for_quotes
    cdef dict _indicators_for_trades
    cdef dict _indicators_for_bars

    cdef readonly TraderId trader_id
    """The trader ID associated with the trading strategy.\n\n:returns: `TraderId`"""
    cdef readonly StrategyId id
    """The trading strategies ID.\n\n:returns: `StrategyId`"""
    cdef readonly Clock clock
    """The trading strategies clock.\n\n:returns: `Clock`"""
    cdef readonly UUIDFactory uuid_factory
    """The trading strategies UUID factory.\n\n:returns: `UUIDFactory`"""
    cdef readonly LoggerAdapter log
    """The trading strategies logger adapter.\n\n:returns: `LoggerAdapter`"""
    cdef readonly CacheFacade cache
    """The read-only cache for the strategy.\n\n:returns: `CacheFacade`"""
    cdef readonly PortfolioFacade portfolio
    """The read-only portfolio for the strategy.\n\n:returns: `PortfolioFacade`"""
    cdef readonly OrderFactory order_factory
    """The order factory for the strategy.\n\n:returns: `OrderFactory`"""

    cdef void _check_registered(self) except *

    cpdef bint indicators_initialized(self) except *

# -- ABSTRACT METHODS ------------------------------------------------------------------------------

    cpdef void on_start(self) except *
    cpdef void on_stop(self) except *
    cpdef void on_resume(self) except *
    cpdef void on_reset(self) except *
    cpdef dict on_save(self)
    cpdef void on_load(self, dict state) except *
    cpdef void on_dispose(self) except *
    cpdef void on_instrument(self, Instrument instrument) except *
    cpdef void on_order_book_delta(self, OrderBookData data) except *
    cpdef void on_order_book(self, OrderBook order_book) except *
    cpdef void on_quote_tick(self, QuoteTick tick) except *
    cpdef void on_trade_tick(self, TradeTick tick) except *
    cpdef void on_bar(self, Bar bar) except *
    cpdef void on_data(self, Data data) except *
    cpdef void on_venue_status_update(self, VenueStatusUpdate update) except *
    cpdef void on_instrument_status_update(self, InstrumentStatusUpdate update) except *
    cpdef void on_instrument_close_price(self, InstrumentClosePrice update) except *
    cpdef void on_event(self, Event event) except *

# -- REGISTRATION ----------------------------------------------------------------------------------

    cpdef void register(
        self,
        TraderId trader_id,
        PortfolioFacade portfolio,
        MessageBus msgbus,
        CacheFacade cache,
        Clock clock,
        Logger logger,
    ) except *
    cpdef void register_indicator_for_quote_ticks(self, InstrumentId instrument_id, Indicator indicator) except *
    cpdef void register_indicator_for_trade_ticks(self, InstrumentId instrument_id, Indicator indicator) except *
    cpdef void register_indicator_for_bars(self, BarType bar_type, Indicator indicator) except *

# -- STRATEGY COMMANDS -----------------------------------------------------------------------------

    cpdef dict save(self)
    cpdef void load(self, dict state) except *

# -- SUBSCRIPTIONS ---------------------------------------------------------------------------------

    cpdef void subscribe_data(self, ClientId client_id, DataType data_type) except *
    cpdef void subscribe_instrument(self, InstrumentId instrument_id) except *
    cpdef void subscribe_order_book_deltas(
        self,
        InstrumentId instrument_id,
        BookLevel level=*,
        dict kwargs=*,
    ) except *
    cpdef void subscribe_order_book_snapshots(
        self,
        InstrumentId instrument_id,
        BookLevel level=*,
        int depth=*,
        int interval_ms=*,
        dict kwargs=*,
    ) except *
    cpdef void subscribe_quote_ticks(self, InstrumentId instrument_id) except *
    cpdef void subscribe_trade_ticks(self, InstrumentId instrument_id) except *
    cpdef void subscribe_bars(self, BarType bar_type) except *
    cpdef void subscribe_venue_status_updates(self, Venue venue) except *
    cpdef void subscribe_instrument_status_updates(self, InstrumentId instrument_id) except *
    cpdef void subscribe_instrument_close_prices(self, InstrumentId instrument_id) except *
    cpdef void unsubscribe_data(self, ClientId client_id, DataType data_type) except *
    cpdef void unsubscribe_instrument(self, InstrumentId instrument_id) except *
    cpdef void unsubscribe_order_book_deltas(self, InstrumentId instrument_id) except *
    cpdef void unsubscribe_order_book_snapshots(self, InstrumentId instrument_id, int interval_ms=*) except *
    cpdef void unsubscribe_quote_ticks(self, InstrumentId instrument_id) except *
    cpdef void unsubscribe_trade_ticks(self, InstrumentId instrument_id) except *
    cpdef void unsubscribe_bars(self, BarType bar_type) except *

# -- REQUESTS --------------------------------------------------------------------------------------

    cpdef void request_data(self, ClientId client_id, DataType data_type) except *
    cpdef void request_quote_ticks(
        self,
        InstrumentId instrument_id,
        datetime from_datetime=*,
        datetime to_datetime=*,
    ) except *
    cpdef void request_trade_ticks(
        self,
        InstrumentId instrument_id,
        datetime from_datetime=*,
        datetime to_datetime=*,
    ) except *
    cpdef void request_bars(
        self,
        BarType bar_type,
        datetime from_datetime=*,
        datetime to_datetime=*,
    ) except *

# -- TRADING COMMANDS ------------------------------------------------------------------------------

    cpdef void submit_order(self, Order order, PositionId position_id=*) except *
    cpdef void submit_bracket_order(self, BracketOrder bracket_order) except *
    cpdef void update_order(
        self,
        PassiveOrder order,
        Quantity quantity=*,
        Price price=*,
        Price trigger=*,
    ) except *
    cpdef void cancel_order(self, Order order) except *
    cpdef void cancel_all_orders(self, InstrumentId instrument_id) except *
    cpdef void flatten_position(self, Position position) except *
    cpdef void flatten_all_positions(self, InstrumentId instrument_id) except *

# -- HANDLERS --------------------------------------------------------------------------------------

    cpdef void handle_instrument(self, Instrument instrument) except *
    cpdef void handle_order_book(self, OrderBook order_book) except *
    cpdef void handle_order_book_delta(self, OrderBookData data) except *
    cpdef void handle_quote_tick(self, QuoteTick tick, bint is_historical=*) except *
    cpdef void handle_quote_ticks(self, list ticks) except *
    cpdef void handle_trade_tick(self, TradeTick tick, bint is_historical=*) except *
    cpdef void handle_trade_ticks(self, list ticks) except *
    cpdef void handle_bar(self, Bar bar, bint is_historical=*) except *
    cpdef void handle_bars(self, list bars) except *
    cpdef void handle_data(self, Data data) except *
    cpdef void handle_venue_status_update(self, VenueStatusUpdate update) except *
    cpdef void handle_instrument_status_update(self, InstrumentStatusUpdate update) except *
    cpdef void handle_instrument_close_price(self, InstrumentClosePrice update) except *
    cpdef void handle_event(self, Event event) except *

    cpdef void _handle_data_response(self, DataResponse response) except *
    cpdef void _handle_quote_ticks_response(self, DataResponse response) except *
    cpdef void _handle_trade_ticks_response(self, DataResponse response) except *
    cpdef void _handle_bars_response(self, DataResponse response) except *

# -- EGRESS ----------------------------------------------------------------------------------------

    cdef void _send_data_cmd(self, DataCommand command) except *
    cdef void _send_data_req(self, DataRequest request) except *
    cdef void _send_exec_cmd(self, TradingCommand command) except *

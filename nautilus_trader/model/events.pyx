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

from cpython.datetime cimport datetime

from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.core.datetime cimport format_iso8601
from nautilus_trader.core.message cimport Event
from nautilus_trader.core.uuid cimport UUID
from nautilus_trader.model.c_enums.liquidity_side cimport LiquiditySide
from nautilus_trader.model.c_enums.liquidity_side cimport liquidity_side_to_string
from nautilus_trader.model.c_enums.order_side cimport OrderSide
from nautilus_trader.model.c_enums.order_side cimport order_side_to_string
from nautilus_trader.model.c_enums.order_type cimport OrderType
from nautilus_trader.model.c_enums.order_type cimport order_type_to_string
from nautilus_trader.model.c_enums.time_in_force cimport TimeInForce
from nautilus_trader.model.c_enums.time_in_force cimport time_in_force_to_string
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.identifiers cimport AccountId
from nautilus_trader.model.identifiers cimport ClientOrderId
from nautilus_trader.model.identifiers cimport ExecutionId
from nautilus_trader.model.identifiers cimport PositionId
from nautilus_trader.model.identifiers cimport StrategyId
from nautilus_trader.model.identifiers cimport Symbol
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity
from nautilus_trader.model.position cimport Position


cdef class AccountState(Event):
    """
    Represents an event which includes information on the state of the account.
    """

    def __init__(
            self,
            AccountId account_id not None,
            Currency currency not None,
            Money balance not None,
            Money margin_balance not None,
            Money margin_available not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the AccountState class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        currency : Currency
            The currency for the account.
        balance : Money
            The account balance.
        margin_balance : Money
            The account margin balance.
        margin_available : Money
            The account margin available.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(event_id, event_timestamp)

        self.account_id = account_id
        self.currency = currency
        self.balance = balance
        self.margin_balance = margin_balance
        self.margin_available = margin_available

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id.value}, "
                f"balance={self.balance.to_string_formatted()}, "
                f"margin_balance={self.margin_balance.to_string_formatted()}, "
                f"margin_avail={self.margin_available.to_string_formatted()})")

    def __repr__(self) -> str:
        """
        Return the string representation of this object which includes the objects
        location in memory.

        Returns
        -------
        str

        """
        return f"<{str(self)} object at {id(self)}>"


cdef class OrderEvent(Event):
    """
    The base class for all order events.
    """

    def __init__(
            self,
            ClientOrderId cl_ord_id not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderEvent base class.

        Parameters
        ----------
        cl_ord_id : ClientOrderId
            The client order identifier.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(event_id, event_timestamp)

        self.cl_ord_id = cl_ord_id

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return f"{self.__class__.__name__}(cl_ord_id={self.cl_ord_id})"

    def __repr__(self) -> str:
        """
        Return the string representation of this object which includes the objects
        location in memory.

        Returns
        -------
        str

        """
        return f"<{str(self)} object at {id(self)}>"


cdef class OrderInitialized(OrderEvent):
    """
    Represents an event where an order has been initialized.
    """

    def __init__(
            self,
            ClientOrderId cl_ord_id not None,
            StrategyId strategy_id not None,
            Symbol symbol not None,
            OrderSide order_side,
            OrderType order_type,
            Quantity quantity not None,
            TimeInForce time_in_force,
            UUID event_id not None,
            datetime event_timestamp not None,
            dict options not None,
    ):
        """
        Initialize a new instance of the OrderInitialized class.

        Parameters
        ----------
        cl_ord_id : ClientOrderId
            The client order identifier.
        strategy_id : ClientOrderId
            The strategy identifier.
        symbol : Symbol
            The order symbol.
        order_side : OrderSide
            The order side.
        order_type : OrderType
            The order type.
        quantity : Quantity
            The order quantity.
        time_in_force : TimeInForce
            The order time in force.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.
        options : Dict[str, str]
            The order options. Contains mappings for specific order params.

        Raises
        ------
        ValueError
            If order_side is UNDEFINED.
        ValueError
            If order_type is UNDEFINED.
        ValueError
            If time_in_force is UNDEFINED.

        """
        Condition.not_equal(order_side, OrderSide.UNDEFINED, "order_side", "UNDEFINED")
        Condition.not_equal(order_type, OrderType.UNDEFINED, "order_type", "UNDEFINED")
        Condition.not_equal(time_in_force, TimeInForce.UNDEFINED, "time_in_force", "UNDEFINED")
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.cl_ord_id = cl_ord_id
        self.strategy_id = strategy_id
        self.symbol = symbol
        self.order_side = order_side
        self.order_type = order_type
        self.quantity = quantity
        self.time_in_force = time_in_force
        self.options = options
        self.is_completion_trigger = False


cdef class OrderSubmitted(OrderEvent):
    """
    Represents an event where an order has been submitted by the system to the
    broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            datetime submitted_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderSubmitted class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        submitted_time : datetime
            The order submitted time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.submitted_time = submitted_time
        self.is_completion_trigger = False

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id})")


cdef class OrderInvalid(OrderEvent):
    """
    Represents an event where an order has been invalidated by the Nautilus
    system.
    """

    def __init__(
            self,
            ClientOrderId cl_ord_id not None,
            str reason not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderInvalid class.

        Parameters
        ----------
        cl_ord_id : ClientOrderId
            The client order identifier.
        reason : str
            The order invalid reason.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If invalid_reason is not a valid_string.

        """
        Condition.valid_string(reason, "invalid_reason")
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.reason = reason
        self.is_completion_trigger = True

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"cl_ord_id={self.cl_ord_id}, "
                f"reason={self.reason})")


cdef class OrderDenied(OrderEvent):
    """
    Represents an event where an order has been denied by the Nautilus system.
    """

    def __init__(
            self,
            ClientOrderId cl_ord_id not None,
            str reason not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderDenied class.

        Parameters
        ----------
        cl_ord_id : ClientOrderId
            The client order identifier.
        reason : str
            The order denied reason.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If denied_reason is not a valid_string.

        """
        Condition.valid_string(reason, "denied_reason")
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.reason = reason
        self.is_completion_trigger = True

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"cl_ord_id={self.cl_ord_id}, "
                f"reason={self.reason})")


cdef class OrderRejected(OrderEvent):
    """
    Represents an event where an order has been rejected by the broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            datetime rejected_time not None,
            str reason not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderRejected class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        rejected_time : datetime
            The order rejected time.
        reason : datetime
            The order rejected reason.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If rejected_reason is not a valid_string.

        """
        Condition.valid_string(reason, "rejected_reason")
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.rejected_time = rejected_time
        self.reason = reason
        self.is_completion_trigger = True

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"reason={self.reason})")


cdef class OrderAccepted(OrderEvent):
    """
    Represents an event where an order has been accepted by the broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            OrderId order_id not None,
            datetime accepted_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderAccepted class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        order_id : OrderId
            The broker/exchange order identifier.
        accepted_time : datetime
            The order accepted time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.order_id = order_id
        self.accepted_time = accepted_time
        self.is_completion_trigger = False

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"order_id={self.order_id})")


cdef class OrderWorking(OrderEvent):
    """
    Represents an event where an order is working with the broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            OrderId order_id not None,
            Symbol symbol not None,
            OrderSide order_side,
            OrderType order_type,
            Quantity quantity not None,
            Price price not None,
            TimeInForce time_in_force,
            datetime expire_time,  # Can be None
            datetime working_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderWorking class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        order_id : OrderId
            The broker/exchange order identifier.
        symbol : Symbol
            The order symbol.
        order_side : OrderSide
            The order side.
        order_type : OrderType
            The order type.
        quantity : Quantity
            The order quantity.
        price : Price
            The order price.
        time_in_force : TimeInForce
            The order time in force.
        expire_time : datetime, optional
            The order expire time (for GTD orders only).
        working_time : datetime
            The order working time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If order_side is UNDEFINED.
        ValueError
            If order_type is UNDEFINED.
        ValueError
            If time_in_force is UNDEFINED.

        """
        Condition.not_equal(order_side, OrderSide.UNDEFINED, "order_side", "UNDEFINED")
        Condition.not_equal(order_type, OrderType.UNDEFINED, "order_type", "UNDEFINED")
        Condition.not_equal(time_in_force, TimeInForce.UNDEFINED, "time_in_force", "UNDEFINED")
        Condition.type_or_none(expire_time, datetime, "expire_time")

        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.order_id = order_id
        self.symbol = symbol
        self.order_side = order_side
        self.order_type = order_type
        self.quantity = quantity
        self.price = price
        self.time_in_force = time_in_force
        self.expire_time = expire_time
        self.working_time = working_time
        self.is_completion_trigger = False

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        cdef str expire_time = "" if self.expire_time is None else f" {format_iso8601(self.expire_time)}"
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"order_id={self.order_id}, "
                f"{order_side_to_string(self.order_side)} {self.quantity.to_string_formatted()} "
                f"{self.symbol} {order_type_to_string(self.order_type)} @ "
                f"{self.price} {time_in_force_to_string(self.time_in_force)}{expire_time})")


cdef class OrderCancelReject(OrderEvent):
    """
    Represents an event where an order cancel or modify command has been
    rejected by the broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            datetime rejected_time not None,
            str response_to not None,
            str reason not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderCancelReject class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        rejected_time : datetime
            The order cancel reject time.
        response_to : str
            The order cancel reject response.
        reason : str
            The order cancel reject reason.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If rejected_response_to is not a valid string.
        ValueError
            If rejected_reason is not a valid string.

        """
        Condition.valid_string(response_to, "rejected_response_to")
        Condition.valid_string(reason, "rejected_reason")
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.rejected_time = rejected_time
        self.response_to = response_to
        self.reason = reason
        self.is_completion_trigger = False

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"response_to={self.response_to}, "
                f"reason={self.reason})")


cdef class OrderCancelled(OrderEvent):
    """
    Represents an event where an order has been cancelled with the
    broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            OrderId order_id not None,
            datetime cancelled_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderCancelled class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        order_id : OrderId
            The broker/exchange order identifier.
        cancelled_time : datetime
            The event order cancelled time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.order_id = order_id
        self.cancelled_time = cancelled_time
        self.is_completion_trigger = True

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"order_id={self.order_id})")


cdef class OrderModified(OrderEvent):
    """
    Represents an event where an order has been modified with the
    broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            OrderId order_id not None,
            Quantity modified_quantity not None,
            Price modified_price not None,
            datetime modified_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderModified class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        order_id : OrderId
            The broker/exchange order identifier.
        modified_quantity : Quantity
            The modified quantity.
        modified_price : Price
            The modified price.
        modified_time : datetime
            The modified time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.order_id = order_id
        self.modified_quantity = modified_quantity
        self.modified_price = modified_price
        self.modified_time = modified_time
        self.is_completion_trigger = False

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_order_id={self.cl_ord_id}, "
                f"order_id={self.order_id}, "
                f"qty={self.modified_quantity.to_string_formatted()}, "
                f"price={self.modified_price})")


cdef class OrderExpired(OrderEvent):
    """
    Represents an event where an order has expired with the broker/exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            OrderId order_id not None,
            datetime expired_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderExpired class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        order_id : OrderId
            The broker/exchange order identifier.
        expired_time : datetime
            The order expired time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.order_id = order_id
        self.expired_time = expired_time
        self.is_completion_trigger = True

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"order_id={self.order_id})")


cdef class OrderFilled(OrderEvent):
    """
    Represents an event where an order has been filled at the exchange.
    """

    def __init__(
            self,
            AccountId account_id not None,
            ClientOrderId cl_ord_id not None,
            OrderId order_id not None,
            ExecutionId execution_id not None,
            PositionId position_id not None,
            StrategyId strategy_id not None,
            Symbol symbol not None,
            OrderSide order_side,
            Quantity filled_qty not None,
            Quantity leaves_qty not None,
            Price avg_price not None,
            Money commission not None,
            LiquiditySide liquidity_side,
            Currency base_currency not None,
            Currency quote_currency not None,
            datetime execution_time not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the OrderFilled class.

        Parameters
        ----------
        account_id : AccountId
            The account identifier.
        cl_ord_id : ClientOrderId
            The client order identifier.
        order_id : OrderId
            The broker/exchange order identifier.
        execution_id : ExecutionId
            The execution identifier.
        position_id : PositionId
            The broker/exchange position identifier.
        strategy_id : StrategyId
            The strategy identifier.
        symbol : Symbol
            The order symbol.
        order_side : OrderSide
            The execution order side.
        filled_qty : Quantity
            The execution filled quantity.
        leaves_qty : Quantity
            The execution leaves quantity.
        avg_price : Price
            The execution average price.
        liquidity_side : LiquiditySide
            The execution liquidity side.
        base_currency : Currency
            The order securities base currency.
        quote_currency : Currency
            The order securities quote currency.
        execution_time : datetime
            The execution time.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        Condition.not_equal(order_side, OrderSide.UNDEFINED, "order_side", "UNDEFINED")
        Condition.not_equal(liquidity_side, LiquiditySide.NONE, "liquidity_side", "NONE")
        super().__init__(
            cl_ord_id,
            event_id,
            event_timestamp,
        )

        self.account_id = account_id
        self.order_id = order_id
        self.execution_id = execution_id
        self.position_id = position_id
        self.strategy_id = strategy_id
        self.symbol = symbol
        self.order_side = order_side
        self.filled_qty = filled_qty
        self.leaves_qty = leaves_qty
        self.avg_price = avg_price
        self.commission = commission
        self.liquidity_side = liquidity_side
        self.base_currency = base_currency
        self.quote_currency = quote_currency
        self.execution_time = execution_time
        self.is_partial_fill = self.leaves_qty > 0
        self.is_completion_trigger = not self.is_partial_fill

    cdef OrderFilled clone(self, PositionId position_id, StrategyId strategy_id):
        """
        Clone this event with the position identifier changed to that given.
        The original position_id must be null, otherwise an exception is raised.

        Parameters
        ----------
        position_id : PositionId, optional
            The position identifier to set.
        strategy_id : StrategyId, optional
            The strategy identifier to set.

        Raises
        ------
        ValueError
            If position_id is not null and self.position_id does not match.
        ValueError
            If strategy_id is not null and self.strategy_id does not match.

        """
        if self.position_id.not_null():
            Condition.equal(position_id, self.position_id, "position_id", "self.position_id")
        if self.strategy_id.not_null():
            Condition.equal(strategy_id, self.strategy_id, "strategy_id", "self.strategy_id")

        return OrderFilled(
            self.account_id,
            self.cl_ord_id,
            self.order_id,
            self.execution_id,
            position_id,  # Set identifier
            strategy_id,  # Set identifier
            self.symbol,
            self.order_side,
            self.filled_qty,
            self.leaves_qty,
            self.avg_price,
            self.commission,
            self.liquidity_side,
            self.base_currency,
            self.quote_currency,
            self.execution_time,
            self.id,
            self.timestamp
        )

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.account_id}, "
                f"cl_ord_id={self.cl_ord_id}, "
                f"order_id={self.order_id}, "
                f"position_id={self.position_id}, "
                f"strategy_id={self.strategy_id}, "
                f"symbol={self.symbol}, "
                f"side={order_side_to_string(self.order_side)}"
                f"-{liquidity_side_to_string(self.liquidity_side)}, "
                f"filled_qty={self.filled_qty.to_string_formatted()}, "
                f"leaves_qty={self.leaves_qty.to_string_formatted()}, "
                f"avg_price={self.avg_price}, "
                f"commission={self.commission.to_string_formatted()})")


cdef class PositionEvent(Event):
    """
    The base class for all position events.
    """

    def __init__(
            self,
            Position position not None,
            OrderFilled order_fill not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the PositionEvent base class.

        Parameters
        ----------
        position : Position
            The position.
        order_fill : OrderFilled
            The order fill event which triggered the event.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(event_id, event_timestamp)
        self.position = position
        self.order_fill = order_fill

    def __repr__(self) -> str:
        """
        Return the string representation of this object which includes the objects
        location in memory.

        Returns
        -------
        str

        """
        return f"<{str(self)} object at {id(self)}>"


cdef class PositionOpened(PositionEvent):
    """
    Represents an event where a position has been opened.
    """

    def __init__(
            self,
            Position position not None,
            OrderFilled order_fill not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the PositionOpened class.

        Parameters
        ----------
        position : Position
            The position.
        order_fill : OrderFilled
            The order fill event which triggered the event.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        """
        super().__init__(
            position,
            order_fill,
            event_id,
            event_timestamp,
        )

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.position.account_id}, "
                f"position_id={self.position.id}, "
                f"strategy_id={self.position.strategy_id}, "
                f"entry={order_side_to_string(self.position.entry)}, "
                f"avg_open={round(self.position.avg_open_price, 5)}, "
                f"{self.position.status_string()})")


cdef class PositionModified(PositionEvent):
    """
    Represents an event where a position has been modified.
    """

    def __init__(
            self,
            Position position not None,
            OrderFilled order_fill not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the PositionModified class.

        Parameters
        ----------
        position : Position
            The position.
        order_fill : OrderFilled
            The order fill event which triggered the event.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If position is not open.

        """
        Condition.true(position.is_open(), "position.is_open()")
        super().__init__(
            position,
            order_fill,
            event_id,
            event_timestamp,
        )

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return (f"{self.__class__.__name__}("
                f"account_id={self.position.account_id}, "
                f"position_id={self.position.id}, "
                f"strategy_id={self.position.strategy_id}, "
                f"entry={order_side_to_string(self.position.entry)}, "
                f"avg_open={self.position.avg_open_price}, "
                f"realized_points={self.position.realized_points}, "
                f"realized_return={round(self.position.realized_return * 100, 3)}%, "
                f"realized_pnl={self.position.realized_pnl.to_string_formatted()}, "
                f"{self.position.status_string()})")


cdef class PositionClosed(PositionEvent):
    """
    Represents an event where a position has been closed.
    """

    def __init__(
            self,
            Position position not None,
            OrderEvent order_fill not None,
            UUID event_id not None,
            datetime event_timestamp not None,
    ):
        """
        Initialize a new instance of the PositionClosed class.

        Parameters
        ----------
        position : Position
            The position.
        order_fill : OrderEvent
            The order fill event which triggered the event.
        event_id : UUID
            The event identifier.
        event_timestamp : datetime
            The event timestamp.

        Raises
        ------
        ValueError
            If position is not closed.

        """
        Condition.true(position.is_closed(), "position.is_closed()")
        super().__init__(
            position,
            order_fill,
            event_id,
            event_timestamp,
        )

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        cdef str duration = str(self.position.open_duration).replace("0 days ", "")
        return (f"{self.__class__.__name__}("
                f"account_id={self.position.account_id}, "
                f"position_id={self.position.id}, "
                f"strategy_id={self.position.strategy_id}, "
                f"entry={order_side_to_string(self.position.entry)}, "
                f"duration={duration}, "
                f"avg_open={self.position.avg_open_price}, "
                f"avg_close={self.position.avg_close_price}, "
                f"realized_points={round(self.position.realized_points, 5)}, "
                f"realized_return={round(self.position.realized_return * 100, 3)}%, "
                f"realized_pnl={self.position.realized_pnl.to_string_formatted()})")

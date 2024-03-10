from enum import unique, Enum

from nautilus_trader.core.rust.model import OrderSide, OrderType, TimeInForce


class EnumWrapper(Enum):
    @classmethod
    def map_value_name(cls, value):
        return cls(value).name


class BnsTpCode(EnumWrapper):
    """
    TradeAction
    """

    SELL = "1"  # 매도
    BUY = "2"  # 매수


@unique
class OrdprcPtnCode(EnumWrapper):
    """
    Order Price Type
    """

    LIMIT_PRICE = "00"  # 지정가
    MARKET_PRICE = "03"  # 시장가
    CONDITIONAL_LIMIT_PRICE = "05"  # 조건부지정가
    BEST_LIMIT_PRICE = "06"  # 최유리지정가
    TOP_PRIORITY_LIMIT_PRICE = "07"  # 최우선지정가
    PRE_OPENING_SESSION_CLOSING_PRICE = "61"  # 장개시전시간외종가
    AFTER_HOURS_CLOSING_PRICE = "81"  # 시간외종가
    AFTER_HOURS_SINGLE_PRICE = "82"  # 시간외단일가


@unique
class MgntrnCode(EnumWrapper):
    """
    Order Type
    """

    REGULAR = "000"  # 보통
    PUBLIC_OWN_FINANCING_NEW = "003"  # 유통/자기융자신규
    PUBLIC_MAJOR_SHARE_NEW = "005"  # 유통대주신규
    OWN_MAJOR_SHARE_NEW = "007"  # 자기대주신규
    PUBLIC_FINANCING_REPAYMENT = "101"  # 유통융자상환
    OWN_FINANCING_REPAYMENT = "103"  # 자기융자상환
    PUBLIC_MAJOR_SHARE_REPAYMENT = "105"  # 유통대주상환
    OWN_MAJOR_SHARE_REPAYMENT = "107"  # 자기대주상환
    DEPOSIT_COLLATERAL_LOAN_REPAYMENT_CREDIT = "180"  # 예탁담보대출상환(신용)


class OrdCndiTpCode(Enum):
    """
    Order Condition
    """

    NONE = "0"  # 없음
    IOC = "1"  # IOC (즉시 체결 또는 취소)
    FOK = "2"  # FOK (전량 체결 또는 취소)


class EbestEnumParser:
    """
    Provides parsing methods for enums used by the `Ebest` API.
    """

    ext_to_int_order_side = {
        BnsTpCode.SELL: OrderSide.SELL,
        BnsTpCode.BUY: OrderSide.BUY,
    }
    int_to_ext_order_side = {v: k for k, v in ext_to_int_order_side.items()}

    ext_to_int_order_price_type = {
        OrdprcPtnCode.LIMIT_PRICE: OrderType.LIMIT,
        OrdprcPtnCode.MARKET_PRICE: OrderType.MARKET,
    }
    int_to_ext_order_price_type = {v: k for k, v in ext_to_int_order_price_type.items()}

    # NOTE: NautilusTrader does not support conditional orders
    ext_to_int_order_type = {}

    ext_to_int_time_in_force = {
        OrdCndiTpCode.NONE: TimeInForce.GTC,
        OrdCndiTpCode.IOC: TimeInForce.IOC,
        OrdCndiTpCode.FOK: TimeInForce.FOK,
    }
    int_to_ext_time_in_force = {v: k for k, v in ext_to_int_time_in_force.items()}

    @classmethod
    def order_side_to_nautilus(cls, v) -> OrderSide:
        return cls.ext_to_int_order_side[v]

    @classmethod
    def order_side_to_ebest(cls, v: OrderSide) -> str:
        return cls.int_to_ext_order_side[v].value

    @classmethod
    def order_price_type_to_nautilus(cls, v) -> OrderType:
        return cls.ext_to_int_order_price_type[v]

    @classmethod
    def order_price_type_to_ebest(cls, v) -> str:
        return cls.int_to_ext_order_price_type[v].value

    @classmethod
    def order_type_to_nautilus(cls, v) -> None:
        raise NotImplementedError

    @classmethod
    def order_type_to_ebest(cls, v) -> None:
        raise NotImplementedError

    @classmethod
    def time_in_force_to_nautilus(cls, v) -> TimeInForce:
        return cls.ext_to_int_time_in_force[v]

    @classmethod
    def time_in_force_to_ebest(cls, v) -> str:
        return cls.int_to_ext_time_in_force[v].value

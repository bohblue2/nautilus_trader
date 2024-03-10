import time
from decimal import Decimal

from nautilus_trader.model.currency import Currency
from nautilus_trader.model.identifiers import InstrumentId, Symbol
from nautilus_trader.model.objects import Price, Quantity

from nautilus_trader.adapters.ebest.blocks import t8436OutBlock
from nautilus_trader.adapters.ebest.common import EBEST_VENUE
from nautilus_trader.model.instruments import Instrument, Equity


def _calc_price_increment(price: int) -> int:
    increment = 1
    if price < 2000:
        increment = 1
    elif price < 5000:
        increment = 5
    elif price < 20000:
        increment = 10
    elif price < 50000:
        increment = 50
    elif price < 200000:
        increment = 100
    elif price < 500000:
        increment = 500
    elif price >= 500000:
        increment = 1000
    return increment


# noinspection PyTypeChecker
def parse_equity_instrument(data: t8436OutBlock) -> Instrument:
    instrument_id = InstrumentId(Symbol(data.shcode), EBEST_VENUE)
    price_precision = 1
    timestamp = time.time_ns()
    return Equity(
        instrument_id=instrument_id,
        raw_symbol=Symbol(data.shcode),
        currency=Currency.from_str("KRW"),
        price_precision=price_precision,
        price_increment=Price(_calc_price_increment(data.jnilclose), price_precision),
        multiplier=Quantity.from_int(1),
        lot_size=Quantity.from_int(1),
        isin=data.expcode,
        maker_fee=Decimal(0.00165),  # 0.015% + VAT(0.3%) = 0.00165
        taker_fee=Decimal(0.00165),  # 0.015% + VAT(0.3%) = 0.00165
        ts_event=timestamp,
        ts_init=timestamp,
        info={
            "market": "kospi" if data.gubun == "1" else "kosdaq",
            "is_etf": data.etfgubun == "1",
            "is_etn": data.etfgubun == "2",
            "is_spac": data.spac_gubun == "3",
        },
    )

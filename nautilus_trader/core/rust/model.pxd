# Warning, this file is autogenerated by cbindgen. Don't modify this manually. */

from libc.stdint cimport uint8_t, uint16_t, uint64_t, int64_t
from nautilus_trader.core.rust.core cimport Buffer16, Buffer32

cdef extern from "../includes/model.h":

    const uint8_t FIXED_PRECISION # = 9

    const double FIXED_SCALAR # = 1000000000.0

    cdef enum BookLevel:
        L1_TBBO # = 1,
        L2_MBP # = 2,
        L3_MBO # = 3,

    cdef enum CurrencyType:
        CRYPTO,
        FIAT,

    cdef enum OrderSide:
        BUY # = 1,
        SELL # = 2,

    cdef struct BTreeMap_BookPrice__Level:
        pass

    cdef struct HashMap_u64__BookPrice:
        pass

    cdef struct String:
        pass

    cdef struct Ladder:
        OrderSide side;
        BTreeMap_BookPrice__Level *levels;
        HashMap_u64__BookPrice *cache;

    cdef struct Symbol:
        String *value;

    cdef struct Venue:
        String *value;

    cdef struct InstrumentId:
        Symbol symbol;
        Venue venue;

    cdef struct OrderBook:
        Ladder bids;
        Ladder asks;
        InstrumentId instrument_id;
        BookLevel book_level;
        OrderSide last_side;
        int64_t ts_last;

    cdef struct Price_t:
        int64_t fixed;
        uint8_t precision;

    cdef struct Quantity_t:
        uint64_t fixed;
        uint8_t precision;

    cdef struct Currency_t:
        Buffer16 code;
        uint8_t precision;
        uint16_t iso4217;
        Buffer32 name;
        CurrencyType currency_type;

    cdef struct Money_t:
        int64_t fixed;
        Currency_t currency;

    OrderBook order_book_new(InstrumentId instrument_id, BookLevel book_level);

    Price_t price_new(double value, uint8_t precision);

    Price_t price_from_fixed(int64_t fixed, uint8_t precision);

    void price_free(Price_t price);

    double price_as_f64(const Price_t *price);

    void price_add_assign(Price_t a, Price_t b);

    void price_sub_assign(Price_t a, Price_t b);

    Quantity_t quantity_new(double value, uint8_t precision);

    Quantity_t quantity_from_fixed(uint64_t fixed, uint8_t precision);

    void quantity_free(Quantity_t qty);

    double quantity_as_f64(const Quantity_t *qty);

    void quantity_add_assign(Quantity_t a, Quantity_t b);

    void quantity_add_assign_u64(Quantity_t a, uint64_t b);

    void quantity_sub_assign(Quantity_t a, Quantity_t b);

    void quantity_sub_assign_u64(Quantity_t a, uint64_t b);

    Currency_t currency_new(Buffer16 code,
                            uint8_t precision,
                            uint16_t iso4217,
                            Buffer32 name,
                            CurrencyType currency_type);

    void currency_free(Currency_t currency);

    Money_t money_new(double amount, Currency_t currency);

    Money_t money_from_fixed(int64_t fixed, Currency_t currency);

    void money_free(Money_t money);

    double money_as_f64(const Money_t *money);

    void money_add_assign(Money_t a, Money_t b);

    void money_sub_assign(Money_t a, Money_t b);
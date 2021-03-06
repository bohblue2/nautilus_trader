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

from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.quicktions cimport Fraction


cdef class Decimal(Fraction):
    cdef readonly int precision

    cdef inline Decimal add(self, Fraction other)
    cdef inline Decimal sub(self, Fraction other)

    @staticmethod
    cdef inline Decimal from_float_c(double value, int precision)
    cpdef double as_double(self) except *
    cpdef str to_string(self)


cdef class Quantity(Fraction):
    cdef readonly int precision

    cdef inline Quantity add(self, Quantity other)
    cdef inline Quantity sub(self, Quantity other)

    @staticmethod
    cdef inline Quantity from_float_c(double value, int precision)
    cpdef double as_double(self) except *
    cpdef str to_string(self)
    cpdef str to_string_formatted(self)


cdef class Price(Fraction):
    cdef readonly int precision

    cdef inline Price add(self, Fraction other)
    cdef inline Price sub(self, Fraction other)

    @staticmethod
    cdef inline Price from_float_c(double value, int precision)
    cpdef double as_double(self) except *
    cpdef str to_string(self)


cdef class Money(Fraction):
    cdef readonly Currency currency

    cdef inline Money add(self, Money other)
    cdef inline Money sub(self, Money other)

    cpdef double as_double(self) except *
    cpdef str to_string(self)
    cpdef str to_string_formatted(self)

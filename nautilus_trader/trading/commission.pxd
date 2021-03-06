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

from nautilus_trader.model.c_enums.liquidity_side cimport LiquiditySide
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.identifiers cimport Symbol
from nautilus_trader.model.objects cimport Money
from nautilus_trader.model.objects cimport Quantity


cdef class CommissionModel:

    cpdef Money calculate(
        self,
        Symbol symbol,
        Quantity filled_qty,
        Currency base_currency,
        LiquiditySide liquidity_side,
    )


cdef class GenericCommissionModel(CommissionModel):

    cdef dict rates
    cdef double default_rate_bp
    cdef Money minimum

    cpdef double get_rate(self, Symbol symbol) except *


cdef class MakerTakerCommissionModel(CommissionModel):

    cdef dict taker_rates
    cdef dict maker_rates
    cdef double taker_default_rate_bp
    cdef double maker_default_rate_bp

    cpdef double get_rate(self, Symbol symbol, LiquiditySide liquidity_side) except *

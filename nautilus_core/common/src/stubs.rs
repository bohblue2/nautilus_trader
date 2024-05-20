// -------------------------------------------------------------------------------------------------
//  Copyright (C) 2015-2024 Nautech Systems Pty Ltd. All rights reserved.
//  https://nautechsystems.io
//
//  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
//  You may not use this file except in compliance with the License.
//  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
// -------------------------------------------------------------------------------------------------

//! Type stubs to facilitate testing.

use nautilus_core::time::get_atomic_clock_static;
use nautilus_model::identifiers::stubs::{strategy_id_ema_cross, trader_id};
use rstest::fixture;

use crate::factories::OrderFactory;

#[fixture]
pub fn order_factory() -> OrderFactory {
    let trader_id = trader_id();
    let strategy_id = strategy_id_ema_cross();
    OrderFactory::new(
        trader_id,
        strategy_id,
        None,
        None,
        get_atomic_clock_static(),
    )
}
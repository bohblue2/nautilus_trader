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

import unittest

from nautilus_trader.model.objects import Decimal


class DecimalTests(unittest.TestCase):

    def test_initialized_with_no_value_returns_valid_decimal(self):
        # Arrange
        # Act
        result = Decimal()

        # Assert
        self.assertEqual(0, result)
        self.assertEqual(0, result.precision)
        # self.assertEqual(decimal.Decimal("0"), result.as_decimal())
        self.assertEqual(0, result.as_double())

    def test_from_float_with_negative_precisions_raises_exception(self):
        # Arrange
        # Act
        # Assert
        self.assertRaises(ValueError, Decimal.from_float, 1.0, -1)

    def test_instantiate_with_valid_inputs_returns_expected_values(self):
        # Arrange
        # Act
        result0 = Decimal.from_float(1.0, 1)
        result1 = Decimal.from_float(1.0, 2)
        result2 = Decimal.from_float(-1.001, 3)
        result3 = Decimal.from_float(1.0005, 3)
        result4 = Decimal(100)
        result5 = Decimal.from_float(10000000000001.01, 2)  # Max significands
        result6 = Decimal.from_float(1999999.000001015, 9)  # Max significands and precision

        # Assert  # TODO: Keep as_decimal?
        # self.assertEqual(decimal.Decimal("1"), result0.as_decimal())
        # self.assertEqual(decimal.Decimal("1.00"), result1.as_decimal())
        # self.assertEqual(decimal.Decimal("-1.001"), result2.as_decimal())
        # self.assertEqual(decimal.Decimal("1.000"), result3.as_decimal())  # Rounds down
        # self.assertEqual(decimal.Decimal("100.0"), result4.as_decimal())
        # self.assertEqual(decimal.Decimal("10000000000001.01"), result5.as_decimal())
        # self.assertEqual(decimal.Decimal("1999999.000001015"), result6.as_decimal())

        self.assertEqual(1, result0)
        self.assertEqual(1, result0)
        self.assertEqual(Decimal.from_float(-1.001, precision=3), result2)
        self.assertEqual(Decimal.from_float(1.000, precision=3), result3)
        self.assertEqual(100, result4)
        self.assertEqual(10000000000001.01, result5.as_double())
        self.assertEqual(1999999.000001015, result6.as_double())

        self.assertEqual("1.0", result0.to_string())
        self.assertEqual("1.00", result1.to_string())
        self.assertEqual("-1.001", result2.to_string())
        self.assertEqual("1.000", result3.to_string())
        self.assertEqual("10000000000001.01", result5.to_string())
        self.assertEqual("1999999.000001015", result6.to_string())

    def test_initialized_with_extreme_value_scientific_notation_returns_zero(self):
        # Arrange
        # Act
        result1 = Decimal.from_float(1E-10, 9)   # Max precision
        result2 = Decimal.from_float(-1E-10, 9)  # Max precision

        # Assert
        self.assertEqual(0.0, result1.as_double())
        self.assertEqual(0.0, result2.as_double())
        # self.assertEqual(decimal.Decimal("0"), result1.as_decimal())
        # self.assertEqual(decimal.Decimal("0"), result2.as_decimal())

    def test_as_double_with_various_values_returns_expected_double(self):
        # Arrange
        # Act
        result0 = Decimal.from_float(1.0012, 0).as_double()
        result1 = Decimal.from_float(1.0012, 3).as_double()
        result2 = Decimal.from_float(-0.020, 2).as_double()
        result3 = Decimal.from_float(1.0015, 3).as_double()

        # Assert
        self.assertEqual(1.0, result0)
        self.assertEqual(1.001, result1)
        self.assertEqual(-0.02, result2)
        self.assertEqual(1.002, result3)

    # TODO: Keep as decimal?
    # def test_as_decimal_with_various_values_returns_expected_decimal(self):
    #     # Arrange
    #     # Act
    #     result0 = Decimal.from_float(1.0012, 0).as_decimal()
    #     result1 = Decimal.from_float(1.0012, 3).as_decimal()
    #     result2 = Decimal.from_float(-0.020, 2).as_decimal()
    #     result3 = Decimal.from_float(1.0015, 3).as_decimal()
    #
    #     # Assert
    #     self.assertEqual(decimal.Decimal("1.0"), result0)
    #     self.assertEqual(decimal.Decimal("1.001"), result1)
    #     self.assertEqual(decimal.Decimal("-0.02"), result2)
    #     self.assertEqual(decimal.Decimal("1.002"), result3)

    # def test_decimal_addition(self):
    #     # Arrange
    #     # Act
    #     result0 = Decimal.from_float(1.00001, 5) + 0.00001
    #     result1 = Decimal.from_float(1.00001, 5) + Decimal.from_float(0.00001, 5)
    #
    #     # Assert
    #     self.assertEqual(float, type(result0))
    #     self.assertEqual(Decimal, type(result1))
    #     self.assertEqual(1.0000200000000001, result0)
    #     self.assertEqual(Decimal.from_float(1.00002, 5), result1)

    # def test_decimal_subtraction(self):
    #     # Arrange
    #     # Act
    #     result0 = Decimal.from_float(1.00001, 5) - 0.00001
    #     result1 = Decimal.from_float(1.00001, 5) - Decimal.from_float(0.00001, 5)
    #
    #     # Assert
    #     self.assertEqual(float, type(result0))
    #     self.assertEqual(Decimal, type(result1))
    #     self.assertEqual(1.0, result0)
    #     self.assertEqual(1.0, result1)
    #     self.assertEqual(result0, result1)

    # def test_decimal_division(self):
    #     # Arrange
    #     # Act
    #     result0 = Decimal(1.00001, 5) / 2.0
    #     result1 = Decimal(1.00001, 5) / Decimal(0.5000, 5)
    #
    #     # Assert
    #     self.assertEqual(float, type(result0))
    #     self.assertEqual(Decimal, type(result1))
    #     self.assertEqual(0.500005, result0)
    #     self.assertEqual(Decimal(2.00002, precision=5), result1)

    # def test_decimal_multiplication(self):
    #     # Arrange
    #     # Act
    #     result0 = Decimal(1.00001, 5) * 2.0
    #     result1 = Decimal(1.00001, 5) * Decimal(1.5000, 5)
    #
    #     # Assert
    #     self.assertEqual(float, type(result0))
    #     self.assertEqual(Decimal, type(result1))
    #     self.assertEqual(2.00002, result0)
    #     self.assertEqual(Decimal(1.50002, 5), result1)

    def test_equality_with_various_values_returns_expected_result(self):
        # Arrange
        # Act
        # Assert
        self.assertEqual(Decimal(), Decimal(0))
        self.assertEqual(Decimal.from_float(1.0, 1), Decimal.from_float(1.0, 1))
        self.assertEqual(Decimal.from_float(1000000000000001, 9), Decimal.from_float(1000000000000001, 9))
        self.assertEqual(Decimal.from_float(10000000000001.01, 9), Decimal.from_float(10000000000001.01, 9))
        self.assertEqual(Decimal.from_float(1999999.000001015, 9), Decimal.from_float(1999999.000001015, 9))
        self.assertNotEqual(Decimal.from_float(1999999.000001015, 9), Decimal.from_float(1999999.000001014, 9))

    def test_comparisons_with_various_values_returns_expected_result(self):
        # Arrange
        # Act
        # Assert
        self.assertTrue(Decimal.from_float(0.000000001, 9) > Decimal.from_float(0, 9))
        self.assertTrue(Decimal.from_float(0.000000001, 9) >= Decimal.from_float(0, 9))
        self.assertTrue(Decimal() >= Decimal(0))
        self.assertTrue(Decimal.from_float(1.0, 1) >= Decimal.from_float(1.0, 0))
        self.assertTrue(Decimal.from_float(0.000000000, 9) < Decimal.from_float(0.000000001, 9))
        self.assertTrue(Decimal.from_float(0.000000001, 9) <= Decimal.from_float(0.000000001, 9))
        self.assertTrue(Decimal() <= Decimal(0))
        self.assertTrue(Decimal.from_float(1.0, 0) <= Decimal.from_float(1.0, 0))

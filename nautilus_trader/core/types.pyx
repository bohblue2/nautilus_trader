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

from nautilus_trader.core.correctness cimport Condition


cdef class ValidString:
    """
    Represents a valid string value. A valid string value cannot be None, empty or all white space.
    """

    def __init__(self, str value):
        """
        Initialize a new instance of the ValidString class.

        Parameters
        ----------
        value : str
            The value of the string.

        Raises
        ------
        ValueError
            If value is not a valid string.

        """
        Condition.valid_string(value, "value")

        self.value = value

    cpdef str to_string(self, bint with_class=False):
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        if with_class:
            return f"{self.__class__.__name__}({self.value})"
        else:
            return self.value

    def __eq__(self, ValidString other) -> bool:
        """
        Return a value indicating whether this object is equal to (==) the given object.

        Parameters
        ----------
        other : object
            The other object to equate.

        Returns
        -------
        bool

        """
        return self.value == other.value

    def __ne__(self, ValidString other) -> bool:
        """
        Return a value indicating whether this object is not equal to (!=) the given object.

        Parameters
        ----------
        other : object
            The other object to equate.

        Returns
        -------
        bool

        """
        return self.value != other.value

    def __lt__(self, ValidString other) -> bool:
        """
        Return a value indicating whether this object is less than (<) the given object.

        Parameters
        ----------
        other : ValidString
            The other object.

        Returns
        -------
        bool

        """
        return self.value < other.value

    def __le__(self, ValidString other) -> bool:
        """
        Return a value indicating whether this object is greater than or equal to (>=) the given
        object.

        Parameters
        ----------
        other : ValidString
            The other object.

        Returns
        -------
        bool

        """
        return self.value <= other.value

    def __gt__(self, ValidString other) -> bool:
        """
        Return a value indicating whether this object is greater than (>) the given object.

        Parameters
        ----------
        other : ValidString
            The other object.

        Returns
        -------
        bool

        """
        return self.value > other.value

    def __ge__(self, ValidString other) -> bool:
        """
        Return a value indicating whether this object is greater than or equal to (>=) the given
        object.

        Parameters
        ----------
        other : ValidString
            The other object.

        Returns
        -------
        bool

        """
        return self.value >= other.value

    def __hash__(self) -> int:
        """
        Return the hash code of this object.

        Returns
        -------
        int

        """
        return hash(self.value)

    def __str__(self) -> str:
        """
        Return the string representation of this object.

        Returns
        -------
        str

        """
        return self.value

    def __repr__(self) -> str:
        """
        Return the string representation of this object which includes the objects
        location in memory.

        Returns
        -------
        str

        """
        return f"<{str(self.__class__.__name__)}({str(self.value)}) object at {id(self)}>"


cdef class Identifier(ValidString):
    """
    The base class for all identifiers.
    """

    def __init__(self, str value):
        """
        Initialize a new instance of the Identifier class.

        Parameters
        ----------
        value : str
            The value of the identifier.

        Raises
        ------
        ValueError
            If value is not a valid string.

        """
        super().__init__(value)

        self.id_type = self.__class__.__name__

    def __eq__(self, Identifier other) -> bool:
        """
        Return a value indicating whether this object is equal to (==) the given object.

        Parameters
        ----------
        other : object
            The other object to equate.

        Returns
        -------
        bool

        """
        return self.id_type == other.id_type and self.value == other.value

    def __ne__(self, Identifier other) -> bool:
        """
        Return a value indicating whether this object is not equal to (!=) the given object.

        Parameters
        ----------
        other : object
            The other object to equate.

        Returns
        -------
        bool

        """
        return self.id_type != other.id_type or self.value != other.value

    def __hash__(self) -> int:
        """
        Return the hash code of this object.

        Returns
        -------
        int

        """
        return hash(self.value)

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

from nautilus_trader.core.message cimport Command
from nautilus_trader.core.message cimport Event
from nautilus_trader.model.instrument cimport Instrument
from nautilus_trader.model.order cimport Order


cdef class Serializer:
    """
    The base class for all serializers.

    """
    cdef inline str convert_camel_to_snake(self, str value):
        return ''.join([f'_{c.lower()}' if c.isupper() else c for c in value]).lstrip('_').upper()

    cdef inline str convert_snake_to_camel(self, str value):
        cdef list components = value.split('_')
        cdef str x
        return ''.join(x.title() for x in components)

    cpdef str py_convert_camel_to_snake(self, str value):
        return self.convert_camel_to_snake(value)

    cpdef str py_convert_snake_to_camel(self, str value):
        return self.convert_snake_to_camel(value)


cdef class DictionarySerializer(Serializer):
    """
    The base class for all dictionary serializers.

    """

    def __init__(self):
        """
        Initialize a new instance of the DictionarySerializer class.
        """
        super().__init__()

    cpdef bytes serialize(self, dict dictionary):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef dict deserialize(self, bytes dictionary_bytes):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")


cdef class InstrumentSerializer(Serializer):
    """
    The base class for all instrument serializers.

    """

    def __init__(self):
        """
        Initialize a new instance of the InstrumentSerializer class.

        """
        super().__init__()

    cpdef bytes serialize(self, Instrument instrument):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef Instrument deserialize(self, bytes instrument_bytes):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")


cdef class OrderSerializer(Serializer):
    """
    The base class for all order serializers.

    """

    def __init__(self):
        """
        Initialize a new instance of the OrderSerializer class.

        """
        super().__init__()

    cpdef bytes serialize(self, Order order):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef Order deserialize(self, bytes order_bytes):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass ")


cdef class CommandSerializer(Serializer):
    """
    The base class for all command serializers.

    """

    def __init__(self):
        """
        Initialize a new instance of the CommandSerializer class.
        """
        super().__init__()

    cpdef bytes serialize(self, Command command):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef Command deserialize(self, bytes command_bytes):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")


cdef class EventSerializer(Serializer):
    """
    The base class for all event serializers.

    """

    def __init__(self):
        """
        Initialize a new instance of the EventSerializer class.
        """
        super().__init__()

    cpdef bytes serialize(self, Event event):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")

    cpdef Event deserialize(self, bytes event_bytes):
        # Abstract method
        raise NotImplementedError("method must be implemented in the subclass")

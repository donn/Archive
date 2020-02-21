import utils
import defstruct
from base import OrderedObj
from types import MethodType

num_value_of_unit = {
        'k':1e+3,
        'c':1e-2,
        'm':1e-3,
        'u':1e-6,
        'MICRONS':1e-6,
        'n':1e-9,
        'p':1e-12,
        'f':1e-15,
        'none':1
        }

unit_types = {
        'cap':'f',
        'ind':'h',
        'time':'s',
        'res':'ohm'
        }

class Unit:
    def __init__(self, num, factor):
        self.num = num
        self.factor = factor
        self.mul_val = self.num * num_value_of_unit[self.factor[0]]

    def __float__(self):
        return self.mul_val

    def __str__(self):
        return str(self.num) + ' ' + str(self.factor.upper())

    #def standardize(self):
    #    return self.mul_val

class Decl( OrderedObj):
    decl_ID = None
    def __init__(self, declaration):
        """docstring for __init__"""
        self.ID                 = Decl.decl_ID
        self.declaration 	= declaration

    def __call__(self):
        return (self.ID, self.declaration, '\n')

    def __str__(self):
        return str(self.declaration)
class Input:
    pass
class Output:
    pass
class string(str):
    pass
class NamedPin(OrderedObj):
    def __init__(self, name):
        self.name = name

    def __eq__(self, obj):
        return obj.equate_to_pin(self)

    def equate_to_pin(self, pin):
        return self.name == pin.name

    def equate_to_BusBit(self, bus_bit):
        return str(self) == str(bus_bit)

class BusBit(OrderedObj):
    def __init__(self, name, num):
        self.name 	= name
        self.num 	= num
        self.name_as_str = str(str(name) + str(num))
    def __call__(self):
        return (self.name_as_str)

    def __str__(self):
        return (self.name_as_str)

    def __eq__(self, ele_to_check_value):

        if isinstance(ele_to_check_value, str):
            ele_to_check_value = string(ele_to_check_value)
            ele_to_check_value.equate_to_BusBit = MethodType(BusBit.equate_to_BusBit, ele_to_check_value)

        return ele_to_check_value.equate_to_BusBit(self)

    def equate_to_BusBit(self, bus_bit):
        return str(self) == str(bus_bit)

class TypeCheckers:
    @classmethod
    def isport_pin(cls, pin):
        return utils.isthat_type(pin, defstruct.DEF.design_spec.nets.net.port_pin)

    @classmethod
    def iscell_pin(cls, pin):
        return utils.isthat_type(pin, defstruct.DEF.design_spec.nets.net.cell_pin)

    @classmethod
    def isbus_bit(cls, pin):
        return utils.isthat_type(pin, BusBit)

    @classmethod
    def isInput(cls, resource):
        return utils.isthat_type(resource, Input)

    @classmethod
    def isOutput(cls, resource):
        return utils.isthat_type(resource, Output)

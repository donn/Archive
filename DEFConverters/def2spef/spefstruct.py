from base import OrderedObj
from defstruct import DEF
import utils
from modtypes import TypeCheckers, Decl

class SPEFutils:
    @classmethod
    def get_its_name(cls, SPEF_Header, it, predic):
        pass

    @classmethod
    def cell_pin_name(cls, SPEF_Header, cell_pin):
        return cell_pin.cell+SPEF_Header.DelimChar+cell_pin.name

    @classmethod
    def bus_bit_name(cls, SPEF_Header, bus_bit):
        return bus_bit.name.name+SPEF_Header.BusDelimChar.opening+str(bus_bit.name.num)+SPEF_Header.BusDelimChar.closing

    @classmethod
    def get_node_legal_name(cls, SPEF_Header, node):
        if TypeCheckers.iscell_pin(node):
            return cls.cell_pin_name(SPEF_Header, node)
        else:
            if TypeCheckers.isbus_bit(node.name):
                return cls.bus_bit_name(SPEF_Header, node)
            return node.name
    # NOT IMPLELEMENTED
    def get_node_legal_name2(cls, SPEF_Header, node):
        node.get_legal_name(SPEF_Header)

class SPEF(OrderedObj):
    def __init__(self,header, internal):
        self.header = header
        self.internal = internal

    class ID:
        SPEF            = '*SPEF'
        DESIGN            = '*DESIGN'
        DATE            = '*DATE'
        VENDOR          = '*VENDOR'
        PROGRAM             = '*PROGRAM'
        FILEVERSION             = '*VERSION'
        DESIGNFLOW             = '*DESIGN_FLOW'
        DIVIDER             = '*DIVIDER'
        DELIMITER             = '*DELIMITER'
        BUSDELIMITER             = '*BUS_DELIMITER'
        TUNIT             = '*T_UNIT'
        CUNIT             = '*C_UNIT'
        RUNIT             = '*R_UNIT'
        LUNIT             = '*L_UNIT'
        dnet             = '*D_NET'
        conn_sec             = '*CONN'
        cap_sec             = '*CAP'
        res_sec             = '*RES'
        end             = '*END'
        extern_pin             = '*P'
        intern_pin             = '*I'
        coordinates             = '*C'
        cap_load             = '*L'
        driver_cell             = '*D'
        inpt             = 'I'
        outpt             = 'O'

    class Header(OrderedObj):
        def __init__(self, decl_list):
            self.decl_list = decl_list
            for ele in self.decl_list:
                ele.create_entry_in_header(self)
            self.x = SPEF.ID.SPEF
        def __call__(self):
            return self.decl_list


        class StdNum(Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.StdNum = self.declaration
                self.ID = SPEF.ID.SPEF

        class DesName(Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.DesName = self.declaration
                self.ID = SPEF.ID.DESIGN

        class CreDate(Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.CreDate = self.declaration
                self.ID = SPEF.ID.DATE

        class Vendor(Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.Vendor = self.declaration
                self.ID = SPEF.ID.VENDOR

        class Prog(Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.Prog = self.declaration
                self.ID = SPEF.ID.PROGRAM

        class FVer( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.FVer = self.declaration
                self.ID = SPEF.ID.FILEVERSION

        class DesFlow( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.DesFlow = self.declaration
                self.ID = SPEF.ID.DESIGNFLOW

        class DivChar( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.DivChar = self.declaration
                self.ID = SPEF.ID.DIVIDER

        class DelimChar( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.DelimChar = self.declaration
                self.ID = SPEF.ID.DELIMITER

        class BusDelimChar(Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.BusDelimChar = self.declaration
                self.ID = SPEF.ID.BUSDELIMITER

        class TUnit( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.TUnit = self.declaration
                self.ID = SPEF.ID.TUNIT

        class CUnit( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.CUnit = self.declaration
                self.ID = SPEF.ID.CUNIT

        class RUnit( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.RUnit = self.declaration
                self.ID = SPEF.ID.RUNIT

        class LUnit( Decl):
            def create_entry_in_header(self, SPEF_Header):
                SPEF_Header.LUnit = self.declaration
                self.ID = SPEF.ID.LUNIT

    class Internal:
        def __init__(self, nets):
            self.nets = nets

        def __call__(self):
            return self.nets

        class DNet:
            def __init__(self, SPEF_Header, name, total_cap, conn_sec, cap_sec, res_sec):
                self.name = SPEFutils.get_node_legal_name(SPEF_Header,name)
                self.total_cap = total_cap
                self.conn_sec = conn_sec
                self.cap_sec =  cap_sec
                self.res_sec = res_sec
            def __call__(self):
                return ('\n', SPEF.ID.dnet,self.name,self.total_cap,'\n',self.conn_sec,self.cap_sec,self.res_sec,'\n',SPEF.ID.end)
            class ListLike(OrderedObj):
                def __init__(self, members):
                    self.members = members

                def __iter__(self):
                    return iter(self.members)

                def construct_call(self, ID):
                    acc = []
                    for index in range(0,len(self.members)):
                        acc.append((index+1, self.members[index], '\n'))
                    return (ID,'\n',acc)


            class Conn(ListLike):
                def __call__(self):
                    return (SPEF.ID.conn_sec,'\n', self.members)

                class Pin:
                    def __init__(self, SPEF_Header,conn_pin,extern_intern, direction, attributes):
                        self.extern_intern = extern_intern
                        self.name = SPEFutils.get_node_legal_name(SPEF_Header, conn_pin)
                        self.direction = direction
                        self.attributes = attributes
                    def __call__(self):
                        return (self.extern_intern, self.name, self.direction, self.attributes, '\n')

                    class PinCoordinates:
                        def __init__(self, pnt):
                            self.pnt = pnt
                        def __call__(self):
                            return (SPEF.ID.coordinates, self.pnt)
                    class DriverCell:
                        def __init__(self, cell_type):
                            self.cell_type = cell_type
                        def __call__(self):
                            return (SPEF.ID.driver_cell, self.cell_type)
                    class LoadCap:
                        def __init__(self, load_capacitance):
                            self.load_cap = load_capacitance
                        def __call__(self):
                            return (SPEF.ID.cap_load, self.load_cap)
            class ParaMember(OrderedObj):

                def __init__(self,SPEF_Header,para, fst_pin,snd_pin=None):

                    self.fst_node = SPEFutils.get_node_legal_name(SPEF_Header, fst_pin)
                    self.para = para
                    if snd_pin:
                        self.snd_node =SPEFutils.get_node_legal_name(SPEF_Header, snd_pin)
                    else:
                        self.snd_node = snd_pin
                def __call__(self):
                    if self.snd_node:
                        return (self.fst_node, self.snd_node, self.para)
                    else:
                        return (self.fst_node, self.para)
            class Cap(ListLike):
                def __call__(self):
                    return self.construct_call( SPEF.ID.cap_sec)
            class Res(ListLike):
                def __call__(self):
                    return self.construct_call( SPEF.ID.res_sec)

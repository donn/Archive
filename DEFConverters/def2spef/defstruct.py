from base import OrderedObj
import utils
from modtypes import TypeCheckers, Input, Output, NamedPin, Decl

class Pinutils:
    def isin_iolist(self, iolist):
        for ele in iolist:
            if ele == self:
                return True
        return False

class DEFutils:
    def get_oftype(self, req_type, def_ele):
        for item in def_ele:
            if item == self:
                for info in item.information:
                    if type(info) == req_type:
                        return info

    def get_placement(self, def_ele):
        return self.get_oftype( DEF.placement,def_ele)

    def get_layer(self, def_ele):
        return self.get_oftype( DEF.metal_layer,def_ele)

class def_element:
    def __init__(self, number, members):
        self.number 	= number
        self.members 	= utils.flatten_rec_tuple(members)

    def __iter__(self):
        return iter(self.members)

    def get_member_by_name(self, member_name):
        for member in self.members:
            if member.name == member_name:
                return member

    def __call__(self):
        return self.members
class DEF:
    def __init__(self, decs, design_specification):
        """docstring for __init__"""
        self.decs 	= decs
        self.design 	= design_specification

    class declarations( OrderedObj):
        def __init__(self, decl_list):
            self.decl_list = utils.flatten_rec_tuple(decl_list)

        class version(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                self.array = str(declaration).split(".")
                self.major = self.array[0]
                self.minor = self.array[1]
            def __call__(self):
                return array

        class namescasesensitive(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                self.state = declaration
            def __call__(self):
                return self.state

        class dividerchar(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                self.dchar = declaration.strip('\"')
            def __call__(self):
                return self.declaration.strip('\"')

        class busbitchars(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                declaration = declaration.strip('\"')
                self.opening = declaration[0]
                self.closing = declaration[1]

            def __call__(self):
                return self.opening + self.closing

        class design(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                self.array = declaration.split(".")
                self.major = declaration[0]
                self.minor = declaration[1]
            def __call__(self):
                return self.declaration

        class technology(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                self.tech = declaration
            def __call__(self):
                return self.tech

        class distance_unit(Decl):
            def __init__(self, declaration):
                super().__init__(declaration)
                self.distance_unit = declaration
            def __call__(self):
                return self.distance_unit

        def get_version(self):
            return utils.get_member(DEF.declarations.version, self.decl_list)
        def get_namescasesensitive(self):
            return utils.get_member(DEF.declarations.namescasesensitive, self.decl_list)
        def get_dividerchar(self):
            return utils.get_member(DEF.declarations.dividerchar, self.decl_list)
        def get_busbitchars(self):
            return utils.get_member(DEF.declarations.busbitchars, self.decl_list)
        def get_design(self):
            return utils.get_member(DEF.declarations.design, self.decl_list)
        def get_distance_unit(self):
            return utils.get_member(DEF.declarations.distance_unit, self.decl_list)

    class design_spec( OrderedObj):
        def __init__(self, diearea_specs, rows_specs, tracks_specs, comp_specs, pins_specs, nets_specs):
            """docstring for __init__"""
            self.diearea	=        diearea_specs
            self.rows       =        utils.flatten_rec_tuple(rows_specs)
            self.tracks		=        utils.flatten_rec_tuple(tracks_specs)
            self.comp		=        comp_specs
            self.pins		=        pins_specs
            self.nets		=        nets_specs
        def get_placement(self, obj):
            return obj.get_placement(self)

        def get_layer(self, obj):
            return obj.get_layer(self)

        class diearea:
            def __init__(self, pnt1, pnt2):
                self.place 	= pnt1
                self.area 	= pnt2
            def __call__(self):
                return self.area

        class components(def_element):
            class component( OrderedObj,DEFutils):
                def __init__(self, name, comp_type, information):
                    self.name 		= name
                    self.comp_type 	= comp_type
                    self.information 	= utils.flatten_rec_tuple(information)
                def __eq__(self, obj):
                    return obj.equate_to_component(self)

        class pins(def_element):
            class pin(NamedPin, OrderedObj,DEFutils):
                def __init__(self, name, net_name, information):
                    NamedPin.__init__(self, name)
                    self.net_name 	= net_name
                    self.information 	= utils.flatten_rec_tuple(information)

        class nets(def_element):
            class net(NamedPin, OrderedObj):
                def __init__(self, name, connected_pins, options):
                    """docstring for __init__"""
                    NamedPin.__init__(self, name)
                    self.connected_pins 	= utils.flatten_rec_tuple(connected_pins)
                    self.options            = options
                def set_conn_pins_dir(self, BLIF_spec):
                    for pin in self.connected_pins:
                        if TypeCheckers.isport_pin(pin):
                            input_ports = BLIF_spec.get_in_ports()
                            if pin in input_ports:
                                pin.direction = Input
                            else:
                                pin.direction = Output
                        else:
                            # Cell pin
                            gates = BLIF_spec.get_gates()
                            for gate in gates:
                                if pin in gate:
                                    gate_out_pin = gate.get_out_pin()
                                    if pin.name == gate_out_pin.name:
                                        pin.direction = Output
                                    else:

                                        pin.direction = Input
                class port_pin(NamedPin, DEFutils, OrderedObj, Pinutils):
                    def __init__(self, name):
                        """docstring for __init__"""
                        NamedPin.__init__(self, name)
                        self.direction        = None

                    def get_placement(self, DEF_design_spec):
                        return super().get_placement(DEF_design_spec.pins)

                    def get_layer(self, DEF_design_spec):
                        return super().get_placement(DEF_design_spec.pins)



                class cell_pin(NamedPin, DEFutils, OrderedObj, Pinutils):
                    def __init__(self, cell, name):
                        """docstring for __init__"""
                        self.cell       = cell
                        NamedPin.__init__(self, name)
                        self.cell_type  = utils.get_txt_before(cell, '_') # This is not robust, dependant on naming rule for gates_instances in the supplied files
                        self.direction        = None

                    def equate_to_gate(self, gate):
                        return gate.name == self.cell_type

                    def equate_to_component(self, component):
                        return component.name == self.cell

                    def In_gate(self, gate):
                        if self.cell_type == gate.name:
                            return self.name in [gate_pin.name for gate_pin in gate.gate_pins]
                        else:
                            return False

                    def get_placement(self, DEF_design_spec):
                        return super().get_placement(DEF_design_spec.comp)
                    def get_layer(self, DEF_design_spec):
                        return super().get_placement(DEF_design_spec.comp)

    class placement( OrderedObj):
        def __init__(self, pnt, orientation):
            self.place 	        = pnt
            self.orientation 	= orientation

        def __sub__(self, obj):
            return obj.subtract_placement(self)

        def subtract_placement(self, obj):
            return self.place - obj.place

    class metal_layer:
        def __init__(self, pnt1, pnt2, layer_level):
            self.layer_level 	= layer_level
            self.pnt1 	        = pnt1
            self.pnt2 	        = pnt2
        def __call__(self):
            return self.layer_level

    class pin_polarity:
        def __init__(self, direction):
            self.direction  = direction

    class use_signal:
        def __init__(self):
            nop = 0

    class point( OrderedObj):
        def __init__(self, x, y):
            self.x 	= x
            self.y 	= y

        def __sub__(self, obj):
           return obj.subtract_point(self)

        def subtract_point(self, pnt):
            return abs(pnt.x - self.x) + abs(pnt.y - self.y)

    class track(OrderedObj):
        def __init__(self, direction, start, number, space, layer_number):
            self.direction	=direction
            self.start	        =start
            self.number	        =number
            self.space	        =space
            self.layer_number	=layer_number

    class row(OrderedObj):
        def __init__(self, name, site, x, y, orientation, numX, numY, stepX, stepY):
            self.name = name
            self.site = site
            self.x = site
            self.y = site
            self.orientation = orientation
            self.numX = numX
            self.numY = numY
            self.stepX = stepX
            self.stepY = stepY
            
    class gcellgrid(OrderedObj):
        def __init__(self, orientation, start, num, space):
            self.orientation = orientation
            self.start = start
            self.num = num
            self.space = space
#----------DEF ENDS-------------------------------#

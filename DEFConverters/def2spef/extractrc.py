#parasitic extraction from LEF file
import utils
import re
from spefstruct import SPEF
from spefstruct import SPEFutils
from defstruct import DEF
from lefstruct import LEF
from collections import Counter
from modtypes import Input, Output, Unit
from libstruct import LIB
import modtypes
import lits


# -------ENDS LEF-------#

# -------Begins LIB-----#


def least_common(counter_obj):
   return counter_obj.most_common()[-1][0]

def get_cell_pin_of_ref(other_pins):
    directions  = []
    for pin in other_pins:
        directions.append(pin.direction)
    pin_of_ref_type = least_common(Counter(directions))
    for pin in other_pins:
        if pin.direction == pin_of_ref_type:
            return pin

def construct_para_sec(SPEF_Header,connected_pins, units, DEF_datastruct, LEF_txt, para_type=None):
    DEF_design_spec = DEF_datastruct.design
    DEF_declarations = DEF_datastruct.decs
    DEF_distance_unit = DEF_declarations.get_distance_unit().declaration
    def fill_para_sec(SPEF_Header, pin_of_ref, other_pins, DEF_design_spec, LEF_txt):
        def calc_net_para(pin_of_ref, other_pin, DEF_design_spec, LEF_txt, para_type):
            def get_lvl_para(LEF_txt,lvl):
                layer_info = utils.get_txt_after(LEF_txt,' '.join([LEF.Lit.LAYER,lvl]))
                spac = utils.get_word_after(layer_info,LEF.Lit.SPACING)
                wid = utils.get_word_after(layer_info,LEF.Lit.WIDTH)
                res = utils.get_word_after(layer_info,LEF.Lit.RESISTANCE)
                cap = utils.get_word_after(layer_info,LEF.Lit.CAPACITANCE)
                return LEF.metal_layer(lvl, wid, spac, res, cap)


            ref_place = DEF_design_spec.get_placement(pin_of_ref)
            for pin in other_pins:
                pin_place =  DEF_design_spec.get_placement(pin)
                if type(pin) is DEF.design_spec.nets.net.cell_pin:
                    lvl = "metal1"
                else:
                    lvl = (DEF_design_spec.get_layer(pin))()
                LEF_metal_layer = get_lvl_para(LEF_txt,lvl)

                length =   (ref_place - pin_place)
                # Should always standardize units, to be of a format-agnostic unit, which is the standard
                LEF_database_unit = LEF.get_database_unit(LEF_txt)
                if para_type is SPEF.Internal.DNet.Res:
                    # In Ohms
                    ext_metal_info = float(LEF_metal_layer.res )* LEF_database_unit
                else:
                    # In Pico Farads
                    ext_metal_info = float(LEF_metal_layer.cap)* LEF_database_unit
                    # Now in Farads
                # 1ohm | 1 Farad * 1 micron meter * 1
                return float(ext_metal_info) * float(length) * float(LEF_metal_layer.wid)

        para_sec = []
        for pin in other_pins:
            parasitic = calc_net_para(pin_of_ref, pin,DEF_design_spec, LEF_txt, para_type)
            para_sec.append(SPEF.Internal.DNet.ParaMember(SPEF_Header, parasitic, pin_of_ref, pin))
        return para_sec
    pin_of_ref = None
    other_pins = []
    for conn_pin in connected_pins:
        # Each array of connected pins has only one different (Input or Output) pin other than the rest
        # From here it is wrong
        if type(conn_pin) is DEF.design_spec.nets.net.port_pin:
            pin_of_ref = conn_pin
        else:
            other_pins.append(conn_pin)
    if not pin_of_ref:
        # The pins types will contain
        # the least common occurence of
        # input or output type
        # That should be our pin_of_ref
        pin_of_ref = get_cell_pin_of_ref(other_pins)
        other_pins.remove(pin_of_ref)
    return fill_para_sec(SPEF_Header, pin_of_ref, other_pins, DEF_design_spec, LEF_txt)

def construct_cap_sec(SPEF_Header,connected_pins, units, DEF_design_spec, LEF_txt):
    return SPEF.Internal.DNet.Cap(construct_para_sec(SPEF_Header,connected_pins, units, DEF_design_spec, LEF_txt))

def construct_res_sec(SPEF_Header,connected_pins, units, DEF_design_spec, LEF_txt):
    return SPEF.Internal.DNet.Res(construct_para_sec(SPEF_Header,connected_pins, units, DEF_design_spec, LEF_txt,SPEF.Internal.DNet.Res))

def construct_conn_sec(SPEF_Header, connected_pins, DEF_design_spec, BLIF_model_specs, LIB_txt):
    in_ports = BLIF_model_specs.get_in_ports()
    conn_sec_members = []
    for conn_pin in connected_pins:
        attributes = []
        # Name ext
        name = conn_pin.name
        # Extern-intern ext
        if type(conn_pin) is DEF.design_spec.nets.net.cell_pin:
            extern_intern = SPEF.ID.intern_pin
            # Coordinates ext
            coordinates = DEF_design_spec.get_placement(conn_pin).place # This returns a point object
            attributes.append(SPEF.Internal.DNet.Conn.Pin.PinCoordinates(coordinates))
            # Direction ext
            BLIF_gate_type = conn_pin.cell_type
            if conn_pin.direction is Input:
                direction = SPEF.ID.inpt
                load_cap = LIB.get_gate_pin_capacitance( LIB_txt,BLIF_gate_type, name)
                attributes.append(SPEF.Internal.DNet.Conn.Pin.LoadCap(load_cap.num))

            else:

                direction = SPEF.ID.outpt
                attributes.append(SPEF.Internal.DNet.Conn.Pin.DriverCell(BLIF_gate_type))

            pin_in_con_sec = SPEF.Internal.DNet.Conn.Pin(SPEF_Header, conn_pin,extern_intern, direction, attributes)
        else:
            extern_intern = SPEF.ID.extern_pin
            # Direction ext
            attributes = []
            if conn_pin in in_ports:
                direction = SPEF.ID.inpt
            else:
                direction = SPEF.ID.outpt
            pin_in_con_sec = SPEF.Internal.DNet.Conn.Pin(SPEF_Header, conn_pin, extern_intern, direction, attributes)
        conn_sec_members.append(pin_in_con_sec)
    return SPEF.Internal.DNet.Conn(conn_sec_members)

def get_total_cap(cap_sec):
    total_cap = 0
    for cap_spec in cap_sec:
        total_cap += float(cap_spec.para)
    return total_cap

def ext_rc(SPEF_Header,DEF_datastruct, BLIF_datastruct, LEF_txt, LIB_txt):
    # Get input and output ports
    BLIF_model = BLIF_datastruct() # Not robust : CHANGE, [0] to dynamic
    BLIF_model_specs = BLIF_model()
    # For each net, get pins
    DEF_parsingset = DEF_datastruct.decs()
    diearea, tracks, components, pins, nets = DEF_datastruct.design()
    DEF_design_spec = DEF_datastruct.design
    internal_nets = []
    units= (LIB.get_time_unit(LIB_txt), LIB.get_res_unit(LIB_txt), LIB.get_cap_unit(LIB_txt))
    for net in nets():
        # Setting connected_pins_directions
        net.set_conn_pins_dir(BLIF_model_specs)
        net_name, connected_pins = net()
        # Construct the conn sec
        conn_sec = construct_conn_sec(SPEF_Header, connected_pins, DEF_design_spec, BLIF_model_specs, LIB_txt)
        # Construct the cap sec
        cap_sec = construct_cap_sec(SPEF_Header,connected_pins, units, DEF_datastruct, LEF_txt)
        total_cap = get_total_cap(cap_sec)
        # Construct the res sec
        res_sec = construct_res_sec(SPEF_Header,connected_pins, units, DEF_datastruct, LEF_txt)
        # Check port or internal
        internal_nets.append(SPEF.Internal.DNet(SPEF_Header, net, total_cap, conn_sec, cap_sec, res_sec))
    return SPEF.Internal(internal_nets)


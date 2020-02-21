from base import OrderedObj
import lits
import utils
import re
from modtypes import Unit

class LIB:

    class Lit:
        CELL='cell'
        PIN='pin'
        CAPACITANCE='capacitance'
        def pin_pat(pin_name):
            return LIB.Lit.PIN+lits.CONT_SPAC_PAT+lits.LPAREN+lits.CONT_SPAC_PAT+pin_name+lits.CONT_SPAC_PAT+lits.RPAREN
        CAP_PAT = CAPACITANCE+lits.CONT_SPAC_PAT+lits.COLON+lits.CONT_SPAC_PAT
        ID_PAT = lits.CONT_SPAC_PAT + lits.COLON + lits.CONT_SPAC_PAT
        CAP_LOAD_UNIT = 'capacitive_load_unit'
        CAP_UNIT_PAT = CAP_LOAD_UNIT + lits.CONT_SPAC_PAT + lits.LPAREN
        RES_UNIT_ID = 'pulling_resistance_unit'
        TIME_UNIT_ID = 'time_unit'
        TIME_UNIT_PAT = TIME_UNIT_ID + ID_PAT
        RES_UNIT_PAT = RES_UNIT_ID  + ID_PAT

    #-------ENDS LIB--------#

    #--------ENDS Literals-----------#

    def get_unit(LIB_txt, pattern):
        unit_txt_unfiltered = utils.get_word_after(LIB_txt, pattern)
        num_and_factor = re.findall(r'\w+',unit_txt_unfiltered)[0]
        num = re.findall(r'[0-9]+', num_and_factor)[0]
        factor = re.findall(r'[a-zA-z]+', num_and_factor)[0]
        return Unit(float(num), factor)

    def get_cap_unit(LIB_txt):
        txt_after_lib_cap_ID = utils.get_word_after(LIB_txt, LIB.Lit.CAP_UNIT_PAT)
        num = utils.get_txt_before(txt_after_lib_cap_ID, lits.COMA)
        txt_after_coma = utils.get_word_after(txt_after_lib_cap_ID, lits.COMA)
        unit_literal = utils.get_txt_before(txt_after_coma, lits.RPAREN)
        factor = re.findall(r'\w+', unit_literal)[0]
        return Unit(float(num), factor)

    def get_res_unit(LIB_txt):
        return LIB.get_unit(LIB_txt, LIB.Lit.RES_UNIT_PAT)

    def get_time_unit(LIB_txt):
        return LIB.get_unit(LIB_txt, LIB.Lit.TIME_UNIT_PAT)

    def get_all_units(LIB_txt):
        return (LIB.get_time_unit(LIB_txt) , LIB.get_cap_unit(LIB_txt), LIB.get_res_unit(LIB_txt))

    def get_gate_pin_capacitance( LIB_txt,gate_name, pin_name):
        def get_cap( LIB_txt,gate_name, pin_name):
            gate_sec = utils.get_txt_after(LIB_txt,gate_name)
            pin_sec = utils.get_txt_after(gate_sec,LIB.Lit.pin_pat(pin_name))
            return utils.get_word_after(pin_sec,LIB.Lit.CAP_PAT)
        factor = LIB.get_cap_unit(LIB_txt).factor
        return Unit(float(re.sub(r'[^\d.]+','', get_cap(LIB_txt,gate_name, pin_name))), factor)

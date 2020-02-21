from base import OrderedObj
from modtypes import Unit
import lits
import utils
import re
#-------------------LEF Starts--------------------------#

class LEF:
    class metal_layer(OrderedObj):
        def __init__(self, lvl, wid, spac, res, cap):

            self.lvl    =    lvl
            self.wid    =    wid
            self.spac   =    spac
            self.res    =    res
            self.cap    =    cap

    class Units:
        res = 'none'
        cap = 'p'

    class Lit:
        LAYER='LAYER'
        METAL='metal'
        SPACING='SPACING'+lits.CONT_SPAC_PAT
        RPERSQ = 'RPERSQ'
        CPERSQDIST = 'CPERSQDIST'
        WIDTH='WIDTH'+lits.CONT_SPAC_PAT
        RESISTANCE='RESISTANCE'+ lits.CONT_SPAC_PAT+RPERSQ+lits.CONT_SPAC_PAT
        CAPACITANCE='CAPACITANCE'+ lits.CONT_SPAC_PAT+CPERSQDIST+lits.CONT_SPAC_PAT
        DATABASE = 'DATABASE[ \t]*\n*'
        UNITS = 'UNITS'

    def get_database_unit(LEF_txt):
        units_sec = utils.get_txt_after(LEF_txt, LEF.Lit.UNITS)
        factor = utils.get_word_after(units_sec, LEF.Lit.DATABASE)
        num = utils.get_word_after(units_sec, factor)

        return 1000 # Hard Coded : CHANGE

#------------------LEF Ends------------------------------#

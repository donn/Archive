#!/usr/bin/env python3.5
import defparser
import sys
import argparse
import blifparser
import utils
import datetime
import extractrc
from spefstruct import SPEF
from defstruct import DEF
from modtypes import Unit
from libstruct import LIB
from lefstruct import LEF

def get_parsers():
    """docstring for get_parsers"""
    return (defparser.defparser(),blifparser.blifparser())

def parse_to_structs(DEFparser,DEFlexer, BLIFparser, BLIFlexer, DEF_txt, BLIF_txt):
    DEF_datastruct =   DEFparser.parse(DEF_txt,lexer=DEFlexer)
    BLIF_datastruct =   BLIFparser.parse(BLIF_txt,lexer=BLIFlexer)
    return (DEF_datastruct ,BLIF_datastruct)

def get_files_txts(args):
    def aux(file_name): # Auxilary function
        with open(file_name,'r') as txt_tobeparsed:
            return txt_tobeparsed.read()
    DEF_txt=aux(args.DEF)
    BLIF_txt=aux(args.BLIF)
    LIB_txt=aux(args.LIB)
    LEF_txt=aux(args.LEF)
    return (DEF_txt, BLIF_txt, LIB_txt, LEF_txt)

def construct_SPEF_file(DEF_datastruct, BLIF_datastruct, units, LEF_txt, LIB_txt):
    DEF_declarations = DEF_datastruct.decs
    stdnum = utils.quoteit("IEEE 1481-1998")
    design = utils.quoteit(str(DEF_declarations.get_design()))
    todaydate = utils.quoteit(str(datetime.date.today()))
    vendor  = utils.quoteit("Intended Tool")
    program = utils.quoteit("def2spef")
    fileversion = utils.quoteit("0.1")
    designflow = utils.quoteit("Design_Flow")
    dividerchar = DEF_declarations.get_dividerchar()
    delimiterchar = ":"
    busdelimiterchar = DEF_declarations.get_busbitchars()
    tunit = "1 PS"
    cunit = "1 PF"
    runit = "1 OHM"
    lunit = "1 UH"
    decl_list = [SPEF.Header.StdNum(stdnum), SPEF.Header.DesName(design),SPEF.Header.CreDate(todaydate),SPEF.Header.Vendor(vendor),SPEF.Header.Prog(program),SPEF.Header.FVer(fileversion),SPEF.Header.DesFlow(designflow),SPEF.Header.DivChar(dividerchar),SPEF.Header.DelimChar(delimiterchar),SPEF.Header.BusDelimChar(busdelimiterchar),SPEF.Header.TUnit(tunit),SPEF.Header.CUnit(cunit),SPEF.Header.RUnit(runit),SPEF.Header.LUnit(lunit)]
    header = SPEF.Header(decl_list)
    internal = extractrc.ext_rc(header, DEF_datastruct, BLIF_datastruct, LEF_txt, LIB_txt)
    return SPEF(header, internal)

if __name__=="__main__":
    args_parser = argparse.ArgumentParser(prog='def2spef.py',description="""Converts DEF files to SPEF files via parasitics extraction, given a LIB, LEF and BLIF files.\n
            \nif no output file is specified, a SPEF file is created with the DEF file name, extension included""")
    args_parser.add_argument('DEF', help='Design Exchange Format file name')
    args_parser.add_argument('LEF', help='Library Exchange Format file name')
    args_parser.add_argument('LIB', help='Liberty file name')
    args_parser.add_argument('BLIF', help='Berkley Logic Interchange Format file name')
    args_parser.add_argument('-out', help='output file name')
    args = args_parser.parse_args(sys.argv[1:])
    (DEFparser,DEFlexer),( BLIFparser,BLIFlexer) =   get_parsers()
    DEF_txt, BLIF_txt, LIB_txt, LEF_txt = get_files_txts(args)
    # Optional Argument
    if args.out:
        SPEF_handler = open(args.out, 'w')
    else:
        print("here and the out file name is ", args.DEF+'.spef')
        SPEF_handler = open(args.DEF+'.spef', 'w')
    DEF_datastruct,BLIF_datastruct = parse_to_structs(DEFparser,DEFlexer, BLIFparser, BLIFlexer, DEF_txt, BLIF_txt)
    units = LIB.get_all_units(LIB_txt)
    SPEF_datastruct = construct_SPEF_file(DEF_datastruct, BLIF_datastruct,units, LEF_txt, LIB_txt)
    utils.write_any(SPEF_datastruct, SPEF_handler)
    LEF.get_database_unit(LEF_txt)

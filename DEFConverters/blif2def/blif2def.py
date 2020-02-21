#!/usr/bin/env python3

import ply.lex as lex
import ply.yacc as yacc
import sys
import os
import io
import re
import blifparser
import conv2def
from collections import OrderedDict
import getopt

if __name__ == "__main__":
    def print_usage():
        print("usage: ./blif2def.py [-a aspect_ratio: float] [-h row_height: int] [-s site_width: int] [-u core_utilization: float] <*.blif> <*.lef> <*.def> ")

    components          =   {}
    pins                =   []
    nets                =   {}
    gatetypes           =   {}
    def_parsing_settings    =   OrderedDict()
    model               =   ""
    default_cmd_options =   {
        'aspect_ratio': 1,
        'core_utilization': 0.7,
        'site_width': 1600,
        'row_height': 2000,
        'power_network_synthesis': False
    }

    cmd_options  =  default_cmd_options

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'a:h:s:u', ['aspect_ratio=', 'row_height=', 'site_width=', 'core_utilization=', 'help'])
    except getopt.GetoptError:
        print_usage()
        exit(64)

    for opt, arg in opts:
        if opt in ('--help'):
            print_usage()
            exit(0)
        elif opt in ('-a', '--aspect_ratio'):
            cmd_options['aspect_ratio'] = float(arg)
        elif opt in ('-h', '--row_height'):
            cmd_options['row_height'] = int(arg)
        elif opt in ('-s', '--site_width'):
            cmd_options['site_width'] = int(arg)
        elif opt in ('-u', '--core_utilization'):
            cmd_options['core_utilization'] = float(arg)
        # elif opt in ('-p', '--power_network_synthesis'):
        #     cmd_options['power_network_synthesis'] = True
        else:
            print_usage()
            exit(64)

    if len(args) != 3:
        print_usage()
        exit(64)

    with open(args[0],'r') as design_blif_file_tobeparsed:
        blif_txt=design_blif_file_tobeparsed.read()

    with open(args[1],'r') as scl_lef_file_tobeparsed:
        scl_txt=scl_lef_file_tobeparsed.read()

    blif_parser= blifparser.construct_blif_parser()
    AST  = blif_parser.parse(blif_txt)

    model = None
    for element in AST:
        if element[0] == 'model':
            model = element[1]
            break
    if not model:
        print("No model found in file.")
        exit(65)
        
    conv2def.construct_pins_comp(AST,pins,components,gatetypes,model)
    pins = conv2def.flatten(pins)
    comp_nets   =   conv2def.construct_nets(components,nets)
    design_blif_file_tobeparsed.close()

    conv2def.write_to_def(
        blif_txt,
        scl_txt,
        args[2],
        cmd_options,
        def_parsing_settings,
        model,
        gatetypes,
        components,
        pins,
        nets
    )

#!/usr/bin/env python3
import sys
import os
import io
import re
import getopt
import defparser
import syn

if __name__ == "__main__":
    analyze = False
    options =   {
        'vertical_ring_layer': 8,
        'vertical_strap_count': 16,
        'horizontal_ring_layer': 9,
        'power_budget': 1000,
        'target_ir_drop': 250,
        'virtual_rail_layer': 1,
        'power_net': "VDD",
        'ground_net': "VSS"
    }

    def get_angry():
        print("Invalid invocation.")

    def print_usage():
        print("Usage: ./pns.py [-V vertical_ring_layer: int] [-C vertical_strap_count: int] [-H horizontal_ring_layer: int] [-p power_budget: int, mW] [-d target_ir_drop: int, mV] [-v virtual_rail_layer: int] [-P power_net: string] [-G ground_net: string] [-a analyze: toggle] [-h help: toggle] <DEF> <Output DEF (Optional)>")

    try:
        opts, args = getopt.getopt(sys.argv[1:], 'V:C:H:p:d:v:P:G:a:h', ['vertical_ring_layer=', 'vertical_strap_count=', 'horizontal_ring_layer=',  'power_budget=', 'target_ir_drop=', 'virtual_rail_layer=', 'power_net=', 'ground_net=', 'analyze', 'help'])
    except getopt.GetoptError:
        get_angry()
        print_usage()
        exit(64)

    for opt, arg in opts:
        if opt in ('-h', '--help'):
            print_usage()
            exit(0)
        if opt in ('-a', '--analyze'):
            analyze = True
        elif opt in ('-C', '--vertical_strap_count'):
            options['vertical_strap_count='] = int(arg)
        elif opt in ('-V', '--vertical_ring_layer'):
            options['vertical_ring_layer'] = int(arg)
        elif opt in ('-H', '--horizontal_ring_layer'):
            options['horizontal_ring_layer'] = int(arg)
        elif opt in ('-p', '--power_budget'):
            options['power_budget'] = int(arg)
        elif opt in ('-d', '--target_ir_drop'):
            options['target_ir_drop'] = int(arg)
        elif opt in ('-v', '--virtual_rail_layer'):
            options['virtual_rail_layer'] = int(arg)
        elif opt in ('-P', '--power_net'):
            options['power_net'] = arg
        elif opt in ('-G', '--ground_net'):
            options['ground_net'] = arg
        else:
            get_angry()
            print_usage()
            exit(64)

    inputFile = None
    outputFile = None

    if len(args) == 1:
        inputFile = args[0]
        outputFile = args[0] + ".syn.def"
    elif len(args) == 2:
        inputFile = args[0]
        outputFile = args[1]
    else:
        get_angry()
        print_usage()
        exit(64)

    with open(inputFile, 'r') as file:
        data = file.read()

    if not analyze:
        defparser, deflexer = defparser.defparser()
        # deflexer.input(data)
        # while True:
        #     tok = deflexer.token()
        #     print(tok)
        #     if not tok:
        #         break
        structure = defparser.parse(data, lexer=deflexer)
        print(structure)
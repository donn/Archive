#!/usr/bin/env python3

from math import sqrt, pow, ceil
from collections import OrderedDict

def construct_pins_comp(AST_tree_list,pins, components, gatetypes, model):
    if not AST_tree_list :
        pins = flatten(pins)
        return pins, components
    else:
        head, *tail = AST_tree_list

        if type(head) is not tuple:
            if head == 'model':
                model = tail[0]
            elif head == 'input':
                pins.append(tail)
            elif head == 'output':
                pins.append(tail)
            elif head == 'gate':
                gatename, *gatevariables = tail
                if gatename in gatetypes:
                    gatetypes[gatename]['number'] += 1
                else:
                    gatetypes[gatename] = {'number': 1,'height': None,'width': None}
                components[gatename + '_'+ str(gatetypes[gatename]['number'])] = gatevariables
        else:
            construct_pins_comp(head,pins,components, gatetypes, model)
            construct_pins_comp(tail,pins,components, gatetypes, model)

def flatten(arraytoflat):
    """docstring for flatten"""
    def flatten_aux(arraytoflat, acc):
        if arraytoflat:
            head, *tail = arraytoflat
            if type(head) is not str:
                flatten_aux(head, acc)
                flatten_aux(tail, acc)
            else:
                acc.append(head)
                flatten_aux(tail, acc)
        else:
            return acc
    acc = []
    flatten_aux(arraytoflat, acc)
    return  acc

def construct_nets(comp,nets):

    def aux(singcompnets, acc):
        if singcompnets:
            head, *tail = singcompnets
            if head:
                headofhead, *tailofhead = head
                acc.append(headofhead)
                aux(tailofhead, acc)
            aux(tail, acc)
        else:
            return acc

    def aux_2(comp_nets_dict):
        for singcomp, singcompnets in comp_nets_dict.items():
            for net in singcompnets:
                if net[1] not in nets:
                    nets[net[1]] = []
                nets[net[1]].append((singcomp, net[0]))
    new_comp = {}
    for singcomp,singcompnets in comp.items():
        acc = []
        aux(singcompnets, acc)
        new_comp[singcomp]  =   acc
    aux_2(new_comp)

def write_to_def(blif_txt, scl_txt, file_to_write,cmd_options,def_parsing_settings,model, gatetypes, components, pins, nets):
    def write_tracks(file_handler, area_info, tracks):
        negaspace_x, negaspace_y, core_width, core_height = area_info
        for track in tracks:
            layer = track[0]
            direction = track[1]
            step = track[2]
            negaspace = negaspace_x if direction == 'X' else negaspace_y
            length = core_width if direction == 'X' else core_height
            total_length = core_width - negaspace
            file_handler.write(' '.join(['TRACKS', direction, 'DO', str(int(ceil(total_length / step))),'STEP', str(step), 'LAYER', layer, ';\n']))
        file_handler.write('\n')

    def write_components(file_handler, components):
        file_handler.write("COMPONENTS " +str(len(components))+ ' ;\n')
        for onegate, info in gatetypes.items():
            for x in range(1, info['number'] + 1):
                    file_handler.write("- " + onegate + "_" + str(x) + ' ' + onegate + " ;\n")
        file_handler.write('END COMPONENTS\n')
        file_handler.write('\n')

    def write_pins(file_handler,pins):
        file_handler.write("PINS " + str(len(pins)) + ' ;\n')
        for onepin in pins:
            file_handler.write("- " + onepin + " + NET " + onepin + " ;\n")
        file_handler.write('END PINS\n')
        file_handler.write('\n')

    def write_nets(file_handler,nets):
        file_handler.write("NETS " + str(len(nets)) + " ;")
        for onenet, connected_pins in nets.items():
            file_handler.write("\n- " + onenet)
            if onenet in pins:
                file_handler.write("\n( PIN " + onenet + " )")
            for onepin in connected_pins:
                file_handler.write("\n( "+ onepin[0] + " " + onepin[1] + " )")
            file_handler.write(' ;')
        file_handler.write('\nEND NETS')
        file_handler.write('\n')

    def write_def_parsing_settings(blif_txt, scl_txt,file_handler,cmd_options,def_parsing_settings, gatetypes):
        # Writes header, returns die area info
        def round_to_multiple_of(x, base):
            return int(ceil(x/base) * base)

        def calculate_die_area(scl_txt,cmd_options, gatetypes):
            def calculate_total_cell_area(cmd_options,gatetypes):
                total_cell_area = 0
                for onegate, onegatespecs in gatetypes.items():
                    total_cell_area += (pow(def_parsing_settings['UNITS DISTANCE MICRONS'],2) * gatetypes[onegate]['height'] * gatetypes[onegate]['width'] *  gatetypes[onegate]['number'])
                    #print(onegate, gatetypes[onegate])
                    #print(total_cell_area )

                die_area = total_cell_area   / cmd_options['core_utilization']
                # ar = cw / ch
                ar = cmd_options['aspect_ratio']
                core_height =   sqrt(die_area/ ar)
                core_width  =   ar * core_height
                # so if ar = 2 so cw * ch = 2 ch ^ 2 = die_area so we get ch then cw
                # after that we make sure that the cw is multiple of the site width -s option
                # then we make sure that the ch is a multiple of the row height -h option
                core_height =   round_to_multiple_of(core_height, cmd_options['row_height'])
                core_width  =   round_to_multiple_of(core_width, cmd_options['site_width'])

                negaspace_x = -(cmd_options['site_width'] * 3)
                negaspace_y = -(cmd_options['row_height'] * 2)

                return negaspace_x, negaspace_y, core_width, core_height

            def get_cells_height_width(gatetypes):
                for onegate,number in gatetypes.items():
                    size_txt = scl_txt.split(onegate, 1)[1].split("SIZE",1)[1] # captured "SIZE width BY height"
                    width = size_txt.split()[0]
                    height = size_txt.split("BY", 1)[1].split()[0]
                    gatetypes[onegate]['height']  =   float(height)
                    gatetypes[onegate]['width']  =   float(width)

            get_cells_height_width(gatetypes)

            return calculate_total_cell_area(cmd_options,gatetypes)

        def_parsing_settings['VERSION']                 =   '5.6' # To be decided later
        def_parsing_settings['NAMESCASESENSITIVE']      =   'ON'
        def_parsing_settings['DIVIDERCHAR']             =   '"/"'
        if '[' or ']' in blif_txt:
            def_parsing_settings['BUSBITCHARS']         =   '"[]"'
        else:
            def_parsing_settings['BUSBITCHARS']         =   '"<>"'
        def_parsing_settings['DESIGN']                  =   model
        def_parsing_settings['UNITS DISTANCE MICRONS']  =   int(scl_txt.split('MICRONS', 1)[1].split()[0])

        negaspace_x, negaspace_y, core_width, core_height  = calculate_die_area(scl_txt,cmd_options,gatetypes)

        def_parsing_settings['DIEAREA'] = ' '.join(['(', str(negaspace_x), str(negaspace_y), ') (', str(core_width), str(core_height), ')'])

        for settingname, value in def_parsing_settings.items():
            file_handler.write(settingname + " " + str(value) + " ;\n")

        file_handler.write('\n')

        return negaspace_x, negaspace_y, core_width, core_height

    with open(file_to_write,'w+') as file_tobewritten:
        area_info = write_def_parsing_settings(blif_txt, scl_txt, file_tobewritten, cmd_options, def_parsing_settings,gatetypes)
        write_tracks(file_tobewritten, area_info, [('metal1', 'Y', cmd_options['row_height']), ('metal2', 'X', cmd_options['site_width']), ('metal3', 'Y', cmd_options['row_height']), ('metal4', 'X', cmd_options['site_width'] * 2)])
        write_components(file_tobewritten,components)
        write_pins(file_tobewritten, pins)
        write_nets(file_tobewritten, nets)
        file_tobewritten.write('\nEND DESIGN\n')


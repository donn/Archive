#!/usr/bin/env python3

import ply.lex as lex
import ply.yacc as yacc
import sys
import io
import re
import conv2def
from math import sqrt, pow, ceil

from collections import OrderedDict

def construct_blif_parser():

    tokens = [
            'COMMENT',
            'MODEL',
            'INPUT',
            'OUTPUT',
            'NAMES',
            'LATCH',
            'END',
            'NEWLINE',
            'EQUAL',
            'COMMAND',
            'LOGIC_GATE',
            'GENERIC_LATCH',
            'LIBRARY_GATE',
            'MODEL_REF',
            'SUBFILE_REFERENCE',
            'FSM_DECRIPTION',
            'CLOCK_CONSTRAINT',
            'AREA_CONSTR',
            'DELAY',
            'WIRE_LOAD_SLOPE',
            'WIRE',
            'INPUT_ARRIVAL',
            'DEFAULT_INPUT_ARRIVAL',
            'OUTPUT_REQUIRED',
            'DEFAULT_OUTPUT_REQUIRED',
            'INPUT_DRIVE',
            'DEFAULT_INPUT_DRIVE',
            'MAX_INPUT_LOAD',
            'DEFAULT_MAX_INPUT_LOAD',
            'OUTPUT_LOAD',
            'DEFAULT_OUTPUT_LOAD',
            'VARNAME',
            'VALUE'
            ]


    states=(('COMMENT','exclusive'),)
    def t_COMMENT(t):
        r'\#'
        t.lexer.begin('COMMENT')
    def t_COMMENT_end(t):
        r'\n'
        t.lexer.lineno += t.value.count('\n')
        t.lexer.begin('INITIAL')
    def t_COMMENT_error(t):

        t.lexer.skip(1)

    t_COMMENT_ignore = r' '

    t_MODEL                     =   r'\.model'
    t_INPUT                     =   r'\.inputs'
    t_OUTPUT                    =   r'\.outputs'
    t_NAMES                     =   r'\.names'
    t_END                       =   r'\.end'
    t_EQUAL                     =   r'\='
    def t_NEWLINE(t):
        r'\n'
        t.lexer.lineno += 1
        pass
    """below to support different commands"""
    t_LOGIC_GATE                =   r'\.gate|.subckt'
    t_GENERIC_LATCH             =   r'\.latch'
    t_LIBRARY_GATE              =   r'\.latch|\.mlatch'
    t_SUBFILE_REFERENCE         =   r'\.search'
    t_FSM_DECRIPTION            =   r'\.start_kiss'
    t_CLOCK_CONSTRAINT          =   r'\.clock'
    t_AREA_CONSTR               =   r'\.area'
    t_DELAY                     =   r'\.delay'
    t_WIRE_LOAD_SLOPE           =   r'\.wire_load_slope'
    t_WIRE                      =   r'\.wire'
    t_INPUT_ARRIVAL             =   r'\.input_arrival'
    t_DEFAULT_INPUT_ARRIVAL     =   r'\.default_input_arrival'
    t_OUTPUT_REQUIRED           =   r'\.output_required'
    t_DEFAULT_OUTPUT_REQUIRED   =   r'\.default_output_required'
    t_INPUT_DRIVE               =   r'\.input_drive'
    t_DEFAULT_INPUT_DRIVE       =   r'\.default_input_drive'
    t_MAX_INPUT_LOAD            =   r'\.max_input_load'
    t_DEFAULT_MAX_INPUT_LOAD    =   r'\.default_max_input_load'
    t_OUTPUT_LOAD               =   r'\.output_load'
    t_DEFAULT_OUTPUT_LOAD       =   r'\.default_output_load'

    t_VARNAME                   =   r'[\$a-zA-Z0-9_\<\>\[\]]+[\.]*[a-zA-Z0-9_\<\>\[\]]*'
    def t_VALUE(t):
        r'[0-9]'
        return t
    def t_error(t):
        print("Illegal string")
        print(t)
        t.lexer.skip(1)




    t_ignore = r' '
    def p_error(p):
        for x in p.lexer:
           print(x)
        print('rule parsed inside error', p)
        print("Syntax error found!")








    def p_blif_txt(p):
        '''
        blif_txt    :   model model_spec    END blif_txt
                    |   empty
        '''
        if(len(p)==5):
            p[0]  = (p[1], p[2],p[3],p[4])

    def p_model(p):
        '''
        model           :   MODEL   VARNAME

        '''
        p[0] = ('model', p[2])

    def p_model_spec(p):
        '''
        model_spec  :   input_list      model_spec
                    |   output_list     model_spec
                    |   gate_command    model_spec
                    |   name_command    model_spec
                    |   empty
        '''
        if (len(p)==3):
            p[0] = (p[1], p[2])
        elif(len(p)==2):
            p[0] = (p[1])

    def p_input_list(p):
        '''
        input_list      :   INPUT VARNAME y
        y               :   VARNAME y
                        |   empty
        '''
        if (len(p)==4):
            p[0]    =   ('input', p[2], p[3])
        elif(len(p)==3):
            p[0]    =   (p[1],p[2])
        elif(len(p)==2):
            p[0]    =   (p[1])

    def p_output_list(p):
        '''
        output_list     :   OUTPUT VARNAME x
        x               :   VARNAME x
                        |   empty
        '''
        if (len(p)==4):
            p[0]    =   ('output', p[2], p[3])
        elif(len(p)==3):
            p[0]    =   (p[1],p[2])
        elif(len(p)==2):
            p[0]    =   (p[1])

    def p_gate_command(p):
        '''
        gate_command    :   LOGIC_GATE  VARNAME var_list
        '''
        p[0]    =  ('gate', p[2], p[3])

    def p_name_command(p):
        '''
        name_command    :   NAMES   VARNAME
                        |   NAMES   VARNAME VALUE
        '''
        if (len(p) == 3):
            p[0] = (p[2], '0')
        else:
            p[0] = (p[2], p[3])
    def p_var_list(p):
        '''
        var_list        :   VARNAME EQUAL   VARNAME var_list
                        |   empty
        '''
        if(len(p)==5):
            p[0]    =   ((p[1], p[3]), p[4])
        elif(len(p)==4):
            p[0]    =   (p[1], p[3])

    def p_empty(p):
        '''
        empty :
        '''
        p[0] = None


    lexer = lex.lex()
    parser = yacc.yacc()
    return parser







'''
<logic-gate>
 <generic-latch>
 <library-gate>
 <model-reference>
 <subfile-reference>
 <fsm-description>
<clock-constraint>
 <delay-constraint>
'''
'''
.area                       <area>
.delay                      <in-name> <phase> <load> <max-load> <brise> <drise> <bfall> <dfall>
.wire_load_slope            <load>
.wire                       <wire-load-list>
.input_arrival              <in-name> <rise> <fall> [<before-after> <event>]
.default_input_arrival      <rise> <fall>
.output_required            <out-name> <rise> <fall> [<before-after> <event>]
.default_output_required    <rise> <fall>
.input_drive                <in-name> <rise> <fall>
.default_input_drive        <rise> <fall>
.max_input_load             <load>
.default_max_input_load     <load>
.output_load                <out-name>     <load>
.default_output_load        <load>
'''


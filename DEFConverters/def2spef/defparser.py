#!/usr/bin/env python3
import pprint
import ply.lex as lex
import ply.yacc as yacc
import io
import sys as System
from collections import OrderedDict
from defstruct import DEF
from modtypes import BusBit

__lexer_test__ = False

# Lexer
tokens = [
    'COMMENT',
    'VERSION',
    'NAMESCASESENSITIVE',
    'DESIGN',
    'UNITS',
    'DISTANCE',
    'MICRONS',
    'TECHNOLOGY',
    'DIEAREA',
    'ROW',
    'TRACKS',
    'GCELLGRID',
    'DO',
    'STEP',
    'LAYER',
    'DIRECTION',
    'POLARITY',
    'USE',
    'SIGNAL',
    'METAL_ID',
    'COMPONENTS',
    'VARNAME',
    'PLACED',
    'PINS',
    'PIN',
    'NETS',
    'NET',
    'INT',
    'STRING',
    'FLOAT', 'BOOL',
    'SEMICOLON',
    'NEWLINE',
    'MINUS',
    'PLUS',
    'END',
    'LPAREN',
    'RPAREN',
    'LANGLE',
    'RANGLE',
    'LBRACKET',
    'RBRACKET',
    'FWSLASH',
    'PIPE',
    'DIVIDERCHAR',
    'BUSBITCHARS',
    'CHAR_PAIRS_QUOTED'
]

def t_COMMENT(token):
    r'\#.*\n'
    token.lexer.lineno += 1
    pass

def t_FLOAT(token):
    r'[0-9](\.[0-9]+)'
    token.value = float(token.value)
    return token

def t_INT (token):
    r'-?[0-9]+'
    token.value = int(token.value)
    return token

def t_CHAR_PAIRS_QUOTED(t):
    r'\".+\"'
    return t

def t_PLACED(t):
    r'PLACED'
    return t

def t_VERSION(t):
    r'VERSION'
    return t

def t_BUSBITCHARS(t):
    r'BUSBITCHARS'
    return t

def t_DIVIDERCHAR(t):
    r'DIVIDERCHAR'
    return t

def t_NAMESCASESENSITIVE(t):
    r'NAMESCASESENSITIVE'
    return t

def t_UNITS(t):
    r'UNITS'
    return t

def t_MICRONS(t):
    r'MICRONS'
    return t

def t_TECHNOLOGY(t):
    r'TECHNOLOGY'
    return t

def t_DISTANCE(t):
    r'DISTANCE'
    return t

def t_DESIGN(t):
    r'DESIGN'
    return t

def t_GCELLGRID(t):
    r'GCELLGRID'
    return t

def t_TRACKS(t):
    r'TRACKS'
    return t

def t_ROW(t):
    r'ROW'
    return t

#def t_SECTION(token):
#    r'|PINPROPERTIES|BLOCKAGES|SLOTS|FILLS|SPECIALNETS||SCANCHAINS|GROUPS|BEGINEXT'
#    return token

def t_NETS(t):
    r'NETS'
    return t

def t_NET(t):
    r'NET'
    return t

def t_DIEAREA(t):
    r'DIEAREA'
    return t

def t_COMPONENTS(t):
    r'COMPONENTS'
    return t

def t_PINS(t):
    r'PINS'
    return t

def t_PIN(t):
    r'PIN'
    return t

def t_END(token):
    r'END'
    return token

def t_DO(t):
    r'DO'
    return t

def t_STEP(t):
    r'STEP'
    return t

def t_LAYER(t):
    r'LAYER'
    return t

def t_USE(t):
    r'USE'
    return t

def t_SIGNAL(t):
    r'SIGNAL'
    return t

def t_DIRECTION(t):
    r'DIRECTION'
    return t

def t_POLARITY(t):
    r'INPUT|OUTPUT'
    return t

def t_METAL_ID(t):
    r'(metal|M)([0-9]+|RDL)'
    return t

def t_BOOL(t):
    r'ON|OFF'
    return t

def t_VARNAME(t):
    r'(\\\[|\\\]|\\/|[a-zA-Z0-9_/\.])+'
    return t

def t_SEMICOLON(token):
    r'\;'
    return token


def t_LPAREN(token):
    r'\('
    return token

def t_RPAREN(token):
    r'\)'
    return token

def t_RBRACKET(token):
    r'\]'
    return token

def t_LBRACKET(token):
    r'\['
    return token

def t_LANGLE(token):
    r'\<'
    return token

def t_RANGLE(token):
    r'\>'
    return token

def t_PIPE(token):
    r'\|'
    return token


def t_MINUS(token):
    r'\-'
    return token

def t_PLUS(token):
    r'\+'
    return token

def t_NEWLINE(token):
    r'\n'
    token.lexer.lineno += 1
    pass

t_ignore = ' \t\r'

lexer_errors = 0

def t_error(token):
    global lexer_errors
    lexer_errors += 1
    #print('Unexpected character ' + token.value + ' at line ' + str(token.lexer.lineno))
    token.lexer.skip(1)

lexer = lex.lex()


class Settings:
    brackets = ['<>', '[]']
    dividers = ['|', '/']
    version = 5.6
    caseSensitive = False
    dividerChar = '/'
    busBitChars = '[]'
    distanceUnits = 100

# Parser
def p_root(p):
    """
        root    :   declarations    design_spec  root
                |   empty
    """
    if (len(p) == 4):
        p[0] = DEF(DEF.declarations(p[1]), p[2])
    #if (len(p) == 4):
    #    p[0] = (p[1], p[2])

def p_declarations(p):
    """
        declarations    :   version_spec    declarations
                        |   namescasesensitive_spec  declarations
                        |   dividerchar_spec  declarations
                        |   busbitchars_spec    declarations
                        |   design_dec  declarations
                        |   technology_dec  declarations
                        |   unitsdistancemicrons_spec declarations
                        |   empty
    """
    if (len(p) == 3):
        p[0] = (p[1], p[2])

def p_busbitchars_spec(p):
    """
        busbitchars_spec    :   BUSBITCHARS CHAR_PAIRS_QUOTED   SEMICOLON
    """
    p[0]    =   DEF.declarations.busbitchars(p[2])
def p_version_spec(p):
    """
        version_spec    : VERSION FLOAT SEMICOLON
    """
    p[0]    =   DEF.declarations.version(p[2])
def p_namescasesensitive_spec(p):
    """
        namescasesensitive_spec  : NAMESCASESENSITIVE BOOL SEMICOLON
    """
    p[0]    =   DEF.declarations.namescasesensitive(p[2])
def p_dividerchar_spec(p):
    """
                    dividerchar_spec    : DIVIDERCHAR CHAR_PAIRS_QUOTED SEMICOLON
    """
    p[0]    =   DEF.declarations.dividerchar(p[2])
def p_design_dec(p):
    """
        design_dec  :   DESIGN VARNAME SEMICOLON
    """
    p[0]    =   DEF.declarations.design(p[2])
def p_technology_dec(p):
    """
        technology_dec  :   TECHNOLOGY VARNAME SEMICOLON
    """
    p[0]    =   DEF.declarations.technology(p[2])
def p_unitsdistancemicrons_spec(p):
    """
        unitsdistancemicrons_spec   :   UNITS DISTANCE MICRONS INT SEMICOLON
    """
    p[0] =  DEF.declarations.distance_unit(p[4])

def p_design_spec(p):
    """
        design_spec :   diearea_specs rows_specs tracks_specs gcellgrid_specs   comp_specs  pins_specs  nets_specs END DESIGN
    """
    #p[0] = DEF.design_spec(p[1], p[2], p[3], p[4], p[5], p[6])

def p_diearea_specs(p):
    """
        diearea_specs    :   DIEAREA xandy    xandy    SEMICOLON
    """
    p[0] = DEF.design_spec.diearea(p[2],p[3])

    # NOTE: DO and STEP are actually recursive elements themselves and should be implemented that way in the future, but so far there are no such samples.

def p_rows_specs(p):
    """
        rows_specs  :   ROW VARNAME VARNAME INT INT VARNAME DO INT VARNAME INT STEP INT INT SEMICOLON rows_specs
                    |   empty
    """
    if (len(p) == 16):
        p[0] = (DEF.row(p[2], p[3], p[4], p[5], p[6], p[8], p[10], p[12], p[13]), p[15])

def p_tracks_specs(p):
    """
        tracks_specs    :   TRACKS VARNAME INT DO INT STEP INT LAYER METAL_ID SEMICOLON tracks_specs
                        |   empty
    """
    if (len(p) == 12):
        p[0] = (DEF.track(p[2], p[3], p[5], p[7], p[9]), p[11])

def p_gcellgrid_specs(p):
    """
        gcellgrid_specs :   GCELLGRID VARNAME INT DO INT STEP INT SEMICOLON gcellgrid_specs
                        |   empty
    """
    if (len(p) == 10):
        p[0] = (DEF.gcellgrid(p[2], p[3], p[5], p[7]), p[9]);

def p_comp_specs(p):
    """
        comp_specs      :   COMPONENTS  INT SEMICOLON   components_mem   END COMPONENTS
    """
    p[0] = DEF.design_spec.components(p[2], p[4])

def p_components_mem(p):
    """
        components_mem    :   MINUS   VARNAME    VARNAME    component_info  components_mem
                            |   empty
    """
    if(len(p)==6):
        p[0] = (DEF.design_spec.components.component(p[2], p[3], p[4]), p[5])

def p_component_info(p):
    """
        component_info  :   PLUS   PLACED  xandy    VARNAME component_info
                        |   SEMICOLON
    """
    if (len(p)  ==  6):
        p[0]    =   (DEF.placement(p[3], p[4]), p[5])

def p_pins_specs(p):
    """
        pins_specs  :   PINS    INT SEMICOLON   pins_mem    END PINS
    """
    p[0] = DEF.design_spec.pins(p[2], p[4])

def p_pins_mem(p):
    """
        pins_mem    :   MINUS  pin_name PLUS    NET pin_name    pin_info    pins_mem
                    |   empty
    """
    if (len(p) == 8):
        p[0] = (DEF.design_spec.pins.pin(p[2], p[5], p[6]), p[7])

def p_pin_info(p):
    """
        pin_info    :   PLUS    LAYER   METAL_ID    xandy   xandy   pin_info
                    |   PLUS    DIRECTION   POLARITY    pin_info
                    |   PLUS    PLACED  xandy   VARNAME pin_info
                    |   PLUS    USE     SIGNAL  pin_info
                    |   SEMICOLON
    """
                    
    if (len(p) == 3):
        if p[3] == "SIGNAL":
            p[0] = (DEF.use_signal(), p[4])
        else:
            p[0] = (DEF.pin_polarity(p[3]), p[4])
    if (len(p) == 7):
        p[0] =  (DEF.metal_layer(p[3], p[4], p[5]), p[6])
    if (len(p) == 6):
        p[0] =  (DEF.placement(p[3], p[4]), p[5])

def p_pin_name(p):
    """
        pin_name    :   VARNAME
                    |   VARNAME     bus_bit

    """
    if (len(p)  ==  3):
        p[0]    =   BusBit(p[1], p[2])
    else:
        p[0]    =   p[1]

def p_bus_bit(p):
    """
    bus_bit     :   LANGLE      INT RANGLE
                |   LBRACKET    INT RBRACKET
    """
    p[0]    =   p[2]

def p_xandy(p):
    """
        xandy   :   LPAREN  INT INT RPAREN
    """
    p[0] = DEF.point(p[2], p[3])

def p_nets_specs(p):
    """
        nets_specs  :   NETS    INT SEMICOLON   nets_mem    END NETS
    """
    p[0] = DEF.design_spec.nets(p[2], p[4])

def p_nets_mem(p):
    """
        nets_mem    :   MINUS  net_name con_pins net_opts   nets_mem
                    |   empty
    """
    if (len(p) == 5):
        p[0] = (DEF.design_spec.nets.net(p[2], p[3], p[4]), p[5])


def p_net_name(p):
    """
        net_name    :   pin_name
                    |   VARNAME
    """
    p[0]    =   p[1]

def p_con_pins(p):
    """
        con_pins    :   con_pin con_pins
                    |   empty
    """
    if (len(p) == 3):
        p[0]    =   (p[1], p[2])

def p_net_opts(p):
    """
        net_opts    :   PLUS    USE SIGNAL  net_opts
                    |   SEMICOLON
    """
    if len(p) == 4:
        p[0] = ((p[2], p[3]), p[4])

def p_con_pin(p):
    """
        con_pin         :   LPAREN  name_and_pin RPAREN
        name_and_pin    :   PIN pin_name
                    |   VARNAME    VARNAME
    """
    if (len(p)  == 4):
        p[0]    =   p[2]
    else:
        if p[1] == 'PIN':
            p[0] = DEF.design_spec.nets.net.port_pin(p[2])
        else:

            p[0] = DEF.design_spec.nets.net.cell_pin(p[1], p[2])

def p_error(p):
    global parser
    token = parser.symstack[-1]
    print(parser.symstack)
    last_cr = lexer.lexdata.rfind('\n',0,token.lexpos)
    if last_cr < 0:
        last_cr = 0
    column = (token.lexpos - last_cr) + 1
    if hasattr(token, 'value'):
        print('SYNTAX ERROR: line ' + str(p.lineno) + ':' + str(column) + ': Unexpected token "' + str(p.value) + '". (Did not expect ' + str(p.type) + ' after token ' + str(token.value) + ')')
    else:
        print('SYNTAX ERROR: line ' + str(p.lineno) + ':' + str(column) + ': Unexpected token "' + str(p.value) + '". (Did not expect ' + str(p.type) + ' at root)')

def p_empty(p):
    '''
    empty :
    '''
    p[0] = None

parser = yacc.yacc()

def defparser():
    return (parser, lexer)

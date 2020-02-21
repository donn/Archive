import re
from collections import Iterable


def get_member(targeted_type, the_list):
    for mem in the_list:
        if type(mem) is targeted_type:
            return mem

def quoteit(the_string):
    return "\"" + the_string + "\""

def isthat_type(item, that_type):
    return type(item) is that_type

def flatten_rec_tuple(recursive_tuple):
    def unpackable(item):
        try:
            head, tail = item
            return True
        except ValueError:
            return False

    def aux(recursive_tuple,acc):
        if not recursive_tuple:
            return acc
        else:
            if unpackable(recursive_tuple):
                head,tail = recursive_tuple
                acc.append(head)
                return aux(tail, acc)
            return recursive_tuple
    return aux(recursive_tuple, [])

def get_txt_before(txt, pattern):
    return re.split(pattern, txt, 1)[0]

def get_word_after(txt, pattern):
    alltxtafter = get_txt_after(txt,pattern)
    return get_txt_before(alltxtafter, r'[\s]*')

def get_txt_after(txt, pattern):
    try:
        x = re.split(pattern, txt, 1)[1]
        return x
    except IndexError:
        return "index error in get_txt_after"

#def print_any(item):
#    def callit_with(func, obj):
#        if callable(obj):
#            func(obj())
#        else:
#            func(obj)
#    try:
#        if type(item) is not str:
#            for ele in item:
#                callit_with(print_any, ele)
#        else:
#            callit_with(print, item)
#    except TypeError:
#        callit_with(print, item)


def write_any(item, file_handler):
    #print("type of obj at hand:", type(item), print(item))
    if item:
        if callable(item):
            write_any(item(), file_handler)
        else:
            if type(item) is str:
                file_handler.write(str(item)+' ')
            else:
                if isinstance(item, Iterable):
                    for ele in item:
                        write_any(ele, file_handler)
                else:
                    if callable(item):
                        write_any(item(), file_handler)
                    else:
                        file_handler.write(str(item)+ ' ')

def print_any(item):
    if item:
        if callable(item):
            print_any(item())
        else:
            if type(item) is str:
                print(str(item)+' ')
            else:
                if isinstance(item, Iterable):
                    for ele in item:
                        #print(type(ele))
                        print_any(ele)
                else:
                    if callable(item):
                        print_any(item())
                    else:
                        print("type is : ", type(item))
                        print(str(item)+ ' ')



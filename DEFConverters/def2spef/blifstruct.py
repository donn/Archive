from base import  RecMemberContainer, OrderedObj
import utils
from modtypes import Input, Output
class BLIF:
    def __init__(self,  models):
        """docstring for __init__"""
        self.models = utils.flatten_rec_tuple(models)
        self.number = len(self.models)

    def __call__(self):
        return self.models[0] # To be CHANGED

    class model(OrderedObj):
        def __init__(self, name, specs):
            self.name = name
            self.specs = specs
        def __call__(self):
            return self.specs

        class spec(OrderedObj, RecMemberContainer):
            def get_type_list(self, blif_element_type,func):
                type_list = []
                for spec in self.members:
                    if type(spec) == blif_element_type:
                        func(type_list, spec)
                return type_list

            #@classmethod
            #def flatten_list_of_lists(cls, the_list):
            #    acc = []
            #    print("the_list", the_list)
            #    for one_list in the_list:
            #        print('it is a list: ', isinstance(one_list, list))
            #        if isinstance(one_list, list):
            #            acc.extend(one_list.members)
            #    print("flatten acc is ", acc)
            #    return acc

            def get_in_ports(self):
                the_list = self.get_type_list( BLIF.model.spec.input_list, list.extend)
                return BLIF.model.spec.input_list(the_list)

            def get_out_ports(self):
                the_list = self.get_type_list(BLIF.model.spec.output_list,list.extend)
                return BLIF.model.spec.output_list(the_list)

            def get_gates(self):
                return self.get_type_list( BLIF.model.spec.gate, list.append)

            class io_list(OrderedObj):
                def __init__(self, members):
                    """docstring for  io_list"""
                    self.members = utils.flatten_rec_tuple(members)

                def __iter__(self):
                    return iter(self.members)

                def __contains__(self, ele_to_find):
                    ele_to_find.isin_iolist(self)

            class input_list(io_list):
                pass
            class output_list(io_list):
                pass

            class gate:
                def __init__(self, name, gate_pins):
                    """docstring for __init__"""
                    self.name = name
                    self.gate_pins = utils.flatten_rec_tuple(gate_pins)

                def __eq__(self, obj):
                    return obj.equate_to_gate(self)

                def get_out_pin(self):
                    for pin in self.gate_pins:
                        if pin.direction is Output:
                            return pin

                def __contains__(self, pin_under_test):
                    return pin_under_test.In_gate(self)

                class pin(OrderedObj):
                    def __init__(self, name, net, direction):
                        self.name = name
                        self.net = net
                        self.direction = direction

            class var:
                def __init__(self, name, value):
                    """docstring for __init__"""
                    self.name = name
                    self.value = value

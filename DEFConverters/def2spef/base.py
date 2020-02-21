import utils


from collections import OrderedDict

class OrderedObj(object):
    def __new__(cls, *args, **kwargs):
        instance = object.__new__(cls)
        instance.__odict__ = OrderedDict()
        return instance

    def __setattr__(self, key, value):
        if key != '__odict__':
            self.__odict__[key] = value
        object.__setattr__(self, key, value)

    def keys(self):
        return self.__odict__.keys()

    def values(self):
        return self.__odict__.values()

    def iteritems(self):
        return self.__odict__.iteritems()

    def __call__(self):
        return tuple(self.__odict__.values())




class RecMemberContainer:
    def __init__(self, members):
        self.members 	= utils.flatten_rec_tuple(members)
    def __call__(self):
        return self.members


# distutils: language = c++

from .njd cimport NJD

cdef extern from "mecab2njd.h" nogil:
    void mecab2njd(NJD * njd, char **feature, int size);

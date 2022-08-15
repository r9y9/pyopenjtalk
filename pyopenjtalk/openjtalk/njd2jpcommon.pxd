# distutils: language = c++
# cython: language_level=3

from pyopenjtalk.openjtalk.jpcommon cimport JPCommon
from pyopenjtalk.openjtalk.njd cimport NJD


cdef extern from "njd2jpcommon.h" nogil:
    void njd2jpcommon(JPCommon * jpcommon, NJD * njd)

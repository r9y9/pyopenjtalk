# coding: utf-8
# cython: boundscheck=True, wraparound=True


import numpy as np

cimport numpy as np
np.import_array()

cimport cython

from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map

from libcpp.cast cimport reinterpret_cast
from libc.stdint cimport uint8_t

from openjtalk.mecab cimport Mecab, Mecab_initialize, Mecab_load, Mecab_analysis
from openjtalk.mecab cimport Mecab_get_feature, Mecab_get_size, Mecab_refresh
from openjtalk.njd cimport NJD, NJD_initialize, NJD_refresh
from openjtalk cimport njd as _njd
from openjtalk.jpcommon cimport JPCommon, JPCommon_initialize,JPCommon_make_label
from openjtalk.jpcommon cimport JPCommon_get_label_size, JPCommon_get_label_feature
from openjtalk.jpcommon cimport JPCommon_refresh
from openjtalk cimport njd2jpcommon
from openjtalk.text2mecab cimport text2mecab
from openjtalk.mecab2njd cimport mecab2njd
from openjtalk.njd2jpcommon cimport njd2jpcommon

cdef class OpenJTalk(object):
    cdef Mecab* mecab
    cdef NJD* njd
    cdef JPCommon* jpcommon

    def __cinit__(self):
        self.mecab = new Mecab()
        self.njd = new NJD()
        self.jpcommon = new JPCommon()

        Mecab_initialize(self.mecab)
        NJD_initialize(self.njd)
        JPCommon_initialize(self.jpcommon)

    def load(self, bytes dn_mecab=None):
        if dn_mecab is None:
            dn_mecab = b"/usr/local/dic"
        cdef int r
        r = Mecab_load(self.mecab, dn_mecab)
        return r

    def run_frontend(self, bytes text):
        cdef char buff[512]
        text2mecab(buff, text)
        Mecab_analysis(self.mecab, buff)
        mecab2njd(self.njd, Mecab_get_feature(self.mecab), Mecab_get_size(self.mecab))
        _njd.njd_set_pronunciation(self.njd)
        _njd.njd_set_digit(self.njd)
        _njd.njd_set_accent_phrase(self.njd)
        _njd.njd_set_accent_type(self.njd)
        _njd.njd_set_unvoiced_vowel(self.njd)
        _njd.njd_set_long_vowel(self.njd)
        njd2jpcommon(self.jpcommon, self.njd)
        JPCommon_make_label(self.jpcommon)

        cdef int label_size = JPCommon_get_label_size(self.jpcommon)
        cdef char** label_feature
        label_feature = JPCommon_get_label_feature(self.jpcommon)
        print(label_size)

        #JPCommon_refresh(self.jpcommon)
        #NJD_refresh(self.njd)
        #Mecab_refresh(self.mecab)

        return label_feature[0]

    def __dealloc__(self):
        del self.mecab
        del self.njd
        del self.jpcommon

    def hello(self):
        print("world")

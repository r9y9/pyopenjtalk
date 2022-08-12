# coding: utf-8
# cython: language_level=3
# cython: boundscheck=False, wraparound=True
# cython: c_string_type=unicode, c_string_encoding=ascii, cdivision=True

from libc.stdint cimport uint8_t
import numpy as np

cimport numpy as np
np.import_array()

cimport cython
from cpython.bytes cimport PyBytes_AS_STRING

from pyopenjtalk.openjtalk.mecab cimport Mecab, Mecab_initialize, Mecab_load, Mecab_analysis
from pyopenjtalk.openjtalk.mecab cimport Mecab_get_feature, Mecab_get_size, Mecab_refresh, Mecab_clear
from pyopenjtalk.openjtalk.njd cimport NJD, NJD_initialize, NJD_refresh, NJD_print, NJD_clear
from pyopenjtalk.openjtalk cimport njd as _njd
from pyopenjtalk.openjtalk.jpcommon cimport JPCommon, JPCommon_initialize,JPCommon_make_label
from pyopenjtalk.openjtalk.jpcommon cimport JPCommon_get_label_size, JPCommon_get_label_feature
from pyopenjtalk.openjtalk.jpcommon cimport JPCommon_refresh, JPCommon_clear
from pyopenjtalk.openjtalk cimport njd2jpcommon
from pyopenjtalk.openjtalk.text2mecab cimport text2mecab
from pyopenjtalk.openjtalk.mecab2njd cimport mecab2njd
from pyopenjtalk.openjtalk.njd2jpcommon cimport njd2jpcommon

cdef inline str njd_node_get_string(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_string(node))).decode("utf-8")

cdef inline str njd_node_get_pos(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos(node))).decode("utf-8")

cdef inline str njd_node_get_pos_group1(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos_group1(node))).decode("utf-8")

cdef inline str njd_node_get_pos_group2(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos_group2(node))).decode("utf-8")

cdef inline str njd_node_get_pos_group3(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos_group3(node))).decode("utf-8")

cdef inline str njd_node_get_ctype(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_ctype(node))).decode("utf-8")

cdef inline  str njd_node_get_cform(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_cform(node))).decode("utf-8")

cdef inline str njd_node_get_orig(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_orig(node))).decode("utf-8")

cdef inline str njd_node_get_read(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_read(node))).decode("utf-8")

cdef inline str njd_node_get_pron(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pron(node))).decode("utf-8")

cdef inline int njd_node_get_acc(_njd.NJDNode* node):
    return _njd.NJDNode_get_acc(node)

cdef inline int njd_node_get_mora_size(_njd.NJDNode* node):
    return _njd.NJDNode_get_mora_size(node)

cdef inline str njd_node_get_chain_rule(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_chain_rule(node))).decode("utf-8")

cdef inline int njd_node_get_chain_flag(_njd.NJDNode* node):
    return _njd.NJDNode_get_chain_flag(node)


cdef inline str njd_node_print(_njd.NJDNode* node):
    return "{},{},{},{},{},{},{},{},{},{},{}/{},{},{}".format(
        njd_node_get_string(node),
        njd_node_get_pos(node),
        njd_node_get_pos_group1(node),
        njd_node_get_pos_group2(node),
        njd_node_get_pos_group3(node),
        njd_node_get_ctype(node),
        njd_node_get_cform(node),
        njd_node_get_orig(node),
        njd_node_get_read(node),
        njd_node_get_pron(node),
        njd_node_get_acc(node),
        njd_node_get_mora_size(node),
        njd_node_get_chain_rule(node),
        njd_node_get_chain_flag(node)
    )


cdef list njd_print(_njd.NJD* njd):
    cdef _njd.NJDNode* node = njd.head
    njd_results = []
    while node is not NULL:
        njd_results.append(njd_node_print(node))
        node = node.next
    return njd_results

@cython.no_gc
@cython.final
@cython.freelist(4)
cdef class OpenJTalk:
    """OpenJTalk

    Args:
        dn_mecab (bytes): Dictionaly path for MeCab.
    """
    cdef Mecab* mecab
    cdef NJD* njd
    cdef JPCommon* jpcommon

    def __cinit__(self, bytes dn_mecab=b"/usr/local/dic"):
        self.mecab = new Mecab()
        self.njd = new NJD()
        self.jpcommon = new JPCommon()

        Mecab_initialize(self.mecab)
        NJD_initialize(self.njd)
        JPCommon_initialize(self.jpcommon)

        r = self._load(dn_mecab)
        if r != 1:
            self._clear()
            raise RuntimeError("Failed to initalize Mecab")

    cpdef inline void _clear(self):
        with nogil:
            Mecab_clear(self.mecab)
            NJD_clear(self.njd)
            JPCommon_clear(self.jpcommon)

    cpdef inline int _load(self, const uint8_t[::1] dn_mecab):
        cdef int ret
        with nogil:
            ret = Mecab_load(self.mecab, <const char*>&dn_mecab[0])
        return ret


    cpdef inline tuple run_frontend(self, object text, int verbose=0):
        """Run OpenJTalk's text processing frontend
        """
        if isinstance(text, str):
            text = text.encode("utf-8")
        cdef:
            char buff[8192]
            const char* text_ptr
            int label_size
            char** label_feature
        text_ptr = PyBytes_AS_STRING(text)
        with nogil:
            text2mecab(buff, text_ptr)
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

            label_size = JPCommon_get_label_size(self.jpcommon)
            label_feature = JPCommon_get_label_feature(self.jpcommon)

        labels = []
        cdef int i
        for i in range(label_size):
            # This will create a copy of c string
            # http://cython.readthedocs.io/en/latest/src/tutorial/strings.html
            labels.append(<unicode>label_feature[i])

        cdef list njd_results = njd_print(self.njd)

        if verbose > 0:
            NJD_print(self.njd)

        # Note that this will release memory for label feature
        with nogil:
            JPCommon_refresh(self.jpcommon)
            NJD_refresh(self.njd)
            Mecab_refresh(self.mecab)
        return njd_results, labels

    def g2p(self, object text, bint kana=False, bint join=True):
        """Grapheme-to-phoeneme (G2P) conversion
        """
        cdef list njd_results, labels
        njd_results, labels = self.run_frontend(text)
        if not kana:
            prons = list(map(lambda s: s.split("-")[1].split("+")[0], labels[1:-1]))
            if join:
                prons = " ".join(prons)
            return prons

        # kana
        prons = []
        for n in njd_results:
            row = n.split(",")
            if row[1] == "記号":
                p = row[0]
            else:
                p = row[9]
            # remove special chars
            for c in "’":
                p = p.replace(c,"")
            prons.append(p)
        if join:
            prons = "".join(prons)
        return prons

    def __dealloc__(self):
        self._clear()
        del self.mecab
        del self.njd
        del self.jpcommon

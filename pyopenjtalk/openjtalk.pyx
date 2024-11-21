# coding: utf-8
# cython: boundscheck=True, wraparound=True
# cython: c_string_type=unicode, c_string_encoding=ascii

from contextlib import contextmanager
from threading import Lock

from libc.stdlib cimport calloc
from libc.string cimport strlen

from .openjtalk.mecab cimport Mecab, Mecab_initialize, Mecab_load, Mecab_analysis
from .openjtalk.mecab cimport Mecab_get_feature, Mecab_get_size, Mecab_refresh, Mecab_clear
from .openjtalk.mecab cimport createModel, Model, Tagger, Lattice
from .openjtalk.mecab cimport mecab_dict_index as _mecab_dict_index
from .openjtalk.njd cimport NJD, NJD_initialize, NJD_refresh, NJD_print, NJD_clear
from .openjtalk cimport njd as _njd
from .openjtalk.jpcommon cimport JPCommon, JPCommon_initialize,JPCommon_make_label
from .openjtalk.jpcommon cimport JPCommon_get_label_size, JPCommon_get_label_feature
from .openjtalk.jpcommon cimport JPCommon_refresh, JPCommon_clear
from .openjtalk.text2mecab cimport text2mecab
from .openjtalk.mecab2njd cimport mecab2njd
from .openjtalk.njd2jpcommon cimport njd2jpcommon

cdef njd_node_get_string(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_string(node))).decode("utf-8")

cdef njd_node_get_pos(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos(node))).decode("utf-8")

cdef njd_node_get_pos_group1(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos_group1(node))).decode("utf-8")

cdef njd_node_get_pos_group2(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos_group2(node))).decode("utf-8")

cdef njd_node_get_pos_group3(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pos_group3(node))).decode("utf-8")

cdef njd_node_get_ctype(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_ctype(node))).decode("utf-8")

cdef njd_node_get_cform(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_cform(node))).decode("utf-8")

cdef njd_node_get_orig(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_orig(node))).decode("utf-8")

cdef njd_node_get_read(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_read(node))).decode("utf-8")

cdef njd_node_get_pron(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_pron(node))).decode("utf-8")

cdef int njd_node_get_acc(_njd.NJDNode* node) noexcept:
    return _njd.NJDNode_get_acc(node)

cdef int njd_node_get_mora_size(_njd.NJDNode* node) noexcept:
    return _njd.NJDNode_get_mora_size(node)

cdef njd_node_get_chain_rule(_njd.NJDNode* node):
    return (<bytes>(_njd.NJDNode_get_chain_rule(node))).decode("utf-8")

cdef int njd_node_get_chain_flag(_njd.NJDNode* node) noexcept:
    return _njd.NJDNode_get_chain_flag(node)


cdef node2feature(_njd.NJDNode* node):
    return {
        "string": njd_node_get_string(node),
        "pos": njd_node_get_pos(node),
        "pos_group1": njd_node_get_pos_group1(node),
        "pos_group2": njd_node_get_pos_group2(node),
        "pos_group3": njd_node_get_pos_group3(node),
        "ctype": njd_node_get_ctype(node),
        "cform": njd_node_get_cform(node),
        "orig": njd_node_get_orig(node),
        "read": njd_node_get_read(node),
        "pron": njd_node_get_pron(node),
        "acc": njd_node_get_acc(node),
        "mora_size": njd_node_get_mora_size(node),
        "chain_rule": njd_node_get_chain_rule(node),
        "chain_flag": njd_node_get_chain_flag(node),
    }


cdef njd2feature(_njd.NJD* njd):
    cdef _njd.NJDNode* node = njd.head
    features = []
    while node is not NULL:
        features.append(node2feature(node))
        node = node.next
    return features


cdef void feature2njd(_njd.NJD* njd, features):
    cdef _njd.NJDNode* node

    for feature_node in features:
        node = <_njd.NJDNode *> calloc(1, sizeof(_njd.NJDNode))
        _njd.NJDNode_initialize(node)
        # set values
        _njd.NJDNode_set_string(node, feature_node["string"].encode("utf-8"))
        _njd.NJDNode_set_pos(node, feature_node["pos"].encode("utf-8"))
        _njd.NJDNode_set_pos_group1(node, feature_node["pos_group1"].encode("utf-8"))
        _njd.NJDNode_set_pos_group2(node, feature_node["pos_group2"].encode("utf-8"))
        _njd.NJDNode_set_pos_group3(node, feature_node["pos_group3"].encode("utf-8"))
        _njd.NJDNode_set_ctype(node, feature_node["ctype"].encode("utf-8"))
        _njd.NJDNode_set_cform(node, feature_node["cform"].encode("utf-8"))
        _njd.NJDNode_set_orig(node, feature_node["orig"].encode("utf-8"))
        _njd.NJDNode_set_read(node, feature_node["read"].encode("utf-8"))
        _njd.NJDNode_set_pron(node, feature_node["pron"].encode("utf-8"))
        _njd.NJDNode_set_acc(node, feature_node["acc"])
        _njd.NJDNode_set_mora_size(node, feature_node["mora_size"])
        _njd.NJDNode_set_chain_rule(node, feature_node["chain_rule"].encode("utf-8"))
        _njd.NJDNode_set_chain_flag(node, feature_node["chain_flag"])
        _njd.NJD_push_node(njd, node)

# based on Mecab_load in impl. from mecab.cpp
cdef inline int Mecab_load_with_userdic(Mecab *m, char* dicdir, char* userdic) noexcept nogil:
    if userdic == NULL or strlen(userdic) == 0:
        return Mecab_load(m, dicdir)

    if m == NULL or dicdir == NULL or strlen(dicdir) == 0:
        return 0

    Mecab_clear(m)

    cdef (char*)[5] argv = ["mecab", "-d", dicdir, "-u", userdic]
    cdef Model *model = createModel(5, argv)

    if model == NULL:
        return 0
    m.model = model

    cdef Tagger *tagger = model.createTagger()
    if tagger == NULL:
        Mecab_clear(m)
        return 0
    m.tagger = tagger

    cdef Lattice *lattice = model.createLattice()
    if lattice == NULL:
        Mecab_clear(m)
        return 0
    m.lattice = lattice

    return 1

def _generate_lock_manager():
    lock = Lock()

    @contextmanager
    def f():
        with lock:
            yield

    return f


cdef class OpenJTalk(object):
    """OpenJTalk

    Args:
        dn_mecab (bytes): Dictionaly path for MeCab.
        userdic (bytes): Dictionary path for MeCab userdic.
            This option is ignored when empty bytestring is given.
            Default is empty.
    """
    cdef Mecab* mecab
    cdef NJD* njd
    cdef JPCommon* jpcommon
    _lock_manager = _generate_lock_manager()

    def __cinit__(self, bytes dn_mecab=b"/usr/local/dic", bytes userdic=b""):
        cdef char* _dn_mecab = dn_mecab
        cdef char* _userdic = userdic

        self.mecab = new Mecab()
        self.njd = new NJD()
        self.jpcommon = new JPCommon()

        with nogil:
            Mecab_initialize(self.mecab)
            NJD_initialize(self.njd)
            JPCommon_initialize(self.jpcommon)

            r = self._load(_dn_mecab, _userdic)
            if r != 1:
                self._clear()
                raise RuntimeError("Failed to initalize Mecab")

    cdef void _clear(self) noexcept nogil:
        Mecab_clear(self.mecab)
        NJD_clear(self.njd)
        JPCommon_clear(self.jpcommon)

    cdef int _load(self, char* dn_mecab, char* userdic) noexcept nogil:
        return Mecab_load_with_userdic(self.mecab, dn_mecab, userdic)

    @_lock_manager()
    def run_frontend(self, text):
        """Run OpenJTalk's text processing frontend
        """
        cdef char buff[8192]

        if isinstance(text, str):
            text = text.encode("utf-8")
        cdef const char* _text = text
        with nogil:
            text2mecab(buff, _text)
            Mecab_analysis(self.mecab, buff)
            mecab2njd(self.njd, Mecab_get_feature(self.mecab), Mecab_get_size(self.mecab))
            _njd.njd_set_pronunciation(self.njd)
            _njd.njd_set_digit(self.njd)
            _njd.njd_set_accent_phrase(self.njd)
            _njd.njd_set_accent_type(self.njd)
            _njd.njd_set_unvoiced_vowel(self.njd)
            _njd.njd_set_long_vowel(self.njd)
        features = njd2feature(self.njd)

        # Note that this will release memory for njd feature
        NJD_refresh(self.njd)
        Mecab_refresh(self.mecab)

        return features

    @_lock_manager()
    def make_label(self, features):
        """Make full-context label
        """
        feature2njd(self.njd, features)
        with nogil:
            njd2jpcommon(self.jpcommon, self.njd)

            JPCommon_make_label(self.jpcommon)

            label_size = JPCommon_get_label_size(self.jpcommon)
            label_feature = JPCommon_get_label_feature(self.jpcommon)

        labels = []
        for i in range(label_size):
            # This will create a copy of c string
            # http://cython.readthedocs.io/en/latest/src/tutorial/strings.html
            labels.append(<unicode>label_feature[i])

        # Note that this will release memory for label feature
        JPCommon_refresh(self.jpcommon)
        NJD_refresh(self.njd)

        return labels

    def g2p(self, text, kana=False, join=True):
        """Grapheme-to-phoeneme (G2P) conversion
        """
        njd_features = self.run_frontend(text)

        if not kana:
            labels = self.make_label(njd_features)
            prons = list(map(lambda s: s.split("-")[1].split("+")[0], labels[1:-1]))
            if join:
                prons = " ".join(prons)
            return prons

        # kana
        prons = []
        for n in njd_features:
            if n["pos"] == "記号":
                p = n["string"]
            else:
                p = n["pron"]
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

def mecab_dict_index(bytes dn_mecab, bytes path, bytes out_path):
    cdef (char*)[10] argv = [
        "mecab-dict-index",
        "-d",
        dn_mecab,
        "-u",
        out_path,
        "-f",
        "utf-8",
        "-t",
        "utf-8",
        path
    ]
    cdef int ret
    with nogil:
        ret = _mecab_dict_index(10, argv)
    return ret

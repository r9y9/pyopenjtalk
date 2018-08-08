# distutils: language = c++

from libc.stdint cimport uint32_t
from libcpp cimport bool
from libcpp.string cimport string
from libcpp.map cimport map
from libc.stdio cimport FILE

cdef extern from "openjtalk/njd.h":
    cdef cppclass NJDNode:
        char *string;
        char *pos;
        char *pos_group1;
        char *pos_group2;
        char *pos_group3;
        char *ctype;
        char *cform;
        char *orig;
        char *read;
        char *pron;
        int acc;
        int mora_size;
        char *chain_rule;
        int chain_flag;
        void *prev;
        void *next;

    cdef cppclass NJD:
        NJDNode *head
        NJDNode *tail

    void NJD_initialize(NJD * njd);
    void NJD_load(NJD * njd, const char *str);
    void NJD_load_from_fp(NJD * njd, FILE * fp);
    int NJD_get_size(NJD * njd);
    void NJD_push_node(NJD * njd, NJDNode * node);
    void NJD_remove_silent_node(NJD * njd);
    void NJD_print(NJD * njd);
    void NJD_fprint(NJD * njd, FILE * fp);
    void NJD_sprint(NJD * njd, char *buff, const char *split_code);
    void NJD_refresh(NJD * njd);
    void NJD_clear(NJD * wl);

cdef extern from "openjtalk/njd_set_accent_phrase.h":
    void njd_set_accent_phrase(NJD * njd);

cdef extern from "openjtalk/njd_set_accent_type.h":
    void njd_set_accent_type(NJD * njd);

cdef extern from "openjtalk/njd_set_digit.h":
    void njd_set_digit(NJD * njd);

cdef extern from "openjtalk/njd_set_long_vowel.h":
    void njd_set_long_vowel(NJD * njd);

cdef extern from "openjtalk/njd_set_pronunciation.h":
    void njd_set_pronunciation(NJD * njd);

cdef extern from "openjtalk/njd_set_unvoiced_vowel.h":
    void njd_set_unvoiced_vowel(NJD * njd);

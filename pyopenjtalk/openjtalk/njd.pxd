# distutils: language = c++

from libc.stdio cimport FILE

cdef extern from "openjtalk/njd.h":
    cdef cppclass NJDNode:
        char *string
        char *pos
        char *pos_group1
        char *pos_group2
        char *pos_group3
        char *ctype
        char *cform
        char *orig
        char *read
        char *pron
        int acc
        int mora_size
        char *chain_rule
        int chain_flag
        NJDNode *prev
        NJDNode *next

    void NJDNode_initialize(NJDNode * node)
    void NJDNode_set_string(NJDNode * node, const char *str)
    void NJDNode_set_pos(NJDNode * node, const char *str)
    void NJDNode_set_pos_group1(NJDNode * node, const char *str)
    void NJDNode_set_pos_group2(NJDNode * node, const char *str)
    void NJDNode_set_pos_group3(NJDNode * node, const char *str)
    void NJDNode_set_ctype(NJDNode * node, const char *str)
    void NJDNode_set_cform(NJDNode * node, const char *str)
    void NJDNode_set_orig(NJDNode * node, const char *str)
    void NJDNode_set_read(NJDNode * node, const char *str)
    void NJDNode_set_pron(NJDNode * node, const char *str)
    void NJDNode_set_acc(NJDNode * node, int acc)
    void NJDNode_set_mora_size(NJDNode * node, int size)
    void NJDNode_set_chain_rule(NJDNode * node, const char *str)
    void NJDNode_set_chain_flag(NJDNode * node, int flag)
    void NJDNode_add_read(NJDNode * node, const char *str)
    void NJDNode_add_pron(NJDNode * node, const char *str)
    void NJDNode_add_acc(NJDNode * node, int acc)
    void NJDNode_add_mora_size(NJDNode * node, int size)
    const char *NJDNode_get_string(NJDNode * node)
    const char *NJDNode_get_pos(NJDNode * node)
    const char *NJDNode_get_pos_group1(NJDNode * node)
    const char *NJDNode_get_pos_group2(NJDNode * node)
    const char *NJDNode_get_pos_group3(NJDNode * node)
    const char *NJDNode_get_ctype(NJDNode * node)
    const char *NJDNode_get_cform(NJDNode * node)
    const char *NJDNode_get_orig(NJDNode * node)
    const char *NJDNode_get_read(NJDNode * node)
    const char *NJDNode_get_pron(NJDNode * node)
    int NJDNode_get_acc(NJDNode * node)
    int NJDNode_get_mora_size(NJDNode * node)
    const char *NJDNode_get_chain_rule(NJDNode * node)
    int NJDNode_get_chain_flag(NJDNode * node)
    void NJDNode_load(NJDNode * node, const char *str)
    NJDNode *NJDNode_insert(NJDNode * prev, NJDNode * next, NJDNode * node)
    void NJDNode_copy(NJDNode * node1, NJDNode * node2)
    void NJDNode_print(NJDNode * node)
    void NJDNode_fprint(NJDNode * node, FILE * fp)
    void NJDNode_sprint(NJDNode * node, char *buff, const char *split_code)
    void NJDNode_clear(NJDNode * node)

    cdef cppclass NJD:
        NJDNode *head
        NJDNode *tail

    void NJD_initialize(NJD * njd)
    void NJD_load(NJD * njd, const char *str)
    void NJD_load_from_fp(NJD * njd, FILE * fp)
    int NJD_get_size(NJD * njd)
    void NJD_push_node(NJD * njd, NJDNode * node)
    void NJD_remove_silent_node(NJD * njd)
    void NJD_print(NJD * njd)
    void NJD_fprint(NJD * njd, FILE * fp)
    void NJD_sprint(NJD * njd, char *buff, const char *split_code)
    void NJD_refresh(NJD * njd)
    void NJD_clear(NJD * wl)

cdef extern from "openjtalk/njd_set_accent_phrase.h":
    void njd_set_accent_phrase(NJD * njd)

cdef extern from "openjtalk/njd_set_accent_type.h":
    void njd_set_accent_type(NJD * njd)

cdef extern from "openjtalk/njd_set_digit.h":
    void njd_set_digit(NJD * njd)

cdef extern from "openjtalk/njd_set_long_vowel.h":
    void njd_set_long_vowel(NJD * njd)

cdef extern from "openjtalk/njd_set_pronunciation.h":
    void njd_set_pronunciation(NJD * njd)

cdef extern from "openjtalk/njd_set_unvoiced_vowel.h":
    void njd_set_unvoiced_vowel(NJD * njd)

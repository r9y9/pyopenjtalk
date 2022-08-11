# distutils: language = c++

from libc.stdio cimport FILE

cdef extern from "jpcommon.h" nogil:
    cdef cppclass JPCommonNode:
        char *pron
        char *pos
        char *ctype
        char *cform
        int acc
        int chain_flag
        void *prev
        void *next

    cdef cppclass JPCommon:
        JPCommonNode *head
        JPCommonNode *tail
        void *label

    void JPCommon_initialize(JPCommon * jpcommon)
    void JPCommon_push(JPCommon * jpcommon, JPCommonNode * node)
    void JPCommon_make_label(JPCommon * jpcommon)
    int JPCommon_get_label_size(JPCommon * jpcommon)
    char **JPCommon_get_label_feature(JPCommon * jpcommon)
    void JPCommon_print(JPCommon * jpcommon)
    void JPCommon_fprint(JPCommon * jpcommon, FILE * fp)
    void JPCommon_refresh(JPCommon * jpcommon)
    void JPCommon_clear(JPCommon * jpcommon)

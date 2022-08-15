# distutils: language = c++
# cython: language_level=3

cdef extern from "mecab.h" nogil:
    cdef cppclass Mecab:
        char **feature
        int size
        void *model
        void *tagger
        void *lattice

    cdef int Mecab_initialize(Mecab *m)
    cdef int Mecab_load(Mecab *m, const char *dicdir)
    cdef int Mecab_analysis(Mecab *m, const char *str)
    cdef int Mecab_print(Mecab *m)
    int Mecab_get_size(Mecab *m)
    char **Mecab_get_feature(Mecab *m)
    cdef int Mecab_refresh(Mecab *m)
    cdef int Mecab_clear(Mecab *m)

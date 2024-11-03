# distutils: language = c++

cdef extern from "mecab.h":
    cdef cppclass Mecab:
        char **feature
        int size
        void *model
        void *tagger
        void *lattice

    cdef int Mecab_initialize(Mecab *m) nogil
    cdef int Mecab_load(Mecab *m, const char *dicdir) nogil
    cdef int Mecab_analysis(Mecab *m, const char *str) nogil
    cdef int Mecab_print(Mecab *m)
    int Mecab_get_size(Mecab *m) nogil
    char **Mecab_get_feature(Mecab *m) nogil
    cdef int Mecab_refresh(Mecab *m) nogil
    cdef int Mecab_clear(Mecab *m) nogil
    cdef int mecab_dict_index(int argc, char **argv) nogil

cdef extern from "mecab.h" namespace "MeCab":
    cdef cppclass Tagger:
        pass
    cdef cppclass Lattice:
        pass
    cdef cppclass Model:
        Tagger *createTagger() nogil
        Lattice *createLattice() nogil
    cdef Model *createModel(int argc, char **argv) nogil

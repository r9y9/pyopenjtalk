# distutils: language = c++
# cython: language_level=3

cdef extern from "text2mecab.h" nogil:
    void text2mecab(char *output, const char *input)

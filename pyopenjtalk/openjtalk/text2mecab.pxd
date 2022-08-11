# distutils: language = c++

cdef extern from "text2mecab.h" nogil:
    void text2mecab(char *output, const char *input)

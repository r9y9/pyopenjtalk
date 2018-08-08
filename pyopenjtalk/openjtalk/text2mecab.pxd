# distutils: language = c++

cdef extern from "openjtalk/text2mecab.h":
    void text2mecab(char *output, const char *input)

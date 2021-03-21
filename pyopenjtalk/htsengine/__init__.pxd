# distutils: language = c++


cdef extern from "HTS_engine.h":
    cdef cppclass _HTS_Engine:
        pass
    ctypedef _HTS_Engine HTS_Engine

    void HTS_Engine_initialize(HTS_Engine * engine)
    char HTS_Engine_load(HTS_Engine * engine, char **voices, size_t num_voices)
    size_t HTS_Engine_get_sampling_frequency(HTS_Engine * engine)
    size_t HTS_Engine_get_fperiod(HTS_Engine * engine)
    void HTS_Engine_refresh(HTS_Engine * engine)
    void HTS_Engine_clear(HTS_Engine * engine)
    const char *HTS_Engine_get_fullcontext_label_format(HTS_Engine * engine)
    char HTS_Engine_synthesize_from_strings(HTS_Engine * engine, char **lines, size_t num_lines)
    char HTS_Engine_synthesize_from_fn(HTS_Engine * engine, const char *fn)
    double HTS_Engine_get_generated_speech(HTS_Engine * engine, size_t index)
    size_t HTS_Engine_get_nsamples(HTS_Engine * engine)
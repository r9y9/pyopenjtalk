# coding: utf-8
# cython: language_level=3
# cython: boundscheck=False, wraparound=False
# cython: c_string_type=unicode, c_string_encoding=ascii, cdivision=True

import numpy as np

cimport numpy as np

np.import_array()

cimport cython
from cpython.mem cimport PyMem_Free, PyMem_Malloc
from cython.parallel cimport prange
from libc.stdint cimport uint8_t

from pyopenjtalk.htsengine cimport (HTS_Engine, HTS_Engine_add_half_tone,
                                    HTS_Engine_clear, HTS_Engine_get_fperiod,
                                    HTS_Engine_get_generated_speech,
                                    HTS_Engine_get_nsamples,
                                    HTS_Engine_get_sampling_frequency,
                                    HTS_Engine_initialize, HTS_Engine_load,
                                    HTS_Engine_refresh, HTS_Engine_set_speed,
                                    HTS_Engine_synthesize_from_strings)


@cython.final
@cython.no_gc
@cython.freelist(4)
cdef class HTSEngine:
    """HTSEngine

    Args:
        voice (bytes): File path of htsvoice.
    """
    cdef HTS_Engine* engine

    def __cinit__(self, bytes voice=b"htsvoice/mei_normal.htsvoice"):
        self.engine = new HTS_Engine()

        HTS_Engine_initialize(self.engine)

        if self.load(voice) != 1:
          self.clear()
          raise RuntimeError("Failed to initalize HTS_Engine")

    cpdef inline char load(self, const uint8_t[::1] voice):
        cdef:
            char ret
            const uint8_t *voice_ptr = &voice[0]
        with nogil:
            ret = HTS_Engine_load(self.engine, <char**>(&voice_ptr), 1)
        return ret

    cpdef inline size_t get_sampling_frequency(self):
        """Get sampling frequency
        """
        cdef size_t ret
        with nogil:
            ret = HTS_Engine_get_sampling_frequency(self.engine)
        return ret

    cpdef inline size_t get_fperiod(self):
        """Get frame period"""
        cdef size_t ret
        with nogil:
            ret = HTS_Engine_get_fperiod(self.engine)
        return ret

    cpdef inline void set_speed(self, double speed=1.0):
        """Set speed

        Args:
            speed (float): speed
        """
        with nogil:
            HTS_Engine_set_speed(self.engine, speed)

    cpdef inline void add_half_tone(self, double half_tone=0.0):
        """Additional half tone in log-f0

        Args:
            half_tone (float): additional half tone
        """
        with nogil:
            HTS_Engine_add_half_tone(self.engine, half_tone)

    cpdef inline np.ndarray[np.float64_t, ndim=1] synthesize(self, list labels):
        """Synthesize waveform from list of full-context labels

        Args:
            labels: full context labels

        Returns:
            np.ndarray: speech waveform
        """
        self.synthesize_from_strings(labels)
        cdef np.ndarray[np.float64_t, ndim=1] x = self.get_generated_speech()
        self.refresh()
        return x

    cpdef inline char synthesize_from_strings(self, list labels) except? 0:
        """Synthesize from strings"""
        cdef size_t num_lines = len(labels)
        cdef char **lines = <char**> PyMem_Malloc((num_lines + 1) * sizeof(char*))
        cdef int n
        for n in range(len(labels)):
            lines[n] = <char*>labels[n]
        cdef char ret
        with nogil:
            ret = HTS_Engine_synthesize_from_strings(self.engine, lines, num_lines)
        PyMem_Free(lines) # todo: use finally
        if ret != 1:
            raise RuntimeError("Failed to run synthesize_from_strings")
        return ret

    cpdef inline np.ndarray[np.float64_t, ndim=1] get_generated_speech(self):
        """Get generated speech"""
        cdef size_t nsamples = HTS_Engine_get_nsamples(self.engine)
        cdef np.ndarray[np.float64_t, ndim=1] speech = np.zeros([nsamples], dtype=np.float64)
        cdef double[::1] speech_view = speech
        cdef int index
        for index in prange(nsamples, nogil=True):
            speech_view[index] = HTS_Engine_get_generated_speech(self.engine, <size_t>index)
        return speech

    cpdef inline str get_fullcontext_label_format(self):
        """Get full-context label format"""
        cdef const char* f
        with nogil:
            f = HTS_Engine_get_fullcontext_label_format(self.engine)
        return (<bytes>f).decode("utf-8")

    cpdef inline void refresh(self):
        with nogil:
            HTS_Engine_refresh(self.engine)

    cpdef inline void clear(self):
        with nogil:
            HTS_Engine_clear(self.engine)

    def __dealloc__(self):
        self.clear()
        del self.engine

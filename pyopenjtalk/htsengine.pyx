# coding: utf-8
# cython: boundscheck=True, wraparound=True
# cython: c_string_type=unicode, c_string_encoding=ascii

import numpy as np

cimport numpy as np
np.import_array()

cimport cython
from libc.stdlib cimport malloc, free

from .htsengine cimport HTS_Engine
from .htsengine cimport (
    HTS_Engine_initialize, HTS_Engine_load, HTS_Engine_clear, HTS_Engine_refresh,
    HTS_Engine_get_sampling_frequency, HTS_Engine_get_fperiod,
    HTS_Engine_set_speed, HTS_Engine_add_half_tone,
    HTS_Engine_synthesize_from_strings,
    HTS_Engine_get_generated_speech, HTS_Engine_get_nsamples
)

cdef class HTSEngine(object):
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

    def load(self, bytes voice):
        cdef char* voices = voice
        cdef char ret
        with nogil:
            ret = HTS_Engine_load(self.engine, &voices, 1)
        return ret

    def get_sampling_frequency(self):
        """Get sampling frequency
        """
        return HTS_Engine_get_sampling_frequency(self.engine)

    def get_fperiod(self):
        """Get frame period"""
        return HTS_Engine_get_fperiod(self.engine)

    def set_speed(self, speed=1.0):
        """Set speed

        Args:
            speed (float): speed
        """
        HTS_Engine_set_speed(self.engine, speed)

    def add_half_tone(self, half_tone=0.0):
        """Additional half tone in log-f0

        Args:
            half_tone (float): additional half tone
        """
        HTS_Engine_add_half_tone(self.engine, half_tone)

    def synthesize(self, list labels):
        """Synthesize waveform from list of full-context labels

        Args:
            labels: full context labels

        Returns:
            np.ndarray: speech waveform
        """
        self.synthesize_from_strings(labels)
        x = self.get_generated_speech()
        self.refresh()
        return x

    def synthesize_from_strings(self, list labels):
        """Synthesize from strings"""
        cdef size_t num_lines = len(labels)
        cdef char **lines = <char**> malloc((num_lines + 1) * sizeof(char*))
        for n in range(num_lines):
            lines[n] = <char*>labels[n]

        cdef char ret
        with nogil:
            ret = HTS_Engine_synthesize_from_strings(self.engine, lines, num_lines)
            free(lines)
        if ret != 1:
            raise RuntimeError("Failed to run synthesize_from_strings")

    def get_generated_speech(self):
        """Get generated speech"""
        cdef size_t nsamples = HTS_Engine_get_nsamples(self.engine)
        cdef np.ndarray speech = np.empty([nsamples], dtype=np.float64)
        cdef double[:] speech_view = speech
        cdef size_t index
        with (nogil, cython.boundscheck(False)):
            for index in range(nsamples):
                speech_view[index] = HTS_Engine_get_generated_speech(self.engine, index)
        return speech

    def get_fullcontext_label_format(self):
        """Get full-context label format"""
        return (<bytes>HTS_Engine_get_fullcontext_label_format(self.engine)).decode("utf-8")

    def refresh(self):
        HTS_Engine_refresh(self.engine)

    def clear(self):
        HTS_Engine_clear(self.engine)

    def __dealloc__(self):
        self.clear()
        del self.engine

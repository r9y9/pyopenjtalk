import numpy as np
import pyopenjtalk


def test_tts():
    x, sr = pyopenjtalk.tts("こんちゃっす")
    assert x.dtype == np.float64
    assert sr == 48000


def test_htsengine():
    labels = pyopenjtalk.extract_fullcontext("こんちゃ")
    x, sr = pyopenjtalk.synthesize(labels)
    assert x.dtype == np.float64
    assert sr == 48000


def test_htsengine_pip():
    x, sr = pyopenjtalk.synthesize(pyopenjtalk.extract_fullcontext("こんちゃ"))
    assert x.dtype == np.float64
    assert sr == 48000

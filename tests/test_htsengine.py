import numpy as np
import pyopenjtalk


def test_tts():
    x, sr = pyopenjtalk.tts("こんちゃっす")
    assert x.dtype == np.float64
    assert sr == 48000


def test_htsengine():
    _, labels = pyopenjtalk.run_frontend("こんちゃ")
    x, sr = pyopenjtalk.run_backend(labels)
    assert x.dtype == np.float64
    assert sr == 48000

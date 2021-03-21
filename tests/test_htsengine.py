import numpy as np
import pyopenjtalk


def test_tts():
    x, sr = pyopenjtalk.tts("こんちゃっす")
    assert x.dtype == np.float64
    assert sr == 48000


def test_tts_speed():
    x, sr = pyopenjtalk.tts("こんちゃっす")

    x_fast, sr = pyopenjtalk.tts("こんちゃっす", speed=1.5)
    assert len(x) > len(x_fast)

    x_slow, sr = pyopenjtalk.tts("こんちゃっす", speed=0.5)
    assert len(x_slow) > len(x)


def test_tts_half_tone():
    x, sr = pyopenjtalk.tts("こんちゃっす")

    # +2
    x_high, _ = pyopenjtalk.tts("こんちゃっす", half_tone=2)
    # -2
    x_low, _ = pyopenjtalk.tts("こんちゃっす", half_tone=-2)

    # half_tone should not change durations
    assert len(x) == len(x_high) == len(x_low)


def test_htsengine():
    labels = pyopenjtalk.extract_fullcontext("こんちゃ")
    x, sr = pyopenjtalk.synthesize(labels)
    assert x.dtype == np.float64
    assert sr == 48000


def test_htsengine_pipe():
    x, sr = pyopenjtalk.synthesize(pyopenjtalk.extract_fullcontext("こんちゃ"))
    assert x.dtype == np.float64
    assert sr == 48000

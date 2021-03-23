import os
from os.path import exists

import pkg_resources
import six

if six.PY2:
    from urllib import urlretrieve
else:
    from urllib.request import urlretrieve

import tarfile

try:
    from .version import __version__  # NOQA
except ImportError:
    raise ImportError("BUG: version.py doesn't exist. Please file a bug report.")

from .htsengine import HTSEngine
from .openjtalk import OpenJTalk

# Dictionary directory
# defaults to the package directory where the dictionary will be automatically downloaded
OPEN_JTALK_DICT_DIR = os.environ.get(
    "OPEN_JTALK_DICT_DIR",
    pkg_resources.resource_filename(__name__, "open_jtalk_dic_utf_8-1.11"),
).encode("ascii")
_DICT_URL = (
    "https://downloads.sourceforge.net/open-jtalk/open_jtalk_dic_utf_8-1.11.tar.gz"
)

# Default mei_normal.voice for HMM-based TTS
DEFAULT_HTS_VOICE = pkg_resources.resource_filename(
    __name__, "htsvoice/mei_normal.htsvoice"
).encode("ascii")

# Global instance of OpenJTalk
_global_jtalk = None
# Global instance of HTSEngine
# mei_normal.voice is used as default
_global_htsengine = None


def _extract_dic():
    global OPEN_JTALK_DICT_DIR
    filename = pkg_resources.resource_filename(__name__, "dic.tar.gz")
    print('Downloading: "{}"'.format(_DICT_URL))
    urlretrieve(_DICT_URL, filename)
    print("Extracting tar file {}".format(filename))
    with tarfile.open(filename, mode="r|gz") as f:
        f.extractall(path=pkg_resources.resource_filename(__name__, ""))
    OPEN_JTALK_DICT_DIR = pkg_resources.resource_filename(
        __name__, "open_jtalk_dic_utf_8-1.11"
    ).encode("ascii")
    os.remove(filename)


def _lazy_init():
    if not exists(OPEN_JTALK_DICT_DIR):
        _extract_dic()


def g2p(*args, **kwargs):
    """Grapheme-to-phoeneme (G2P) conversion

    This is just a convenient wrapper around `run_frontend`.

    Args:
        text (str): Unicode Japanese text.
        kana (bool): If True, returns the pronunciation in katakana, otherwise in phone.
          Default is False.
        join (bool): If True, concatenate phones or katakana's into a single string.
          Default is True.

    Returns:
        str or list: G2P result in 1) str if join is True 2) list if join is False.
    """
    global _global_jtalk
    if _global_jtalk is None:
        _lazy_init()
        _global_jtalk = OpenJTalk(dn_mecab=OPEN_JTALK_DICT_DIR)
    return _global_jtalk.g2p(*args, **kwargs)


def extract_fullcontext(text):
    """Extract full-context labels from text

    Args:
        text (str): Input text

    Returns:
        list: List of full-context labels
    """
    # note: drop first return
    _, labels = run_frontend(text)
    return labels


def synthesize(labels, speed=1.0, half_tone=0.0):
    """Run OpenJTalk's speech synthesis backend

    Args:
        labels (list): Full-context labels
        speed (float): speech speed rate. Default is 1.0.
        half_tone (float): additional half-tone. Default is 0.

    Returns:
        np.ndarray: speech waveform (dtype: np.float64)
        int: sampling frequency (defualt: 48000)
    """
    if isinstance(labels, tuple) and len(labels) == 2:
        labels = labels[1]

    global _global_htsengine
    if _global_htsengine is None:
        _global_htsengine = HTSEngine(DEFAULT_HTS_VOICE)
    sr = _global_htsengine.get_sampling_frequency()
    _global_htsengine.set_speed(speed)
    _global_htsengine.add_half_tone(half_tone)
    return _global_htsengine.synthesize(labels), sr


def tts(text, speed=1.0, half_tone=0.0):
    """Text-to-speech

    Args:
        text (str): Input text
        speed (float): speech speed rate. Default is 1.0.
        half_tone (float): additional half-tone. Default is 0.

    Returns:
        np.ndarray: speech waveform (dtype: np.float64)
        int: sampling frequency (defualt: 48000)
    """
    return synthesize(extract_fullcontext(text), speed, half_tone)


def run_frontend(text, verbose=0):
    """Run OpenJTalk's text processing frontend

    Args:
        text (str): Unicode Japanese text.
        verbose (int): Verbosity. Default is 0.

    Returns:
        tuple: Pair of 1) NJD_print and 2) JPCommon_make_label.
        The latter is the full-context labels in HTS-style format.
    """
    global _global_jtalk
    if _global_jtalk is None:
        _lazy_init()
        _global_jtalk = OpenJTalk(dn_mecab=OPEN_JTALK_DICT_DIR)
    return _global_jtalk.run_frontend(text, verbose)

# coding: utf-8

from __future__ import division, print_function, absolute_import

import pkg_resources
from os.path import exists
import os
import six
if six.PY2:
    from urllib import urlretrieve
else:
    from urllib.request import urlretrieve
import tarfile

try:
    from .version import __version__
except ImportError:
    raise ImportError("BUG: version.py doesn't exist. Please file a bug report.")

from .openjtalk import OpenJTalk

# Dictionary directory
# defaults to the package directory where the dictionary will be automatically downloaded
OPEN_JTALK_DICT_DIR = os.environ.get(
    "OPEN_JTALK_DICT_DIR", pkg_resources.resource_filename(
        __name__, "open_jtalk_dic_utf_8-1.10")).encode("ascii")
_DICT_URL = "https://downloads.sourceforge.net/open-jtalk/open_jtalk_dic_utf_8-1.10.tar.gz"

# Global instance of OpenJTalk
_global_jtalk = None


def _extract_dic():
    global OPEN_JTALK_DICT_DIR
    filename = pkg_resources.resource_filename(__name__, "dic.tar.gz")
    print('Downloading: "{}"'.format(_DICT_URL))
    urlretrieve(_DICT_URL, filename)
    print('Extracting tar file {}'.format(filename))
    with tarfile.open(filename, mode="r|gz") as f:
        f.extractall(path=pkg_resources.resource_filename(__name__, ""))
    OPEN_JTALK_DICT_DIR = pkg_resources.resource_filename(
        __name__, "open_jtalk_dic_utf_8-1.10").encode("ascii")
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


def run_frontend(*args, **kwargs):
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
    return _global_jtalk.run_frontend(*args, **kwargs)

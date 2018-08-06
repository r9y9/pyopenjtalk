# coding: utf-8

from __future__ import division, print_function, absolute_import

import pkg_resources
import tempfile
import subprocess
from os.path import join, dirname
import os

__version__ = pkg_resources.get_distribution('pyopenjtalk').version

# htsvoice_path = join(dirname(__file__), "htsvoice/mei_normal.htsvoice")
htsvoice_path = pkg_resources.resource_filename(__name__, "htsvoice/mei_normal.htsvoice")
dict_path = "/usr/local/dic"


def openjtalk(text, cleanup=True):
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".txt", delete=False) as f:
        f.write(text)
        text_path = f.name

    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".wav") as f:
        wav_path = f.name

    with tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".trace") as f:
        trace_path = f.name

    cmd = ["/usr/local/bin/open_jtalk", "-m", htsvoice_path, "-x", dict_path,
           text_path, "-ow", wav_path, "-ot", trace_path]

    # Run
    subprocess.check_call(cmd)

    prons = []
    labels = []
    pron_in = False
    label_in = False
    global_in = False
    global_params = {"Sampring frequency": None, "Frame period": None}
    with open(trace_path) as f:
        for l in f:
            l = l[:-1]
            if l.startswith("[Text analysis result]"):
                pron_in = True
                continue
            if pron_in and len(l) == 0:
                pron_in = False
            if pron_in:
                row = l.split(",")
                hinsi = row[1]
                if hinsi == "記号":
                    prons.append(row[0])
                else:
                    prons.append(row[9])

            if l.startswith("[Output label]"):
                label_in = True
                continue
            if label_in and len(l) == 0:
                label_in = False
            if label_in:
                labels.append(l)

            if l.startswith("[Global parameter]"):
                global_in = True
                continue
            if global_in:
                row = list(map(lambda s: s.strip(), l.split("->")))
                if len(row) < 2:
                    continue
                k = row[0]
                if k in global_params.keys():
                    v = row[1]
                    for s in ["(Hz)", "(point)"]:
                        v = v.replace(s, "")
                    global_params[k] = v

    if cleanup:
        for p in [text_path, wav_path, trace_path]:
            os.remove(p)

    # Fix typ..
    for b, a in [("Sampring frequency", "Sampling frequency")]:
        assert b in global_params
        val = global_params[b]
        del global_params[b]
        global_params[a] = val

    return prons, labels, global_params

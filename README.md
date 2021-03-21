# pyopenjtalk

[![PyPI](https://img.shields.io/pypi/v/pyopenjtalk.svg)](https://pypi.python.org/pypi/pyopenjtalk)
[![Python package](https://github.com/r9y9/pyopenjtalk/actions/workflows/ci.yaml/badge.svg)](https://github.com/r9y9/pyopenjtalk/actions/workflows/ci.yaml)
[![Build Status](https://travis-ci.org/r9y9/pyopenjtalk.svg?branch=master)](https://travis-ci.org/r9y9/pyopenjtalk)
[![License](http://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat)](LICENSE.md)
[![DOI](https://zenodo.org/badge/143748865.svg)](https://zenodo.org/badge/latestdoi/143748865)

**THIS IS ALPHA VERSION!**

A python wrapper for [OpenJTalk](http://open-jtalk.sp.nitech.ac.jp/). Note that this is built on top of a [modified version of OpenJTalk](https://github.com/r9y9/open_jtalk).

It's currently limited for text processing frontend functionality.

## Installation

The package is based on cython and built on top of the shared library of the OpenJTalk. Please have a look at the `travis.yml` and see how the shared library is installed. After you have installed the OpenJTalk shared library, then the installation of the package is just as follows:

```
pip install pyopenjtalk
```

## Quick demo

```py
In [1]: import pyopenjtalk

In [2]: pyopenjtalk.g2p("こんにちは")
Out[2]: 'k o N n i ch i w a'

In [3]: pyopenjtalk.g2p("こんにちは", kana=True)
Out[3]: 'コンニチワ'
```

## LISENCE

- pyopenjtalk: MIT license ([LICENSE.md](LICENSE.md))

## LISENCE for third party libraries

- Open JTalk: Modified BSD license ([COPYING](https://github.com/r9y9/open_jtalk/blob/1.10/src/COPYING))
- htsvoice in this repository: Please check [pyopenjtalk/htsvoice/README.md](pyopenjtalk/htsvoice/README.md).
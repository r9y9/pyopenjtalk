.. pyopenjtalk documentation master file, created by
   sphinx-quickstart on Thu Aug  9 01:27:44 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

pyopenjtalk
===========

.. warning::

   This is still an alpha version and APIs are subject to change.

A python wrapper for `OpenJTalk <https://github.com/r9y9/open_jtalk>`_.

https://github.com/r9y9/pyopenjtalk

Quick demo
----------

.. code-block:: python

   In [1]: import pyopenjtalk

   In [2]: pyopenjtalk.g2p("こんにちは")
   Out[2]: 'k o N n i ch i w a'

   In [3]: pyopenjtalk.g2p("こんにちは", kana=True)
   Out[3]: 'コンニチワ'


Installation
------------

The latest release is availabe on pypi. You can install it by:

.. code::

   pip install pyopenjtalk

.. toctree::
  :maxdepth: 2
  :caption: Package reference

  pyopenjtalk
  openjtalk

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

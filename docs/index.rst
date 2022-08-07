.. pyopenjtalk documentation master file, created by
   sphinx-quickstart on Thu Aug  9 01:27:44 2018.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

pyopenjtalk
===========

A python wrapper for `OpenJTalk <https://github.com/r9y9/open_jtalk>`_.
The package consists of two core components:

- Text processing frontend based on OpenJTalk
- Speech synthesis backend using HTSEngine

https://github.com/r9y9/pyopenjtalk


Installation
------------

The latest release is availabe on pypi. You can install it by:

.. code::

   pip install pyopenjtalk


Workaround for ``ValueError: numpy.ndarray size changed, may indicate binary incompatibility``
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

This type of errors comes from the Numpys' ABI breaking changes. If you see ``ValueError: numpy.ndarray size changed, may indicate binary incompatibility. Expected 96 from C header, got 88 from PyObject`` or similar, please make sure to install numpy first, and then install pyopenjtalk by:

.. code::

   pip install pyopenjtalk --no-build-isolation

or:

.. code::

   pip install git+https://github.com/r9y9/pyopenjtalk --no-build-isolation

The option ``--no-build-isolation`` tells pip not to create a build environment, so the pre-installed numpy is used to build the packge. Hense there should be no Numpy's ABI issues.

.. toctree::
   :maxdepth: 1
   :caption: Notebooks

   notebooks/Demo.ipynb

Please check the usage through the demo notebook.

.. toctree::
  :maxdepth: 2
  :caption: Package reference

  pyopenjtalk
  openjtalk
  htsengine

.. toctree::
    :maxdepth: 1
    :caption: Meta information

    changelog

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

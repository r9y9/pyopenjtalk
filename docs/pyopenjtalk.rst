pyopenjtalk
===========

The functional interface for text processing and waveform synthesis.

.. note::

    For ease of use, all the functional interfaces use global instances of :class:`pyopenjtalk.openjtalk.OpenJTalk` and :class:`pyopenjtalk.htsengine.HTSEngine` internally.

    If you want to get a full control (e.g., using an external dictionary or htsvoice), please manually instanciate and use these classes.

.. automodule:: pyopenjtalk


High-level API
--------------

.. autofunction:: tts
.. autofunction:: g2p
.. autofunction:: extract_fullcontext
.. autofunction:: synthesize


Misc
----

.. autofunction:: run_frontend
.. autofunction:: make_label
.. autofunction:: estimate_accent

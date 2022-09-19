Change log
==========

v0.3.0 <2022-09-20>
-------------------

Newer numpy  (>v1.20.0) is required to avoid ABI compatibility issues. Please check the updated installation guide.

* `#40`_: Introduce marine for Japanese accent estimation. Note that there could be a breakpoint regarding `run_frontend` because this PR changed the behavior of the API.
* `#35`_: Fixes for Python 3.10.

v0.2.0 <2022-02-06>
-------------------

* `#29`_: Update binary dependencies (hts_engine_API/open_jtalk)

v0.1.6 <2022-01-29>
-------------------

* `#27`_: pyopenjtalk cannot be installed in google colab

v0.1.5 <2021-09-18>
-------------------

* `#25`_: FIx dict URL from unstable sourceforge to github release
* `#24`_: Fix travis CI


v0.1.4 <2021-09-16>
-------------------

* `#22`_: Make CMake work properly so that it can be built on Windows
* `#21`_: Don't include mecab/config.h for release tar balls
* `#20`_: Raise errors if cmake fails to run
* `#19`_: Add tqdm progress bar for dictionary download

v0.1.3 <2021-08-11>
-------------------

* `#16`_: Enable pysen on CI
* `#15`_: Support path that including multibyte-characters

v0.1.2 <2021-08-04>
-------------------

* `#13`_: Windows MSVC support

v0.1.1 <2021-05-28>
-------------------

Bug fix release for numpy <v1.20.0

https://github.com/ymd-h/cpprb/discussions/3

v0.1.0 <2021-03-24>
-------------------

Now that text processsing frontend and speech synthesis backend are both available from pyopenjtalk.
Note that there are no API breaking changes from v0.0.x.

* `#9`_: major changes for v0.1.0

v0.0.3 <2021-03-21>
-------------------

* `#7`_: Embed C++ source into the repository
* `#8`_: Goodbye openjtalk shared lib

v0.0.2 <2020-03-01>
-------------------

Minor update

v0.0.1 <2018-08-09>
-------------------

Initial release with OpenJTalk's text processsing functionality

.. _#7: https://github.com/r9y9/pyopenjtalk/issues/7
.. _#8: https://github.com/r9y9/pyopenjtalk/pull/8
.. _#9: https://github.com/r9y9/pyopenjtalk/pull/9
.. _#13: https://github.com/r9y9/pyopenjtalk/pull/13
.. _#15: https://github.com/r9y9/pyopenjtalk/pull/15
.. _#16: https://github.com/r9y9/pyopenjtalk/pull/16
.. _#19: https://github.com/r9y9/pyopenjtalk/pull/19
.. _#20: https://github.com/r9y9/pyopenjtalk/issues/20
.. _#21: https://github.com/r9y9/pyopenjtalk/issues/21
.. _#22: https://github.com/r9y9/pyopenjtalk/pull/22
.. _#24: https://github.com/r9y9/pyopenjtalk/pull/24
.. _#25: https://github.com/r9y9/pyopenjtalk/pull/25
.. _#27: https://github.com/r9y9/pyopenjtalk/issues/27
.. _#29: https://github.com/r9y9/pyopenjtalk/pull/29
.. _#35: https://github.com/r9y9/pyopenjtalk/pull/35
.. _#40: https://github.com/r9y9/pyopenjtalk/pull/40

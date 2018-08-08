# coding: utf-8

from __future__ import with_statement, print_function, absolute_import

from setuptools import setup, find_packages, Extension
from distutils.version import LooseVersion

import numpy as np
import os
from glob import glob
from os.path import join


openjtalk_install_prefix = os.environ.get(
    "OPEN_JTALK_INSTALL_PREFIX", "/usr/local/")

openjtalk_include_top = join(openjtalk_install_prefix, "include")
openjtalk_library_path = join(openjtalk_install_prefix, "lib")

lib_candidates = list(filter(lambda l: l.startswith("libopenjtalk."),
                             os.listdir(join(openjtalk_library_path))))
if len(lib_candidates) == 0:
    raise OSError("openjtalk library cannot be found")

min_cython_ver = '0.21.0'
try:
    import Cython
    ver = Cython.__version__
    _CYTHON_INSTALLED = ver >= LooseVersion(min_cython_ver)
except ImportError:
    _CYTHON_INSTALLED = False

try:
    if not _CYTHON_INSTALLED:
        raise ImportError('No supported version of Cython installed.')
    from Cython.Distutils import build_ext
    from Cython.Build import cythonize
    cython = True
except ImportError:
    cython = False

if cython:
    ext = '.pyx'
    cmdclass = {'build_ext': build_ext}
else:
    ext = '.cpp'
    cmdclass = {}
    if not os.path.exists(join("pyopenjtalk", "openjtalk" + ext)):
        raise RuntimeError("Cython is required to generate C++ code")

ext_modules = cythonize(
    [Extension(
        name="pyopenjtalk.openjtalk",
        sources=[
            join("pyopenjtalk", "openjtalk" + ext),
        ],
        include_dirs=[np.get_include(),
                      join(openjtalk_include_top)],
        library_dirs=[openjtalk_library_path],
        libraries=["openjtalk"],
        extra_compile_args=[],
        extra_link_args=[],
        language="c++")],
)

with open('README.md', 'r') as fd:
    long_description = fd.read()

setup(
    name='pyopenjtalk',
    version='0.0.1',
    description='A python wrapper for OpenJTalk',
    long_description=long_description,
    long_description_content_type='text/markdown',
    author='Ryuichi Yamamoto',
    author_email='zryuichi@gmail.com',
    url='https://github.com/r9y9/pyopenjtalk',
    license='MIT',
    packages=find_packages(),
    package_data={'': ['htsvoice/*']},
    ext_modules=ext_modules,
    cmdclass=cmdclass,
    install_requires=[
        'numpy >= 1.8.0',
    ],
    tests_require=['nose', 'coverage'],
    extras_require={
        'test': ['nose', 'scipy'],
    },
    classifiers=[
        "Operating System :: POSIX",
        "Operating System :: Unix",
        "Operating System :: MacOS",
        "Programming Language :: Cython",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.4",
        "Programming Language :: Python :: 3.5",
        "License :: OSI Approved :: MIT License",
        "Topic :: Scientific/Engineering",
        "Topic :: Software Development",
        "Intended Audience :: Science/Research",
        "Intended Audience :: Developers",
    ],
    keywords=["OpenJTalk"]
)

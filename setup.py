# coding: utf-8

from __future__ import with_statement, print_function, absolute_import

from setuptools import setup, find_packages, Extension
from distutils.version import LooseVersion

import numpy as np
import os
from glob import glob
from os.path import join

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

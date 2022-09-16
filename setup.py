import os
import subprocess
import sys
from distutils.errors import DistutilsExecError
from distutils.spawn import spawn
from distutils.version import LooseVersion
from glob import glob
from itertools import chain
from os.path import exists, join
from subprocess import run

import numpy as np
import setuptools.command.build_py
import setuptools.command.develop
from setuptools import Extension, find_packages, setup

platform_is_windows = sys.platform == "win32"

version = "0.3.0"

min_cython_ver = "0.21.0"
try:
    import Cython

    ver = Cython.__version__
    _CYTHON_INSTALLED = ver >= LooseVersion(min_cython_ver)
except ImportError:
    _CYTHON_INSTALLED = False


msvc_extra_compile_args_config = [
    "/source-charset:utf-8",
    "/execution-charset:utf-8",
]

try:
    if not _CYTHON_INSTALLED:
        raise ImportError("No supported version of Cython installed.")
    from Cython.Distutils import build_ext

    cython = True
except ImportError:
    cython = False

if cython:
    ext = ".pyx"

    def msvc_extra_compile_args(compile_args):
        cas = set(compile_args)
        xs = filter(lambda x: x not in cas, msvc_extra_compile_args_config)
        return list(chain(compile_args, xs))

    class custom_build_ext(build_ext):
        def build_extensions(self):
            compiler_type_is_msvc = self.compiler.compiler_type == "msvc"
            for entry in self.extensions:
                if compiler_type_is_msvc:
                    entry.extra_compile_args = msvc_extra_compile_args(
                        entry.extra_compile_args
                        if hasattr(entry, "extra_compile_args")
                        else []
                    )

            build_ext.build_extensions(self)

    cmdclass = {"build_ext": custom_build_ext}
else:
    ext = ".cpp"
    cmdclass = {}
    if not os.path.exists(join("pyopenjtalk", "openjtalk" + ext)):
        raise RuntimeError("Cython is required to generate C++ code")


# Workaround for `distutils.spawn` problem on Windows python < 3.9
# See details: [bpo-39763: distutils.spawn now uses subprocess (GH-18743)]
# (https://github.com/python/cpython/commit/1ec63b62035e73111e204a0e03b83503e1c58f2e)
def test_quoted_arg_change():
    child_script = """
import os
import sys
if len(sys.argv) > 5:
    try:
        os.makedirs(sys.argv[1], exist_ok=True)
        with open(sys.argv[2], mode=sys.argv[3], encoding=sys.argv[4]) as fd:
            fd.write(sys.argv[5])
    except OSError:
        pass
"""

    try:
        # write
        package_build_dir = "build"
        file_name = join(package_build_dir, "quoted_arg_output")
        output_mode = "w"
        file_encoding = "utf8"
        arg_value = '"ARG"'

        spawn(
            [
                sys.executable,
                "-c",
                child_script,
                package_build_dir,
                file_name,
                output_mode,
                file_encoding,
                arg_value,
            ]
        )

        # read
        with open(file_name, mode="r", encoding=file_encoding) as fd:
            return fd.readline() != arg_value
    except (DistutilsExecError, TypeError):
        return False


def escape_string_macro_arg(s):
    return s.replace("\\", "\\\\").replace('"', '\\"')


def escape_macro_element(x):
    (k, arg) = x
    return (k, escape_string_macro_arg(arg)) if type(arg) == str else x


def escape_macros(macros):
    return list(map(escape_macro_element, macros))


custom_define_macros = (
    escape_macros
    if platform_is_windows and test_quoted_arg_change()
    else (lambda macros: macros)
)


# open_jtalk sources
src_top = join("lib", "open_jtalk", "src")

# generate config.h for mecab
# NOTE: need to run cmake to generate config.h
# we could do it on python side but it would be very tricky,
# so far let's use cmake tool
if not exists(join(src_top, "mecab", "src", "config.h")):
    cwd = os.getcwd()
    build_dir = join(src_top, "build")
    os.makedirs(build_dir, exist_ok=True)
    os.chdir(build_dir)

    # NOTE: The wrapped OpenJTalk does not depend on HTS_Engine,
    # but since HTSEngine is included in CMake's dependencies, it refers to a dummy path.
    r = run(["cmake", "..", "-DHTS_ENGINE_INCLUDE_DIR=.", "-DHTS_ENGINE_LIB=dummy"])
    r.check_returncode()
    os.chdir(cwd)

all_src = []
include_dirs = []
for s in [
    "jpcommon",
    "mecab/src",
    "mecab2njd",
    "njd",
    "njd2jpcommon",
    "njd_set_accent_phrase",
    "njd_set_accent_type",
    "njd_set_digit",
    "njd_set_long_vowel",
    "njd_set_pronunciation",
    "njd_set_unvoiced_vowel",
    "text2mecab",
]:
    all_src += glob(join(src_top, s, "*.c"))
    all_src += glob(join(src_top, s, "*.cpp"))
    include_dirs.append(join(os.getcwd(), src_top, s))

# Extension for OpenJTalk frontend
ext_modules = [
    Extension(
        name="pyopenjtalk.openjtalk",
        sources=[join("pyopenjtalk", "openjtalk" + ext)] + all_src,
        include_dirs=[np.get_include()] + include_dirs,
        extra_compile_args=[],
        extra_link_args=[],
        language="c++",
        define_macros=custom_define_macros(
            [
                ("HAVE_CONFIG_H", None),
                ("DIC_VERSION", 102),
                ("MECAB_DEFAULT_RC", '"dummy"'),
                ("PACKAGE", '"open_jtalk"'),
                ("VERSION", '"1.10"'),
                ("CHARSET_UTF_8", None),
            ]
        ),
    )
]

# Extension for HTSEngine backend
htsengine_src_top = join("lib", "hts_engine_API", "src")
all_htsengine_src = glob(join(htsengine_src_top, "lib", "*.c"))
ext_modules += [
    Extension(
        name="pyopenjtalk.htsengine",
        sources=[join("pyopenjtalk", "htsengine" + ext)] + all_htsengine_src,
        include_dirs=[np.get_include(), join(htsengine_src_top, "include")],
        extra_compile_args=[],
        extra_link_args=[],
        libraries=["winmm"] if platform_is_windows else [],
        language="c++",
        define_macros=custom_define_macros(
            [
                ("AUDIO_PLAY_NONE", None),
            ]
        ),
    )
]

# Adapted from https://github.com/pytorch/pytorch
cwd = os.path.dirname(os.path.abspath(__file__))
if os.getenv("PYOPENJTALK_BUILD_VERSION"):
    version = os.getenv("PYOPENJTALK_BUILD_VERSION")
else:
    try:
        sha = (
            subprocess.check_output(["git", "rev-parse", "HEAD"], cwd=cwd)
            .decode("ascii")
            .strip()
        )
        version += "+" + sha[:7]
    except subprocess.CalledProcessError:
        pass
    except IOError:  # FileNotFoundError for python 3
        pass


class build_py(setuptools.command.build_py.build_py):
    def run(self):
        self.create_version_file()
        setuptools.command.build_py.build_py.run(self)

    @staticmethod
    def create_version_file():
        global version, cwd
        print("-- Building version " + version)
        version_path = os.path.join(cwd, "pyopenjtalk", "version.py")
        with open(version_path, "w") as f:
            f.write("__version__ = '{}'\n".format(version))


class develop(setuptools.command.develop.develop):
    def run(self):
        build_py.create_version_file()
        setuptools.command.develop.develop.run(self)


cmdclass["build_py"] = build_py
cmdclass["develop"] = develop


with open("README.md", "r", encoding="utf8") as fd:
    long_description = fd.read()

setup(
    name="pyopenjtalk",
    version=version,
    description="A python wrapper for OpenJTalk",
    long_description=long_description,
    long_description_content_type="text/markdown",
    author="Ryuichi Yamamoto",
    author_email="zryuichi@gmail.com",
    url="https://github.com/r9y9/pyopenjtalk",
    license="MIT",
    packages=find_packages(),
    package_data={"": ["htsvoice/*"]},
    ext_modules=ext_modules,
    cmdclass=cmdclass,
    install_requires=[
        "numpy >= 1.20.0",
        "cython >= " + min_cython_ver,
        "six",
        "tqdm",
    ],
    tests_require=["nose", "coverage"],
    extras_require={
        "docs": [
            "sphinx_rtd_theme",
            "nbsphinx>=0.8.6",
            "Jinja2>=3.0.1",
            "pandoc",
            "ipython",
            "jupyter",
        ],
        "lint": [
            "pysen",
            "types-setuptools",
            "mypy<=0.910",
            "black>=19.19b0,<=20.8",
            "click<8.1.0",
            "flake8>=3.7,<4",
            "flake8-bugbear",
            "isort>=4.3,<5.2.0",
            "types-decorator",
        ],
        "test": ["pytest", "scipy"],
        "marine": ["marine>=0.0.5"],
    },
    classifiers=[
        "Operating System :: POSIX",
        "Operating System :: Unix",
        "Operating System :: MacOS",
        "Operating System :: Microsoft :: Windows",
        "Programming Language :: Cython",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.7",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "License :: OSI Approved :: MIT License",
        "Topic :: Scientific/Engineering",
        "Topic :: Software Development",
        "Intended Audience :: Science/Research",
        "Intended Audience :: Developers",
    ],
    keywords=["OpenJTalk", "Research"],
)

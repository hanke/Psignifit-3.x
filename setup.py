#!/usr/bin/env python
# encoding: utf-8
# vi: set ft=python sts=4 ts=4 sw=4 et:

######################################################################
#
#   See COPYING file distributed along with the psignifit package for
#   the copyright and license terms
#
######################################################################

""" setup.py for Psignifit 3.x """

from distutils.core import setup, Extension
import numpy
import os

# metadata definitions
name = "pypsignifit"
version = "3.0beta"
author = "Ingo Fründ, Valentin Haenel"
author_email = "psignifit-users@lists.sourceforge.net"
description = "Statistical inference for psychometric functions"
url= "http://sourceforge.net/projects/psignifit/"
license = "MIT"
packages = ["pypsignifit"]

# Psi++ source files
psipp_sources = [
    "src/bootstrap.cc",
    "src/core.cc",
    "src/data.cc",
    "src/mclist.cc",
    "src/mcmc.cc",
    "src/optimizer.cc",
    "src/psychometric.cc",
    "src/rng.cc",
    "src/sigmoid.cc",
    "src/special.cc",
    "src/linalg.cc",
    "src/getstart.cc",
    "src/prior.cc",
    "src/integrate.cc"]

# psipy interface
psipy_sources = ["psipy/psipy.cc"]
psipy = Extension ( "_psipy",
    sources = psipp_sources + psipy_sources,
    include_dirs=[numpy.get_include(), "src", "psipy"])

# swignifit interface
swignifit_sources = ["swignifit/swignifit_raw.cxx"]
swignifit = Extension('swignifit._swignifit_raw',
        sources = psipp_sources + swignifit_sources,
        include_dirs=["src"])

# decide which interface to use
# control this via the INTERFACE environment varible
# by default build swignifit only
interface = os.getenv("INTERFACE")
ext_modules = []
if interface not in ("swignifit", "psipy", None):
    raise ValueError("The interface '%s' does not exist!" % interface)
if interface == "swignifit" or interface == None:
    packages.append("swignifit")
    ext_modules.append(swignifit)
if interface == "psipy":
    ext_modules.append(psipy)

if __name__ == "__main__":
    setup(name = name,
        version = version,
        author = author,
        author_email = author_email,
        description = description,
        url = url,
        license = license,
        packages = packages,
        ext_modules = ext_modules)

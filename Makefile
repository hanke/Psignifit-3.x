# vim: set fdm=marker:
######################################################################
#
#   See COPYING file distributed along with the psignifit package for
#   the copyright and license terms
#
######################################################################

# The main Psignifit 3.x Makefile

#################### VARIABLE DEFINITIONS ################### {{{

SPHINX_DOCOUT=doc-html
EPYDOC_DCOOUT=api
PSIPP_DOCOUT=psipp-api
PSIPP_SRC=src
PYTHON=python
.PHONY : swignifit psipy ipython psipp-doc

#}}}

#################### GROUPING FILES ################### {{{

PYTHONFILES=$(addprefix pypsignifit/, __init__.py psignidata.py psignierrors.py psigniplot.py psigobservers.py pygibbsit.py)
CFILES_LIB=$(addprefix src/, bootstrap.cc core.cc data.cc linalg.cc mclist.cc mcmc.cc optimizer.cc psychometric.cc rng.cc sigmoid.cc special.cc
HFILES_LIB=$(addprefix src/, bootstrap.h  core.h  data.h  errors.h linalg.h mclist.h mcmc.h optimizer.h prior.h psychometric.h rng.h sigmoid.h special.h psipp.h)
PSIPY_INTERFACE=$(addprefix psipy/, psipy.cc psipy_doc.h pytools.h)
SWIGNIFIT_INTERFACE=swignifit/swignifit_raw.i
SWIGNIFIT_AUTOGENERATED=$(addprefix swignifit/, swignifit_raw.py swignifit_raw.cxx)
SWIGNIFIT_HANDWRITTEN=$(addprefix swignifit/, interface_methods.py utility.py)
DOCFILES=$(addprefix doc-src/, API.rst index.rst TUTORIAL.rst *.png)
EPYDOC_TARGET=swignifit psipy pypsignifit

# }}}

#################### MAIN DEFINITIONS ################### {{{

build: python-build

install: python-install

doc: python-doc psipp-doc

clean: clean-python-doc clean-python psipp-clean

test: psipy-test swignifit-test psipp-test

# }}}

#################### PYTHON DEFINITIONS ################### {{{

python-install: swig
	python setup.py install

python-build: psipy swignifit

clean-python: psipy-clean swignifit-clean
	-rm -rv build

python-doc: $(DOCFILES) $(PYTHONFILES) python-build
	mkdir -p $(SPHINX_DOCOUT)/$(EPYDOC_DCOOUT)
	epydoc -o $(SPHINX_DOCOUT)/$(EPYDOC_DCOOUT) $(EPYDOC_TARGET)
	PYTHONPATH=.:doc-src sphinx-build doc-src $(SPHINX_DOCOUT)

clean-python-doc:
	-rm -rv $(SPHINX_DOCOUT)

ipython: psipy swignifit
	ipython

psipy_vs_swignifit: psipy swignifit
	PYTHONPATH=. $(PYTHON) tests/psipy_vs_swignifit.py

psipy_vs_swignifit_time: psipy swignifit
	PYTHONPATH=. $(PYTHON) tests/psipy_vs_swignifit_time.py

# }}}

#################### PSIPP COMMANDS ################### {{{

psipp:
	cd $(PSIPP_SRC) && $(MAKE)

psipp-doc:
	doxygen

psipp-clean:
	cd $(PSIPP_SRC) && $(MAKE) clean
	-rm -rv $(SPHINX_DOCOUT)/$(PSIPP_DOCOUT)

psipp-test:
	cd $(PSIPP_SRC) && $(MAKE) test

# }}}

#################### PSIPY COMMANDS ################### {{{

psipy: $(PYTHONFILES) $(CFILES) $(HFILES) $(PSIPY_INTERFACE) setup.py
	INTERFACE=psipy $(PYTHON) setup.py  build_ext -i

psipy-install:
	INTERFACE=psipy $(PYTHON) setup.py install

psipy-test: psipy swignifit
	-PYTHONPATH=. INTERFACE="psipy" python tests/interface_test.py

psipy-clean:
	-rm -rv _psipy.so

# }}}

#################### SWIGNIFIT COMMANDS ################### {{{

swig: $(SWIGNIFIT_AUTOGENERATED)

swignifit: $(PYTHONFILES) $(CFILES) $(HFILES) $(SWIGNIFIT_AUTOGENERATED) $(SWIGNIFIT_HANDWRITTEN) setup.py
	INTERFACE=swignifit $(PYTHON) setup.py build_ext -i

swignifit-install: swig
	INTERFACE=swignifit $(PYTHON) setup.py install

$(SWIGNIFIT_AUTOGENERATED): $(SWIGNIFIT_INTERFACE)
	swig -c++ -python -v -Isrc  -o swignifit/swignifit_raw.cxx swignifit/swignifit_raw.i

swignifit-clean:
	-rm -rv $(SWIGNIFIT_AUTOGENERATED)
	-rm -rv swignifit/_swignifit_raw.so

swignifit-test: swignifit-test-raw swignifit-test-interface swignifit-test-utility

swignifit-test-raw: swignifit
	-PYTHONPATH=. $(PYTHON) tests/swignifit_raw_test.py

swignifit-test-interface: swignifit
	-PYTHONPATH=. INTERFACE="swignifit" $(PYTHON) tests/interface_test.py

swignifit-test-utility: swignifit
	-PYTHONPATH=. $(PYTHON) tests/utility_test.py

# }}}

#################### PYPSIGNIFIT COMMANDS ################### {{{

test-pypsignifit:
	-PYTHONPATH=build/`ls -1 build | grep lib` $(PYTHON) pypsignifit/psignidata.py


# }}}

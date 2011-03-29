# vim: set fdm=marker:
######################################################################
#
#   See COPYING file distributed along with the psignifit package for
#   the copyright and license terms
#
######################################################################

# The main Psignifit 3.x Makefile

#################### VARIABLE DEFINITIONS ################### {{{

SHELL=/bin/bash
CLI_INSTALL=$(HOME)/bin
SPHINX_DOCOUT=doc-html
EPYDOC_DCOOUT=api
PSIPP_DOCOUT=psipp-api
PSIPP_SRC=src
PYTHON=python
CLI_SRC=cli
TODAY=`date +%d-%m-%G`
LONGTODAY=`date +%G-%m-%d`
GIT_DESCRIPTION=`git describe --tags`
CLI_VERSION_HEADER=cli/cli_version.h
MPSIGNIFIT_VERSION=mpsignifit/psignifit_version.m
PYPSIGNIFIT_VERSION=pypsignifit/__version__.py
.PHONY : swignifit psipy ipython psipp-doc

#}}}

#################### GROUPING FILES ################### {{{

PYTHONFILES=$(addprefix pypsignifit/, __init__.py psignidata.py psignierrors.py psigniplot.py psigobservers.py pygibbsit.py)
CFILES_LIB=$(addprefix src/, bootstrap.cc core.cc data.cc linalg.cc mclist.cc mcmc.cc optimizer.cc psychometric.cc rng.cc sigmoid.cc special.cc getstart.cc )
HFILES_LIB=$(addprefix src/, bootstrap.h  core.h  data.h  errors.h linalg.h mclist.h mcmc.h optimizer.h prior.h psychometric.h rng.h sigmoid.h special.h psipp.h getstart.h)
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

clean: clean-python-doc clean-python psipp-clean cli-clean mpsignifit-clean

test: psipy-test swignifit-test psipp-test

# }}}

#################### PYTHON DEFINITIONS ################### {{{

python-install: swig python-version
	$(PYTHON) setup.py install

python-build: swignifit python-version

clean-python: psipy-clean swignifit-clean
	-rm -rv build
	-rm pypsignifit/*.pyc
	-rm $(PYPSIGNIFIT_VERSION)

python-doc: $(DOCFILES) $(PYTHONFILES) python-build
	mkdir -p $(SPHINX_DOCOUT)/$(EPYDOC_DCOOUT)
	# epydoc -o $(SPHINX_DOCOUT)/$(EPYDOC_DCOOUT) $(EPYDOC_TARGET)
	PYTHONPATH=.:doc-src sphinx-build doc-src $(SPHINX_DOCOUT)

clean-python-doc:
	-rm -rv $(SPHINX_DOCOUT)

ipython: psipy swignifit
	ipython

psipy_vs_swignifit: psipy swignifit
	PYTHONPATH=. $(PYTHON) tests/psipy_vs_swignifit.py

psipy_vs_swignifit_time: psipy swignifit
	PYTHONPATH=. $(PYTHON) tests/psipy_vs_swignifit_time.py

python-version:
	if git rev-parse &> /dev/null ; then \
		echo "version = '"$(GIT_DESCRIPTION)"'" > $(PYPSIGNIFIT_VERSION); \
	fi

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

################### CLI COMMANDS ###################### {{{
cli-install:  cli-version cli-build
	if [ -d $(CLI_INSTALL) ]; then echo $(CLI_INSTALL) " exists adding files"; else	mkdir $(CLI_INSTALL); echo ""; echo ""; echo ""; echo "WARNING: I had to create " $(CLI_INSTALL) "you will most probably have to add it to your PATH"; echo ""; echo ""; echo ""; fi
	cd $(CLI_SRC) && cp psignifit-mcmc psignifit-diagnostics psignifit-bootstrap psignifit-mapestimate $(CLI_INSTALL)
cli-build: cli-version
	cd $(CLI_SRC) && $(MAKE)
cli-clean:
	cd $(CLI_SRC) && $(MAKE) clean
	-rm $(CLI_VERSION_HEADER)
cli-test: cli-install
	$(PYTHON) tests/cli_test.py
cli-uninstall:
	rm $(CLI_INSTALL)/psignifit-mcmc
	rm $(CLI_INSTALL)/psignifit-diagnostics
	rm $(CLI_INSTALL)/psignifit-bootstrap
	rm $(CLI_INSTALL)/psignifit-mapestimate

cli-version:
	if git rev-parse &> /dev/null ; then \
		echo "#ifndef CLI_VERSION_H" > $(CLI_VERSION_HEADER) ; \
		echo "#define CLI_VERSION_H" >> $(CLI_VERSION_HEADER) ; \
		echo "#define VERSION \""$(GIT_DESCRIPTION)"\"" >> $(CLI_VERSION_HEADER) ; \
		echo "#endif" >> $(CLI_VERSION_HEADER) ; \
	fi
# }}}

#################### PSIPY COMMANDS ################### {{{

psipy: $(PYTHONFILES) $(CFILES) $(HFILES) $(PSIPY_INTERFACE) setup.py
	INTERFACE=psipy $(PYTHON) setup.py  build_ext -i

psipy-install:
	INTERFACE=psipy $(PYTHON) setup.py install

psipy-test: psipy swignifit
	-PYTHONPATH=. INTERFACE="psipy" $(PYTHON) tests/interface_test.py

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
	-rm -rv swignifit/*.pyc

swignifit-test: swignifit-test-raw swignifit-test-interface swignifit-test-utility

swignifit-test-raw: swignifit
	-PYTHONPATH=. $(PYTHON) tests/swignifit_raw_test.py

swignifit-test-interface: swignifit
	-PYTHONPATH=. INTERFACE="swignifit" $(PYTHON) tests/interface_test.py

swignifit-test-utility: swignifit
	-PYTHONPATH=. $(PYTHON) tests/utility_test.py

# }}}

#################### PYPSIGNIFIT COMMANDS ################### {{{

pypsignifit-test:
	-PYTHONPATH=. $(PYTHON) pypsignifit/psignidata.py

# }}}


#################### MPSIGNIFIT COMMANDS ################### {{{

mpsignifit-version:
	if git rev-parse &> /dev/null ; then \
		echo "function psignifit_version()" > $(MPSIGNIFIT_VERSION) ; \
		echo "disp('"$(GIT_DESCRIPTION)"')" >> $(MPSIGNIFIT_VERSION) ; \
	fi

mpsignifit-clean:
	rm $(MPSIGNIFIT_VERSION)

# }}}

#################### DISTRIBUTION COMMANDS ################## {{{

dist-changelog:
	if [[ `git symbolic-ref HEAD` != refs/heads/master ]] ; then \
		echo "FATAL: not on master branch!"; \
		false; \
	fi
	echo $(LONGTODAY) > tmp
	echo >> tmp
	echo "* " >> tmp
	echo >> tmp
	cat changelog >> tmp
	cp changelog changelog_old
	cp tmp changelog
	$(EDITOR) changelog +3
	if diff tmp changelog; then \
		mv changelog_old changelog; \
		echo "FATAL: changelog not modified!"; \
		false; \
	else \
		git commit changelog -m "changelog entry for upload"; \
		git push origin; \
	fi

dist-tar: python-version cli-version mpsignifit-version
	git archive --format=tar --prefix=psignifit3.0_beta_$(TODAY)/ master > psignifit3.0_beta_$(TODAY).tar
	tar --transform "s,^,psignifit3.0_beta_$(TODAY)/," -rf psignifit3.0_beta_$(TODAY).tar $(PYPSIGNIFIT_VERSION) $(CLI_VERSION_HEADER) $(MPSIGNIFIT_VERSION)
	gzip psignifit3.0_beta_$(TODAY).tar

dist-zip: dist-tar
	tar -xvzf psignifit3.0_beta_$(TODAY).tar.gz
	zip -r psignifit3.0_beta_$(TODAY).zip psignifit3.0_beta_$(TODAY)
	rm -r psignifit3.0_beta_$(TODAY)

dist-swigged: dist-zip swig
	tar xzf psignifit3.0_beta_$(TODAY).tar.gz
	cp swignifit/swignifit_raw.cxx swignifit/swignifit_raw.py psignifit3.0_beta_$(TODAY)/swignifit/
	mv psignifit3.0_beta_$(TODAY) psignifit3.0_beta_swigged_$(TODAY)
	tar czf psignifit3.0_beta_swigged_$(TODAY).tar.gz psignifit3.0_beta_swigged_$(TODAY)
	zip -r psignifit3.0_beta_swigged_$(TODAY).zip psignifit3.0_beta_swigged_$(TODAY)
	rm -r psignifit3.0_beta_swigged_$(TODAY)

dist-win: psignifit-cli.iss cli-version
	if [ -d WindowsInstaller ]; then rm -r WindowsInstaller; fi
	cd cli && rm -r build && make -f MakefileMinGW
	wine $(HOME)/.wine/drive_c/Program\ Files/Inno\ Setup\ 5/ISCC.exe psignifit-cli.iss
	mv WindowsInstaller/psignifit-cli_3_beta_installer.exe psignifit-cli_3_beta_installer_$(TODAY).exe

dist-upload-doc: python-doc
	scp -r doc-html/* igordertigor,psignifit@web.sourceforge.net:/home/groups/p/ps/psignifit/htdocs/
	git tag doc-$(LONGTODAY)
	git push origin doc-$(LONGTODAY)

dist-upload-archives:
	make dist-changelog
	git tag snap-$(LONGTODAY)
	make dist-swigged
	make dist-win
	mkdir psignifit3.0_beta_$(TODAY)
	cp psignifit3.0_beta_$(TODAY).tar.gz psignifit3.0_beta_swigged_$(TODAY).tar.gz psignifit3.0_beta_$(TODAY).zip psignifit3.0_beta_swigged_$(TODAY).zip psignifit-cli_3_beta_installer_$(TODAY).exe psignifit3.0_beta_$(TODAY)
	scp -rv psignifit3.0_beta_$(TODAY) igordertigor,psignifit@frs.sourceforge.net:/home/frs/project/p/ps/psignifit/
	rm -r psignifit3.0_beta_$(TODAY)
	git push origin snap-$(LONGTODAY)

# }}}

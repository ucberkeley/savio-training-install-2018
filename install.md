% Savio installation training
% October 18, 2018


# Introduction

We'll spend about 30 minutes going through this material as a demonstration. I encourage you to login to your account and try out the various examples yourself as we go through them. The remainder of the scheduled time will be open time for you to work on your installations with each other and with help from us.

Some of this material is based on the extensive Savio documention we have prepared and continue to prepare, available at [http://research-it.berkeley.edu/services/high-performance-computing/user-guide](http://research-it.berkeley.edu/services/high-performance-computing/user-guide). In particular we have some detailed installation instructions under the "Installing your own" tab at [http://research-it.berkeley.edu/services/high-performance-computing/accessing-and-installing-software](http://research-it.berkeley.edu/services/high-performance-computing/accessing-and-installing-software).

The materials for this tutorial are available using git at [https://github.com/ucberkeley/savio-training-install-2018](https://github.com/ucberkeley/savio-training-install-2018) or simply as a [zip file](https://github.com/ucberkeley/savio-training-install-2018/archive/master.zip).

These *install.html* and *install_slides.html* files were created from *install.md* by running 'make' within the repository directory (see *Makefile* for details on how that creates the html files).

Please see this [zip file](https://github.com/ucberkeley/savio-training-intro-2018/archive/master.zip) for materials from our introductory training on September 18, including accessing Savio, data transfer, and basic job submission.


# Outline

This training session will cover the following topics:

 - Software installation
     - Installing third-party software
     - Installing Python and R packages that rely on third-party software
         - Python example
         - R example
 - Hands-on software installation help

# Modules

Recall that very little software is available except via the modules system.

Simple tools like gnuplot, newer versions of git, cmake, gcc, etc... are all available in the software module farm, not loaded by default in user environments. 


# Third-party software installation - overview

In general, third-party software will provide installation instructions on a webpage, Github README, or install file inside the package source code.

The key for installing on Savio is making sure everything gets installed in your own home, project, or scratch directory and making sure you have the packages on which the software depends on also installed by you or loaded from the Savio modules. 

A common installation approach is the GNU build system (Autotools), which involves three steps: configure, make, and make install.

  - *configure*: this queries your system to find out what tools (e.g., compilers and other packages) you have available to use in building and using the software
  - *make*: this compiles the source code in the software package
  - *make install*: this moves the compiled code (library files and executables) and header files and the like to their permanent home

# Installation logistics

We recommend you set up a directory structure that mimics how we install software on Savio. We'll assume you are installing in a group directory, but you could equally well do this in your home directory or even on scratch (albeit with the danger the installation might be purged).

If you haven't already set up the directory structure for your group, here are the steps:

```
my_group=co_stat
cd /global/home/groups/${my_group}
mkdir software
mkdir software/sources
mkdir software/modules
mkdir software/scripts
mkdir software/modfiles
chmod -R g+rwX software
```

However, you can manage your directories as you like; the above is just a suggestion.

# Third-party software installation - examples

Here are a couple examples of installing a piece of software in your home directory.

### yaml package example

```
# install yaml, an optional dependency for Python yaml package
PKG=yaml
V=0.1.7

DIR=/global/home/groups/${my_group}/software
SRCDIR=${DIR}/sources/${PKG}/${V}
INSTALLDIR=${DIR}/modules/${PKG}/${V}

mkdir -p ${INSTALLDIR}
mkdir -p ${SRCDIR}

cd ${SRCDIR}
wget http://pyyaml.org/download/libyaml/${PKG}-${V}.tar.gz
tar -xvzf ${PKG}-${V}.tar.gz
cd ${PKG}-${V}
module load gcc/4.8.5
# --prefix is key to install in directory you have access to
./configure  --prefix=$INSTALLDIR | tee ../configure-${V}.log
make | tee ../make-${V}.log
make install | tee ../install-${V}.log
```

To save the information on how you installed the software, we recommend you save the code above. In this case you would save it in `software/scripts/yaml/install.sh`.

# Third-party software installation - examples

Here are a couple examples of installing a piece of software in your home directory.

### geos package example

```
PKG=geos
V=3.6.2

DIR=/global/home/groups/${my_group}/software
SRCDIR=${DIR}/sources/${PKG}/${V}
INSTALLDIR=${DIR}/modules/${PKG}/${V}

mkdir -p ${INSTALLDIR}
mkdir -p ${SRCDIR}

cd ${SRCDIR}
wget http://download.osgeo.org/${PKG}/${PKG}-${V}.tar.bz2
tar -xvjf ${PKG}-${V}.tar.bz2
cd ${PKG}-${V}
module load gcc/4.8.5
# --prefix is key to install in directory you have access to
./configure  --prefix=$INSTALLDIR | tee ../configure-${V}.log
make | tee ../make-${V}.log
make install | tee ../install-${V}.log
```


For Cmake, the following may work (this is not a worked example, just some template code):
```
PKG=foo
INSTALLDIR=~/software/${PKG}
cmake -DCMAKE_INSTALL_PREFIX=${INSTALLDIR} . | tee ../cmake.log
```

# Third-party software installation - final steps

To use the software you just installed as a dependency of other software you want to install (e.g., Python or R packages), you often need to make Linux aware of the location of the following in your newly-installed software:

  - library files (for other software to link against)
  - header files (for other software to compile against).

If a library file can't be found, you'll likely see an error message such as *`libfoo.so` not found*.
In this case make sure make sure the compiler can find the *lib* or *lib64* directory that contains the file(s).

If a header file can't be found, you'll likely see comments about *.h* files not being found. In this case make sure make sure the compiler can find the *include* directory that contains the file(s).

# Installing Python and R packages 

Note: in the following we'll install in our user directory; it would take some additional wrangling to install in a location available to other group members.

Note if we install pyyaml outside a virtualenv, we don't need to do all this because Savio uses Anaconda and has the yaml system package installed and the installation of pyyaml knows where to find yaml.h and libyaml.so. So this is primarily an illustration and not what would be needed in practice (plus pyyaml is already installed on Savio).

```
module load python/3.6
virtualenv /global/home/groups/${my_group}/pyyaml
source /global/home/groups/${my_group}/pyyaml/bin/activate

PYPKG=pyyaml
V=0.1.7
PKGDIR=/global/home/groups/${my_group}/software/modules/yaml/${V}

# This fails:
pip install --user --ignore-installed ${PYPKG}
ls .local/lib/python3.6/site-packages
# can't find yaml.h file

# This fails too:
pip install --user --ignore-installed --global-option=build_ext  \
    --global-option="-I/${PKGDIR}/include" ${PYPKG}
# can't find libyaml.so file

# This succeeds:
pip install --user --ignore-installed --global-option=build_ext \
    --global-option="-I/${PKGDIR}/include" \
    --global-option="-L/${PKGDIR}/lib" ${PYPKG}
```


# Installing Python and R packages 

Here's an R example. In this case compilation would go ok, except R needs access to a geos-related binary for configuration and to the libgeos library file when it test runs the installed rgeos package at the end of the process. 

```
V=3.6.2
PKGDIR=/global/home/groups/${my_group}/software/modules/geos/${V}
module load r/3.4.2

Rscript -e "install.packages('rgeos', repos = 'https://cran.cnr.berkeley.edu')"
# that fails as it can't find geos-config,
# an executable installed as part of geos

export PATH=${PKGDIR}/bin:${PATH}
Rscript -e "install.packages('rgeos', repos = 'https://cran.cnr.berkeley.edu')"
# that installs (almost), but fails to run when tested because
# libgoes-3.6.2.so can't be found

export LD_LIBRARY_PATH=${INSTALLDIR}/lib:${LD_LIBRARY_PATH}
Rscript -e "install.packages('rgeos', repos = 'https://cran.cnr.berkeley.edu')"
```

You may sometimes need to use the `configure.args` or `configure.vars` arguments to `install.packages()` to provide information on the location of `include` and `lib` directories of dependencies (similar to what we did for pyyaml. 

# Accessing executables and libraries at run-time

The issues we saw installing rgeos were not really compilation issues, but rather issues in finding binaries and libraries at run time.

For binaries, Linux only looks in certain directories for executables. These directories are in your PATH variable. So in the previous example we added the directory containing geos-config to our PATH.

For library (.so) files Linux only looks in certain directories for the location of .so library files. To tell Linux to look in additional directories, you can add them to your LD_LIBRARY_PATH variable.

In the rgeos case, anytime we want to use the rgeos package, we need to make sure LD_LIBRARY_PATH is set so that rgeos can find `libgeos-3.6.2.so`.

# Installation for an entire group

Optionally if you'd like your group members to have write access to the directories for the software you installed, you would do this:

```
PKG=rgeos
cd /global/home/groups/${my_group}/software
chmod -R g+rwX {sources,modfiles,modules,scripts}/${PKG}
```


# Setting up a module for your software


You may also want to set up a module for the software you just installed. This allows you and your group members to easily set your environment so that the software is accessible for you. To do this you need to do the following.

First we'll need a directory in which to store our module files:

```
V=3.6.2
MYMODULEPATH=/global/home/groups/${my_group}/software/modfiles
mkdir -p ${MYMODULEPATH}/geos
export MODULEPATH=${MODULEPATH}:${MYMODULEPATH}  # good to put this in your .bashrc
```

Now we create a module file for the version (or one each for multiple versions) of the software we have installed. E.g., for our geos installation we would edit  `${MYMODULEPATH}/geos/3.6.2` based on looking at examples of other module files. An example module file for our geos example is *example-modulefile*.

```
cp example-modulefile ${MYMODULEPATH}/geos/3.6.2
```

Or see some of the Savio system-level modules in `/global/software/sl-7.x86_64/modfiles`. 

```
cat /global/software/sl-7.x86_64/modfiles/apps/ml/tensorflow/1.7.0-py36
```


# How to get additional help

 - For technical issues and questions about using Savio: 
    - brc-hpc-help@berkeley.edu
 - For questions about computing resources in general, including cloud computing: 
    - brc@berkeley.edu
 - For questions about data management (including HIPAA-protected data): 
    - researchdata@berkeley.edu



###
### In most cases, defaults and auto-detection should provide an easy way of
### building SciDAVis without changing anything in this file (in contrast to
### prior versions).
###
### Windows users are expected to place all dependencies in the 3rdparty folder
### with default directory names (i.e., with version numbers stripped). In case
### you already have copies of the libraries installed somewhere, you need to
### change the paths below in order to use them.
###
### On Linux and MacOS X, the default configuration assumes Qwt and QwtPlot3D
### sources to be unpacked to the 3rdparty folders, with version numbers
### stripped from the directory names (as on Windows). If you're sure that a
### system-wide installation of Qwt and QwtPlot3D (e.g. from your distribution's
### package manager) is compiled against Qt4 (not Qt3), you can use it by
### executing "qmake PRESET=linux_package" instead of just "qmake" during the
### build process. Note that this also disables some features which are
### commonly not needed or even bothersome when integrating SciDAVis in a
### package manager (user-selectable paths to manual/plugins, checking for new
### versions on startup).
### 

################################################################################
### Choose between common configurations                                       #
###                                                                            #
### (currently not applicable on Windows)                                      #
### Depending on your system and requirements, you may or may not need to      #
### fine-tune other options below.                                             #
################################################################################

unix:isEmpty(PRESET) { # allow command-line argument to override settings here

	### Link statically against Qwt and Qwtplot3D in 3rdparty folder
	### (in order to make sure they're compiled against Qt4, not Qt3).
	### Intended for Linux users building from source (on possibly somewhat
	### older systems).
	#PRESET = default_installation

	### Link dynamically against system-wide installed libraries. Intended mainly
	### for building Linux packages for distributions with Qwt and QwtPlot3D
	### packages compiled against Qt4 (probably most current ones).
	!osx_dist {PRESET = linux_package}

	### Link statically as much as possible. Qwt, QwtPlot3D and MuParser are
	### expected to be supplied in the 3rdparty folder. Python, SIP, PyQt and Qt
	### are linked in dynamically in order to integrate with an existing Python
	### installation. Intended mainly for building self-contained Linux binaries.
	### (TODO: Could we include SIP+PyQt+Qt in the self-contained bundle, as done
	### in the Windows installer?)
	#PRESET = self_contained
}

unix:message(Building with preset $$PRESET)

################################################################################
### What to install                                                            #
###                                                                            #
### Comment out anything you want to exclude.                                  #
################################################################################


### Linux Desktop integration
!contains(PRESET, self_contained) {
	unix:INSTALLS   += desktop_entry mime_package mime_link icons man_page appdata
}

################################################################################
### Where to install                                                           #
###                                                                            #
### IMPORTANT: The paths given here specify where SciDAVis will search for     #
###            the files at runtime. If you want "make install" to place them  #
###            anywhere else (e.g. in a temporary directory structure used for #
###            building a package), use "make INSTALL_ROOT=/some/place install"#
###            and/or copy files to the desired locations by other means.      #
################################################################################

unix {# Linux / MacOS X
	contains(PRESET, self_contained) {
      ### Unless you're trying to build a self-contained bundle, see the
		### (heavily commented) "else" block below.

		### When installing into a self-contained directory structure (e.g. for
		### universal Linux binaries), use relative paths at runtime in order to
		### support relocation.
		isEmpty(INSTALLBASE): INSTALLBASE = .

		target.path = "$$INSTALLBASE"

		documentation.path = "$$INSTALLBASE/doc"
		manual.path = "$$INSTALLBASE/manual"

		translationfiles.path = "$$INSTALLBASE/translations"

		pythonconfig.path = "$$INSTALLBASE"
		pythonutils.path = "$$INSTALLBASE"

		plugins.path = "$$INSTALLBASE/plugins"

	} else {

		### this is what is called "prefix" when using GNU autotools
		isEmpty(INSTALLBASE): INSTALLBASE = /usr

		### where to put the binary (the application itself)
		target.path = "$$INSTALLBASE/bin"

		### location of documentation files
		documentation.path = "$$INSTALLBASE/share/doc/scidavis"

		### Usually, the manual will be expected in the "manual" subfolder of "documentation.path" (see above).
		### To override this, uncomment the next line and adjust the path behind the '='.
		#manual.path = "$$INSTALLBASE/share/doc/scidavis/manual"

		### location of translation files (*.qm)
		translationfiles.path = "$$INSTALLBASE/share/scidavis/translations"

 		### Important (if you use Python): the following two paths are where the application will expect 
		### scidavisrc.py and scidavisUtil.py, respectively. Alternatively you can also put scidavisrc.py 
		### (or ".scidavis.py") into the users home directory. scidavisUtil.py must be either in the 
		### directory specified here or somewhere else in the python path (sys.path) where "import" can find it

		### where scidavisrc.py is searched for at runtime
		pythonconfig.path = "$$INSTALLBASE/../etc"
		### where the scidavisUtil python module is searched for at runtime
		pythonutils.path = "$$INSTALLBASE/share/scidavis"

		### where plugins are expected by default
		plugins.path = "$$INSTALLBASE/lib/scidavis/plugins"
	}
	
###################### DESKTOP INTEGRATION ##################################	
	
	desktop_entry.files = scidavis/scidavis.desktop
	desktop_entry.path = "$$INSTALLBASE/share/applications"

	mime_package.files = scidavis/scidavis.xml
	mime_package.path = "$$INSTALLBASE/share/mime/packages"

	man_page.files = scidavis.1
	man_page.path = "$$INSTALLBASE/share/man/man1"
	
	appdata.files = scidavis.appdata.xml
	appdata.path = "$$INSTALLBASE/share/appdata"

	#deprecated
	mime_link.files = scidavis/x-sciprj.desktop
	mime_link.path = "$$INSTALLBASE/share/mimelnk/application"
	
	contains(INSTALLS, icons) {
		# scalable icon
		icons.files = scidavis/icons/scidavis.svg
		icons.path = "$$INSTALLBASE/share/icons/hicolor/scalable/apps"

		# hicolor icons for different resolutions
		resolutions = 16 22 32 48 64 128
		for(res, resolutions) {
			eval(icon_hicolor_$${res}.files = scidavis/icons/hicolor-$${res}/scidavis.png)
			eval(icon_hicolor_$${res}.path = "$$INSTALLBASE/share/icons/hicolor/$${res}x$${res}/apps")
			INSTALLS += icon_hicolor_$${res}
		}

		# locolor icons for different resolutions
		resolutions = 16 22 32
		for(res, resolutions) {
			eval(icon_locolor_$${res}.files = scidavis/icons/locolor-$${res}/scidavis.png)
			eval(icon_locolor_$${res}.path = "$$INSTALLBASE/share/icons/locolor/$${res}x$${res}/apps")

			INSTALLS += icon_locolor_$${res}
		}
	}
}

win32 {# Windows
	isEmpty(INSTALLBASE): INSTALLBASE = .

	target.path = "$$INSTALLBASE"
	documentation.path = "$$INSTALLBASE"
	translationfiles.path = "$$INSTALLBASE/translations"
	pythonconfig.path = "$$INSTALLBASE"
	pythonutils.path = "$$INSTALLBASE"
	plugins.path = "$$INSTALLBASE/fitPlugins"
}

### 64bit Linux only suffix
linux-g++-64: libsuff = 64 
unix:LIBS         += -L/usr/lib$${libsuff}

################################################################################
### Optional features                                                          #
################################################################################

### a console displaying output of scripts; particularly useful on Windows
### where running SciDAVis from a terminal is inconvenient
DEFINES         += SCRIPTING_CONSOLE

### a dialog for selecting the scripting language on a per-project basis
DEFINES         += SCRIPTING_DIALOG

!contains(PRESET, linux_package) {
	### Enables choosing of help folder at runtime, instead of relying on the above path only.
	### The downside is that the help folder will be remembered as a configuration option, so a binary
	### package cannot easily update the path for its users.
	### Dynamic selection of the manual path was the only available option up until SciDAVis 0.2.3.
	DEFINES += DYNAMIC_MANUAL_PATH

   ### Similar to DYNAMIC_MANUAL_PATH, but for the plugin folder
	DEFINES += DYNAMIC_PLUGIN_PATH

	### Check for new releases on startup (can be disabled in the preferences).
	DEFINES += SEARCH_FOR_UPDATES

	### Provide links to manual/translations download in help menu
	DEFINES += DOWNLOAD_LINKS
}

### support for Origin OPJ import using liborigin2
mxe|osx_dist|aegis {
CONFIG+=liborigin
}
liborigin {
DEFINES  += ORIGIN_IMPORT
}

### python support
aegis {
CONFIG+=python
}

################################################################################
### Dependencies                                                               #
################################################################################

# code for maintained branch of liborigin. 

contains(PRESET, default_installation) {
	### Link statically against Qwt and Qwtplot3D (in order to make sure they
	### are compiled against Qt4), dynamically against everything else.

	INCLUDEPATH  += ../3rdparty/qwt/src
	LIBS         += ../3rdparty/qwt/lib/libqwt.a

	INCLUDEPATH  += ../3rdparty/qwtplot3d/include
	LIBS         += ../3rdparty/qwtplot3d/lib/libqwtplot3d.a

	INCLUDEPATH  += /usr/include/muParser
	LIBS         += -lgsl -lgslcblas -lz -lGLU
	LIBS         += -lmuparser

}

osx_dist {
	# Uses MacPorts supplied versions of the dependencies

        QMAKE_CXX = clang++
        QMAKE_LINK = clang++

	INCLUDEPATH  += /usr/local/include
	INCLUDEPATH  += /opt/local/include
	INCLUDEPATH  += /opt/local/include/qwt
	INCLUDEPATH  += /opt/local/include/qwtplot3d

	LIBS         += -L/usr/local/lib -L/opt/local/lib -lqwt

	INCLUDEPATH  += /opt/local/include/qwtplot3d
	LIBS         += -lqwtplot3d

	INCLUDEPATH  += /opt/local/include/muParser
	INCLUDEPATH  += /opt/local/Library/Frameworks/Python.framework/Versions/2.7/include/python2.7/
	LIBS         += -lgsl -lgslcblas -lz
	LIBS         += -lmuparser -lpython2.7

# this was an attempt to add a post build step. Doesn't seem to work,
# so just run this step manually
        QMAKE_EXTRA_TARGETS += mac-dist
        mac-dist.commands = sh mkMacDist.sh

}

contains(PRESET, linux_package) {
	### dynamically link against Qwt(3D) installed system-wide

        exists(/usr/include/qt5/qwt5-qt5)      {INCLUDEPATH+=/usr/include/qt5/qwt5-qt5}
        exists(/usr/include/qt5/qwtplot3d-qt5) {INCLUDEPATH+=/usr/include/qt5/qwtplot3d-qt5}
        exists(/usr/include/qwt5-qt5) {INCLUDEPATH+=/usr/include/qwt5-qt5}
        exists(/usr/include/qwtplot3d) {INCLUDEPATH+=/usr/include/qwtplot3d}

        system (ls /usr/lib*/libqwt5-qt5.so) {LIBS+=-lqwt5-qt5}
        system (ls /usr/lib*/*/libqwt5-qt5.so) {LIBS+=-lqwt5-qt5}
        system (ls /usr/lib*/libqwt-qt5.so) {LIBS+=-lqwt-qt5}
        system (ls /usr/lib*/libqwtplot3d-qt5.so) {LIBS+=-lqwtplot3d-qt5}
        system (ls /usr/lib*/*/libqwtplot3d-qt5.so) {LIBS+=-lqwtplot3d-qt5}


	LIBS         += -lz -lGLU 

	INCLUDEPATH  += /usr/include/muParser
	LIBS         += -lgsl -lgslcblas
	LIBS         += -lmuparser 

        # enable user installed packages
        INCLUDEPATH = "$(HOME)/usr/include" $$INCLUDEPATH
        QMAKE_LIBDIR = "$(HOME)/usr/lib" $$QMAKE_LIBDIR


}

contains(PRESET, self_contained) {
	### mostly static linking, for self-contained binaries

	INCLUDEPATH  += ../3rdparty/qwt/src
	LIBS         += ../3rdparty/qwt/lib/libqwt.a

	INCLUDEPATH  += ../3rdparty/qwtplot3d/include
	LIBS         += ../3rdparty/qwtplot3d/lib/libqwtplot3d.a

	INCLUDEPATH  += ../3rdparty/muparser/include
	LIBS         += ../3rdparty/muparser/lib/libmuparser.a

	LIBS         += /usr/lib/libgsl.a /usr/lib/libgslcblas.a

}

win32: {
!mxe {
	### Static linking mostly, except Qt, Python and QwtPlot3D.
	### The latter seems to be impossible to link statically on Windows.

	isEmpty(LIBPATH): LIBPATH = ../3rdparty

	INCLUDEPATH  += "$${LIBPATH}/qwt/src"
	LIBS         += "$${LIBPATH}/qwt/lib/libqwt.a"

	INCLUDEPATH  += "$${LIBPATH}/qwtplot3d/include"
	LIBS         += "$${LIBPATH}/qwtplot3d/lib/qwtplot3d.dll"

	INCLUDEPATH  += "$${LIBPATH}/muparser/include"
	LIBS         += "$${LIBPATH}/muparser/lib/libmuparser.a"

	INCLUDEPATH  += "$${LIBPATH}/gsl/include"
	LIBS         += "$${LIBPATH}/gsl/lib/libgsl.a"
	LIBS         += "$${LIBPATH}/gsl/lib/libgslcblas.a"
  }
}

# Mingw cross compilation environment on Linux. 
mxe {
  # these need to go in CXXFLAGS to ensure they appear before $$QMAKE_INCDIR_QT and $$QMAKE_INCDIR_QT
  DEFINES += CONSOLE
  DEFINES -= UNICODE _UNICODE
  QMAKE_INCDIR  += . "$$(HOME)/usr/mxe/include"  "$$[QT_INSTALL_PREFIX]/include/qwt5-qt5"
  QMAKE_LIBDIR += "$(HOME)/usr/mxe/lib" "$(HOME)/usr/mxe/lib64" "$$[QT_INSTALL_PREFIX]/lib"
  LIBS +=  -mwindows -lqwt5-qt5 -lqwtplot3d -lmuparser -lgsl -lgslcblas
  # Qt libraries specified here to get around a dependency bug in qmake
  LIBS += -lQt5OpenGL -lQt5Gui -lQt5Network -lQt5Core
  LIBS += -lole32 -loleaut32 -limm32 -lcomdlg32 -luuid 
  LIBS += -lwinspool -lssl -lcrypto -lwinmm -lgdi32 -lws2_32
  LIBS += -ljpeg -lpng -lmng -ltiff -lz -llzma -llcms2
  LIBS += -lopengl32 -lglu32 
}

# for converage testing
gcov {
   QMAKE_CXXFLAGS+=-fprofile-arcs -ftest-coverage
   QMAKE_LFLAGS+=-fprofile-arcs -ftest-coverage  
}

#############################################################################
### Names of the lupdate and lrelease programs                              #
###                                                                         #
### These are needed if you want to compile and install the translations    #
### automatically. Possibly needs to be adapted if you have an unusual Qt   #
### installation.                                                           #
#############################################################################

exists(/usr/bin/lupdate-qt5) {
	# Debian, Ubuntu, Fedora
	LUPDATE_BIN = lupdate-qt5
	LRELEASE_BIN = lrelease-qt5
} else {
	# anything else
	LUPDATE_BIN = lupdate
	LRELEASE_BIN = lrelease
}


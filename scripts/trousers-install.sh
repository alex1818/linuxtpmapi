#!/bin/sh
# TPM Trousers Installation script
# Can do almost everything from compiling to configuring, making and make install...
#

#--- defaults (change these if you are a packager)
CONFARGS="--prefix=/usr"                   # configure args, e.g. --prefix=/usr

std_sleep() {
  sleep 1
}

conf_yesno_answer() {
  unset ANSWER
  while [ "$ANSWER" != 'yes' ] && [ "$ANSWER" != 'no' ]
  do {
    echo -n "$1"
    read ANSWER
  }
  done
}

# startup...

echo "TPM trousers-0.3.8"
echo

if [ ! -f configure ]
then
    if [ -f ../configure ]
    then {
      cd ..
    }
    else {
      echo "You're running this from the wrong directory."
      echo "Change to the trousers source's main directory and try again."
    }
    fi
fi

if [ -w / ]
then
    echo "You are running trousers-0.3.8l as root, this is not advisable. Please rerun as a user."
    echo "information."
    
fi

if [ ! -w . ]
then
    echo "you are about configuring and make, make isntall."
fi

# check whether RPM installed, and if it is, remove any old trousers-0.3.8 rpm.
if [ -x `which rpm 2>/dev/null` ]; then
    if [ -n "`rpm -qi trousers 2>/dev/null|grep "^Name"`" ]; then
      echo "Warning: Old  trousers rpm detected. Do you want to remove it first?"
      conf_yesno_answer "(yes/no) "
      if [ "$ANSWER" = 'yes' ]; then
        echo "We need to remove the rpm as root, please enter your root password"
        echo
        echo Starting  trousers rpmrpm removal...
        su -c "rpm -e trousers; RET=$?"
        if [ $RET -eq 0 ]; then
          echo Done.
        else
          echo "FAILED. Probably you aren't installing as root."
          echo "Expect problems (library conflicts with existing install etc.)."
        fi
      else
        echo "Sorry, I won't install trousers when an rpm version is still installed."
        echo "(trousers  support suffered from way too many conflicts between RPM"
        echo "and source installs)"
        echo "Have a nice day !"
        exit 1
      fi
    fi
fi

# check whether trousers binary still available
if [ -x `which trousers  2>/dev/null` ] && [ -n "`tcsd  --version 2>/dev/null`" ]
then
    echo "Warning !! trousers binary (still) found, which may indicate"
    echo "a (conflicting) previous installation."
    echo "You might want to abort and uninstall trousers  first."
    echo "(If you previously tried to install from source manually, "
    echo "run 'make uninstall' from the trousers root directory)"
    std_sleep
fi

# Ask the user if they want to build and install trousers:
echo
echo "We need to install trousers  as the root user. Do you want us to build trousers,"
echo "'su root' and install trousers ?  Enter 'no' to build trousers  without installing:"
conf_yesno_answer "(yes/no) "
ROOTINSTALL="$ANSWER"

if [ "$ROOTINSTALL" = "yes" ]
then sucommand="make install"
fi

# run the configure script, if necessary

if [ -f Makefile ]
then
    echo "I see that trousers  has already been configured, so I'll skip that."
    std_sleep
else
    echo "Running configure..."
    echo
    if ! ./configure $CONFARGS
    then {
      echo
      echo "Configure failed, aborting install."
      exit 1
    }
    fi
fi

# Now do the compilation and (optionally) installation

echo
echo "Compiling trousers . Grab a lunch or two, rent a video, or whatever,"
echo "in the meantime..."
echo
std_sleep

# try to just make trousers , if this fails 'make depend' and try to remake
if ! { make; }
then
    if ! { make depend && make; }
    then
      echo
      echo "Compilation failed, aborting install."
      exit 1
    fi
fi

if [ "$ROOTINSTALL" = "no" ]
then
    exit 0
fi

echo
echo "Performing 'make install' as root to install binaries, enter root password"

if ! su root -c "$sucommand"
then
    echo
    echo "Incorrect root password. If you are running Ubuntu or a similar distribution,"
    echo "'make install' needs to be run via the sudo wrapper, so trying that one now"
    if ! sudo su root -c "$sucommand"
    then
         echo
         echo "Either you entered an incorrect password or we failed to"
         echo "run '$sucommand' correctly."
         echo "If you didn't enter an incorrect password then please"
         echo "report this error and any steps to possibly reproduce it to"
         echo "http://bugs.sourceforge.com/"
         echo
         echo "Installation failed, aborting."
         exit 1
    fi
fi

# it's a wrap
echo
echo "Installation complete."
echo "If you have problems with trousers, please read the documentation first,"
echo "as many kinds of potential problems are explained there."

exit 0


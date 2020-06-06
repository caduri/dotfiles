#!/bin/bash

# Install Command Line Tools
if      pkgutil --pkg-info com.apple.pkg.CLTools_Executables >/dev/null 2>&1
then    printf '%s\n' "Command Line Tools are installed"
else    printf '%s\n' "Install Command Line Tools..."
        xcode-select --install && sleep 1
        osascript -e 'tell application "System Events"' -e 'tell process "Install Command Line Developer Tools"' -e 'keystroke return' -e 'click button "Agree" of window "License Agreement"' -e 'end tell' -e 'end tell'

# Install Homebrew
if      type -P brew >/dev/null 2>&1
then    printf '%s\n' "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
else    printf '%s\n' "Homebrew is installed, updating..."
        brew update
fi

# Install Python3
if      type -P python3 >/dev/null 2>&1
then    printf '%s\n' "Installing python..."
        brew install python
else    printf '%s\n' "Python is installed"
fi

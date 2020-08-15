#!/bin/bash

# Install Command Line Tools
if      pkgutil --pkg-info com.apple.pkg.CLTools_Executables >/dev/null 2>&1
then    printf '%s\n' "Command Line Tools are installed"
else    printf '%s\n' "Install Command Line Tools..."
        xcode-select --install && sleep 1
        osascript -e 'tell application "System Events"' -e 'tell process "Install Command Line Developer Tools"' -e 'keystroke return' -e 'click button "Agree" of window "License Agreement"' -e 'end tell' -e 'end tell'
fi

# Install Homebrew
if      type brew >/dev/null 2>&1
then    printf '%s\n' "Homebrew is installed, updating..."
        brew update
        brew upgrade git
else    printf '%s\n' "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# Install git
if      brew ls --versions git > /dev/null 2>&1
then    printf '%s\n' "git is installed, updating..."
        brew update
        brew upgrade git
else    printf '%s\n' "Installing git..."
        brew install git
fi

# Install Pyenv
if        brew ls --versions pyenv > /dev/null 2>&1
then      printf '%s\n' "Pyenv is installed, updating..."
          brew upgrade pyenv
else      printf '%s\n' "Installing pyenv..."
          brew install pyenv
          export PATH="$PATH;$(pyenv root)/shims"
          echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
          . ~/.bash_profile
          git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/xxenv-latest
fi

# Install Python 2 & 3 latest version
printf '%s\n' "Installing Python 3..."
pyenv latest install
printf '%s\n' "Installing Python 2.7..."
pyenv latest install 2.7
pyenv latest global
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
else    printf '%s\n' "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

# install Git
if        type git >/dev/null 2>&1 
then      printf '%s\n' "Git is installed, updating..."
          brew upgrade git
else      printf '%s\n' "Installing git..."
          brew install git
fi

# Install Pyenv
if        type pyenv >/dev/null 2>&1 
then      printf '%s\n' "Python is installed, updating..."
          brew upgrade pyenv
else      printf '%s\n' "Installing python..."
          brew install pyenv
          export PATH="$PATH;$(pyenv root)/shims"
          echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> ~/.bash_profile
          exec "$SHELL"
          git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/xxenv-latest
fi

# Install Python 2 & 3 latest version
pyenv latest install
pyenv latest install 2.7
pyenv latest global
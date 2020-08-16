#!/usr/bin/env bash

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
        brew tap phinze/homebrew-cask
        brew install brew-cask
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
          printf '%s\n' "Installing pyenv virtualenv..."
          brew install pyenv-virtualenv
          printf '%s\n' "Installing pipenv..."
          brew install pipenv
          echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\n  eval "$(pyenv virtualenv-init -)"\n  eval "$(pipenv --completion)"\nfi' >> ~/.bash_profile
          . ~/.bash_profile
          git clone https://github.com/momo-lab/xxenv-latest.git "$(pyenv root)"/plugins/xxenv-latest
fi

# Install Python 2 & 3 latest version
printf '%s\n' "Installing Python 3..."
pyenv latest install
printf '%s\n' "Installing Python 2.7..."
pyenv latest install 2.7
pyenv latest global


# Clone repo & Install ansible modules
if      [ -d "~/.dotfiles" ] 
then    printf '%s\n' "Updating repo"
        cd ~/.dotfiles && git pull origin master
else    printf '%s\n' "Clone repo"
        git clone git@github.com:caduri/dotfiles.git ~/.dotfiles
fi

cd ~/.dotfiles/local-ansible && pipenv install
cd ~/.dotfiles/local-ansible && pipenv run ansible-galaxy install -r requirements.yml --force
cd ~/.dotfiles/local-ansible && pipenv run ansible-playbook playbook.yml
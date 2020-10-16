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
        brew cleanup
        brew doctor
else    printf '%s\n' "Installing homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
        brew tap homebrew/cask
        brew install brew-cask
fi

# Install git
if      brew ls --versions git > /dev/null 2>&1
then    printf '%s\n' "git is already installed"
else    printf '%s\n' "Installing git..."
        brew install git
fi

# Install lastpass-cli
if      brew ls --versions lastpass-cli > /dev/null 2>&1
then    printf '%s\n' "lastpass-cli is already installed"
else    printf '%s\n' "Installing lastpass-cli..."
        brew install lastpass-cli
fi

# Install Pyenv
if        brew ls --versions pyenv > /dev/null 2>&1
then      printf '%s\n' "Pyenv is already installed"
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
printf '%s\n' "Installing latest Python 3..."
pyenv latest install --skip-existing
printf '%s\n' "Installing latest Python 2.7..."
pyenv latest install 2.7 --skip-existing
pyenv latest global

# login into lastpass
printf '%s: ' "Please provide lastpass username"
read LASTPASS_USER
printf '%s\n' "Logging in to lastpass"
lpass login $LASTPASS_USER

# Generate SSH token and register to github
if      [[ -d ~/.ssh && -f ~/.ssh/id_rsa ]]; 
then    printf '%s\n' "SSH token exists, skipping registration to github"
else    printf '%s\n' "Generating SSH token"
        ssh-keygen -q -t rsa -N '' <<< ""$'\n'"y" 2>&1 >/dev/null
        eval "$(ssh-agent -s)"
        ssh-add -K ~/.ssh/id_rsa
        SSH_RSA="$(cat ~/.ssh/id_rsa.pub)"
        
        printf '%s\n' "Fetching github username from lastpass"
        GITHUB_USER="$(lpass show -u Github)"
        printf '%s\n' "Fetching github token from lastpass"
        GITHUB_TOKEN="$(lpass show Github --field=Token)"

        curl -u "$GITHUB_USER:$GITHUB_TOKEN" --data '{"title":"DevMachine","key":"'"$SSH_RSA"'"}' https://api.github.com/user/keys
fi

# Clone repo & Install ansible modules
if      [[ -d ~/.dotfiles ]];
then    printf '%s\n' "Updating repo"
        cd ~/.dotfiles && git pull origin master
else    printf '%s\n' "Clone repo"
        git clone git@github.com:caduri/dotfiles.git ~/.dotfiles
fi

# Install sdkman
if      [[ -f ~/.install_sdkman.sh ]];
then    printf '%s\n' "Sdkman exists, skipping installation"
else    printf '%s\n' "Installing Sdkman"
        curl -s "https://get.sdkman.io" --output ~/install_sdkman.sh
        chmod +x ~/install_sdkman.sh
        ./install_sdkman.sh
        . "$HOME/.sdkman/bin/sdkman-init.sh"
fi

# Install nvm
if      [[ -f ~/.install_nvm.sh ]];
then    printf '%s\n' "nvm exists, skipping installation" #todo update ??
else    printf '%s\n' "Installing nvm"
        curl -s "https://raw.githubusercontent.com/nvm-sh/nvm/v0.36.0/install.sh" --output ~/install_nvm.sh
        chmod +x ~/install_nvm.sh
        ./install_nvm.sh
        . ~/.nvm/nvm.sh
        nvm install v12.19.0
fi

# Running ansible playbook
printf '%s\n' "Preparing to run ansible playbook, installing requirements..."
cd ~/.dotfiles/local-ansible && pipenv install
printf '%s\n' "Preparing to run ansible playbook, installing anisble galaxy requirements..."
cd ~/.dotfiles/local-ansible && pipenv run ansible-galaxy install -r requirements.yml --force
printf '%s\n' "Running playbook"
cd ~/.dotfiles/local-ansible && pipenv run ansible-playbook main.yml -i inventory --ask-become-pass
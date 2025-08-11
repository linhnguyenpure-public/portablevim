#!/bin/bash -xe
cpath=`pwd`
runpath=$cpath/runtime

# Define installer
## Define installer: Mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    brew --version || /opt/homebrew/bin/brew --version || /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    gumma_install () {
        #use this for supported os
        #brew install --build-from-source $1 || /opt/homebrew/bin/brew upgrade $1
        #use this for non-supported os
        /opt/homebrew/bin/brew install --build-from-source $(/opt/homebrew/bin/brew deps --include-build $1) $1 || /opt/homebrew/bin/brew upgrade $1
    }
fi 

## Define installer: Cygwin
if [[ "$OSTYPE" == "cygwin" ]]; then
    # No gumma_install
    :
fi

## Define installer: Linux
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    uname -a | grep Debian
    if [[ $? == "0" ]]; then
        gumma_install() {
            sudo apt-get install $1
        }
    else
        # In case this is WSL with Ubuntu LST
        uname -a | grep USLT
        if [[ $? == "0" ]]; then
            gumma_install() {
                sudo apt-get install $1
            }
	    else
            gumma_install() {
                yum install $1
            }
        fi
    fi
fi

## Define installer: Pi
if [[ "$OSTYPE" == "linux-gnueabihf" ]]; then
    gumma_install() {
        apt-get install $1
    }
fi


# Common Setup: Dotfiles
set +x
echo "About to delete and recreate:"
echo "runtime"
echo "~/.custom.sh"
echo "~/.tmux.conf"
echo "~/.vimrc, ~/.vim"
echo "~/.ctags"
set -x
read -n 1 -s -r -p "Press c to continue, s to skip..." continue && echo
if [[ $continue == "c" ]]; then
    echo "Remove above files"
    rm -rf runtime
    rm -rf ~/.custom.sh
    rm -rf ~/.tmux.conf
    rm -rf ~/.vimrc ~/.vim
    rm -rf ~/.ctags

    echo "Create and link above files"
    mkdir $runpath
    cp $cpath/.bash_profile_portable $runpath/.bash_profile_portable
    echo -e "PORTABLEVIM=`pwd`\n" >> $runpath/.bash_profile_portable
    echo -e "source $runpath/.bash_profile_portable\n" >> $runpath/.bash_profile_portable

    cp -r $cpath/.bashrc $runpath/.bashrc && ( [ -L ~/.bashrc ] || ln -s $runpath/.bashrc ~/.bashrc )
    cp -r $cpath/.custom.sh $runpath/.custom.sh && ( [ -L ~/.custom.sh ] || ln -s $runpath/.custom.sh ~/.custom.sh )

    cp -r $cpath/.tmux.conf $runpath/.tmux.conf && ( [ -L ~/.tmux.conf ] || ln -s $runpath/.tmux.conf ~/.tmux.conf )

    cp $cpath/.vimrc $runpath/.vimrc && ( [ -L ~/.vimrc ] || ln -s $runpath/.vimrc ~/.vimrc )
    cp -r $cpath/.vim $runpath/.vim && ( [ -L ~/.vim ] || ln -s $runpath/.vim ~/.vim )

    cp $cpath/.ctags $runpath/.ctags && ( [ -L ~/.ctags ] || ln -s $runpath/.ctags ~/.ctags )

    [[ -f ~/.proprietary.sh ]] || touch ~/.proprietary.sh
    [[ -f ~/.proprietary.vim ]] || touch ~/.proprietary.vim
else
    echo "Skipping removal of dotfiles and creation of new links"
fi


# OS-specific Setup: Dotfiles & Settings
## OS-specific Setup: Dotfiles & Settings -- Mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    cp -r $cpath/.iterm2 $runpath/.iterm2 && ( [ -L ~/.iterm2 ] || ln -s $runpath/.iterm2 ~/.iterm2 )
    cp -r $cpath/Mac/.iterm2_shell_integration.bash $runpath/.iterm2_shell_integration.bash && ( [ -L ~/.iterm2_shell_integration.bash ] || ln -s $runpath/.iterm2_shell_integration.bash ~/.iterm2_shell_integration.bash )

    # Increase keyboard key repeat rate
    defaults write -g InitialKeyRepeat -int 10
    defaults write -g KeyRepeat -int 1
fi

## OS-specific Setup: Dotfiles & Settings -- Cygwin
if [[ "$OSTYPE" == "cygwin" ]]; then
    echo -e 'alias python="python -i"\n' >> $runpath/.bash_profile_portable

    #Change default cygwin home folder, per https://cygwin.com/cygwin-ug-net/ntsec.html#ntsec-mapping-nsswitch-syntax
    # Move this step in README, do manually
    #echo -e 'db_home:  /%H/cygwin' >> /etc/nsswitch.conf
    #echo "Restart cygwin now"

    # Setup SSH
    [ -L ~/.ssh/config ] || ln -s /cygdrive/c/Users/$USERNAME/.ssh/config ~/.ssh/config
    [ -L ~/.ssh/id_ed25519 ] || ln -s /cygdrive/c/Users/$USERNAME/.ssh/id_ed25519 ~/.ssh/id_ed25519
    [ -L ~/.ssh/id_ed25519.pub ] || ln -s /cygdrive/c/Users/$USERNAME/.ssh/id_ed25519.pub ~/.ssh/id_ed25519.pub

    # For gitk
    # export DISPLAY=localhost:0.0 xterm

    cuser=$(whoami | awk -F'\\' '{print $2}')
fi

## OS-specific Setup: Dotfiles & Settings -- Linux
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    :
fi

## Pi
if [[ "$OSTYPE" == "linux-gnueabihf" ]]; then
    :
fi

# OS-specific Setup: Apps
## OS-specific Setup: Apps -- Mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    gumma_install bash

    # Setup PATH for bash
        # https://stackoverflow.com/questions/10574969/how-do-i-install-bash-3-2-25-on-mac-os-x-10-5-8
    echo '/opt/homebrew/bin/bash' | sudo tee -a /etc/shells;
    [[ "$PATH" == *"homebrew"* ]] || echo -e "PATH=/opt/homebrew/bin:$PATH" >> $runpath/.bash_profile_portable
    [[ "$SHELL" == *"bash"* ]] || chsh -s /opt/homebrew/bin/bash

    gumma_install reattach-to-user-namespace

    # iTerm
    command -v wget || gumma_install wget
    if [ ! -d "/Applications/iTerm.app" ] || [ ! -d "/Volumes/LinhData/iTerm.app"] ; then
        wget https://iterm2.com/downloads/stable/iTerm2-3_4_16.zip
        unzip iTerm2-3_4_16.zip
        mv iTerm.app/ /Applications/
        rm iTerm2-3_4_16.zip
    fi
fi

## OS-specific Setup: Apps -- Cygwin 
if [[ "$OSTYPE" == "cygwin" ]]; then
    set +x
    echo "Open setup-x86_64.exe cygwin then install:"
    echo "vim, mosh"
    echo "wget, git, ctags, tmux"
    # https://unix.stackexchange.com/questions/227889/cygwin-on-windows-cant-open-display
    # also install xinit and xorg-server to enable gitk
    echo "For gitk, way1: install xinit, then run startxwin&"
    echo "For gitk, way2: install xinit, xorg-server"
    set -x
    read -n 1 -s -r -p "Press any key to continue..." && echo 
fi

## OS-specific Setup: Apps -- Linux
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    ### Debian
    uname -a | grep Debian
    if [[ $? == "0" ]]; then
        # https://vi.stackexchange.com/questions/13564/why-is-vim-for-debian-compiled-without-clipboard
        gumma_install vim-gtk
    fi

    ### WSL with Ubuntu LST
    uname -a | grep USLT
    if [[ $? == "0" ]]; then
	    # NOTE: Use nvim instead, to get clipboard to work, need to download vcxsrv and run server
        gumma_install nvim
        gumma_install xclip
        set +x
        echo 'Need to install https://github.com/mintty/wsltty for mouse to work in WSL'
        echo 'Need to build vim from scratch for clipboard, x11 features'
        set -x
    fi
fi

## OS-specific Setup: Apps -- Pi
if [[ "$OSTYPE" == "linux-gnueabihf" ]]; then
    :
fi


# Common Setup: Apps
if [[ "$OSTYPE" != "cygwin" ]]; then
    command -v wget || gumma_install wget
    command -v git || gumma_install git
    [ `which ctags` == "/opt/homebrew/bin/ctags" ] || gumma_install ctags || gumma_install exuberant-ctags
    [ `which tmux` == "/opt/homebrew/bin/tmux" ] || gumma_install tmux
    gumma_install vim

    ## Setup SSH
    echo "Plugin: YouCompleteMe needs to be compiled. Go to its website to get instructions"
    mkdir -p ~/.ssh
    chmod 700 ~/.ssh
    KEY_FILE=~/.ssh/id_ed25519
    if [ ! -f "$KEY_FILE" ]; then
        echo "Generating new ED25519 SSH key..."
        ssh-keygen -t ed25519 -C "$(whoami)@$(hostname)" -f "$KEY_FILE" -N ""
    else
        echo "SSH key already exists at $KEY_FILE"
    fi
fi


# Common setup: Dotfiles & Settings for Apps
## Vim
[[ -d ~/.vim/bundle ]] || git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
read -p "Install vim plugins? y/n" install
if [[ $install == "y" ]]; then
    vim +PlugInstall +qall # install all plugins
fi

#exec -l $SHELL not sure what this is for
echo "Setup finished"

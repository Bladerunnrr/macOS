#/bin/bash


# macOS Monterey Homebrew manual installation in a different directory.
# https://itectec.com/superuser/how-should-i-install-homebrew-into-usr-local-subdirectory-manually/


# Make temp install folder
sudo mkdir /usr/local/brewtmp1

# $USER is your current account name with Admin Priv...
sudo chown $USER:admin /usr/local/brewtmp1

ls -l /usr/local

cd /usr/local/brewtmp1

curl -L https://github.com/Homebrew/brew/tarball/master | tar xz

ls -l /usr/local/brewtmp1/Homebrew-brew-*

mv Homebrew-brew-* homebrew

cd /usr/local

sudo mv /usr/local/brewtmp1/homebrew /usr/local

# Add the following path to .bash_profile or .zprofile
echo export PATH=${HOME}/homebrew/bin:$PATH

# Delete brewtemp1 folder
sudo rm -rf /usr/local/brewtmp1

which brew

brew update

brew install htop
brew install cmatrix
brew install neofetch

brew install --cask google-chrome
brew install --cask handbrake
brew install --cask obs
brew install --cask qbittorrent
brew install --cask steam
brew install --cask vlc

# Upgrade Cask packages
brew upgrade --cask google-chrome
brew upgrade --cask handbrake
brew upgrade --cask obs
brew upgrade --cask qbittorrent
brew upgrade --cask steam
brew install --cask streamlabs-obs
brew upgrade --cask vlc


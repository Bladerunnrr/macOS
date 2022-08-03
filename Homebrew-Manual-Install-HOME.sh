#/bin/bash



# macOS Monterey Homebrew manual installation in a different directory.
# https://itectec.com/superuser/how-should-i-install-homebrew-into-usr-local-subdirectory-manually/


cd ~

curl -L https://github.com/Homebrew/brew/tarball/master | tar xz

mv Homebrew-brew-* homebrew

# Add the following path to .bash_profile or .zprofile
echo export PATH=${HOME}/homebrew/bin:$PATH >> ~/.zshrc


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

brew upgrade --cask google-chrome handbrake obs qbittorrent steam streamlabs-obs vlc


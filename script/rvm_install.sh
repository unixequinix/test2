sudo apt-get update
sudo apt-get upgrade
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
sudo apt-get remove ruby2.1 ruby2.3 ruby1.9 ruby-switch
sudo apt-get clean
sudo apt-get autoclean
rm -rf ~/glownet_web/shared/bundle/

gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby=2.3.1
source ~/.profile
rvm requirements
gem install passenger bundler --no-doc --no-ri
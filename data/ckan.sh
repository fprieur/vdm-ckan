#!/bin/bash

locale-gen
export LC_ALL="en_US.UTF-8"
sudo locale-gen en_US.UTF-8

sudo apt-get update

sudo apt-get install python-dev postgresql libpq-dev python-pip python-virtualenv git-core solr-jetty openjdk-6-jdk vim -y

mkdir -p /home/vagrant/ckan/lib
sudo ln -s /home/vagrant/ckan/lib /usr/lib/ckan
mkdir -p /home/vagrant/ckan/etc
sudo ln -s /home/vagrant/ckan/etc /etc/ckan

sudo mkdir -p /usr/lib/ckan/default
sudo chown `whoami` /usr/lib/ckan/default
virtualenv --no-site-packages /usr/lib/ckan/default
. /usr/lib/ckan/default/bin/activate

pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.2#egg=ckan'
pip install -r /usr/lib/ckan/default/src/ckan/requirements.txt
deactivate
. /usr/lib/ckan/default/bin/activate

sudo -u postgres psql -l

sudo -u postgres createuser -S -D -R ckan_default
sudo -u postgres psql -c "ALTER USER ckan_default with password 'pass'"
sudo -u postgres createdb -O ckan_default ckan_default -E utf-8

sudo mkdir -p /etc/ckan/default
sudo chown -R `whoami` /etc/ckan/
cd /usr/lib/ckan/default/src/ckan
deactivate
. /usr/lib/ckan/default/bin/activate
paster make-config ckan /etc/ckan/default/development.ini

sudo rm /etc/ckan/default/development.ini

sudo cp /vagrant_data/development.ini /etc/ckan/default

sudo rm /etc/default/jetty
sudo cp /vagrant_data/data/jetty /etc/default/

sudo service jetty start

sudo mv /etc/solr/conf/schema.xml /etc/solr/conf/schema.xml.bak

sudo ln -s /usr/lib/ckan/default/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml

sudo service jetty restart

cd /usr/lib/ckan/default/src/ckan
deactivate
. /usr/lib/ckan/default/bin/activate
paster db init -c /etc/ckan/default/development.ini

ln -s /usr/lib/ckan/default/src/ckan/who.ini /etc/ckan/default/who.ini

cd /usr/lib/ckan/default/src/ckan
deactivate
. /usr/lib/ckan/default/bin/activate
paster serve /etc/ckan/default/development.ini

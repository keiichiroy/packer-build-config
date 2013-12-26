#http://chrisadams.me.uk/2010/05/10/setting-up-a-centos-base-box-for-development-and-testing-with-vagrant/
#kernel source is needed for vbox additions

date > /etc/vagrant_box_build_time

#enable repos which is now EOL
cp /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.orig
sed -i "s/^mirrorlist/#mirrorlist/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s/^#baseurl/baseurl/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s/mirror.centos.org\/centos\/\$releasever/vault.centos.org\/4.9/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s/mirror.centos.org\/centos/vault.centos.org/g" /etc/yum.repos.d/CentOS-Base.repo
sed -i "/\[extras\]$/a enabled=0" /etc/yum.repos.d/CentOS-Base.repo
sed -i "/\[addons\]$/a enabled=0" /etc/yum.repos.d/CentOS-Base.repo
sed -i "/\[update\]$/a enabled=0" /etc/yum.repos.d/CentOS-Base.repo
sed -i "s/gpgcheck=1/gpgcheck=0/g" /etc/yum.repos.d/CentOS-Base.repo

# yum for vboxadd
yum -y install gcc kernel-utils kernel-devel
# yum for ruby
yum -y install gcc gcc-c++ make patch rpm-build readline-devel zlib-devel openssl-devel curl-devel

# install yaml
cd /tmp
wget http://ftp.riken.jp/Linux/fedora/epel/4/SRPMS/libyaml-0.1.2-3.el4.src.rpm
rpmbuild --rebuild libyaml-0.1.2-3.el4.src.rpm --clean
cd /usr/src/redhat/RPMS/i386
rpm -ivh libyaml-0.1.2-3.i386.rpm libyaml-devel-0.1.2-3.i386.rpm
rm -f /tmp/libyaml-0.1.2-3.el4.src.rpm

# install ruby
cd /tmp
wget http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p484.tar.gz
tar xvzf ruby-1.9.3-p484.tar.gz
cd ruby-1.9.3-p484
./configure --enable-shared --enable-load-relative --disable-install-doc --prefix=/opt/ruby-1.9.3-p484
make
make install
echo "export PATH=$PATH:/opt/ruby-1.9.3-p484/bin" >> /etc/profile.d/ruby-1.9.3-p484.sh

cd /tmp
rm -f /tmp/ruby-1.9.3-p484.tar.gz
rm -rf /tmp/ruby-1.9.3-p484

# install chef and puppet
gem install chef --no-ri --no-rdoc
gem install puppet --no-ri --no-rdoc

#Installing vagrant keys
mkdir /home/vagrant/.ssh
chmod 700 /home/vagrant/.ssh
cd /home/vagrant/.ssh
wget --no-check-certificate 'https://raw.github.com/mitchellh/vagrant/master/keys/vagrant.pub' -O authorized_keys
chown -R vagrant /home/vagrant/.ssh

#Prepare kernel source for VBoxGuestAddition build
cd /usr/local/src
wget http://ftp.riken.jp/Linux/kernel.org/linux/kernel/v2.6/linux-2.6.9.tar.bz2
tar jfxv linux-2.6.9.tar.bz2
KERN_DIR=/usr/local/src/linux-2.6.9

#Installing the virtualbox guest additions
VBOX_VERSION=$(cat /home/vagrant/.vbox_version)
cd /tmp
wget http://download.virtualbox.org/virtualbox/$VBOX_VERSION/VBoxGuestAdditions_$VBOX_VERSION.iso
mount -o loop VBoxGuestAdditions_$VBOX_VERSION.iso /mnt
sh /mnt/VBoxLinuxAdditions.run
umount /mnt

rm VBoxGuestAdditions_$VBOX_VERSION.iso
rm /usr/local/src/linux-2.6.9.tar.bz2
rm -rf /usr/local/src/linux-2.6.9

#poweroff -h

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
exit

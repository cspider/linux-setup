function echo_message() {

    echo "------------------------------------------------------------------ "
    echo "${1}"
    echo "------------------------------------------------------------------ "
}
USER_NAME="susantac"
USER_HOME="/home/${USER_NAME}"

dnf update bash -y
# Install visual source code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf -y check-update
dnf install -y code 
## Facter helps to detect if we are running on virtual machine or bare metal
dnf -y install facter

cp -f /usr/share/applications/code.desktop  ${USER_HOME}/Desktop/

# Install gnome-tweaks to enable desktop 

dnf install gnome-tweaks -y

# Install chrome browser
chrome_status=$(which google-chrome)

if [[ -z ${chrome_status}  ]]; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    dnf localinstall google-chrome-stable_current_x86_64.rpm -y

    cp -f /usr/share/applications/google-chrome.desktop ${USER_HOME}/Desktop/
    chmod u+x ${USER_HOME}/Desktop/google-chrome.desktop
    chown ${USER_NAME}:${USER_NAME} ${USER_HOME}/Desktop/google-chrome.desktop
    ## Cleanup chrome
    rm -f google-chrome-stable_current*  
else 
    echo_message "Skipping Chrome install. Is already installed at: ${chrome_status}}"
fi



# Now do java 11 and Java 17
# Following did not work as sudo altenatives could not switch between java
dnf install java-11-openjdk-devel -y
dnf install java-17-openjdk-devel -y
#dnf install java-1.8.0-openjdk-devel -y

# switch between java using the following:
# sudo alternatives --config java
# Also add the follow to .bashrc or .zshenv 
# export JAVA_HOME=$(dirname $(dirname $(readlink $(readlink $(which javac)))))


# Prepare for IntelliJ IDE
dnf install epel-release -y
dnf update

# devtools
INTELLIJ_HOME=${USER_HOME}/devtools/IntelliJ
if [[ ! -d ${INTELLIJ_HOME}  ]]; then 
    echo_message "Installing IntelliJ at ${INTELLIJ_HOME}"
    mkdir -p ${INTELLIJ_HOME}
    cd ${INTELLIJ_HOME}
    wget https://download.jetbrains.com/idea/ideaIU-2021.2.3.tar.gz
    tar -xvf ideaIU-2021.2.3.tar.gz
    rm -f ideaIU-2021.2.3.tar.gz
    INTELLIJ_INSTALL_DIR=$(ls)
    rm -f /usr/bin/idea
    ln -s ${INTELLIJ_HOME}/${INTELLIJ_INSTALL_DIR}/bin/idea.sh /usr/bin/idea
    chmod +x /usr/bin/idea
    cd ~
    chown susantac:susantac /home/susantac/devtools
else   
    echo_message "Skipping IntelliJ install. Is already installed at ${INTELLIJ_HOME}"
fi

#
# **** TODO  - check if Docker is already installed, then skip 
#              rather than generating bunch of errors
#

# Install Docker
## Add Docker repository for dnf 
which docker > /dev/null 2>&1
if [ "$?" -ne "0" ]; then
   echo "Docker is not installed. Going to install Docker....."
   dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
   dnf install  --allowerasing docker-ce docker-ce-cli containerd.io -y
   ## Enable and Start docker service
   systemctl enable --now docker
   ## Permit all user to connect to Docker engine via socket
   chmod 666 /var/run/docker.sock
   ## Add current user to Docker group
   usermod -aG docker $USER
fi

# Support for virtualization - you do not need this if you installed 
# Linux in server mode
detect_virtual=$(dmesg | grep -i "Hypervisor detected")
if [[ !(-z "${detect_virtual}") && "${detect_virtual}" =~ "Hypervisor"  ]]; then
  echo "Running on a hypervisor....."
  dnf install virt-install virt-viewer -y
  # However libvirtd service is not enabled by default, enable it
  systemctl enable libvirtd --now
  #Manual check later to make sure
  # virt-host-validate
fi

# This Oh-My-Zsh section is configured as per 
#       https://mpolinowski.github.io/devnotes/2019-09-22--zsh-on-centos8
#Install oh-my-zsh - most probably already installed - so a no-op
dnf -y install zsh
## Make it a default shell 
chsh -s $(which zsh) root
chsh -s $(which zsh)    # For you user account

## Install Oh-My-Zsh Framework
wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh

#Install Maven
MVN_VERSON=3.9.0
if [[ ! -d  "${USER_HOME}/devtools/${MVN_VERSION}" ]]; then
  cd ${USER_HOME}/devtools
  wget https://dlcdn.apache.org/maven/maven-3/${MVN_VERSON}/binaries/apache-maven-${MVN_VERSON}-bin.tar.gz
  tar xzvf apache-maven-${MVN_VERSON}-bin.tar.gz
  chown -R susantac:susantac ./apache-maven-${MVN_VERSON}
  rm -f apache-maven-${MVN_VERSON}-bin.tar.gz  # Clean up tar file
  # Add ${USER_NAME}/devtools/apache-maven-${MVN_VERSON}/bin to the PATH variable
  # and M2_HOME to ${USER_NAME}/devtools/apache-maven-${MVN_VERSON}
fi

# Thought about Groovy. Manuals install is easier
# https://groovy-lang.org/install.html

# Install Gradle
# Install Postman
# cd Downloads/
# tar -xzf Postman-linux-x64-7.32.0.tar.gz
# sudo mkdir -p /opt/apps/
# sudo mv Postman-linux-x64-7.32.0/Postman /opt/apps/
# sudo ln -s /opt/apps/Postman/Postman /usr/local/bin/postman
# postman

# Will add Terraform and AWS CLI
terraform_response=$(which terraform 2>/dev/null)
if [ -z $terraform_response ]; then
  dnf install -y dnf-plugins-core
  dnf config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
  dnf install terraform -y
else
  echo "terraform is already installed. Skipping Terraform..."
fi 



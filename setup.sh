function echo_message() {

    echo "------------------------------------------------------------------ "
    echo "${1}"
    echo "------------------------------------------------------------------ "
}

USER_HOME="susantac"

dnf update bash -y
# Install visual source code
rpm --import https://packages.microsoft.com/keys/microsoft.asc
sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'

dnf -y check-update
dnf install -y code 


cp -f /usr/share/applications/code.desktop  /home/susantac/Desktop/

# Install gnome-tweaks to enable desktop 

dnf install gnome-tweaks -y

# Install chrome browser
chrome_status=$(which google-chrome)

if [[ -z ${chrome_status}  ]]; then
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
    dnf localinstall google-chrome-stable_current_x86_64.rpm -y

    cp -f /usr/share/applications/google-chrome.desktop /home/susantac/Desktop/
    chmod u+x /home/susantac/Desktop/google-chrome.desktop
    chown susantac:susantac /home/susantac/Desktop/google-chrome.desktop
    ## Cleanup chrome
    rm -f google-chrome-stable_current*  
else 
    echo_message "Skipping Chrome install. Is already installed at: ${chrome_status}}"
fi


# Now do java 11, java 7 and java 8

dnf install java-11-openjdk-devel -y
dnf install java-17-openjdk-devel -y
dnf install java-1.8.0-openjdk-devel -y


# Prepare for IntelliJ IDE
dnf install epel-release -y
dnf update

# devtools
INTELLIJ_HOME=/home/${USER_HOME}/devtools/IntelliJ
if [[ ! -d ${INTELLIJ_HOME}  ]]; then 
    echo_message "Installing IntelliJ at ${INTELLIJ_HOME}"
    mkdir -p ${INTELLIJ_HOME}
    cd ${INTELLIJ_HOME}
    wget https://download.jetbrains.com/idea/ideaIU-2021.2.3.tar.gz
    tar -xvf ideaIU-2021.2.3.tar.gz
    rm -f ideaIU-2021.2.3.tar.gz
    INTELLIJ_INSTALL_DIR=$(ls)
    ln -s ./${INTELLIJ_INSTALL_DIR}/bin/idea.sh /usr/bin/idea
    cd ~
    chown susantac:susantac /home/susantac/devtools
else 
    
    echo_message "Skipping IntelliJ install. Is already installed at ${INTELLIJ_HOME}"

fi

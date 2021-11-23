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
wget https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
dnf localinstall google-chrome-stable_current_x86_64.rpm -y

cp -f /usr/share/applications/google-chrome.desktop /home/susantac/Desktop/
chmod u+x /home/susantac/Desktop/google-chrome.desktop
chown susantac:susantac /home/susantac/Desktop/google-chrome.desktop
## Cleanup chrome
rm -f google-chrome-stable_current*


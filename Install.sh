#!/bin/bash
# Обновление и база
sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git xorg-server xorg-xinit i3-wm steam dmenu lxsession telegram-desktop discord networkmanager --noconfirm

# Установка AUR-помощника (yay)
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin && makepkg -si --noconfirm && cd .. && rm -rf yay-bin

# Репозиторий CachyOS (геймерское ядро)
sudo pacman-key --recv-key FBA220DFC065CEFA --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC065CEFA
sudo pacman -U 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-3-1-any.pkg.tar.zst' --noconfirm
echo -e "\n[cachyos]\nInclude = /etc/pacman.d/cachyos-repo.list" | sudo tee -a /etc/pacman.conf
sudo pacman -Syu --noconfirm
sudo pacman -S linux-cachyos-bore linux-cachyos-bore-headers --noconfirm
if [ -f /boot/grub/grub.cfg ]; then sudo grub-mkconfig -o /boot/grub/grub.cfg; fi

# Драйверы Nvidia
yay -S nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils --noconfirm

# Автологин
USER_NAME=$(whoami)
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf
echo -e "\nif [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then\n  exec startx\nfi" >> ~/.bash_profile

# Настройки i3 и Steam
mkdir -p ~/.config/i3
echo -e "#!/bin/sh\nlxsession &\ni3 &\nexec steam -tenfoot -applaunch 570 -novid -high -prewarm" > ~/.xinitrc
chmod +x ~/.xinitrc
echo -e "\nbindsym \$mod+t exec telegram-desktop\nbindsym \$mod+d exec discord\nbindsym Mod1+Tab focus next" >> ~/.config/i3/config

# Система
sudo systemctl enable --now NetworkManager
sudo reboot

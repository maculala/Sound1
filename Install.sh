#!/bin/bash

echo "=== ЗАПУСК ОПТИМИЗАЦИИ СИСТЕМЫ ПОД ДОТУ ==="

# 1. Полное обновление базы и установка окружения
sudo pacman -Syu --noconfirm
sudo pacman -S --needed base-devel git xorg-server xorg-xinit i3-wm steam dmenu lxsession telegram-desktop discord networkmanager pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber --noconfirm

# 2. Чиним и подключаем твой HDD с Дотой (/dev/sda1)
sudo mkdir -p /mnt/storage
# Проверяем, прописан ли уже HDD, если нет — добавляем в автозагрузку системы
if ! grep -q "/mnt/storage" /etc/fstab; then
    echo -e "\n/dev/sda1 /mnt/storage ntfs-3g defaults,nofail,uid=1000,gid=1000,dmask=022,fmask=133 0 0" | sudo tee -a /etc/fstab
fi
sudo mount -a

# 3. Установка AUR-помощника (yay)
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin && makepkg -si --noconfirm && cd .. && rm -rf yay-bin
fi

# 4. Подключение репозитория CachyOS и геймерского ядра Bore
sudo pacman-key --recv-key FBA220DFC065CEFA --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key FBA220DFC065CEFA
sudo pacman -U 'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-3-1-any.pkg.tar.zst' --noconfirm
if ! grep -q "\[cachyos\]" /etc/pacman.conf; then
    echo -e "\n[cachyos]\nInclude = /etc/pacman.d/cachyos-repo.list" | sudo tee -a /etc/pacman.conf
fi
sudo pacman -Syu --noconfirm
sudo pacman -S linux-cachyos-bore linux-cachyos-bore-headers --noconfirm

# Обновляем загрузчик GRUB под новое ядро
if [ -f /boot/grub/grub.cfg ]; then 
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# 5. Драйверы под твою Nvidia (Legacy 470xx)
yay -S nvidia-470xx-dkms nvidia-470xx-utils lib32-nvidia-470xx-utils --noconfirm

# 6. Настройка автологина в систему (чтобы не вводить пароль при включении)
USER_NAME=$(whoami)
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf

# Автозапуск графики при старте
echo -e "\nif [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then\n  exec startx\nfi" >> ~/.bash_profile

# 7. Конфиги оконного менеджера i3 и автозапуск Стива в режиме Big Picture
mkdir -p ~/.config/i3
echo -e "#!/bin/sh\nlxsession &\npipewire &\npipewire-pulse &\nwireplumber &\ni3 &\nexec steam -tenfoot -applaunch 570 -novid -high -prewarm" > ~/.xinitrc
chmod +x ~/.xinitrc

# Горячие клавиши для i3 (Дискорд, Телеграм, Альт-Таб)
echo -e "\nbindsym \$mod+t exec telegram-desktop\nbindsym \$mod+d exec discord\nbindsym Mod1+Tab focus next" >> ~/.config/i3/config

# Включаем сеть
sudo systemctl enable --now NetworkManager

echo "=== ВСЁ ГОТОВО! СИСТЕМА ПЕРЕЗАГРУЖАЕТСЯ ==="
sleep 3
sudo reboot


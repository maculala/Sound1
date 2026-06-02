#!/bin/bash
set -e

echo "=================================================="
echo "===  1. АВТОМАТИЧЕСКАЯ ПОЧИНКА И СБРОС PACMAN  ==="
echo "=================================================="
# Создаем идеальный чистый конфиг pacman с нуля, чтобы не было ошибок
sudo tee /etc/pacman.conf << 'EOF'
[options]
HoldPkg     = pacman glibc
Architecture = auto
Color
CheckSpace
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist
EOF

echo "=================================================="
echo "===    2. ОБНОВЛЕНИЕ И УСТАНОВКА ПРОГРАММ       ==="
echo "=================================================="
echo "[*] Обновление баз пакетов..."
sudo pacman -Syu --noconfirm

echo "[*] Установка инструментов компиляции и заголовков ядра..."
sudo pacman -S --needed base-devel git dkms linux-headers --noconfirm

echo "[*] Установка графики, Steam, Telegram, Discord и звука..."
sudo pacman -S --needed xorg-server xorg-xinit i3-wm steam dmenu lxsession telegram-desktop discord networkmanager pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber ntfs-3g --noconfirm

echo "=================================================="
echo "===         3. НАСТРОЙКА ДРАЙВЕРОВ NVIDIA       ==="
echo "=================================================="
echo "[*] Сборка драйверов Nvidia..."
sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils --noconfirm || true

echo "[*] Компиляция модулей ядра..."
sudo dkms autoinstall
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf
sudo mkinitcpio -P

echo "=================================================="
echo "===         4. МОНТИРОВАНИЕ ДИСКА ПОД ДОТУ      ==="
echo "=================================================="
sudo mkdir -p /mnt/storage
if ! grep -q "/mnt/storage" /etc/fstab; then
    echo -e "\n/dev/sda1 /mnt/storage ntfs-3g defaults,nofail,uid=1000,gid=1000,dmask=022,fmask=133 0 0" | sudo tee -a /etc/fstab
fi
sudo mount -a || echo "Диск примонтируется после перезагрузки."

echo "=================================================="
echo "===         5. АВТОЛОГИН И АВТОЗАПУСК СТИМА     ==="
echo "=================================================="
USER_NAME="kirill"
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf

# Настраиваем запуск иксов при входе в tty1
truncate -s 0 /home/$USER_NAME/.bash_profile
echo -e "\nif [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then\n  exec startx\nfi" | sudo tee -a /home/$USER_NAME/.bash_profile
sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/.bash_profile

# Прописываем запуск Steam в Big Picture (Режим консоли)
echo "exec steam -tenfoot" | sudo tee /home/$USER_NAME/.xinitrc
sudo chmod +x /home/$USER_NAME/.xinitrc
sudo chown $USER_NAME:$USER_NAME /home/$USER_NAME/.xinitrc

# Включаем сеть
sudo systemctl enable NetworkManager

echo "=================================================="
echo "===    ВСЁ ГОТОВО! НОУТ УХОДИТ В ПЕРЕЗАГРУЗКУ   ==="
echo "=================================================="
sleep 3
sudo reboot

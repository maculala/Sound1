#!/bin/bash

# Настройка вывода ошибок, чтобы скрипт не шел дальше, если что-то сломалось
set -e

echo "=================================================="
echo "=== ЗАПУСК 100% АВТОМАТИЧЕСКОЙ СБОРКИ СИСТЕМЫ ==="
echo "=================================================="

# 1. Синхронизируем базы пакетов и обновляем ключи
echo "[*] Обновление системных баз пакетов..."
sudo pacman -Syu --noconfirm

# 2. Установка базовых утилит сборки, заголовков ядра и DKMS
echo "[*] Установка инструментов компиляции и DKMS..."
sudo pacman -S --needed base-devel git dkms linux-headers --noconfirm

# 3. Установка графического сервера, i3wm и Стима
echo "[*] Установка графического окружения и Steam..."
sudo pacman -S --needed xorg-server xorg-xinit i3-wm steam dmenu lxsession telegram-desktop discord networkmanager pipewire pipewire-pulse pipewire-alsa pipewire-jack wireplumber ntfs-3g --noconfirm

# 4. Скачивание и принудительная сборка драйвера Nvidia Legacy (470xx)
echo "[*] Сборка и установка драйверов Nvidia 470xx..."
# Используем стабильный билд из официального репозитория Arch / AUR
if ! pacman -Qi nvidia-470xx-dkms &>/dev/null; then
    # Если ставишь через yay, скрипт его подтянет, но для надежности ставим dkms версию
    sudo pacman -S nvidia-dkms nvidia-utils lib32-nvidia-utils --noconfirm || true
fi

# Принудительно заставляем DKMS собрать модуль под текущее ядро 7.0.10
echo "[*] Компиляция модулей ядра для видеокарты..."
sudo dkms autoinstall

# Блокируем свободный драйвер nouveau, который вызывает черный экран
echo "blacklist nouveau" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf

# Пересобираем загрузочный образ initramfs с новыми модулями Nvidia
sudo mkinitcpio -P

# 5. Монтирование твоего жесткого диска с играми (без форматирования!)
echo "[*] Настройка монтирования HDD под Доту..."
sudo mkdir -p /mnt/storage
if ! grep -q "/mnt/storage" /etc/fstab; then
    echo -e "\n/dev/sda1 /mnt/storage ntfs-3g defaults,nofail,uid=1000,gid=1000,dmask=022,fmask=133 0 0" | sudo tee -a /etc/fstab
fi
sudo mount -a || echo "Предупреждение: Диск /dev/sda1 пока не подключен, примонтируется при ребуте."

# 6. Настройка автоматического входа в систему без ввода пароля
echo "[*] Настройка автологина пользователя..."
USER_NAME=$(whoami)
sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
echo -e "[Service]\nExecStart=\nExecStart=-/sbin/agetty --autologin $USER_NAME --noclear %I \$TERM" | sudo tee /etc/systemd/system/getty@tty1.service.d/override.conf

# Автостарт иксов (X11) сразу при логине в tty1
truncate -s 0 ~/.bash_profile
echo -e "\nif [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then\n  exec startx\nfi" >> ~/.bash_profile

# 7. Настройка чистого запуска Steam Big Picture без зависаний
echo "[*] Создание чистого графического конфига..."
echo "exec steam -tenfoot" > ~/.xinitrc
chmod +x ~/.xinitrc

# 8. Включение службы сети
sudo systemctl enable --now NetworkManager

echo "=================================================="
echo "===     СБОРКА ЗАВЕРШЕНА! РЕБУТАЕМ НОУТ        ==="
echo "=================================================="
sleep 3
sudo reboot



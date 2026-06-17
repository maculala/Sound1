#!/bin/bash

echo "=== Переход на легкий i3wm для обхода Big Picture ==="

# 1. Устанавливаем i3wm вместо openbox
echo "[1/4] Установка i3-wm..."
sudo pacman -S --needed --noconfirm ntfs-3g i3-wm

# 2. Монтируем диск
sudo mkdir -p /mnt/storage
sudo umount /mnt/storage 2>/dev/null
sudo mount -a

# 3. Чистим старый кэш Стима
sudo pkill -9 steam 2>/dev/null
rm -f ~/.local/share/Steam/registry.vdf

# 4. Пишем новый скрипт запуска сессии через i3
cat << 'INNER_EOF' > ~/.local/share/Steam/dota_session.sh
#!/bin/bash

# Запускаем Стим в фоне (i3 сам подхватит его как обычное окно ПК)
/usr/bin/steam -nofriendsui -nochatui -applaunch 570 &

# Стартуем оконный менеджер i3
exec i3
INNER_EOF

chmod +x ~/.local/share/Steam/dota_session.sh

echo "[ОК] Скрипт переведен на i3wm!"

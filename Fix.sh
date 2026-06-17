#!/bin/bash

echo "=== Финальный конфиг: Запуск через XFCE ==="

# 1. Проверяем, что диск на месте
sudo mkdir -p /mnt/storage
sudo umount /mnt/storage 2>/dev/null
sudo mount -a

# 2. Полностью сносим старый скрипт сессии и пишем правильный запуск
cat << 'INNER_EOF' > ~/.local/share/Steam/dota_session.sh
#!/bin/bash

# Запускаем Стим в фоновом режиме, чтобы он не вешал графику
/usr/bin/steam -nofriendsui -nochatui -applaunch 570 &

# Запускаем сам рабочий стол XFCE, который прикроет Стим от Big Picture режима
exec startxfce4
INNER_EOF

chmod +x ~/.local/share/Steam/dota_session.sh

echo "[УСПЕХ] Конфиг обновлен!"

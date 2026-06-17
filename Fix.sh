#!/bin/bash

echo "=== Финальный фикс: Настройка через xinit ==="

# 1. Монтируем диск
sudo mkdir -p /mnt/storage
sudo umount /mnt/storage 2>/dev/null
sudo mount -a

# 2. Убиваем зависший Стим
sudo pkill -9 steam 2>/dev/null
rm -f ~/.local/share/Steam/registry.vdf

# 3. Пишем конфиг для чистого запуска X-сервера
cat << 'EOF' > ~/.xinitrc
#!/bin/bash

# Запускаем оконный менеджер, чтобы Стим не падал в сегфолт
openbox &

# Даем системе проснуться
sleep 1

# Запускаем Стим в обычном десктопном режиме
exec steam -nofriendsui -nochatui -applaunch 570
EOF

echo "[ОК] Конфиг .xinitrc создан в домашней папке!"

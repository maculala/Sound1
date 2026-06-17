#!/bin/bash

echo "=== Запуск супер-конфига: Диск + Чисто Дота ==="

# 1. Устанавливаем драйвер для NTFS (если его нет)
echo "[1/4] Проверка драйвера NTFS..."
sudo pacman -S --needed --noconfirm ntfs-3g

# 2. Настройка автомонтирования диска в /etc/fstab
echo "[2/4] Настройка автозагрузки диска /mnt/storage..."
# Проверяем, нет ли уже этой записи в fstab, чтобы не дублировать
if ! grep -q "D20A03F00A03D101" /etc/fstab; then
    sudo mkdir -p /mnt/storage
    echo "UUID=D20A03F00A03D101 /mnt/storage ntfs-3g defaults,uid=1000,gid=1000,rw,nofail 0 0" | sudo tee -a /etc/fstab
    echo "[OK] Диск успешно добавлен в /etc/fstab"
else
    echo "[!] Диск уже был прописан в /etc/fstab"
fi

# Принудительно монтируем прямо сейчас
sudo umount /mnt/storage 2>/dev/null
sudo mount -a

# 3. Блокировка Big Picture (убиваем Стим и чистим конфиг)
echo "[3/4] Сброс интерфейса Стима на обычные окна..."
sudo pkill -9 steam 2>/dev/null
mkdir -p ~/.local/share/Steam/

cat << 'INNER_EOF' > ~/.local/share/Steam/registry.vdf
"Registry"
{
  "HKCU"
  {
    "Software"
    {
      "Valve"
      {
        "Steam"
        {
          "StartupToGamepadUI" "0"
          "ConnectToSubManager" "0"
        }
      }
    }
  }
}
INNER_EOF

# 4. Обновление скрипта автозапуска сессии
echo "[4/4] Обновление скрипта запуска Доты..."
cat << 'INNER_EOF' > ~/.local/share/Steam/dota_session.sh
#!/bin/bash

# Еще раз страхуемся по поводу конфига перед каждым стартом
mkdir -p ~/.local/share/Steam/
cat << 'REG_EOF' > ~/.local/share/Steam/registry.vdf
"Registry"
{
  "HKCU"
  {
    "Software"
    {
      "Valve"
      {
        "Steam"
        {
          "StartupToGamepadUI" "0"
          "ConnectToSubManager" "0"
        }
      }
    }
  }
}
REG_EOF

# Запуск Стима в оконном режиме (-vgui) и старт Доты
exec /usr/bin/steam -vgui -applaunch 570
INNER_EOF

chmod +x ~/.local/share/Steam/dota_session.sh

echo "============================================="
echo "[УСПЕХ] Всё настроено! Диск привязан, режим обновлен."
echo "Можно отправлять ноут в перезагрузку: sudo reboot"
echo "============================================="

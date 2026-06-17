#!/bin/bash

echo "=== Запуск супер-конфига: Диск + Обман Big Picture ==="

# 1. Доставляем openbox (чтобы Стим думал, что мы в полноценной системе)
echo "[1/4] Проверка необходимых пакетов..."
sudo pacman -S --needed --noconfirm ntfs-3g openbox

# 2. Настройка автомонтирования диска в /etc/fstab
echo "[2/4] Настройка автозагрузки диска /mnt/storage..."
if ! grep -q "D20A03F00A03D101" /etc/fstab; then
    sudo mkdir -p /mnt/storage
    echo "UUID=D20A03F00A03D101 /mnt/storage ntfs-3g defaults,uid=1000,gid=1000,rw,nofail 0 0" | sudo tee -a /etc/fstab
    echo "[OK] Диск успешно добавлен в /etc/fstab"
else
    echo "[!] Диск уже был прописан in /etc/fstab"
fi

sudo umount /mnt/storage 2>/dev/null
sudo mount -a

# 3. Полный сброс параметров интерфейса Стима
echo "[3/4] Сброс настроек Steam интерфейса..."
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
          "GamepadUI" "0"
        }
      }
    }
  }
}
INNER_EOF

# 4. Обновление скрипта сессии с запуском оконного менеджера
echo "[4/4] Обновление скрипта запуска Доты..."
cat << 'INNER_EOF' > ~/.local/share/Steam/dota_session.sh
#!/bin/bash

# Сбрасываем конфиг перед стартом
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
          "GamepadUI" "0"
        }
      }
    }
  }
}
REG_EOF

# ЗАПУСКАЕМ ЛЕГКУЮ ОБОЛОЧКУ В ФОНЕ (скроет Big Picture)
openbox &

# Запускаем Стим в обычном режиме десктопа
exec /usr/bin/steam -nofriendsui -nochatui -applaunch 570
INNER_EOF

chmod +x ~/.local/share/Steam/dota_session.sh

echo "============================================="
echo "[УСПЕХ] Скрипт обновлен. Пробуй запускать!"
echo "============================================="

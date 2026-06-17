#!/bin/bash

echo "=== Запуск ультимативного конфига: Диск + Полная блокировка Big Picture ==="

# 1. Устанавливаем необходимые пакеты
echo "[1/4] Проверка драйвера NTFS и оконного менеджера..."
sudo pacman -S --needed --noconfirm ntfs-3g openbox

# 2. Настройка автомонтирования диска в /etc/fstab
echo "[2/4] Настройка автозагрузки диска /mnt/storage..."
# Удаляем старые упоминания этого диска, если они были, чтобы не плодить дубли
sudo sed -i '/D20A03F00A03D101/d' /etc/fstab

# Прописываем диск с правильными правами доступа для чтения и записи
sudo mkdir -p /mnt/storage
echo "UUID=D20A03F00A03D101 /mnt/storage ntfs-3g defaults,uid=1000,gid=1000,rw,nofail 0 0" | sudo tee -a /etc/fstab
echo "[OK] Диск прописан в /etc/fstab"

# Перемонтируем диск прямо сейчас
sudo umount /mnt/storage 2>/dev/null
sudo mount -a

# 3. Полная зачистка старых конфигов и кэша интерфейса Стима
echo "[3/4] Сброс кэша и интерфейса Стима..."
sudo pkill -9 steam 2>/dev/null
sleep 1

# Удаляем кэш разметки интерфейса, который заставляет Стим помнить Big Picture
rm -rf ~/.local/share/Steam/appcache/
rm -rf ~/.local/share/Steam/ubuntu12_32/config/
rm -f ~/.local/share/Steam/registry.vdf

# Жестко выключаем режим Big Picture (GamepadUI) в файле конфигурации
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

# Изменяем имя папки tenfoot (интерфейс Big Picture), чтобы Стим физически не смог его включить
if [ -d "$HOME/.local/share/Steam/tenfoot" ]; then
    mv "$HOME/.local/share/Steam/tenfoot" "$HOME/.local/share/Steam/tenfoot_disabled" 2>/dev/null
fi

# 4. Создание обновленного скрипта сессии «Чисто Дота»
echo "[4/4] Обновление скрипта запуска сессии Доты..."
cat << 'INNER_EOF' > ~/.local/share/Steam/dota_session.sh
#!/bin/bash

# Принудительно задаем переменные окружения обычного ПК
export STEAM_FRAME_FORCE_CLOSE=0
export SDL_VIDEODRIVER=x11
export XDG_CURRENT_DESKTOP=X-Generic

# На всякий случай дублируем сброс конфига перед каждым стартом
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

# Запускаем фоном легкую графическую оболочку, чтобы Стим видел оконную систему
openbox &

# Запускаем Стим в обычном десктопном режиме и стартуем Доту (ID 570)
exec /usr/bin/steam -nofriendsui -nochatui -vgui -applaunch 570
INNER_EOF

# Делаем скрипт запуска исполняемым
chmod +x ~/.local/share/Steam/dota_session.sh

echo "============================================="
echo "[УСПЕХ] Скрипт полностью обновлен!"
echo "Теперь запускай команду в консоли и делай ребут."
echo "============================================="

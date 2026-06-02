cat << 'EOF' > ~/fix_steam_all.sh
#!/bin/bash

echo "=== Полная настройка Стима и Автозагрузки ==="

# 1. Вырубаем Стим под корень
sudo pkill -9 steam 2>/dev/null
sleep 1

# 2. Создаем чистый registry.vdf, блокирующий Big Picture
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

# 3. Добавляем Стим в автозагрузку системы в обычном оконном режиме
mkdir -p ~/.config/autostart
cat << 'INNER_EOF' > ~/.config/autostart/steam.desktop
[Desktop Entry]
Name=Steam
Comment=Application for managing and playing games on Steam
Exec=/usr/bin/steam -silent
Icon=steam
Terminal=false
Type=Application
Categories=Network;FileTransfer;Game;
INNER_EOF

# 4. Чистим мусор и привязываем Доту с внешнего диска
STEAM_APPS="$HOME/.local/share/Steam/steamapps"
rm -rf "$STEAM_APPS/common" "$STEAM_APPS/downloading" "$STEAM_APPS/appmanifest_570.acf"
mkdir -p "$STEAM_APPS/common"

# Проверяем, где лежит Дота на /mnt/storage
if [ -d "/mnt/storage/SteamLibrary/steamapps" ]; then
    SOURCE_DIR="/mnt/storage/SteamLibrary/steamapps"
elif [ -d "/mnt/storage/steamapps" ]; then
    SOURCE_DIR="/mnt/storage/steamapps"
else
    SOURCE_DIR="/mnt/storage"
fi

# Создаем символические ссылки
if [ -f "$SOURCE_DIR/appmanifest_570.acf" ]; then
    ln -s "$SOURCE_DIR/appmanifest_570.acf" "$STEAM_APPS/"
fi

if [ -d "$SOURCE_DIR/common/dota 2 beta" ]; then
    ln -s "$SOURCE_DIR/common/dota 2 beta" "$STEAM_APPS/common/"
elif [ -d "$SOURCE_DIR/dota 2 beta" ]; then
    ln -s "$SOURCE_DIR/dota 2 beta" "$STEAM_APPS/common/"
fi

echo "[OK] Всё готово! Автозагрузка настроена, обычный режим закреплен."
EOF

chmod +x ~/fix_steam_all.sh
~/fix_steam_all.sh

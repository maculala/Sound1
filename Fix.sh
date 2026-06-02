#!/bin/bash

echo "=== Запуск фикса Стима и Доты ==="

# 1. Жестко закрываем Стим, если он запущен
sudo pkill -9 steam 2>/dev/null
sleep 1

# 2. Сбрасываем Big Picture / GamepadUI в обычный десктопный режим
REG_FILE="$HOME/.local/share/Steam/registry.vdf"
if [ -f "$REG_FILE" ]; then
    echo "Настраиваем обычный оконный режим..."
    # Удаляем старые переключатели интерфейса, если они есть
    sed -i '/"StartupToGamepadUI"/d' "$REG_FILE"
    sed -i '/"ConnectToSubManager"/d' "$REG_FILE"
    
    # Прописываем принудительный запуск в десктопе перед закрывающей скобкой
    sed -i 's/"Steam"[[:space:]]*{/"Steam"\n    {\n      "StartupToGamepadUI" "0"\n      "ConnectToSubManager" "0"/1' "$REG_FILE"
fi

# 3. Чистим конфликтующие пустые папки, которые Стим создал при попытке скачивания
STEAM_APPS="$HOME/.local/share/Steam/steamapps"
echo "Очищаем мусорные папки в домашнем каталоге..."
rm -rf "$STEAM_APPS/common"
rm -rf "$STEAM_APPS/downloading"
rm -rf "$STEAM_APPS/appmanifest_570.acf"

# Создаем чистую папку common, если её нет
mkdir -p "$STEAM_APPS/common"

# 4. Ищем, где именно на внешнем диске лежат файлы Доты
if [ -d "/mnt/storage/SteamLibrary/steamapps" ]; then
    SOURCE_DIR="/mnt/storage/SteamLibrary/steamapps"
elif [ -d "/mnt/storage/steamapps" ]; then
    SOURCE_DIR="/mnt/storage/steamapps"
else
    SOURCE_DIR="/mnt/storage"
fi

echo "Найдена папка с играми по пути: $SOURCE_DIR"

# 5. Намертво связываем манифест и файлы Доты с родной папкой Стима
echo "Создаем символические ссылки на Доту..."
if [ -f "$SOURCE_DIR/appmanifest_570.acf" ]; then
    ln -s "$SOURCE_DIR/appmanifest_570.acf" "$STEAM_APPS/"
fi

if [ -d "$SOURCE_DIR/common/dota 2 beta" ]; then
    ln -s "$SOURCE_DIR/common/dota 2 beta" "$STEAM_APPS/common/"
elif [ -d "$SOURCE_DIR/dota 2 beta" ]; then
    ln -s "$SOURCE_DIR/dota 2 beta" "$STEAM_APPS/common/"
fi

echo "[OK] Всё готово! Переключайся в графику (Ctrl+Alt+F1) и запускай Стим."

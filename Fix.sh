#!/bin/bash

echo "=== Финальный фикс: Обман Steam через Символические ссылки ==="

# 1. Жестко тушим Стим
echo "[1/4] Закрытие Steam..."
sudo pkill -9 steam 2>/dev/null
sleep 1

# 2. Проверяем монтирование диска и создаем правильную структуру папок
echo "[2/4] Подготовка папок на жестком диске..."
sudo mkdir -p /mnt/storage
sudo mount -a

# Создаем структуру папок Стима на внешнем диске
mkdir -p /mnt/storage/SteamLibrary/steamapps/common
mkdir -p /mnt/storage/SteamLibrary/steamapps/downloading
mkdir -p /mnt/storage/SteamLibrary/steamapps/shadercache

# Выставляем полные права
sudo chown -R $USER:$USER /mnt/storage
sudo chmod -R 777 /mnt/storage

# 3. Чистим дефолтные папки Стима на SSD и создаем ссылки
echo "[3/4] Создание символических ссылок..."
STEAM_BASE="$HOME/.local/share/Steam/steamapps"
mkdir -p "$STEAM_BASE"

# Перемещаем/удаляем старые папки на SSD, чтобы они не мешали ссылкам
rm -rf "$STEAM_BASE/common" "$STEAM_BASE/downloading" "$STEAM_BASE/shadercache"

# Прокладываем "туннели" на твой NTFS-диск
ln -s /mnt/storage/SteamLibrary/steamapps/common "$STEAM_BASE/common"
ln -s /mnt/storage/SteamLibrary/steamapps/downloading "$STEAM_BASE/downloading"
ln -s /mnt/storage/SteamLibrary/steamapps/shadercache "$STEAM_BASE/shadercache"

# 4. Возвращаем чистый дефолтный конфиг библиотек (чтобы Стим не путался)
echo "[4/4] Сброс конфигурации библиотек..."
mkdir -p ~/.local/share/Steam/config/
cat << 'EOF' > ~/.local/share/Steam/config/libraryfolders.vdf
"libraryfolders"
{
	"0"
	{
		"path"		"/home/kirill/.local/share/Steam"
		"label"		""
		"mounted"		"1"
	}
}
EOF

echo "============================================="
echo "[УСПЕХ] Обман системы настроен! Кнопка Add Drive больше не нужна."
echo "============================================="

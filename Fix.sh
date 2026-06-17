#!/bin/bash

echo "=== Настройка проводника + привязка диска к Steam ==="

# 1. Устанавливаем легкий проводник PCManFM
echo "[1/4] Установка легкого файлового менеджера..."
sudo pacman -S --needed --noconfirm pcmanfm

# 2. Проверяем монтирование диска и создаем нужную папку для Стима
echo "[2/4] Подготовка папок на диске..."
sudo mkdir -p /mnt/storage
sudo mount -a

# Создаем папку SteamLibrary на диске, если её нет
mkdir -p /mnt/storage/SteamLibrary
# Выставляем права, чтобы Стим мог туда писать файлы без запинок
sudo chown -R $USER:$USER /mnt/storage
sudo chmod -R 777 /mnt/storage

# 3. Жестко прописываем диск в конфиг библиотек Стима
echo "[3/4] Регистрация диска в конфигах Steam..."
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
	"1"
	{
		"path"		"/mnt/storage/SteamLibrary"
		"label"		"Games"
		"mounted"		"1"
	}
}
EOF

# 4. Обновляем твой .xinitrc, чтобы проводник помогал Стиму работать
echo "[4/4] Обновление автозапуска графики..."
cat << 'EOF' > ~/.xinitrc
#!/bin/bash

# Запускаем оконный менеджер
openbox &

# Запускаем проводник в режиме поддержки рабочего стола (чтобы работали диалоги)
pcmanfm --desktop &

sleep 1

# Запускаем Стим
exec steam -nofriendsui -nochatui -applaunch 570
EOF

echo "============================================="
echo "[УСПЕХ] Конфиг обновлен! Проводник готов."
echo "============================================="

#!/bin/bash

install_package() {
    local pkg="$1"
    if ! pacman -Qs "$pkg" > /dev/null; then
        sudo pacman -S --noconfirm "$pkg" || { echo "Ошибка установки $pkg. Завершение работы."; exit 1; }
    fi
}

packages=(bspwm kitty sxhkd vim ttf-dejavu picom feh gnome-keyring xorg-xsetroot xorg-xrandr)

for pkg in "${packages[@]}"; do
    install_package "$pkg"
done

mkdir -p $HOME/.config/bspwm $HOME/.config/picom $HOME/.config/kitty $HOME/wallpapers

cd $HOME/Downloads || { echo "Не удалось перейти в директорию $HOME/Downloads. Завершение работы."; exit 1; }

for src in "${!files_to_move[@]}"; do
    if [ -f "$src" ]; then
        mv "$src" "${files_to_move[$src]}"
    fi
done

declare -A files_to_move=(
    [$HOME/Downloads/config/bspwmrc]=$HOME/.config/bspwm
    [$HOME/Downloads/config/sxhkdrc]=$HOME/.config/bspwm
    [$HOME/Downloads/config/picom.conf]=$HOME/.config/picom
    [$HOME/Downloads/config/kitty.conf]=$HOME/.config/kitty
    [$HOME/Downloads/config/theme.conf]=$HOME/.config/kitty
    [$HOME/Downloads/grass.jpg]=$HOME/wallpapers
    [$HOME/Downloads/.xsession]=$HOME/
)

chmod +x $HOME/.config/bspwm/bspwmrc $HOME/.xsession $HOME/Downloads/*.sh $HOME/Downloads/config/*.sh $HOME/Downloads/firefox/*.sh

./display.sh
./cpu.sh

echo "Дополнительные пакеты для установки:"
echo "1. yay"
echo "2. cava"
echo "3. nvidia-settings"
echo "4. minecraft-launcher"

read -p "Введите номера дополнительных пакетов для установки (через пробел): " -a selected_additional_indices

for index in "${selected_additional_indices[@]}"; do
    case "$index" in
        1)
            sudo pacman -S --noconfirm base-devel
            if [ ! -d "$HOME/.yay" ]; then
                git clone https://aur.archlinux.org/yay.git /tmp/yay
                cd /tmp/yay || exit 1
                makepkg -si --noconfirm
                rm -rf /tmp/yay
            fi
            ;;
        2)
            sudo yay -S --noconfirm cava
            ;;
        3)
            sudo pacman -S --noconfirm nvidia-settings
            ;;
        4)
            sudo yay -S --noconfirm minecraft-launcher
            ;;
        *)
            echo "Некорректный номер: $index"
            ;;
    esac
done

sudo pacman -S --noconfirm ly
sudo systemctl enable ly.service

echo "Система требует перезагрузки."

exit 0

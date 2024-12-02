#!/bin/bash

# ------------------------------------------------------
# Verificar si se ejecuta como root
# ------------------------------------------------------
if [ "$(id -u)" = 0 ]; then
    echo "Este script no debe ejecutarse como root"
    exit 1
fi

# ------------------------------------------------------
# Instalar yay si no está instalado
# ------------------------------------------------------
if ! command -v yay &> /dev/null; then
    echo "Instalando yay..."
    sudo pacman -S --needed --noconfirm base-devel git
    git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
    cd /tmp/yay-git || exit
    makepkg -si --noconfirm
    cd - || exit
    rm -rf /tmp/yay-git
fi

# ------------------------------------------------------
# Actualizar el sistema e instalar dependencias básicas
# ------------------------------------------------------
 
if [ ! "$current_browser" == "brave" ] ;then
    echo -e "${GREEN}"
    figlet "Browser"
    echo -e "${NONE}"
    echo ":: The current browser is $current_browser"
    if gum confirm "Do you want to install Brave instead?" ;then
        echo ":: Installing Brave..."
        yay -S --noconfirm brave-bin   
        echo ":: Setting Brave as Default browser" 
        xdg-settings set default-web-browser brave-browser.desktop
        
    elif [ $? -eq 130 ]; then
        echo ":: Installation canceled."
        exit 130
    else
        echo ":: Installation of Brave skipped"
    fi
fi
 
# Arch Linux Dotfiles Installation Script

# Define variables for repeated commands
PACKAGES="bspwm sxhkd alacritty neovim picom polybar rofi neofetch nemo gedit networkmanager network-manager-applet pulseaudio pavucontrol ttf-dejavu ttf-liberation htop xorg-xrandr feh redshift unzip p7zip tar"

# Update system and install necessary packages
echo "Updating system and installing necessary packages..."
sudo pacman -Syu --noconfirm $PACKAGES

# Install login manager (sddm)
# ------------------------------------------------------
echo "Installing SDDM..."
sudo pacman -S sddm --noconfirm

# Enable services
echo "Enabling necessary services..."
sudo systemctl enable sddm.service
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service

# Install and configure Zsh and Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Zsh and Oh My Zsh..."
    sudo pacman -S zsh --noconfirm
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

# Set Zsh as the default shell
echo "Setting Zsh as the default shell..."
chsh -s $(which zsh)

# Install Bluetooth support
# ------------------------------------------------------
echo "Installing Bluetooth support..."
sudo pacman -S bluez bluez-utils pulseaudio-bluetooth --noconfirm

# Install input device configuration tools
# ------------------------------------------------------
echo "Installing input device configuration tools..."
sudo pacman -S xorg-xinput --noconfirm
 
# Install archive support
# ------------------------------------------------------
echo "Instalación completada. El sistema se reiniciará en 5 segundos..."
sleep 5
sudo reboot

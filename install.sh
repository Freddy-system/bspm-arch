#!/bin/bash
# ------------------------------------------------------
# Check if yay is installed
# ------------------------------------------------------
if sudo pacman -Qs yay > /dev/null ; then
    echo ":: yay is already installed!"
else
    echo -e "${GREEN}"
    figlet "yay"
    echo -e "${NONE}"
    echo ":: yay is not installed. Starting the installation!"
    _installPackagesPacman "base-devel"
    SCRIPT=$(realpath "$0")
    temp_path=$(dirname "$SCRIPT")
    echo $temp_path
    git clone https://aur.archlinux.org/yay-git.git ~/yay-git
    cd ~/yay-git
    makepkg -si
    cd $temp_path
    echo ":: yay has been installed successfully."
fi
echo
# ------------------------------------------------------

# Arch Linux Dotfiles Installation Script

# Define variables for repeated commands
PACKAGES="bspwm sxhkd alacritty neovim picom polybar rofi neofetch nemo gedit networkmanager network-manager-applet pulseaudio pavucontrol ttf-dejavu ttf-liberation htop xorg-xrandr feh redshift unzip p7zip tar"

# 1. Verificar e instalar yay
# (Este paso ya está presente al inicio del script)

# 2. Actualizar el sistema e instalar paquetes básicos
echo "Actualizando el sistema e instalando paquetes básicos..."
sudo pacman -Syu --noconfirm $PACKAGES

# 3. Instalar y configurar SDDM
echo "Instalando y configurando SDDM..."
sudo pacman -S sddm --noconfirm
sudo systemctl enable sddm.service

# 4. Instalar Zsh y Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Instalando Zsh y Oh My Zsh..."
    sudo pacman -S zsh --noconfirm
    RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
fi

# 5. Instalar dependencias adicionales para Polybar y otros componentes
echo "Instalando dependencias adicionales..."
sudo pacman -S --noconfirm playerctl

# 6. Instalar temas e iconos
echo "Instalando temas e iconos..."
sudo pacman -S --noconfirm arc-gtk-theme papirus-icon-theme

# 7. Copiar archivos de configuración
echo "Copiando archivos de configuración..."
cp -r ~/Downloads/bspm-arch/bspwm ~/.config/
cp -r ~/Downloads/bspm-arch/sxhkd ~/.config/
cp -r ~/Downloads/bspm-arch/alacritty ~/.config/
cp -r ~/Downloads/bspm-arch/nvim ~/.config/
cp -r ~/Downloads/bspm-arch/picom ~/.config/
cp -r ~/Downloads/bspm-arch/polybar ~/.config/
cp -r ~/Downloads/bspm-arch/rofi ~/.config/

# 8. Configurar SDDM para usar BSPWM 

# 9. Verificar scripts de inicio 
echo "Verificando la ejecución de scripts de inicio..."
if [ ! -f "$HOME/.config/bspwm/bspwmrc" ]; then
    echo "El archivo bspwmrc no se encuentra en ~/.config/bspwm. Copiando..."
    cp ~/Downloads/bspm-arch/bspwm/bspwmrc ~/.config/bspwm/
fi

if [ ! -f "$HOME/.config/sxhkd/sxhkdrc" ]; then
    echo "El archivo sxhkdrc no se encuentra en ~/.config/sxhkd. Copiando..."
    cp ~/Downloads/bspm-arch/sxhkd/sxhkdrc ~/.config/sxhkd/
fi

# Habilitar servicios adicionales
sudo systemctl enable NetworkManager.service
sudo systemctl enable bluetooth.service

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
echo "Installing archive support tools..."
sudo pacman -S unzip p7zip tar --noconfirm

# Verificar y configurar archivos de configuración
if [ ! -f "$HOME/.config/bspwm/bspwmrc" ]; then
    echo "El archivo bspwmrc no se encuentra en ~/.config/bspwm. Copiando..."
    cp ~/Downloads/bspm-arch/bspwm/bspwmrc ~/.config/bspwm/
fi
chmod +x ~/.config/bspwm/bspwmrc

if [ ! -f "$HOME/.config/sxhkd/sxhkdrc" ]; then
    echo "El archivo sxhkdrc no se encuentra en ~/.config/sxhkd. Copiando..."
    cp ~/Downloads/bspm-arch/sxhkd/sxhkdrc ~/.config/sxhkd/
fi
chmod +x ~/.config/sxhkd/sxhkdrc

# Configurar SDDM para usar BSPWM
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/bspwm.desktop > /dev/null <<EOL
[Desktop Entry]
Name=BSPWM
Comment=Binary Space Partitioning Window Manager
Exec=bspwm
Type=Application
EOL

# Reiniciar el sistema para aplicar cambios
echo "Reiniciando el sistema para aplicar cambios..."
sudo reboot

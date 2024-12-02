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
echo "Actualizando el sistema..."
sudo pacman -Syu --noconfirm

# Xorg y drivers
echo "Instalando Xorg y drivers..."
sudo pacman -S --noconfirm xorg-server xorg-xinit xorg-apps xorg-xrandr xorg-xsetroot mesa

# BSPWM y componentes principales
echo "Instalando BSPWM y componentes principales..."
sudo pacman -S --noconfirm bspwm sxhkd picom polybar rofi feh alacritty

# Audio y Bluetooth
echo "Instalando soporte de audio y bluetooth..."
sudo pacman -S --noconfirm pulseaudio pulseaudio-alsa pulseaudio-bluetooth pavucontrol alsa-utils bluez bluez-utils
sudo systemctl enable --now bluetooth.service

# Red y utilidades
echo "Instalando herramientas de red..."
sudo pacman -S --noconfirm networkmanager network-manager-applet
sudo systemctl enable --now NetworkManager.service

# Aplicaciones adicionales
echo "Instalando aplicaciones adicionales..."
sudo pacman -S --noconfirm neovim neofetch htop

# Fuentes y temas
echo "Instalando fuentes y temas..."
sudo pacman -S --noconfirm ttf-dejavu ttf-liberation noto-fonts arc-gtk-theme papirus-icon-theme

# ------------------------------------------------------
# Instalar aplicaciones desde AUR
# ------------------------------------------------------
echo "Instalando aplicaciones desde AUR..."
yay -S --noconfirm brave-bin

# ------------------------------------------------------
# Crear y configurar directorios
# ------------------------------------------------------
echo "Configurando directorios..."
mkdir -p ~/.config/{bspwm,sxhkd,picom,polybar,rofi,alacritty}

# ------------------------------------------------------
# Copiar archivos de configuración
# ------------------------------------------------------
echo "Copiando archivos de configuración..."
cp -r ~/Downloads/bspm-arch/bspwm/* ~/.config/bspwm/
cp -r ~/Downloads/bspm-arch/sxhkd/* ~/.config/sxhkd/
cp -r ~/Downloads/bspm-arch/picom/* ~/.config/picom/
cp -r ~/Downloads/bspm-arch/polybar/* ~/.config/polybar/
cp -r ~/Downloads/bspm-arch/rofi/* ~/.config/rofi/
cp -r ~/Downloads/bspm-arch/alacritty/* ~/.config/alacritty/

# ------------------------------------------------------
# Configurar permisos
# ------------------------------------------------------
echo "Configurando permisos..."
chmod +x ~/.config/bspwm/bspwmrc
chmod +x ~/.config/sxhkd/sxhkdrc
sudo chown -R $USER:$USER ~/.config/{bspwm,sxhkd,picom,polybar,rofi,alacritty}

# ------------------------------------------------------
# Configurar SDDM y sesión de BSPWM
# ------------------------------------------------------
echo "Configurando SDDM y sesión de BSPWM..."
sudo pacman -S --noconfirm sddm
sudo systemctl enable sddm.service

# Crear archivo de sesión para BSPWM
sudo mkdir -p /usr/share/xsessions
sudo tee /usr/share/xsessions/bspwm.desktop > /dev/null <<EOL
[Desktop Entry]
Name=BSPWM
Comment=Binary Space Partitioning Window Manager
Exec=bspwm
Type=Application
Categories=Utility;WindowManager;
EOL

# ------------------------------------------------------
# Configurar xinitrc para iniciar BSPWM
# ------------------------------------------------------
echo "Configurando xinitrc..."
tee ~/.xinitrc > /dev/null <<EOL
#!/bin/sh

# Cargar configuraciones de X
[ -f /etc/X11/xinit/xinitrc.d/?*.sh ] && . /etc/X11/xinit/xinitrc.d/?*.sh

# Configuraciones personalizadas
xsetroot -cursor_name left_ptr &  # Establecer cursor predeterminado
sxhkd &                           # Iniciar demonio de atajos de teclado
picom &                           # Iniciar compositor
polybar &                         # Iniciar barra de estado
feh --bg-fill ~/Wallpapers/wallpaper.jpg &  # Establecer fondo de pantalla

# Iniciar BSPWM como último paso
exec bspwm
EOL
chmod +x ~/.xinitrc

# ------------------------------------------------------
# Configurar shell
# ------------------------------------------------------
echo "Configurando Zsh..."
sudo pacman -S --noconfirm zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    chsh -s $(which zsh)
fi

# ------------------------------------------------------
# Verificación final
# ------------------------------------------------------
echo "Verificando instalación..."
if [ ! -x ~/.config/bspwm/bspwmrc ]; then
    echo "Error: bspwmrc no encontrado o sin permisos de ejecución"
    exit 1
fi

if [ ! -x ~/.config/sxhkd/sxhkdrc ]; then
    echo "Error: sxhkdrc no encontrado o sin permisos de ejecución"
    exit 1
fi

# ------------------------------------------------------
# Crear directorio de wallpapers
# ------------------------------------------------------
mkdir -p ~/Wallpapers

# ------------------------------------------------------
# Reiniciar
# ------------------------------------------------------
echo "Instalación completada. El sistema se reiniciará en 5 segundos..."
sleep 5
sudo reboot
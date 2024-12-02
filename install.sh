#!/bin/bash

# ------------------------------------------------------
# Funciones de utilidad
# ------------------------------------------------------
print_section() {
    echo -e "\n\033[1;33m# ------------------------------------------------------"
    echo "# $1"
    echo -e "# ------------------------------------------------------\033[0m"
}

check_error() {
    if [ $? -ne 0 ]; then
        echo -e "\033[1;31mError: $1\033[0m"
        exit 1
    fi
}

# ------------------------------------------------------
# Verificaciones iniciales
# ------------------------------------------------------
print_section "Verificaciones iniciales"

# Verificar si se ejecuta como root
if [ "$(id -u)" = 0 ]; then
    echo "Este script no debe ejecutarse como root"
    exit 1
fi

# Verificar conexión a internet
ping -c 1 8.8.8.8 > /dev/null 2>&1
check_error "No hay conexión a internet"

# ------------------------------------------------------
# Instalar yay
# ------------------------------------------------------
print_section "Instalando yay"

if ! command -v yay &> /dev/null; then
    sudo pacman -S --needed --noconfirm base-devel git
    check_error "Error al instalar dependencias de yay"
    
    git clone https://aur.archlinux.org/yay-git.git /tmp/yay-git
    check_error "Error al clonar yay"
    
    cd /tmp/yay-git || exit
    makepkg -si --noconfirm
    check_error "Error al instalar yay"
    
    cd - || exit
    rm -rf /tmp/yay-git
fi

# ------------------------------------------------------
# Actualizar sistema e instalar paquetes
# ------------------------------------------------------
print_section "Actualizando sistema e instalando paquetes"

# Actualizar sistema
sudo pacman -Syu --noconfirm
check_error "Error al actualizar el sistema"

# Instalar paquetes base
PACKAGES=(
    "xorg-server" "xorg-xinit" "xorg-apps" "xorg-xrandr" "xorg-xsetroot" "mesa"  # Xorg
    "bspwm" "sxhkd" "picom" "polybar" "rofi" "feh" "alacritty"                   # WM y componentes
    "pulseaudio" "pulseaudio-alsa" "pulseaudio-bluetooth" "pavucontrol"          # Audio
    "bluez" "bluez-utils"                                                         # Bluetooth
    "networkmanager" "network-manager-applet"                                     # Red
    "neovim" "neofetch" "htop"                                                   # Utilidades
    "ttf-dejavu" "ttf-liberation" "noto-fonts"                                   # Fuentes
    "arc-gtk-theme" "papirus-icon-theme"                                         # Temas
)

for package in "${PACKAGES[@]}"; do
    echo "Instalando $package..."
    sudo pacman -S --noconfirm "$package"
    check_error "Error al instalar $package"
done

# ------------------------------------------------------
# Habilitar servicios
# ------------------------------------------------------
print_section "Habilitando servicios"

# Habilitar y iniciar servicios
sudo systemctl enable --now NetworkManager.service
check_error "Error al habilitar NetworkManager"

sudo systemctl enable --now bluetooth.service
check_error "Error al habilitar Bluetooth"

# ------------------------------------------------------
# Instalar paquetes AUR
# ------------------------------------------------------
print_section "Instalando paquetes AUR"

yay -S --noconfirm brave-bin
check_error "Error al instalar brave-bin"

# ------------------------------------------------------
# Configurar directorios y archivos
# ------------------------------------------------------
print_section "Configurando directorios"

# Crear directorios de configuración
CONFIG_DIRS=(
    "bspwm" "sxhkd" "picom" "polybar" "rofi" "alacritty"
)

for dir in "${CONFIG_DIRS[@]}"; do
    mkdir -p "$HOME/.config/$dir"
    check_error "Error al crear directorio $dir"
done

# Copiar archivos de configuración
print_section "Copiando archivos de configuración"

DOTFILES_PATH="$HOME/Descargas/arch/dotfiles"
for dir in "${CONFIG_DIRS[@]}"; do
    if [ -d "$DOTFILES_PATH/$dir" ]; then
        cp -r "$DOTFILES_PATH/$dir/"* "$HOME/.config/$dir/"
        check_error "Error al copiar configuración de $dir"
    fi
done

# ------------------------------------------------------
# Configurar permisos
# ------------------------------------------------------
print_section "Configurando permisos"

# Establecer permisos de ejecución
chmod +x "$HOME/.config/bspwm/bspwmrc"
check_error "Error al configurar permisos de bspwmrc"

chmod +x "$HOME/.config/sxhkd/sxhkdrc"
check_error "Error al configurar permisos de sxhkdrc"

# Establecer propietario
sudo chown -R "$USER:$USER" "$HOME/.config"
check_error "Error al establecer propietario de archivos"

# ------------------------------------------------------
# Configurar SDDM
# ------------------------------------------------------
print_section "Configurando SDDM"

sudo pacman -S --noconfirm sddm
check_error "Error al instalar SDDM"

sudo systemctl enable sddm.service
check_error "Error al habilitar SDDM"

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
check_error "Error al crear archivo de sesión BSPWM"

# ------------------------------------------------------
# Configurar xinitrc
# ------------------------------------------------------
print_section "Configurando xinitrc"

cat > "$HOME/.xinitrc" << 'EOL'
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
check_error "Error al crear .xinitrc"

chmod +x "$HOME/.xinitrc"
check_error "Error al configurar permisos de .xinitrc"

# ------------------------------------------------------
# Configurar fondos de pantalla
# ------------------------------------------------------
print_section "Configurando fondos de pantalla"

# Crear directorio de wallpapers si no existe
mkdir -p "$HOME/Wallpapers"
check_error "Error al crear directorio de wallpapers"

# Copiar wallpaper específico si existe en el directorio de dotfiles
if [ -f "$DOTFILES_PATH/wallpapers/wave-nord.png" ]; then
    cp "$DOTFILES_PATH/wallpapers/wave-nord.png" "$HOME/Wallpapers/"
    check_error "Error al copiar wallpaper wave-nord.png"
    # Modificar .xinitrc para usar wave-nord.png
    sed -i "s|feh --bg-fill ~/Wallpapers/wallpaper.jpg|feh --bg-fill '$HOME/Wallpapers/wave-nord.png'|" "$HOME/.xinitrc"
    check_error "Error al configurar wallpaper en .xinitrc"
else
    echo "Wallpaper wave-nord.png no encontrado en $DOTFILES_PATH/wallpapers/"
    # Buscar cualquier wallpaper disponible como respaldo
    WALLPAPER=$(find "$HOME/Wallpapers" -type f \( -name "*.jpg" -o -name "*.jpeg" -o -name "*.png" \) | head -n 1)
    if [ -n "$WALLPAPER" ]; then
        sed -i "s|feh --bg-fill ~/Wallpapers/wallpaper.jpg|feh --bg-fill '$WALLPAPER'|" "$HOME/.xinitrc"
        check_error "Error al configurar wallpaper alternativo en .xinitrc"
    fi
fi

# ------------------------------------------------------
# Configurar shell
# ------------------------------------------------------
print_section "Configurando Zsh"

sudo pacman -S --noconfirm zsh
check_error "Error al instalar Zsh"

if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    check_error "Error al instalar Oh My Zsh"
    chsh -s "$(which zsh)"
    check_error "Error al cambiar shell por defecto"
fi

# ------------------------------------------------------
# Verificación final
# ------------------------------------------------------
print_section "Verificación final"

# Verificar archivos críticos
if [ ! -x "$HOME/.config/bspwm/bspwmrc" ]; then
    echo "Error: bspwmrc no encontrado o sin permisos de ejecución"
    exit 1
fi

if [ ! -x "$HOME/.config/sxhkd/sxhkdrc" ]; then
    echo "Error: sxhkdrc no encontrado o sin permisos de ejecución"
    exit 1
fi

# ------------------------------------------------------
# Finalización
# ------------------------------------------------------
print_section "Instalación completada"
echo "El sistema se reiniciará en 5 segundos..."
sleep 5
sudo reboot
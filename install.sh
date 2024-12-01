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
# ------------------------------------------------------
# Install tty login and issue
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
echo "Installing archive support tools..."
sudo pacman -S unzip p7zip tar --noconfirm

# Copy configuration files to the home directory
echo "Copying configuration files to the home directory..."
cp -r bspwm ~/.config/
cp -r sxhkd ~/.config/
cp -r alacritty ~/.config/
cp -r nvim ~/.config/
cp -r picom ~/.config/
cp -r polybar ~/.config/
cp -r rofi ~/.config/

# Print completion message
echo "Installation complete! Please restart your session to apply changes."

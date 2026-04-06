#!/bin/bash
set -e

echo "=> Установка базовых пакетов и linux-zen..."
pacstrap -K /mnt base base-devel linux-zen linux-zen-headers linux-firmware nano git wget curl

echo "=> Генерация fstab..."
genfstab -U /mnt >> /mnt/etc/fstab

echo "=> Настройка системы внутри chroot..."
arch-chroot /mnt /bin/bash <<EOF
set -e

# --- 1. Локализация и время ---
ln -sf /usr/share/zoneinfo/Europe/Helsinki /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# --- 2. Сеть ---
echo "arch-pc" > /etc/hostname

# --- 3. Пароли и Пользователь ---
echo "root:132123" | chpasswd
useradd -m -G wheel,video,audio,storage -s /bin/bash dark
echo "dark:123123" | chpasswd
echo "%wheel ALL=(ALL:ALL) ALL" > /etc/sudoers.d/wheel

# --- 4. Загрузчик ---
pacman -S --noconfirm grub efibootmgr
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# --- 5. Основное ПО (Официальные репозитории) ---
# Интерфейс, Сеть, Звук
pacman -S --noconfirm plasma-meta sddm konsole dolphin wayland xorg-xwayland \
networkmanager bluez bluez-utils pipewire pipewire-pulse pipewire-alsa wireplumber

# Твой список (Официальные пакеты)
pacman -S --noconfirm \
qbittorrent \
libreoffice-still \
steam \
firefox \
firefox-developer-edition \
nodejs npm \
python \
docker \
git \
telegram-desktop \
p7zip unrar unzip rsync # Архиваторы и утилиты

# --- 6. Службы ---
systemctl enable NetworkManager sddm bluetooth docker

# --- 7. AUR (yay) и специфичный софт ---
echo "=> Установка yay..."
sudo -u dark bash -c 'cd ~ && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm'

echo "=> Установка софта из AUR..."
# VS Code и Hiddify
sudo -u dark bash -c 'yay -S --noconfirm visual-studio-code-bin hiddify-next-bin'

EOF

echo "====================================================="
echo "Установка завершена! Пароль dark: 123123"
echo "Выполни: umount -R /mnt && reboot"
echo "====================================================="
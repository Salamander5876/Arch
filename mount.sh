#!/bin/bash

# --- НАСТРОЙКИ ДИСКОВ (ИЗМЕНИ ПОД СЕБЯ) ---
DISK_ROOT="/dev/nvme0n1p3"  # Твой основной раздел
DISK_EFI="/dev/nvme0n1p1"   # Твой EFI раздел (обычно 512МБ-1ГБ)
# ------------------------------------------

echo "=> Форматирование разделов..."
mkfs.ext4 -F $DISK_ROOT
mkfs.vfat -F 32 $DISK_EFI

echo "=> Монтирование..."
mount $DISK_ROOT /mnt
mkdir -p /mnt/boot
mount $DISK_EFI /mnt/boot

echo "=> Готово! Теперь можно запускать install.sh"
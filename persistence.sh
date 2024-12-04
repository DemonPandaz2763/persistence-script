#!/bin/bash

# script written according to the kali.org instructions on adding persistence to a live usb

bar='======================================================================================================'
mnt=/mnt/my_usb

# confirm logic. defaults to y
confirm() {
  if [[ -z "$confirm" ]]; then
    confirm="y"
  fi

  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Exiting..."
  exit 0
  fi
}

# check if user is running as root
if [ "$(id -u)" -ne 0 ]; then
  echo 'This script must be run as root. Run again with "sudo ./persistence.sh"'
  exit 1
fi

# usb=/dev/sdX (replace "sdX" with user input)
fdisk -l | grep -E 'Disk /dev/|Disk model'

echo "$bar"
echo -n '[?] Enter desired drive (eg, /dev/sdX): '
read usb

echo "$bar"
echo "This script is designed to be run as the first step in setting up a live kali usb with persistence."
echo "Run at your own risk. This will make a new partition on $usb and then reboot."
echo ""
echo -n "[?] Do you want to continue [Y/n]: "
read -r confirm

confirm

# sudo fdisk $usb (this needs following inputs: n; p; enter; enter; enter; w)
echo "$bar"
echo "[+] Adding Linux partition to $usb"
echo "$bar"

echo -e "n\np\n\n\n\nw" | fdisk "$usb"

echo "$bar"
echo "[+] Finished adding Linux partition to $usb"
echo "$bar"

# sudo mkfs.ext4 -L persistence ${usb}3
fdisk -l ${usb}
echo "$bar"
echo ""
echo -n "[?] Which partition is labeled 'Linux' (eg. /dev/sdb3): "
read -r part

echo ""
echo -n "[?] '$part' was selected. Is this correct? [Y/n]: "
read confirm

confirm

echo "$bar"
echo "[+] Making ext4 persistence filesystem on $part"
echo "$bar"

mkfs.ext4 -L persistence ${part}

# sudo mkdir -p /mnt/my_usb
echo "$bar"
echo "[+] Finished making filesystem"
echo ""
echo "[+] Making mount directory at $mnt"
echo "$bar"

mkdir -p ${mnt}

# sudo mount ${usb}3 /mnt/my_usb
echo "[+] Mounting point made at $mnt"
echo ""
echo "[+] Mounting $usb to $mnt"
echo "$bar"

mount ${part} ${mnt}

# echo "/ union" | sudo tee /mnt/my_usb/persistence.conf and unmount usb
echo "$bar"
echo "Mounted $usb at $mnt"
echo ""
echo "[+] Making configuration file for persistence"
echo "$bar"

echo "/ union" | tee ${mnt}/persistence.conf
umount ${part}

echo "$bar"
echo "[+] Finished making configuration file"
echo ""
echo "[+] Unmounted $usb from $mnt"
echo "[!] Rebooting"
echo "$bar"

#!/usr/bin/env bash

# Download Arch Linux ISO image
# Create new Virtual Box image
  # VDI > Dynamically Allocated > Choose dir and Size
# Choose ISO and boot Arch Linux
# Add port forwarding:
  # Menu > Device > Network > Network Settings > Advanced > Port Forwading
  # (name) ssh (type) TCP (host) 3022 (guest) 22
# Add shared folder
  # Menu > Devices > Shared Folders > Settings > Add new
  # Check: Make Permanent, Auto-Mount
  # Used name: project
# Run:
  # @TODO: Improve partitions for performance
  # fdisk /dev/sda # create new partition: n p <enter> <enter> <enter> w
  # @TODO: Find how to copy this in VBox terminal. Find how to pipe to shell
  # curl -L https://raw.githubusercontent.com/igncp/vagrant-personal-cookbook/master/arch-linux/installation/one.sh
  mkfs.ext4 /dev/sda1
  mount /dev/sda1 /mnt
  pacstrap /mnt base
  genfstab -U /mnt >> /mnt/etc/fstab
  curl -o /mnt/root/start.sh L https://raw.githubusercontent.com/igncp/vagrant-personal-cookbook/master/arch-linux/installation/two.sh
  echo ""
  echo "Next steps:"
  echo "arch-chroot /mnt"
  echo "sh start.sh"

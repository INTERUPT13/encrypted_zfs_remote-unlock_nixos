# encrypted_zfs_remote-unlock_nixos
### flake &amp; guide on how to setup a remotely unlocked encrypted zfs nixos system



# guide:

create bios boot+ext2 boot part:
```bash
zpool create  -o feature@encryption=enabled -O encryption=on -O keylocation=prompt -O keyformat=passphrase -O mountpoint=none -O compression=lz4 -O xattr=sa -O acltype=posixacl -o ashift=12 -R /mnt rpool /dev/sda3 -f

mkswap /dev/sda2

zfs create -o mountpoint=none rpool/root
zfs create -o mountpoint=legacy rpool/root/nixos
zfs create -o mountpoint=legacy rpool/home
```

to stop it from being completely full:
```bash
zfs create -o refreservation=10G -o mountpoint=none rpool/reserved
```
```bash
mount -t zfs rpool/root/nixos /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# swapon /dev/sda2  # TODO when doing this you will have unecrypted swap -> leak ram. TODO swap in zfs
```

### notice:
if you donit already have a hardware configuration or don't want to make one yourself
mount all your stuff and then run 
```bash
nixos-generate-config --root /mnt
```
or whatever


setup ssh keys, if you want both rsa and ed it might look like this
```bash
ssh-keygen -t ed25519
ssh-keygen -t rsa

mkdir /mnt/root/
cp /root/.ssh/id_rsa /mnt/root/initrd_ssh_host_key
cp /root/.ssh/id_ed25519 /mnt/root/initrd_ssh_host_key_ed
```

```bash
nix-shell -p git
git clone "https://github.com/INTERUPT13/encrypted_zfs_remote-unlock_nixos" /mnt/etc/nixos/
nixos-install --flake /mnt/etc/nixos#nixos
```


#notice:
use ur modified configuration.nix
when using dhcp in the initrd If you are unlocking a remote server like a vps the routes might not be correct for example for hetzner GmBH.
to overcome this i will overwrite the correct default gf from the initrd post network stript

finalize:
```bash
nixos-install
reboot
```


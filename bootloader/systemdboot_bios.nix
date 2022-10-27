{pkgs, config, ...}: with pkgs; {
      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      services.zfs.autoScrub.enable = true;

      # TODO services.sanoid for auto snapshots
      #on desktop maybe set os prober -> multiboot for winshit
      boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only
}

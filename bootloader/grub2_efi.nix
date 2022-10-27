{pkgs, config, ...}: with pkgs; {

  boot.loader = {
    grub.enable = true;
    grub.version = 2;
    grub.device = "nodev";
  };

}

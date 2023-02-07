{ config, pkgs, ... }: {
  # run flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo 
  # or sth or wait
  services.flatpak.enable = true;
}

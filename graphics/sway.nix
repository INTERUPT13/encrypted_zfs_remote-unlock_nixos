{config, pkgs, ...}: {
  programs.sway = {
    enable=true;
    wrapperFeatures.gtk = true;
  };

  # useful with sway
  environment.systemPackages = with pkgs; [
    alacritty
    wayland
    swaylock
    swayidle
    grim
    slurp
    wl-clipboard
    bemenu
    mako
  ];

    services.dbus.enable = true;
      xdg.portal = {
      enable = true;
      wlr.enable = true;
      # gtk portal needed to make gtk apps happy
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
}

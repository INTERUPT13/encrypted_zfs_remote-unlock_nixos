{
  description = "encrypted ZFS+remote unlock NixOS flake config for one of my servers";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
    security-cfg = { 
      url = "path:/etc/nixos/encrypted_zfs_remote-unlock_nixos_security";
      flake = false;
      #ref = "uefi";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
    };

    nixos-mailserver-configs = {
      url =
        "git+ssh://git@github.com/INTERUPT13/nixos-mailserver-configs.git";
      flake = false;
      type = "git";
    };

    simpleNixosMailserver = {
      url = 
        "gitlab:simple-nixos-mailserver/nixos-mailserver?ref=master";
    };

    home-manager-cfg-public = {
      url = "path:/etc/nixos/nix-home-manager-config-public";
      #ref = "testing";
    };

    mobile-nixos = {
      url = "github:NixOS/mobile-nixos";
      flake = false;
    };

    nur = { url = "github:INTERUPT13/NUR?ref=INTERUPT13-patch-1"; };

  };
  outputs = { self, nixpkgs, security-cfg, home-manager,  home-manager-cfg-public, simpleNixosMailserver, nixos-mailserver-configs, nur, mobile-nixos }@attrs: {
    nixosConfigurations.tower01 = nixpkgs.lib.nixosSystem (import ./configs/tower01.nix attrs);
    nixosConfigurations.hetzner_mailserver01 = nixpkgs.lib.nixosSystem (import ./configs/hetzner_mailserver01.nix attrs);
    nixosConfigurations.pinephone01= nixpkgs.lib.nixosSystem (import ./configs/pinephone01.nix attrs);
  };
}

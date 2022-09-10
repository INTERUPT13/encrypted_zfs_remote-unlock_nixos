{
  description = "encrypted ZFS+remote unlock NixOS flake config for one of my servers";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
  };

  outputs = { self, nixpkgs}@attrs: with nixpkgs; let
    pub_cfg = {config, pkgs, ...}: {
      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      services.zfs.autoScrub.enable = true;

      # TODO services.sanoid for auto snapshots
      #on desktop maybe set os prober -> multiboot for winshit
      boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

      # TODO move such things as packages in their own flake/module
      environment.systemPackages = with pkgs; [
        mosh
      ];

      system.stateVersion = "22.05"; # Did you read the comment?

      # protect agaainst accidental configuration.nix deletions TODO
      # find out why this doesn't work with pure eval
      #system.copySystemConfiguration = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # to pass flake inputs to modules if needed
      modules = [ 
        ./searx.nix 
        ./hardware-configuration.nix
        pub_cfg

        # EXAMPLE FOUND IN ./security.nix.example
        # security relevant stuff. I wont share my actual config but just think of it
        # as a bunch of firewall,selinux whatever settings
        ./security.nix
      ];
      specialArgs = attrs;
    };
  };
}

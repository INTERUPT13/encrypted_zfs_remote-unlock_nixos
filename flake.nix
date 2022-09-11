{
  description = "encrypted ZFS+remote unlock NixOS flake config for one of my servers";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    security-cfg = { 
      url = "git+ssh://git@github.com/INTERUPT13/encrypted_zfs_remote-unlock_nixos_security.git";
      flake = false;
    };
    # optional you can also use a ./security.cfg in your /etc/nixos/ folder (see below)
    # but i go with a priv git repo flake
    hardware-cfg = { 
      url = "git+ssh://git@github.com/INTERUPT13/encrypted_zfs_remote-unlock_nixos_hardware.git";
      flake = false;
    };

    home-manager-module = {
      url = "git+ssh://git@github.com:INTERUPT13/nixos-home-manager-module.git";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, security-cfg, hardware-cfg, home-manager-module}@attrs: with nixpkgs; let
    # todo splitin modules
    pub_cfg = {config, pkgs, ...}: {
      system.stateVersion = "22.05";

      boot.loader.grub.enable = true;
      boot.loader.grub.version = 2;
      services.zfs.autoScrub.enable = true;

      # TODO services.sanoid for auto snapshots
      #on desktop maybe set os prober -> multiboot for winshit
      boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

      environment.systemPackages = with pkgs; [
        mosh
      ];

      services.openssh.enable = true;
      # TODO cert only
      services.openssh.permitRootLogin = "yes";

      # TODO disable. Acutally put everything like sshd + fw in a "security flake thats not public
      networking.firewall.enable = false;

      # protect agaainst accidental configuration.nix deletions
      #system.copySystemConfiguration = true;
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      # to pass flake inputs to modules if needed
      modules = [ 
        pub_cfg
        (import "${home-manager-module}"/general.nix")
        # EXAMPLE FOUND IN ./security.nix.example
        # security relevant stuff. I wont share my actual config but just think of it
        # as a bunch of firewall,selinux whatever settings
        #./security.nix
        (import "${security-cfg}/security-modules.nix")
        (import "${hardware-cfg}/hardware-modules.nix")
        # ^ using my own priv repos but you can just put it in your /etc/nixos
        # and source via ./<file>.nix TODO guide on how to generate hardware-configuration.nix
      ];
      specialArgs = attrs;
    };
  };
}

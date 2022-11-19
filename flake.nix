{
  description = "encrypted ZFS+remote unlock NixOS flake config for one of my servers";

  inputs = {
    nixpkgs = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    security-cfg = { 
      url = "git+ssh://git@github.com/INTERUPT13/encrypted_zfs_remote-unlock_nixos_security.git";
      flake = false;
      type = "git";
      #ref = "uefi";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
    };


    home-manager-cfg-public = {
      url = "git+ssh://git@github.com/INTERUPT13/nix-home-manager-config-public.git";
      type = "git";
      #ref = "testing";
    };


  };

  outputs = { self, nixpkgs, security-cfg, home-manager,  home-manager-cfg-public}@attrs: with nixpkgs; let
    # todo splitin modules
    pub_cfg = {config, pkgs, ...}: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      system.stateVersion = "22.05";


      services.zfs.autoScrub.enable = true;

      # TODO services.sanoid for auto snapshots

      environment.systemPackages = with pkgs; [
        mosh
      ];

      programs.sway = {
        enable=true;
      };

      users.users.flandre = {
        name = "flandre";
	isNormalUser = true;
      };

      sound.enable = true;
      boot.extraModprobeConfig = ''
  options snd slots=snd-hda-intel
'';


hardware.pulseaudio.enable = true;
hardware.pulseaudio.support32Bit = true;

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

        # bootloader specs/mechanism
        #(import ./bootloader/grub2_efi.nix)
        (import ./bootloader/systemdboot_bios.nix)

	#home-manager.nixosModules.home-manager (home-manager-cfg-public.cfg)
	home-manager.nixosModules.home-manager ({
	  home-manager.users.flandre = home-manager-cfg-public.default_cfg;
	  home-manager.users.root = home-manager-cfg-public.default_cfg;
	})



        # EXAMPLE FOUND IN ./security.nix.example
        # security relevant stuff. I wont share my actual config but just think of it
        # as a bunch of firewall,selinux whatever settings
        #./security.nix
        #(import "${security-cfg}/security-modules.nix")

        (import "${security-cfg}/fw/defconfig.nix")
        (import "${security-cfg}/initrd/zfs_remote_unlock.nix")
        (import "${security-cfg}/sshd/defconfig.nix")

        (import "${security-cfg}/hw/hardware-configuration-hetzner_01.nix")


        #(import "${hardware-cfg}/hardware-modules.nix")
        # ^ using my own priv repos but you can just put it in your /etc/nixos
        # and source via ./<file>.nix TODO guide on how to generate hardware-configuration.nix
      ];
      specialArgs = attrs;
    };
  };
}

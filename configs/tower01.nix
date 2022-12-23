
{ self, nixpkgs, security-cfg, home-manager,  home-manager-cfg-public, ...}@attrs: with nixpkgs; let
    # todo splitin modules
    pub_cfg = {config, pkgs, ...}: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];

      virtualisation = {
        waydroid.enable = true;
        lxd.enable = true;
      };

      system.stateVersion = "22.05";

      #TODO remove
      nixpkgs.config.allowBroken = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;


      # TODO remove
       programs.ssh.extraConfig = ''
              Host eu.nixbuild.net
                pubkeyAcceptedKeyTypes ssh-ed25519
                IdentityFile /home/flandre/.ssh/id_ed25519
            '';

            programs.ssh.knownHosts = {
              nixbuild = {
                hostNames = [ "eu.nixbuild.net" ];
                publicKey =
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
              };
            };

            nix = {
              distributedBuilds = true;
              buildMachines = [{
                hostName = "eu.nixbuild.net";
                system = "x86_64-linux";
                maxJobs = 0;
                supportedFeatures = [ "benchmark" "big-parallel" ];
              }];
            };



      # TODO services.sanoid for auto snapshots







      # protect agaainst accidental configuration.nix deletions
      #system.copySystemConfiguration = true;
    };
  in {
      system = "x86_64-linux";
      # to pass flake inputs to modules if needed
      modules = [ 
        pub_cfg

        (import ./../users/desktop_user.nix {name="flandre";})
        (import ./../sound/desktop_sound_intel.nix)

        (import ./../graphics/sway.nix)


        # bootloader specs/mechanism
        (import ./../bootloader/grub2_efi.nix)
        #(import ./bootloader/systemdboot_bios.nix)

	home-manager.nixosModules.home-manager ({
	  home-manager.users.flandre = home-manager-cfg-public.default_cfg;
	  home-manager.users.root = home-manager-cfg-public.default_cfg;
	})





        # wanted for tauon music box but it sucks so don't neeed it
        #(import ./../flatpak/enable.nix)
        (import ./../zfs/scrubbing.nix)
        (import ./../zfs/snapshots.nix)

        (import "${security-cfg}/fw/defconfig.nix")
        (import "${security-cfg}/initrd/zfs_local_unlock.nix")
        (import "${security-cfg}/sshd/defconfig.nix")

        (import "${security-cfg}/hw/hardware-configuration-tower_01.nix")



      ];
      specialArgs = attrs;
    }

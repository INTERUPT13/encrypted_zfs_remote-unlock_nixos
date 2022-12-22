
{ self, nixpkgs, security-cfg, home-manager,  home-manager-cfg-public, ...}@attrs: with nixpkgs; let
    # todo splitin modules
    pub_cfg = {config, pkgs, ...}: {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];


      virtualisation = {
        waydroid.enable = true;
        lxd.enable = true;
      };

      system.stateVersion = "22.05";

      # TODO remove this is cauz zfs might not work
      #boot.kernelPatches = [ {
      #  name = "waydroid-shit";
      #  patch = null;
      #  extraConfig = ''
      #    CONFIG_ASHMEM y
      #  '';
      #  #extraConfig = ''
      #  #  CONFIG_ASHMEM y
      #  #  CONFIG_ANDROID y
      #  #  CONFIG_ANDROID_BINDER_IPC y
      #  #  CONFIG_ANDROID_BINDERFS y
      #  #  CONFIG_ANDROID_BINDER_DEVICES "binder,hwbinder,vndbinder"
      #  #'';
      #}];
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


      services.zfs.autoScrub.enable = true;

      # TODO services.sanoid for auto snapshots

      environment.systemPackages = with pkgs; [
        mosh
        iptables-legacy
      ];

      programs.sway = {
        enable=true;
      };

      users.users.flandre = {
        name = "flandre";
	isNormalUser = true;
        extraGroups = [ "audio" ];
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
      system = "x86_64-linux";
      # to pass flake inputs to modules if needed
      modules = [ 
        pub_cfg

        # bootloader specs/mechanism
        (import ./../bootloader/grub2_efi.nix)
        #(import ./bootloader/systemdboot_bios.nix)

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
        (import "${security-cfg}/initrd/zfs_local_unlock.nix")
        (import "${security-cfg}/sshd/defconfig.nix")

        (import "${security-cfg}/hw/hardware-configuration-tower_01.nix")


        #(import "${hardware-cfg}/hardware-modules.nix")
        # ^ using my own priv repos but you can just put it in your /etc/nixos
        # and source via ./<file>.nix TODO guide on how to generate hardware-configuration.nix
      ];
      specialArgs = attrs;
    }

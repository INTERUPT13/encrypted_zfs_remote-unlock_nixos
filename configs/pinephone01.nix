{nixpkgs, mobile-nixos, nur, home-manager, home-manager-cfg-public, ... }:
    let
      system = "aarch64-linux";
      defaultUserName = "flandre";
      pkgs = import nixpkgs { system = "${system}"; };
    in with nixpkgs; {
        inherit system;

        modules = [
          (import "${mobile-nixos}/lib/configuration.nix" {
            device = "pine64-pinephone";
          })

          (import ./hardware-configuration.nix)

          (import ./sxmo-nixos/modules/sxmo.nix)

          home-manager.nixosModules.home-manager
          ({
            home-manager.users."${defaultUserName}" =
              home-manager-cfg-public.pinephone_cfg;
            home-manager.users.root = home-manager-cfg-public.pinephone_cfg;
          })

          ({ config, ... }: {

          virtualisation = {
            waydroid.enable = true;
            lxd.enable = true;
          };

            programs.calls.enable = true;

            nix.settings.experimental-features = [ "nix-command" "flakes" ];

            #TODO 
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
                system = "aarch64-linux";
                maxJobs = 1;
                supportedFeatures = [ "benchmark" "big-parallel" ];
              }];
            };

            # TODO remove since doens't seem to work
            #boot.kernelParams = [
            #  # if we wouldn't do this these were the first cards
            #  # used and we wouldn't have working sound. There sure is other ways
            #  # to do this but well this is easy i guess
            #  "snd-aloop.index=1"
            #  "snd.dummy.index=2"
            #];

            hardware.firmware = [ config.mobile.device.firmware ];

            #TODO mobile.boot/stage-1.firmware

            # modem?
            nixpkgs.config.allowUnfree = true;

            # It's recommended to keep enabled on these constrained devices
            zramSwap.enable = true;

            networking.networkmanager.enable = true;
            networking.hostName = "mobile-nixos";
            time.timeZone = "Europe/Berlin";

            sound.enable = true;
            #sound.extraConfig = ''
            #  defaults.pcm.!card 0
            #  defaults.pcm.!card 1
            #'';

            hardware.pulseaudio.enable = true;

            # TODO 
            networking.firewall = {
              enable = true;
              package = pkgs.iptables-legacy;
            };

            system.stateVersion = "22.11"; # Did you read the comment?

            users.users.${defaultUserName} = {
              isNormalUser = true;
              description = "";
              #packages = [ pkgs.tdesktop pkgs.xterm ];
              hashedPassword =
                "$6$culRuFpx6eG5G30k$1FmUVmGqsbzDJwROHwatfWEh/em8NLeJDYGve9v82hhRksgOeo.hHsDoPLJWkUuLglndkBHdCcovmspKK5ppJ0";
              extraGroups = [
                "dialout"
                "feedbackd"
                "networkmanager"
                "video"
                "audio"
                "wheel"
              ];
              shell = pkgs.zsh; # since homemanager config uses it
            };

            services.openssh.enable = true;

            # for jellyfin as for now
            services.flatpak.enable = true;
            #dg.portal = {
            #	enable = true;
            #  extraPortals = [pkgs.xdg-desktop-portal-gtk];
            #};

            services.logind = {
              extraConfig = "  HandlePowerKey=lock\n  HandleLidSwitch=lock\n";
            };

            hardware.opengl = {
              enable = true;
              driSupport = true;
            };
            services.xserver.desktopManager.phosh = {
              enable = true;
              user = "flandre";
              group = "users";
              phocConfig.xwayland = "immediate";
            };

            # Enable xserver
            #services.xserver.enable = true;
            #hardware.opengl.enable = true;
            #hardware.opengl.driSupport = true;
            #services.xserver.windowManager.sxmo.enable = true;
            #services.xserver.displayManager.lightdm.enable = true;
            #services.xserver.displayManager.lightdm.autoLogin = { 
            #  enable = true;
            #  user = "${defaultUserName}";
            #};  
            #services.xserver.displayManager.defaultSession= "none+sxmo";
          })
        ];
      };
    };
}

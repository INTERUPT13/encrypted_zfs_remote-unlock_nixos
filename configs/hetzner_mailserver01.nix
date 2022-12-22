{ self, nixpkgs, security-cfg, home-manager, home-manager-cfg-public, nixos-mailserver-configs, simpleNixosMailserver, ...}@attrs:
    with nixpkgs;
    let
      # todo splitin modules
      pub_cfg = { config, pkgs, ... }: {
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        system.stateVersion = "22.05";
      };
      pkgs = import nixpkgs{system="x86_64-linux";};
      domain_information = (import "${security-cfg}/domain_information/flake.nix" {});
    in {
        system = "x86_64-linux";
        # to pass flake inputs to modules if needed
        modules = [
          pub_cfg

          # bootloader specs/mechanism
          #(import ./bootloader/grub2_efi.nix)
          (import ./../bootloader/systemdboot_bios.nix)

          (import ./../zfs/scrubbing.nix)
          (import ./../users/desktop_user.nix {
            name = "flandre";
            pkgs = (import nixpkgs { system = "x86_64-linux"; });
          })

          #home-manager.nixosModules.home-manager (home-manager-cfg-public.cfg)
          home-manager.nixosModules.home-manager
          ({
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

          simpleNixosMailserver.nixosModule


          ({lib, ...}:
          (import ./../webserver/simple_template.nix {domains=domain_information.domains; inherit lib;}))



          ({config, ...}:
            (import ./../mailserver/basic_template.nix {
              inherit config;
              inherit pkgs;
              fqdn=domain_information.mailserver_fqdn;
              domains= domain_information.domains;
              acme_email = let
                acme_email_domain = domain_information.acme_email_domain;
              in "certz@${acme_email_domain}";
              # login username will not be a but rather a@domain.tld
              loginAccounts = (import "${security-cfg}/mail/login_accounts.nix" {});
              webmail_domain = domain_information.webmail_domain;
            })
          )

          #(import "${nixos-mailserver-configs}/rds.nix")


          # TODO find out why and how this breaks dovecots memory allocator
          #(import "${nixpkgs}/nixos/modules/profiles/hardened.nix")

          #(import "${hardware-cfg}/hardware-modules.nix")
          # ^ using my own priv repos but you can just put it in your /etc/nixos
          # and source via ./<file>.nix TODO guide on how to generate hardware-configuration.nix
        ];
        specialArgs = attrs;
      }

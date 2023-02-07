{ ... }:
let
  ssh_config = {
    programs.ssh.extraConfig =
      "  Host eu.nixbuild.net\n    pubkeyAcceptedKeyTypes ssh-ed25519\n    IdentityFile /home/flandre/.ssh/id_ed25519\n";

    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey =
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };
  };
in {

  x86_config = {
    nix = {
      distributedBuilds = true;
      buildMachines = [{
        hostName = "eu.nixbuild.net";
        system = "x86_64-linux";
        maxJobs = 100;
        supportedFeatures =
          [ "benchmark" "big-parallel" "testing" "kvm" "nixos-test" ];
      }];
    };
  } // ssh_config;
  aarch_config = {
    nix = {
      distributedBuilds = true;
      buildMachines = [{
        hostName = "eu.nixbuild.net";
        system = "aarch64-linux";
        maxJobs = 100;
        supportedFeatures =
          [ "benchmark" "big-parallel" "testing" "nixos-test" ];
      }];
    };
  } // ssh_config;
}


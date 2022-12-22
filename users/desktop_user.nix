{ name, pkgs, ... }: {
  users.users.flandre = {
    inherit name;
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}


{name}: 
{pkgs, ... }: {
  users.users."${name}" = {
    inherit name;
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}

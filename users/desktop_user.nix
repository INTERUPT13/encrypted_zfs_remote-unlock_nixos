{ name, extraGroups ? [ ] }:
{ pkgs, ... }: {
  users.users."${name}" = {
    inherit name;
    inherit extraGroups;
    isNormalUser = true;
    shell = pkgs.zsh;
  };
}

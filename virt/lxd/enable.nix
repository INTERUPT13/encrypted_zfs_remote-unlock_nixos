{pkgs, config, ...}: {
  lxd.enable = true;
  # TODO make it auto add the main user: "flandre" in this case
  # to the lxd group
}

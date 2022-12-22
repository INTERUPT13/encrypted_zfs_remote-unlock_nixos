{ config, ... }: {
  sound.enable = true;
  boot.extraModprobeConfig = ''
    options snd slots=snd-hda-intel
  '';

  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
}

({inputs, ...}: {
  imports = [
    "${inputs.nixpkgs-unstable}/nixos/modules/services/hardware/inputplumber.nix"
    ./pulseaudio-compat.nix
  ];
})

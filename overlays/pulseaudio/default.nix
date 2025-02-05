
{ inputs, ... }:
final: prev: {
  pulseaudioService = inputs.nixpkgs-unstable.legacyPackages.${prev.system}.pulseaudio;
}

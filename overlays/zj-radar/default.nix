{inputs, ...}: final: prev: {
  zj-radar = inputs.zj-radar.packages.${prev.system}.default;
  zj-radar-cli = inputs.zj-radar.packages.${prev.system}.zj-radar-cli;
}

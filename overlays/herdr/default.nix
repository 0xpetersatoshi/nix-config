{inputs, ...}: final: prev: {
  herdr = inputs.herdr.packages.${prev.system}.default;
}

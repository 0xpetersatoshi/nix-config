{channels, ...}: final: prev: {
  # Provide the inputplumber package from unstable
  inputplumber = channels.nixpkgs-unstable.inputplumber;
}

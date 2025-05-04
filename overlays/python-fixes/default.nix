{channels, ...}: final: prev: {
  # Override Python packages to use newer aiohttp
  python312 = prev.python312.override {
    packageOverrides = pyFinal: pyPrev: {
      aiohttp = channels.nixpkgs-unstable.python312.pkgs.aiohttp;
    };
  };

  # Also override python3 which might be used
  python3 = prev.python3.override {
    packageOverrides = pyFinal: pyPrev: {
      aiohttp = channels.nixpkgs-unstable.python3.pkgs.aiohttp;
    };
  };
}

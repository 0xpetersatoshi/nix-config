{...}: final: prev: {
  # Create a fixed version of decky-loader that works with the available aiohttp
  decky-loader = prev.decky-loader.override {
    python3 = prev.python312;
    pythonPackages = prev.python312Packages;
  };

  # Alternative approach: disable decky-loader in the package set
  # This will make it unavailable, forcing Jovian to use a different approach
  # decky-loader = null;
}

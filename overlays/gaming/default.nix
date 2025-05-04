{channels, ...}: final: prev: {
  # Use unstable versions for gaming-related packages
  mangohud = channels.nixpkgs-unstable.mangohud;
  gamescope = channels.nixpkgs-unstable.gamescope;
  steam = channels.nixpkgs-unstable.steam;
  steam-run = channels.nixpkgs-unstable.steam-run;
}

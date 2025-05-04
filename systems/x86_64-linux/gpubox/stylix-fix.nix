{lib, ...}: {
  # This completely disables stylix for the peter user
  home-manager.users.peter = {
    stylix = lib.mkForce {
      enable = false;
      # Explicitly set overlays to null to avoid conflicts
      overlays.enable = lib.mkForce false;
    };
  };
}

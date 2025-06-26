{...}: final: prev: {
  protonmail-desktop = let
    # Create a wrapper package that fixes the Wayland issues
    wrapped = prev.protonmail-desktop.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];

      # We need to completely replace the wrapper to avoid Wayland issues
      postInstall =
        (oldAttrs.postInstall or "")
        + ''
          # Remove the original wrapper
          rm -f $out/bin/proton-mail

          # Create our own wrapper that bypasses Wayland issues
          makeWrapper ${final.electron_35}/bin/electron $out/bin/proton-mail \
            --add-flags "$out/share/proton-mail/app.asar" \
            --set ELECTRON_FORCE_IS_PACKAGED 1 \
            --set ELECTRON_IS_DEV 0 \
            --set ELECTRON_OZONE_PLATFORM_HINT x11 \
            --unset WAYLAND_DISPLAY \
            --unset NIXOS_OZONE_WL \
            --run 'CONFIG_DIR="$HOME/.config/Proton Mail"' \
            --run 'CONFIG_FILE="$CONFIG_DIR/config.json"' \
            --run 'if [ ! -f "$CONFIG_FILE" ] || ! grep -q "windowBounds" "$CONFIG_FILE" 2>/dev/null; then' \
            --run '  echo "Note: ProtonMail may need to generate window configuration on first run."' \
            --run '  mkdir -p "$CONFIG_DIR"' \
            --run 'fi'

          # Ensure desktop file exists
          mkdir -p $out/share/applications
          cat > $out/share/applications/proton-mail.desktop << EOF
          [Desktop Entry]
          Type=Application
          Name=ProtonMail Desktop
          Comment=Unofficial ProtonMail Desktop App
          Icon=protonmail-desktop
          Exec=$out/bin/proton-mail %U
          Terminal=false
          Categories=Network;Email;
          StartupWMClass=Proton Mail
          MimeType=x-scheme-handler/mailto;
          EOF
        '';
    });
  in
    wrapped;
}

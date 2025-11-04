{...}: final: prev: let
  # Create the patched version
  patchedProtonmail = let
    # Create a wrapper package that fixes the Wayland issues
    wrapped = prev.protonmail-desktop.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or []) ++ [final.makeWrapper];

      # We need to completely replace the wrapper to avoid Wayland issues
      # Use postFixup instead of postInstall to run AFTER the original wrapper is created
      postFixup =
        (oldAttrs.postFixup or "")
        + ''
          # Remove the original wrapper
          rm -f $out/bin/proton-mail

          # Create our own wrapper that bypasses Wayland issues by unsetting env vars
          makeWrapper ${final.electron}/bin/electron $out/bin/proton-mail \
            --add-flags "$out/share/proton-mail/app.asar" \
            --set ELECTRON_FORCE_IS_PACKAGED 1 \
            --set ELECTRON_IS_DEV 0 \
            --unset NIXOS_OZONE_WL \
            --unset WAYLAND_DISPLAY \
            --add-flags "--disable-gpu-compositing" \
            --add-flags "--disable-software-rasterizer"

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
in {
  # Patch both regular and stable versions
  protonmail-desktop = patchedProtonmail;
}

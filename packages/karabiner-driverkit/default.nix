{
  lib,
  stdenv,
  fetchurl,
}:
stdenv.mkDerivation rec {
  pname = "karabiner-driverkit";
  version = "5.0.0";

  src = fetchurl {
    url = "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/releases/download/v${version}/Karabiner-DriverKit-VirtualHIDDevice-${version}.pkg";
    hash = "sha256-hKi2gmIdtjl/ZaS7RPpkpSjb+7eT0259sbUUbrn5mMc=";
  };

  dontUnpack = true;
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out
    cp $src $out/Karabiner-DriverKit-VirtualHIDDevice.pkg

    mkdir -p $out/bin
    cat > $out/bin/install-karabiner-driverkit <<'EOF'
    #!/bin/sh
    set -x  # Enable command tracing

    echo "[karabiner-driverkit] Starting installation check..."

    DRIVER_PATH="/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice"
    if [ ! -d "$DRIVER_PATH" ]; then
      echo "[karabiner-driverkit] Driver not found, installing..."

      echo "[karabiner-driverkit] Running installer..."
      installer -pkg $out/Karabiner-DriverKit-VirtualHIDDevice.pkg -target / || {
        echo "[karabiner-driverkit] ERROR: Installation failed with exit code $?"
        exit 1
      }

      echo "[karabiner-driverkit] Waiting for files to settle..."
      sleep 2

      echo "[karabiner-driverkit] Activating VirtualHIDDevice Manager..."
      "/Applications/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager" activate || {
        echo "[karabiner-driverkit] ERROR: Activation failed with exit code $?"
        exit 1
      }

      echo "[karabiner-driverkit] Installation completed successfully"
    else
      echo "[karabiner-driverkit] Driver already installed at $DRIVER_PATH"
    fi

    # Verify installation
    echo "[karabiner-driverkit] Verifying installation..."
    if [ -d "$DRIVER_PATH" ]; then
      echo "[karabiner-driverkit] Driver directory exists"
      ls -la "$DRIVER_PATH"
    else
      echo "[karabiner-driverkit] ERROR: Driver directory not found after installation"
      exit 1
    fi
    EOF
    chmod +x $out/bin/install-karabiner-driverkit
  '';

  meta = with lib; {
    description = "Karabiner-DriverKit-VirtualHIDDevice installer";
    homepage = "https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice";
    platforms = platforms.darwin;
    license = licenses.mit;
  };
}

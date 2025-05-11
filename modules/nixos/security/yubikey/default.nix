{
  config,
  pkgs,
  lib,
  user,
  namespace,
  ...
}:
with lib;
with lib.${namespace}; let
  cfg = config.${namespace}.security.yubikey;
in {
  options.${namespace}.security.yubikey = with types; {
    enable = mkBoolOpt false "Whether to enable yubikey for auth.";
  };

  config = mkIf cfg.enable {
    services = {
      pcscd.enable = true;
      udev.packages = with pkgs; [yubikey-personalization];
      dbus.packages = [pkgs.gcr];
    };

    security.pam = {
      u2f = {
        enable = true;
        settings = {
          cue = true;
          cue_prompt = " Touch the Yubikey to continue...";
          interactive = false;
          origin = "pam://yubi";

          # generated with pamu2fcfg -n -o pam://yubi
          authfile = pkgs.writeText "u2f-mappings" (
            lib.concatStrings [
              user.name
              ":XN9HwLargchRWd7XNxPymHDv1VDJDKHOGD77fZup6E4BQaBlTmeZ0uzp/YAvHTqTPLuajTsr8Ad6nip0ouK/9g==,TDcfjYPCfr4Orml0f/T0AeC/6jNeKaNEYmjLEMQz0sYtpHDss7+wSjWq4VR05H78gDv5+558LO3zQJWYC9Z+fQ==,es256,+presence" # yubikey-5c-nfc-8643
              ":kJFW1nRigwXIDBZ0DH/GDj1lZJ5TdebQipPK5sobWw3IdNWb8OcC6OXkw8NB5bUl5rIIXN98lUB2NWtSP/xWFQ==,xX6dLtKG+OcB5DxmrwzqxaUK0T35LYHbeHYmEBqNjaTntnnntTqKKfi3rPGsRnQ6Ir4qK5P13RaMYybnAQ86UA==,es256,+presence" # yubikey-5c-nano-0583
              ":Bi6exl1XrpImKfDlqvjtGHGvO6YO7JMu54mQIwQAVHgKAd8dJ83wHIye4CMV7j/tdSmx4jDdAN8ZcXo7mS+Z1Q==,OM8OALialjnxz4K7/MderdqSpuTp7Ju0/9b/vlCgVlF5292kxNXSZ032gEZ0mzZQ5X3GZ6EsIXu88RYcmFmcHg==,es256,+presence" # yubikey-5c-nano-0562
              ":Gtc2ARQAzhYfA+HRQbRILjFhCuzixQgPTqUJswaajISS527AYEmF9uchVzUy58452accHyR/3TXn2dUgROLMeQ==,x/ikMMx0tAn0k3hAHsmDmxuZSKUHtKSm+Jp58DEkppH8sk71GvaHQV22LdPbtpEKI5G3OxlUj5frssRb8Ha41Q==,es256,+presence" # yubikey-5-nano-5205
            ]
          );
        };
      };

      services = {
        sudo = {
          u2fAuth = true;
        };
      };
    };

    environment.systemPackages = with pkgs; [
      yubikey-manager # provides ykman
    ];
  };
}

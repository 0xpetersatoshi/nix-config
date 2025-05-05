# Boot

## Enabling Secure Boot with TPM2 Luks Decryption Quickstart

1. Generate Secure Boot keys:

   ```bash
   nix-shell -p sbctl

   # Generate keys
   sudo sbctl create-keys
   ```

2. Update you system config to enable secure boot and rebuild:

   ```nix
   system = {
       boot = {
         secureBoot = true;
         luksDevicePaths = ["/dev/nvme1n1p2"];
         secureBootKeysPath = "/var/lib/sbctl";
       };
     };
   ```

3. Verify everything went well:

   ```bash
   sudo sbctl verify

   ```

   > _NOTE_: It is expected that the files ending with bzImage.efi are not signed.

4. Enable secure boot in the BIOS in "setup mode". This will vary by motherboard but the general steps are:

   - Select the "Security" tab.
   - Select the "Secure Boot" entry.
   - Set "Secure Boot" to enabled.
   - Select "Reset to Setup Mode".

5. Next, enroll the keys generated earlier with vendor keys from Microsoft:

   ```bash
   sudo sbctl enroll-keys --microsoft
   ```

6. Reboot and verify Secure Boot is active:

   ```bash
   sudo bootctl status
   ```

7. Finally, run the luks crypt enroll script to provide a passphrase and allow unlocking the device with tpm2:

   ```bash
   sudo luksCryptenroller
   ```

You should now be able to reboot and have the LUKS encrypted disk unlock automatically.

## Resources

Follow [this guide](https://laniakita.com/blog/nixos-fde-tpm-hm-guide#part-02-secure-boot-with-lanzaboote) for enabling secure boot and configuring automatic LUKS decryption using tpm2.

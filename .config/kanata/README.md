# Configuring Kanata

Kanata is a macOS application that allows you to configure your keyboard layout. Kanata does not start as a background
process. Additionally, it relies on the Karabiner VirtualHiDDevice Driver. This document will guide you through the
steps needed to get Kanata working on macOS as well as how to have it run as a background process.

## Prerequisites

1. First, follow the instructions in [this](https://github.com/pqrs-org/Karabiner-DriverKit-VirtualHIDDevice/tree/main)
   repo to install the Karabiner-DriverKit-VirtualHIDDevice driver.
2. Next, run this `cargo` command to install kanata in `/usr/local/bin`:

```bash
sudo cargo install kanata --root /usr/local
```

3. Create a kanata config file in `~/.config/kanata/config.kbd`. Here's a simple example for adding home row mods:

```
;; Basic home row mods example using QWERTY
;; For a more complex but perhaps usable configuration,
;; see home-row-mod-advanced.kbd

(defcfg
  process-unmapped-keys yes
)
(defsrc
  a   s   d   f   j   k   l   ;
)
(defvar
  ;; Note: consider using different time values for your different fingers.
  ;; For example, your pinkies might be slower to release keys and index
  ;; fingers faster.
  tap-time 200
  hold-time 200
)
(defalias
  a (tap-hold $tap-time $hold-time a lmet)
  s (tap-hold $tap-time $hold-time s lalt)
  d (tap-hold $tap-time $hold-time d lctl)
  f (tap-hold $tap-time $hold-time f lsft)
  j (tap-hold $tap-time $hold-time j rsft)
  k (tap-hold $tap-time $hold-time k rctl)
  l (tap-hold $tap-time $hold-time l ralt)
  ; (tap-hold $tap-time $hold-time ; rmet)
)
(deflayer base
  @a  @s  @d  @f  @j  @k  @l  @;
)
```

## Test Before Configuring the Background Process

1. Test your configuration before configuring the background processes.

- First, run the karabiner virtual hid device daemon:

```bash
sudo '/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon'
```

- Next, run `kanata` with your config:

```bash
sudo /usr/local/bin/kanata --cfg ~/.config/kanata/config.kbd
```

- Validate your configuration is working as expected.

## Configuring the Background Process

1. Prepare the .plist files for the launchctl daemon.

- Create the following plist files:

```bash
sudo nvim /Library/LaunchDaemons/com.karabiner.virtual-hid-device-daemon.plist
sudo nvim /Library/LaunchDaemons/com.kanata.daemon.plist
```

- Add the following to the karabiner plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.karabiner.virtual-hid-device-daemon</string>
    <key>Program</key>
    <string>/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/var/log/karabiner-daemon.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/karabiner-daemon-error.log</string>
    <key>UserName</key>
    <string>root</string>
    <key>GroupName</key>
    <string>wheel</string>
</dict>
</plist>
```

- Add the following to the kanata plist:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.kanata.daemon</string>
    <key>ProgramArguments</key>
    <array>
        <string>/usr/local/bin/kanata</string>
        <string>--cfg</string>
        <string>/Users/peter/.config/kanata/config.kbd</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
        <key>AfterInitialDemand</key>
        <true/>
    </dict>
    <key>StandardOutPath</key>
    <string>/var/log/kanata.log</string>
    <key>StandardErrorPath</key>
    <string>/var/log/kanata-error.log</string>
    <key>UserName</key>
    <string>root</string>
    <key>GroupName</key>
    <string>wheel</string>
    <key>WorkingDirectory</key>
    <string>/tmp</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin</string>
    </dict>
    <key>StartInterval</key>
    <integer>5</integer>
</dict>
</plist>
```

2. Next, ensure the files have the correct permissions:

```bash
sudo chown root:wheel /Library/LaunchDaemons/com.karabiner.virtual-hid-device-daemon.plist
sudo chmod 644 /Library/LaunchDaemons/com.karabiner.virtual-hid-device-daemon.plist
sudo chown root:wheel /Library/LaunchDaemons/com.kanata.daemon.plist
sudo chmod 644 /Library/LaunchDaemons/com.kanata.daemon.plist
```

3. Finally, load the daemons:

```bash
sudo launchctl load /Library/LaunchDaemons/com.karabiner.virtual-hid-device-daemon.plist
sudo launchctl load /Library/LaunchDaemons/com.kanata.daemon.plist
```

4. Validate that everything is running as expected. You can check the status of the processes with this command:

```bash
sudo launchctl list | grep -E "karabiner|kanata"
```

If there are any issues, you can check the logs for errors with this command:

```bash
tail -f /var/log/kanata.log /var/log/kanata-error.log /var/log/karabiner-daemon.log /var/log/karabiner-daemon-error.log
```

## Updating Your Kanata Config

If you need to update your `config.kbd` file, first unload the daemon:

```bash
sudo launchctl unload /Library/LaunchDaemons/com.kanata.daemon.plist
sudo pkill -f kanata
```

Make your config changes and then test them by running:

```bash
sudo kanata --cfg ~/.config/kanata/config.kbd
```

Once you have validated the changes, reload the daemon with:

```bash
sudo launchctl load /Library/LaunchDaemons/com.kanata.daemon.plist
```

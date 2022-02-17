# lowbatt

Automatically get notified at set battery level thresholds using a systemd timer.

## Installation

### Dependencies

- `systemd` - for timer/service, `loginctl`, and dbus
- `libnotify` - for `notify-send`
- `make` - for `Makefile` build

### Build

```
sudo make install
```

## Usage

Once installed, enable and start the systemd timer:

```
sudo systemctl enable --now lowbatt.timer
```

## Configuration

`lowbatt` has 3 thresholds for discharging alerts:

- `low_threshold` - default: 30
- `danger_threshold` - default: 20
- `critical_threshold` - default: 10

These can be checked with the `lowbatt get` command.

If you would rather different thresholds for notifications, you can update these config values:

```
sudo lowbatt set low_threshold 20
sudo lowbatt set danger_threshold 10
sudo lowbatt set critical_threshold 5
```

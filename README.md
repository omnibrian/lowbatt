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

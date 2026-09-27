# Changelog

## 0.1.1

- Image labels Home Assistant needs to uninstall and repair the app cleanly.
- Hours and dusk/dawn follow Home Assistant's time zone. A `config.yaml` made from the old example pins `timezone: America/New_York`; delete that line to follow Home Assistant.
- An `mqtt:` block in `config.yaml` now takes precedence over the Mosquitto app, and a missing broker is reported clearly.

## 0.1.0

- First release.

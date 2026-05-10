# Home Automation Stack

Smart home with Home Assistant, Node-RED automation, Mosquitto MQTT broker, Zigbee2MQTT bridge, and ESPHome firmware builder.

## Services

| Service | Image | URL | Purpose |
|---------|-------|-----|---------|
| Home Assistant | `ghcr.io/home-assistant/home-assistant:2024.10.4` | `https://ha.DOMAIN` | Smart home hub |
| Node-RED | `nodered/node-red:3.1.9` | `https://nodered.DOMAIN` | Flow-based automation |
| Mosquitto | `eclipse-mosquitto:2.0.18` | (MQTT:1883) | MQTT broker |
| Zigbee2MQTT | `koenkk/zigbee2mqtt:1.40.0` | `https://zigbee.DOMAIN` | Zigbee bridge |
| ESPHome | `esphome/esphome:2024.9.2` | `https://esphome.DOMAIN` | ESP firmware builder |

## Quick Start

```bash
cd stacks/home-automation && docker compose up -d

# Home Assistant: https://ha.DOMAIN (create account on first visit)
# Node-RED: https://nodered.DOMAIN
# Zigbee2MQTT: https://zigbee.DOMAIN (requires Zigbee USB dongle)
```

## Home Assistant Integrations

### MQTT (Mosquitto)
Settings → Devices → MQTT → Broker: `mosquitto` port 1883

### Zigbee2MQTT
Settings → Devices → MQTT → Enable discovery. Devices auto-appear.

### Notifications (ntfy)
```yaml
notify:
  - platform: rest
    name: ntfy
    resource: https://ntfy.DOMAIN/home-assistant
    method: POST
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| Zigbee no devices | Check USB dongle: `ls /dev/ttyUSB*` |
| MQTT not connecting | Verify Mosquitto is healthy |
| ESPHome can't flash | Connect ESP via USB or use OTA |
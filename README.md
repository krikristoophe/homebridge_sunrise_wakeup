# Homebridge sunrise wakeup

An [homebridgre](https://homebridge.io) addon (⚠️ not a plugin) to program a sunrise wakeup with homebridge api

## Get started

This addon is an api that can schedule a sunrise wakeup from the homebridge API. A running instance of homebridge with al least one smartbulb (white or colored) are required.

### With docker compose

Add sunrise_wakeup service in your `docker-compose.yaml` file like this :

```yaml
services:
  # ...others services, homebridge...
  sunrise_wakeup:
    image: ghcr.io/krikristoophe/homebridge_sunrise_wakeup:latest
    restart: unless-stopped
    ports:
      - 3000:3000
    volumes:
      - ./data:/app/data:rw
    environment:
      - TZ=Europe/Berlin
      - DB_DIRECTORY=/app/data
      - HOMEBRIDGE_URI=${HOMEBRIDGE_URI}
      - HOMEBRIDGE_USERNAME=${HOMEBRIDGE_USERNAME}
      - HOMEBRIDGE_PASSWORD=${HOMEBRIDGE_PASSWORD}
```

Create `.env` file with required environnements variables :

```env
HOMEBRIDGE_URI=http://<your homebridge hostname>:8581
HOMEBRIDGE_USERNAME=<your homebridge username>
HOMEBRIDGE_PASSWORD=<your homebridge password>
```

> ⚠️ Keep this `.env` file secret !

Start the service :

```sh
docker compose --env-file=.env up sunrise_wakeup -d
```


## Development

### Run from sources

```sh
dart pub run build_runner build --delete-conflicting-outputs # Build all sources

dart run bin/sunrise_wakeup.dart # Run server
```

### Run tests

```sh
dart test
```

### Format and analyze

```sh
dart analyze # Run analyzer
dart format . --fix # Run auto format
```

### Build docker image

```sh
docker build -t sunrise_wakeup:1.0 .
``````

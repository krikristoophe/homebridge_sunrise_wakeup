FROM dart:3.1.5 AS build

# Resolve app dependencies.
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

# Copy app source code and AOT compile it.
COPY . .
# Ensure packages are still up-to-date if anything has changed
RUN dart pub get --offline
RUN dart run build_runner build --delete-conflicting-outputs

RUN dart compile exe bin/sunrise_wakeup.dart -o bin/server

FROM debian:buster-slim

RUN apt-get update && apt-get -y install libsqlite3-0 libsqlite3-dev

COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/

EXPOSE 3000
# Start server.
ENTRYPOINT ["/app/bin/server"]
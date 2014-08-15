#!/bin/bash

dart schafkopfer_server/bin/schafkopfer_server_main.dart &

echo -e "\nserver started with pid $!"

cd schafkopfer_client
pub serve &

echo -e "\nclient started with pid $!"

sleep 1

# disable Check for SameDomainPolicy for local tests
open -a "Chromium.app" http://localhost:8080/index.html --args --disable-web-security
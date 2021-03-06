#!/bin/bash

set -e
# set -o xtrace

cd "$(dirname "$0")"

echo "Installing stable rocketchat from store ($CHANNEL)"
sudo snap install rocketchat-server --channel $CHANNEL/stable

./wait_http.sh http://127.0.0.1:3000

echo "Running tests on rocketchat"
. ./basic_test.sh http://127.0.0.1:3000

echo "Updating rocketchat to edge"
sudo snap refresh rocketchat-server --channel=$CHANNEL/edge

./wait_http.sh http://127.0.0.1:3000

echo "Running another basic test"
./basic_test.sh http://127.0.0.1:3000 

echo "Seeing if information persisted across updates"
test_endpoint "$base_url/api/v1/channels.messages?roomId=GENERAL" -H "$userId" -H "$authToken"
if [[ "$response" != *"This is a test message from $TEST_USER"* ]]; then
  echo "Couldn't find sent message. Somethings wrong!"
  exit 2
fi

echo "Tests passed!"
#!/bin/sh

echo "machine api.mapbox.com login mapbox password $SDK_REGISTRY_TOKEN" >> ~/.netrc
chmod 0600 ~/.netrc

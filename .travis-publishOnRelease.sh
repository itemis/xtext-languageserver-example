#!/bin/bash
# Execute only on tag builds where the tag starts with 'v'

if [[ -n "$TRAVIS_TAG" && "$TRAVIS_TAG" == v* ]]; then
    echo "Publishing version: $TRAVIS_TAG"
    ./gradlew publish
    ./gradlew bintrayUpload
fi
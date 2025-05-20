#!/bin/bash

# This is a dummy build script for Netlify
# It simply echoes a message and exits successfully
# We're using pre-built Flutter web files

echo "Using pre-built Flutter web files from build/web directory"
echo "No build step needed"

# Create build/web directory if it doesn't exist
mkdir -p build/web

# If build/web is empty, show an error message
if [ -z "$(ls -A build/web 2>/dev/null)" ]; then
  echo "ERROR: build/web directory is empty!"
  echo "Please run 'flutter build web --release' locally and commit the build/web directory"
  exit 1
fi

echo "Pre-built files found in build/web directory"
echo "Deployment will proceed with these files"

exit 0

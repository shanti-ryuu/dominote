#!/bin/bash

# This script commits the build/web directory and pushes it to GitHub

echo "Adding build/web directory to Git..."
git add build/web

echo "Adding netlify-build.sh script to Git..."
git add netlify-build.sh

echo "Adding netlify.toml to Git..."
git add netlify.toml

echo "Adding .gitignore to Git..."
git add .gitignore

echo "Committing changes..."
git commit -m "Add build/web directory and Netlify deployment files"

echo "Pushing to GitHub..."
git push

echo "Done! Your changes have been pushed to GitHub."
echo "Netlify should now be able to deploy your Flutter web app."

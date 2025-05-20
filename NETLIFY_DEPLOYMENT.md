# DomiNotes Netlify Deployment Guide

This guide explains how to deploy the pre-built DomiNotes Flutter web app to Netlify.

## Option 1: Deploy via Netlify UI (Recommended for first deployment)

1. **Build the Flutter web app locally**:
   ```bash
   flutter build web --release
   ```
   This will generate the web build files in the `build/web` directory.

2. **Deploy to Netlify**:
   - Go to [Netlify](https://app.netlify.com/)
   - Log in to your account
   - Click on "Sites" in the top navigation
   - Drag and drop the entire `build/web` folder onto the Netlify UI where it says "Drag and drop your site folder here"
   - Wait for the upload to complete
   - Your site will be deployed with a random subdomain (e.g., random-name-123.netlify.app)

3. **Configure your site**:
   - Click on "Site settings"
   - You can change the site name under "Site information" → "Change site name"
   - Set up a custom domain if desired under "Domain management"

## Option 2: Deploy via Netlify CLI

1. **Install Netlify CLI** (if not already installed):
   ```bash
   npm install netlify-cli -g
   ```

2. **Build the Flutter web app**:
   ```bash
   flutter build web --release
   ```

3. **Deploy to Netlify**:
   ```bash
   cd build/web
   netlify deploy --prod
   ```
   Follow the prompts to complete the deployment.

## Option 3: Deploy via GitHub Integration

1. **Push your code to GitHub**:
   Make sure your repository is on GitHub.

2. **Connect to Netlify**:
   - Go to [Netlify](https://app.netlify.com/)
   - Click "New site from Git"
   - Choose GitHub as your Git provider
   - Authorize Netlify to access your GitHub account
   - Select your repository

3. **Configure build settings**:
   - Set the publish directory to `build/web`
   - Leave the build command empty (since we're not building on Netlify)
   - Click "Deploy site"

4. **Important**: Before connecting to GitHub, make sure to:
   - Build the Flutter web app locally: `flutter build web --release`
   - Commit and push the `build/web` directory to your GitHub repository
   - Add `!build/web` to your `.gitignore` file to ensure the build directory is not ignored

## Troubleshooting

- **404 errors on page refresh**: This is handled by the `_redirects` file and `netlify.toml` configuration we've already set up.
- **Service worker issues**: If you encounter issues with the service worker, you may need to update the service worker registration in `index.html`.
- **CORS issues**: If your app makes API calls, you may need to configure CORS headers in Netlify's `_headers` file.

## Notes

- The Flutter web app is built locally because Netlify's build environment doesn't have Flutter installed by default.
- This approach deploys pre-built files, which is faster and more reliable than trying to build Flutter on Netlify.
- For continuous deployment, you'll need to build locally and push the updated `build/web` directory each time you make changes.

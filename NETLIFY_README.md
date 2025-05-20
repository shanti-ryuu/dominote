# DomiNotes Netlify Deployment Instructions

Follow these steps to successfully deploy your DomiNotes Flutter web app to Netlify:

## Step 1: Build the Flutter Web App Locally

First, make sure you have built the Flutter web app locally:

```bash
cd /path/to/dominote
flutter build web --release
```

This will generate the web build files in the `build/web` directory.

## Step 2: Commit the Build Files to Git

The `.gitignore` file has been modified to include the `build/web` directory, which is normally excluded in Flutter projects. Make sure to commit these files to your repository:

```bash
git add build/web
git commit -m "Add built web files for Netlify deployment"
git push
```

## Step 3: Set Up Netlify Deployment

### Option A: Deploy via Netlify UI (GitHub Integration)

1. Go to [Netlify](https://app.netlify.com/) and sign in
2. Click "New site from Git"
3. Choose GitHub as your Git provider and select your repository
4. Configure the build settings:
   - Build command: `./netlify-build.sh` (already set in netlify.toml)
   - Publish directory: `build/web` (already set in netlify.toml)
5. Click "Deploy site"

### Option B: Direct Upload (Manual Deployment)

If you prefer to deploy manually:

1. Go to [Netlify](https://app.netlify.com/) and sign in
2. Go to "Sites" and drag-and-drop your entire `build/web` folder onto the Netlify UI
3. Wait for the upload to complete

## Troubleshooting

If you encounter any issues with the deployment:

1. **Build command errors**: Make sure the `netlify-build.sh` script is executable (`chmod +x netlify-build.sh`)
2. **Empty build directory**: Ensure you've run `flutter build web --release` locally and committed the files
3. **Netlify UI settings override**: If you're using GitHub integration, check that the build command in the Netlify UI is set to `./netlify-build.sh`

## How It Works

The deployment setup uses the following components:

1. **netlify.toml**: Configures the build command and publish directory
2. **netlify-build.sh**: A simple script that checks for pre-built files instead of trying to run Flutter on Netlify
3. **Modified .gitignore**: Ensures the build/web directory is included in your Git repository

This approach avoids the need to install Flutter in the Netlify build environment, which is not supported by default.

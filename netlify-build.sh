#!/bin/bash

# This is a build script for Netlify that creates a minimal web app
# if the build/web directory is missing or empty

echo "Checking for pre-built Flutter web files..."

# Create build/web directory if it doesn't exist
mkdir -p build/web

# If build/web is empty, create a minimal web app
if [ -z "$(ls -A build/web 2>/dev/null)" ]; then
  echo "build/web directory is empty, creating a minimal web app..."
  
  # Create index.html
  cat > build/web/index.html << 'EOL'
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>DomiNotes</title>
  <style>
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
      margin: 0;
      padding: 0;
      display: flex;
      justify-content: center;
      align-items: center;
      min-height: 100vh;
      background-color: #f5f5f5;
      color: #333;
    }
    .container {
      text-align: center;
      padding: 2rem;
      max-width: 800px;
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    }
    h1 {
      font-size: 2.5rem;
      margin-bottom: 1rem;
    }
    p {
      font-size: 1.2rem;
      line-height: 1.6;
      margin-bottom: 1.5rem;
    }
    .icon {
      font-size: 4rem;
      margin-bottom: 1rem;
    }
    .message {
      color: #666;
      font-style: italic;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="icon">📝</div>
    <h1>DomiNotes</h1>
    <p>A modern note-taking app built with Flutter Web</p>
    <p class="message">This is a placeholder page. The actual Flutter web app will be available soon.</p>
  </div>
</body>
</html>
EOL

  # Create manifest.json
  cat > build/web/manifest.json << 'EOL'
{
  "name": "DomiNotes",
  "short_name": "DomiNotes",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#000000",
  "description": "A modern note-taking app inspired by Apple Notes.",
  "orientation": "portrait-primary",
  "prefer_related_applications": false,
  "icons": [
    {
      "src": "icons/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "icons/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOL

  # Create icons directory
  mkdir -p build/web/icons
  
  # Create a simple placeholder icon (1x1 pixel transparent PNG)
  echo -ne '\x89PNG\r\n\x1a\n\x00\x00\x00\rIHDR\x00\x00\x00\x01\x00\x00\x00\x01\x08\x06\x00\x00\x00\x1f\x15\xc4\x89\x00\x00\x00\nIDATx\x9cc\x00\x01\x00\x00\x05\x00\x01\r\n\xa0\x93\x00\x00\x00\x00IEND\xaeB\x60\x82' > build/web/icons/icon-192.png
  cp build/web/icons/icon-192.png build/web/icons/icon-512.png
  cp build/web/icons/icon-192.png build/web/favicon.png
  
  echo "Created minimal web app in build/web directory"
else
  echo "Pre-built files found in build/web directory"
fi

echo "Deployment will proceed with files in build/web"

exit 0

# DomiNotes

A modern note-taking app built with Flutter Web, inspired by Apple Notes but designed for web deployment via Netlify. DomiNotes functions as a Progressive Web App (PWA) that supports offline access and local data storage.

## Features

- **Secure Access**: 4-digit PIN login for security
- **Notes Management**: Create, edit, delete notes
- **Folders Organization**: Create, edit, delete folders
- **Multiple Folders**: Assign one note to multiple folders
- **Dark Mode**: Toggle between light and dark themes
- **Search**: Find notes by title or content
- **Offline Support**: Works without internet after first load
- **Export Options**: Export notes as .txt or .pdf
- **Responsive Design**: Mobile-first but scales to desktop
- **PWA Support**: Installable on mobile devices

## Technologies Used

- Flutter Web for the UI framework
- Hive for local NoSQL database
- Provider for state management
- PWA features for offline support

## Building and Deploying

### Prerequisites

- Flutter SDK (2.10.0 or higher)
- Dart SDK (2.16.0 or higher)

### Local Development

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run -d chrome` to start the app in development mode

### Building for Production

```bash
flutter build web --release
```

This will generate a production build in the `build/web` directory.

### Deploying to Netlify

1. Create a new site on Netlify
2. Upload the contents of the `build/web` directory
3. Configure the site settings as needed

Alternatively, connect your GitHub repository to Netlify for continuous deployment.

## Project Structure

- `lib/models`: Data models for notes, folders, and PIN
- `lib/providers`: State management using Provider
- `lib/screens`: UI screens for the application
- `lib/services`: Services for database, theme, and export
- `lib/utils`: Utility classes and constants
- `lib/widgets`: Reusable UI components

## License

This project is licensed under the MIT License.

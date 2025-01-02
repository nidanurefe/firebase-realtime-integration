
# Health Monitoring Web Application

This is a Flutter web application that connects to Firebase to retrieve health data, including body temperature and pulse information. The application displays real-time data, visualizes it using charts, and allows users to download the data in CSV format.

## Features

- **Real-time data from Firebase**: The app listens for updates to the health data stored in Firebase Realtime Database.
- **Data visualization**: Body temperature and pulse data are displayed on interactive charts using the Syncfusion Flutter Charts package.
- **Data download**: The app allows users to download the health data as a CSV file.
- **Clear Data**: Users can clear the data stored in Firebase with the "Clear Data" button.

## Technologies Used

- **Flutter**: Cross-platform mobile and web application framework.
- **Firebase**: Cloud-based database and authentication system.
- **Syncfusion Flutter Charts**: Charting library for displaying data visualizations.
- **HTML5 Blob**: For generating downloadable CSV files in the browser.

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/health-monitoring-web-app.git```

2. Navigate to the project directory
   
3. Install the necessary dependencies
    ```bash
   flutter pub get
4. Set up Firebase:
   - Create a Firebase project and configure it for web.
   - Download the firebase_options.dart file and place it in the lib directory.
   - Replace DefaultFirebaseOptions.currentPlatform with your Firebase project options.
   

6. Run the app
   ```bash
   flutter run -d chrome



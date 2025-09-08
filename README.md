# HealthCare — Flutter Health App

> A modular, ML-enabled mobile healthcare app built with Flutter. Features include heart-rate monitoring (camera-based PPG), step tracking, stress detection, menstrual tracking, hydration reminders, medication reminders, SOS & nearby hospitals, and more. Designed with Clean Architecture and BLoC for scalable development.

---

## 🚀 Features
- 🔐 **Authentication**
  - Email & Google Sign-In using Firebase
- 👤 **Profile Management**
  - Upload profile images, shimmer placeholders, completion tracker
- 🚶 **Step Counter**
  - Background pedometer & daily summary(Pedometer)
- 🩺 **Heart Rate Monitor**
  - PPG-based BPM detection via phone camera (TensorFlow Lite model)
- 😟 **Stress Detection**
  - Qn-Based-ML 
- 💧 **Hydration Tracker**
  - Smart water intake reminders, circular progress, charts, and history
- 📆 **Menstrual Cycle Tracker**
  - Predictions, stage-wise health tips, and calendar visualization
- 💊 **Medication Reminders**
  - Add/edit medication schedules with interactive notifications
- 🏥 **Nearby Hospitals + SOS**
  - Live GPS location + OpenStreetMap integration
- 🌦 **Weather Updates**
  - Real-time weather data from [wttr.in](https://wttr.in)
- 🗺️ **Map & Location Search**
  - Geocoding via [Nominatim OpenStreetMap](https://nominatim.openstreetmap.org)

---

## 🧭 Tech Stack
### 📱 Frontend
- Flutter SDK (3.6.1+)  
- State Management: `flutter_bloc`, `provider`  
- UI: `flutter_neumorphic`, `lottie`, `fl_chart`, `percent_indicator`, `shimmer`  

### ☁️ Backend
- Firebase Authentication (`firebase_auth`, `google_sign_in`)  
- Firestore Database (`cloud_firestore`)  
- Firebase Storage (`firebase_storage`)  
- Notifications (`flutter_local_notifications`, `awesome_notifications`)  

### 🤖 Machine Learning
- `tflite_flutter` – TensorFlow Lite inference  
  

### 🌍 Location & Maps
- `geolocator`, `location`, `flutter_map`, `latlong2`  
- **Geocoding & Search**: [Nominatim OSM](https://nominatim.openstreetmap.org)  

### 🌦 Weather
- [wttr.in](https://wttr.in) for real-time weather info  


---

## 📁 Architecture & Methodology
- Agile iterative development with sprints, daily commits, and GitHub Actions CI/CD
- - **Clean Architecture**  
  - **Presentation** → UI, BLoC  
  - **Domain** → Use cases  
  - **Data** → Repositories, models  

- **State Management**  
  - `flutter_bloc`, `hydrated_bloc`, `provider`  

- **Navigation**  
  - `go_router` with guards  

- **Offline Support**  
  - Local caching via `shared_preferences` or SQLite  
  - Sync with Firestore when online 

---

## 🛠️ Requirements
- Flutter SDK 3.6.1 or higher  
- Android SDK (API 21+) / iOS tooling for iOS builds  
- Firebase project with Auth, Firestore, Storage, and Cloud Messaging  
- Device with camera & sensors for heart-rate and stress detection features  

---
# 📸 App Screenshots

### 🏠 Dynamic Home Dashboard
Greeting + Health Summary  
![Home Dashboard](screenshots/home_dashboard.png)



### ❤️ Heart Rate
Live BPM graph with real-time camera detection  
![Heart Rate Graph](screenshots/heart_rate.png)



### 💧 Hydration Tracker
Progress + interactive reminders  
![Hydration Progress](screenshots/hydration.png)



### 🌸 Menstrual Calendar
Cycle predictions & daily stages  
![Menstrual Calendar](screenshots/menstrual.png)



### 💊 Medication Timeline
Daily schedule with alerts  
![Medication Timeline](screenshots/medication.png)



### ⛅ Weather Banner
Fetched via **wttr.in**  
![Weather Banner](screenshots/weather.png)



### 🏥 SOS & Nearby Hospitals
**OpenStreetMap Integration** with hospital locator  
![Nearby Hospitals](screenshots/hospitals.png)

---

## ⚙️ Installation (Dev)
```bash
# 1. clone repo
git clone https://github.com/SAKTHI7R/Health-Care.git
cd Health-Care

# 2. install dependencies
flutter pub get

# 3. run app (Android)
flutter run

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

## 🏠 Home & Dashboard
| ![Home Features](DOCS/SCREENSHOTS/HOME_PAGE_V_D.jpg)  | ![Home Features 2](DOCS/SCREENSHOTS/HOME_PAGE_B_D.jpg) | ![Home Page](DOCS/SCREENSHOTS/HOME_FEATURES_D.jpg) |
|---|---|---|
| ![Home Page 2](DOCS/SCREENSHOTS/HOME_FEATURES_B_D.jpg)| ![Home Page Variant](DOCS/SCREENSHOTS/HOME_PAGE_H_D.jpg) | ![Home Page Variant 2](DOCS/SCREENSHOTS/HOME_PAGE_V_L.jpg) |
| ![Home Appoint Noti](DOCS/SCREENSHOTS/HOME_PAGE_APPOINT_NOTI.jpg) | ![Home Appoint Noti 2](DOCS/SCREENSHOTS/HOME_PAGE_APPOINT_NOTI_1.jpg) | ![Home Page Variant](DOCS/SCREENSHOTS/HOME_PAGE_H_D.jpg) |

---

## ❤️ Heart Rate & Fitness
| ![Heart Rate](DOCS/SCREENSHOTS/HEART_RATE.jpg) | ![Heart Rate 2](DOCS/SCREENSHOTS/HEART_RATE_1.jpg) | ![Fitness Tracking](DOCS/SCREENSHOTS/FITNESS_TRACKING.jpg) |
|---|---|---|
| ![Fitness Tracking 2](DOCS/SCREENSHOTS/FITNESSS_TRACKING_B.jpg) | | |

---

## 💧 Hydration Tracker
| ![Water Tracker](DOCS/SCREENSHOTS/WATER_TRACKER.jpg) | ![Water Tracker 2](DOCS/SCREENSHOTS/WATER_TRACKER_1.jpg) |
|---|---|

---

## 🌸 Menstrual Tracking
| ![Menstrual Tracker](DOCS/SCREENSHOTS/MENSTRUAL_TRACKER.jpg) | ![Menstrual Tracker 2](DOCS/SCREENSHOTS/MENSTRUAL_TRACKER_1.jpg) | ![Menstrual Notification](DOCS/SCREENSHOTS/MENSTRUAL_PEDICATION_NOTIFICATION.jpg) |
|---|---|---|

---

## 💊 Medication
| ![Medication](DOCS/SCREENSHOTS/MEDICATION.jpg) | ![Medication 2](DOCS/SCREENSHOTS/MEDICATION2.jpg) | ![Medication 3](DOCS/SCREENSHOTS/MEDICATION3.jpg) |
|---|---|---|
| ![Medication 4](DOCS/SCREENSHOTS/MEDICATION4.jpg) | ![Medication 5](DOCS/SCREENSHOTS/MEDICATION5.jpg) | |

---

## 🧑‍⚕️ Doctor & Appointments
| ![Doctor Appointment](DOCS/SCREENSHOTS/DOCTOR_APPOINTMENT.jpg) | ![Doctor Appointment 1](DOCS/SCREENSHOTS/DOCTOR_APPOINMENT_1.jpg) | ![Doctor Appointment 2](DOCS/SCREENSHOTS/DOCTOR_APPOINTMENT_2.jpg) |
|---|---|---|
| ![Doctor Appointment 3](DOCS/SCREENSHOTS/DOCTOR_APPOINTMENT_3.jpg) | ![Find Doctor](DOCS/SCREENSHOTS/FIND_DOCTOR.jpg) | ![Find Doctor 1](DOCS/SCREENSHOTS/FIND_DOCTOR_1.jpg) |

---

## 🧍 Profile & Login
| ![Login](DOCS/SCREENSHOTS/LOGIN_PAGE.jpg) | ![Profile](DOCS/SCREENSHOTS/PROFILE_PAGE.jpg) | ![Profile 1](DOCS/SCREENSHOTS/PROFILE_PAGE_1.jpg) |
|---|---|---|

---

## 👣 Step Tracker
| ![Step Tracker](DOCS/SCREENSHOTS/STEP_TRACKER.jpg) | ![Step Tracker 1](DOCS/SCREENSHOTS/STEP_TRACKER_1.jpg) | ![Step Tracker 2](DOCS/SCREENSHOTS/STEP_TRACKER_2.jpg) |
|---|---|---|

---

## 🏥 Emergency & SOS
| ![Hospital Locator](DOCS/SCREENSHOTS/HOSPITAL_LOCATOR.jpg) | ![SOS](DOCS/SCREENSHOTS/SOS.jpg) |
|---|---|

---

## 🔔 Notifications
| ![Off App Notification](DOCS/SCREENSHOTS/OFF_APP_NOTIFICATION.jpg) |
|---|

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

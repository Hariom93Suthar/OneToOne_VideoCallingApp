# 📞 One-to-One Video Calling App using Flutter, Firebase & Agora

A complete one-to-one video calling application built using **Flutter**, **Firebase**, **FCM**, and **Agora SDK**.  
The app supports real-time video calls between two users (User A and User B), including incoming call notifications in both **foreground** and **background** — just like WhatsApp.

---

## 🚀 Features

- 👥 Login system for User A and User B (hardcoded for simulation)
- 📶 Internet connectivity check on login screen
- 📲 Real-time one-to-one video calling via Agora
- 🔔 Incoming call screen with accept/reject buttons
- 🔕 Background call notification handling using FCM
- 🎥 Call screen features:
  - Video/audio stream
  - Mute/unmute
  - Switch camera
  - End call

### 📝 New Feature: Call Logs

- 📒 Every video call (incoming or outgoing) is now saved as a call log in Firestore.
- 🔁 Both User A and User B have access to their own call history.
- ✅ Each log entry stores:
  - Caller and Receiver IDs
  - Call Status: `accepted`, `rejected`, or `missed`
  - Timestamp

---

## 🧩 Tech Stack

| Technology     | Purpose                                    |
|----------------|--------------------------------------------|
| **Flutter**    | Frontend development                       |
| **Firebase**   | Backend & notification services            |
| **Firestore**  | Call state management and call logs        |
| **FCM**        | Push notifications for call alerts         |
| **Agora SDK**  | Real-time video & audio communication      |
| **GetX**       | State management and navigation            |

---

## 📱 App Flow

### 1. Onboarding Screen
- Simple introduction screen to the app.

### 2. Login Screen
- Two buttons: `Login as User A` and `Login as User B`
- ✅ Internet Connectivity Check:  
  If the internet is off, a popup appears with:  
  **"Aapka internet connection off hai"**

### 3. Home Screen
- Shows a list of users to call.
- Tap on a user to initiate a call.

---

## 📞 Calling Logic

### 📟 Foreground Calling
- **User A initiates a call** to User B.
- User A sees **Outgoing Call Screen**.
- User B sees **Incoming Call Screen** with Accept/Reject options.
- Upon Accept:
  - Both are taken to **Video Call Screen**.

### 🔕 Background Calling
- If the app is in background or killed:
  - A WhatsApp-style notification appears using FCM.
  - Tapping on it opens the app and brings up the **Incoming Call Screen**.

---

## 🎥 Video Call Screen Features

- ✅ Show local and remote video feeds
- 🔇 Mute/Unmute audio
- 🔄 Flip camera (Front/Back)
- 🔚 End call gracefully

---

## 🛠️ Setup Guide

### 🔐 Agora Setup

1. Go to [Agora Console](https://console.agora.io/) and create a new project.
2. Get your:
   - App ID
   - Temporary Token (for testing)
3. Add it to your Flutter project in the file `agora_config.dart`:

```dart
const String APP_ID = "YOUR_AGORA_APP_ID";
const String TEMP_TOKEN = "YOUR_TEMP_TOKEN";

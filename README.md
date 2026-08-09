# 📋 TaskFlow — Flutter Todo List

A lightweight and user-friendly **Todo List application built with Flutter** for managing daily tasks with local persistence, search, editing, completion tracking, audio feedback, and OCR-powered task creation from images.

---

## 🌟 Overview

**TaskFlow** is an offline-first Flutter todo application designed to keep task management simple and practical.

Users can:

- 📝 Create tasks
- 🔍 Search tasks instantly
- ✏️ Edit task titles
- ✅ Mark tasks as completed or incomplete
- 🗑️ Delete tasks with swipe actions
- 💾 Persist tasks locally on the device
- 📸 Extract text from images and use it to create tasks
- 🔊 Get audio feedback for supported user actions

The application does not require a backend or an internet connection for its core task-management functionality.

---

## ✨ Features

### 📝 Task Management

- Create new tasks
- Edit existing task titles
- Mark tasks as completed or incomplete
- Delete tasks using swipe actions
- Persist tasks between application launches

### 🔍 Task Search

- Live search through existing tasks
- Filter tasks as the user types

### 📸 OCR Task Import

- Select or capture an image using the image picker
- Extract text from the image using **Google ML Kit Text Recognition**
- Convert detected text into tasks

### 💾 Local Storage

- Store tasks locally using **SharedPreferences**
- Access tasks without a backend
- Preserve tasks after restarting the application

### 🔊 Audio Feedback

- Provide audio feedback for supported user actions
- Keep audio-related logic separated inside the audio service

### 🎨 User Interface

- Material 3 design
- Clean and lightweight interface
- Reusable task input widget
- Snackbar-based user feedback

---

## 🛠️ Tech Stack

| Technology | Purpose |
|---|---|
| **Flutter** | Application framework |
| **Dart** | Programming language |
| **Material 3** | UI and design system |
| **SharedPreferences** | Local task persistence |
| **Google ML Kit Text Recognition** | OCR and text extraction |
| **Image Picker** | Camera and gallery image selection |
| **Audioplayers** | Audio feedback |

---

## 📦 Dependencies

```yaml
dependencies:
  shared_preferences: ^2.5.3              # stores task data locally on the device
  audioplayers: ^6.5.1                    # provides audio playback for user feedback
  google_mlkit_text_recognition: ^0.16.0  # extracts text from images using OCR
  image_picker: ^1.2.0                    # selects images from the camera or gallery
  cupertino_icons: ^1.0.8                 # provides icons for iOS-style UI
```

----

## 📂 Project Structure

```text
lib/
│
├── constants/
│   └── app_sounds.dart
│
├── controllers/
│   └── task_controller.dart
│
├── helpers/
│   └── snackbar_helper.dart
│
├── models/
│   └── task.dart
│
├── screens/
│   ├── splash_screen.dart
│   └── todo_home_page.dart
│
├── services/
│   ├── audio_service.dart
│   ├── image_task_service.dart
│   └── task_storage.dart
│
├── widgets/
│   └── task_input_bar.dart
│
├── app.dart
└── main.dart
```

### Folder Responsibilities

| Folder | Responsibility |
|---|---|
| `constants/` | Application-wide constants |
| `controllers/` | Task-related application logic |
| `helpers/` | Reusable helper utilities |
| `models/` | Application data models |
| `screens/` | Application screens |
| `services/` | Storage, OCR, and audio services |
| `widgets/` | Reusable UI components |

---

## 🚀 Getting Started

### Prerequisites

Make sure Flutter is installed and configured correctly.

```bash
flutter doctor
```

### Installation

```bash
git clone https://github.com/rohiitt405/flutter-todo-list.git
cd flutter-todo-list
flutter pub get
flutter run
```

---

## 🔄 How It Works

### 📝 Task Management

Users can create, edit, complete, and delete tasks from the main task list. Changes are automatically saved to local storage.

### 🔍 Search

The search field allows users to quickly filter tasks based on their title.

### 📸 OCR Task Import

Users can select or capture an image containing text. Google ML Kit extracts the text and converts it into tasks.

### 💾 Local Persistence

Tasks are stored locally using **SharedPreferences**, allowing them to remain available after restarting the application.

### 🔊 Audio Feedback

**Audioplayers** provides audio feedback for supported user actions.

---

## 🔐 Permissions

- 📷 **Camera** — used to capture images for OCR.
- 🖼️ **Gallery / Photos** — used to select images for OCR.

---

## 🔮 Future Improvements

- 🏷️ Categories and labels
- 📅 Due dates and reminders
- ⭐ Task priorities
- 🌙 Dark mode
- ☁️ Cloud synchronization
- 💾 Backup and restore
- 📋 Multiple task lists

---

## 🤝 Contributing

Contributions are always welcome!

1. Fork this repository.
2. Create a feature branch.

```bash
git checkout -b feature/new-feature
```

3. Commit your changes.

```bash
git commit -m "Add new feature"
```

4. Push your branch.

```bash
git push origin feature/new-feature
```

5. Submit a Pull Request.

---

## 📄 License

This project is distributed under the **MIT License**.

---

<p align="center">
Made with ❤️ using Flutter
</p>
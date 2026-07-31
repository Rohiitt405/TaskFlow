# 📋 Flutter Todo List

A lightweight and user-friendly **Todo List** application built with **Flutter**. It provides an intuitive interface for managing daily tasks, supports local data persistence, and includes OCR-powered task creation from images.

---

## 🌟 Overview

This application helps users organize their daily activities by allowing them to:

- Create and manage tasks
- Search tasks instantly
- Edit or delete tasks
- Mark tasks as completed
- Import tasks from images using on-device text recognition
- Save tasks locally for offline access

---

## 🚀 Features

- 📝 Create new tasks
- 🔍 Live task search
- ✅ Complete or uncomplete tasks
- ✏️ Edit task titles
- 🗑️ Swipe to delete tasks
- 💾 Local storage using SharedPreferences
- 📸 OCR-based task import from images
- 🔊 Simple audio feedback for user actions
- 🎨 Modern Material 3 design

---

## 🛠️ Built With

- **Flutter**
- **Dart**
- **Material 3**
- **SharedPreferences**
- **Google ML Kit Text Recognition**
- **Image Picker**
- **Audio Players**

---

## 📂 Project Structure

```
lib/
│
├── main.dart
│
├── models/
│   └── task.dart
│
├── screens/
│   └── todo_home_page.dart
│
└── services/
    ├── audio_service.dart
    └── task_storage.dart
```

---

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/rohiitt405/flutter-todo-list.git
```

### 2. Move into the project directory

```bash
cd flutter-todo-list
```

### 3. Install dependencies

```bash
flutter pub get
```

### 4. Launch the app

```bash
flutter run
```

---

## 📱 How It Works

### Add a Task
Enter a task in the text field and tap the **Add** button.

### Search
Use the search bar to instantly filter tasks.

### Edit
Tap the edit icon to modify an existing task.

### Complete
Tap the checkbox to mark a task as completed.

### Delete
Swipe a task to remove it from the list.

### Import from Image
Capture or choose an image containing text. The app detects text using Google ML Kit and converts it into tasks.

---

## 🧪 Testing

Run all widget tests:

```bash
flutter test
```

---

## 📦 Storage

Tasks are stored locally on the device using **SharedPreferences**, ensuring that your data remains available even after restarting the application.

---

## 📸 Screenshots

Place your screenshots inside a `screenshots/` folder.

```
screenshots/
├── home.png
├── search.png
├── edit.png
└── ocr.png
```

Example:

| Home | Search | OCR |
|------|--------|-----|
| ![](screenshots/home.png) | ![](screenshots/search.png) | ![](screenshots/ocr.png) |

---

## 🔐 Permissions

The application may request:

- 📷 Camera permission (for OCR)
- 🖼️ Gallery access (to import images)

---

## 💡 Future Improvements

- Categories and labels
- Due dates
- Task reminders
- Dark mode
- Cloud synchronization
- Task priority
- Backup & restore
- Multiple task lists

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

## ❤️ Acknowledgements

- Flutter Team
- Google ML Kit
- Flutter Community

---

<p align="center">
Made with ❤️ using Flutter
</p>
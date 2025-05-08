# worklyn_task_app

A simple, task management mobile app with the help of Kora

## ✨ Features

- Chat with Kora a bot to help you set tasks
- Get your tasks from her when you need them
- Persists `userId` across sessions using local storage

## 🏗️ Project Structure

✅ `views/` → UI screens  
✅ `models/` → data models  
✅ `services/` → API & storage helpers

---

## 🚀 Getting Started

1. **Clone the repo:**

```bash
git clone https://github.com/ice949/worklyn_task_app.git

```
```bash
cd worklyn_task_app
```


Install dependencies:

```bash
flutter pub get
```


Run the app:
```bash
flutter run
```

📦 Dependencies
http: For API calls

shared_preferences: For persisting userId

url_launcher: and  flutter_linkify: For Launching url within the message

html: To read html within dart

table_calendar: For the calendar and date picking

fluentui_system_icons: For the beautiful icons in the bottom navigation



📝 Usage

✅ Type a message → press Send → see loading indicator → response displayed. if you are a new user  it will ask for your name to create an account

✅ When logged in tell it a task you need to do and Kora will jot it down for you 

✅ Ask Kora anything regarding your tasks and she will respond

✅ If the response contains tasks, it lists the tasks inside the message bubble.

✅ When you click on a task it opens a bottom sheet with details of the task

✅ When you open the app for the second time it logins the user using persisted user data

✅ Go to tasks screen to also view tasks

✅ Click on the task's checkbox to mark it complete or uncompleted

🤝 Contributing
Feel free to submit pull requests or open issues for improvements!

📃 License
MIT License.
See LICENSE for details.


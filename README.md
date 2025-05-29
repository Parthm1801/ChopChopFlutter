ChopChopAI is a motivational homescreen widget app for iOS that lets users set goals with deadlines and receive AI-generated nudges in different tones (TED Talker, Indian Parent, Harsh Coach, etc.). It includes a Python backend powered by OpenAI + MongoDB.


https://github.com/user-attachments/assets/70c701f5-98fd-43e7-87bc-c19566d4c2ff


## 📱 **iOS App Setup (Xcode)**

## Prerequisites

- macOS with latest Xcode

- Flutter installed (flutter doctor)

- CocoaPods installed (sudo gem install cocoapods)

- Firebase iOS setup (add your GoogleService-Info.plist to ios/Runner)

## Getting Started

**Clone the repo**

```
git clone [https://github.com/yourusername/chopchopai.git](https://github.com/Parthm1801/ChopChopFlutter)
cd chopchopai
```

**Install Flutter packages**

```
flutter pub get
```

**Install iOS dependencies**

```
cd ios
pod install
cd ..
```

**Open in Xcode**

```
open ios/Runner.xcworkspace
```

**Widget Setup**

Make sure the FlutterIOSWidget target is properly configured.

Ensure the correct App Group and Background Modes are enabled.

App Group should match across main app and widget extension.

**Run the app**

Select Runner scheme and a simulator or connected iPhone.

Build and run.


**Repo for python backend for quote generation logic with AI :** https://github.com/Parthm1801/ChopChopPython 


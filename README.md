# HealthAI Ring

An advanced wearable device (ring) app built with Flutter that provides real-time monitoring of key health metrics such as heart rate, blood oxygen levels, and sleep patterns, along with personalized insights and alerts. It also includes a **Life Bar** visualization, **daily health scores**, **habit tracking**, and an **AI chat interface** (powered by ChatGPT) to help users improve their well-being and achieve a healthier lifestyle.

---

Before starting, ensure you have the following installed:

- **Flutter SDK:** [Installation Guide](<[https://flutter.dev/docs/get-started/install](https://docs.flutter.dev/get-started/install)>)
- **Dart SDK:** Required version `^3.5.4`
- **Git:** For cloning the repository
- **IDE/Text Editor:** Recommended Visual Studio Code or Android Studio

## SDK Documentation

I provide two PDF guides for integrating the SDK on iOS and Android.  
Because GitHub does not support inline PDF embedding, click the links below to view or download the guides:

- **[iOS_QCBandSDK Development Guide](docs/ios_QCBandSDK.pdf)**  
  This PDF explains how to integrate the QC Band SDK on iOS, including:

  - Environment configuration
  - Bluetooth permissions
  - Connecting and disconnecting from the watch
  - Setting watch time, reading battery, push notifications
  - Retrieving activity data (steps, sleep, etc.)
  - Updating firmware, watch faces, and more

- **[Android_QCBandSDK Development Guide](docs/android_QCBandSDK.pdf)**  
  This PDF covers the QC Band SDK on Android, including:
  - Required permissions
  - Scanning and connecting to the watch
  - Managing data sync (steps, sleep, heart rate, etc.)
  - Handling watch faces (listing, deleting, custom faces)
  - OTA firmware upgrades
  - One-click and manual measurement commands

## Table of Contents

- [Features](#features)
- [Project Overview](#project-overview)
  - [Clean Architecture](#clean-architecture)
  - [Platform Channels](#platform-channels)
  - [Environment Variables](#environment-variables)
  - [Performance Considerations](#performance-considerations)
  - [Key Libraries](#key-libraries)

---

## Features

1. **Real-time Monitoring**: Track heart rate, blood oxygen, and sleep patterns.
2. **Personalized Insights**: Leverage AI to analyze health data and provide recommendations.
3. **Life Bar Visualization**: Graphical representation of daily health metrics.
4. **Daily Health Scores**: See an aggregate score for daily health progress.
5. **Habit Tracking**: Keep track of health-related habits and progress.
6. **AI Chat Interface**: Ask questions related to your health data and habits, with responses powered by ChatGPT.
7. **Notifications and Alerts**: Receive alerts about anomalies or trends requiring attention.
8. **Persistent Bottom Navigation**: Navigate between core sections of the app via a bottom bar that persists across pages.

---

## Project Overview

### Clean Architecture

I follow **Clean Architecture** principles to separate concerns:

- **Core / Domain** (business rules, domain entities, and use cases)
- **Data** (data sources, repositories, remote/local API handling)
- **Presentation** (UI, state management, routing)

This structure makes the codebase easier to scale, test, and maintain.

### Platform Channels

I use **Platform Channels** to integrate native functionalities such as Bluetooth or other OS-specific services with Flutter. The channel method keys are stored in a dedicated file for clarity and to avoid hardcoded strings in the code.

### Environment Variables

I manage environment-specific data (e.g., API keys, server URLs) using the [**flutter_dotenv**](https://pub.dev/packages/flutter_dotenv) package. This allows for separate `.env` files (e.g., `.env.development`, `.env.production`) and keeps sensitive credentials out of the codebase.

### Performance Considerations

- **Efficient State Management**: Using BLoC with minimal rebuild strategies to keep the UI responsive.
- **Lazy Loading/Singleton Services**: Services (e.g., Bluetooth scanning, AI chat) are singletons to avoid unnecessary resource creation.
- **Asynchronous Operations**: Networking calls run asynchronously to keep the UI smooth, and background tasks are used where appropriate.
- **Local Storage**: Relying on fast read/write local storage solutions to reduce disk I/O overhead.

### Key Libraries

- **[Hive](https://pub.dev/packages/hive)**: Used for lightweight and efficient data persistence and caching.
- **[shared_preferences](https://pub.dev/packages/shared_preferences)**: For storing user preferences and small key-value data (like settings or user configurations).
- **[dartz](https://pub.dev/packages/dartz)**: Implements functional paradigms (e.g., `Either` types) to handle failures and successes more gracefully within our use cases.
- **[go_router](https://pub.dev/packages/go_router)**: Simplifies routing across the app, including deep linking support and more structured navigation management.
- **[equatable](https://pub.dev/packages/equatable)**: Provides a simple way to implement value-based equality without needing to write lots of boilerplate `==` and `hashCode`.
- **[speech_to_text](https://pub.dev/packages/speech_to_text)**: Enables speech recognition features, allowing users to interact with the AI chat via voice input.
- **[persistent_bottom_nav_bar](https://pub.dev/packages/persistent_bottom_nav_bar)** (or similar): Maintains a bottom navigation bar across different routes to provide a seamless user experience.

---

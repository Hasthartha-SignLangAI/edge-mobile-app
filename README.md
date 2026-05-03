# Hasthaartha: Real-Time Sign Language AI

Hasthaartha is an advanced mobile application designed to bridge the communication gap for the hearing and speech-impaired community. By combining wearable sensor technology (EMG + IMU) with edge-based deep learning, Hasthaartha provides seamless, real-time translation of Sinhala Sign Language into text and speech.

---

## Key Features

- **Real-Time Translation**: Low-latency gesture recognition using an optimized CNN-LSTM architecture.
- **Dual Translation Modes**:
  - **Word Mode**: Instant translation of individual signs with history tracking.
  - **Sentence Mode**: Compose complex thoughts and translate them into full Sinhala sentences with speech feedback.
- **Smart Calibration**: One-tap recalibration to ensure accuracy across different users and environments.
- **History Management**: Persistent logs of translated gestures for easy reference.
- **Premium UI**: Modern, glassmorphic design system optimized for accessibility and ease of use.
- **Edge Inference**: All AI processing happens locally on the device using ONNX Runtime, ensuring privacy and offline functionality.

---

## Technology Stack

- **Framework**: [Flutter](https://flutter.dev/) (Cross-platform mobile development)
- **State Management**: [Riverpod](https://riverpod.dev/) (Predictable and testable state)
- **Database**: [Isar](https://isar.dev/) (High-performance NoSQL local storage)
- **Connectivity**: [Bluetooth Low Energy (BLE)](https://pub.dev/packages/flutter_blue_plus) for wearable sensor streaming.
- **AI/ML Engine**: [ONNX Runtime](https://onnxruntime.ai/) for high-performance edge inference.
- **Speech**: [Flutter TTS](https://pub.dev/packages/flutter_tts) for localized Sinhala speech synthesis.

---

## Project Structure

This repository contains the primary mobile application and supporting modules:

```text
.
├── hasthaartha_app/      # Main Flutter Application (Active)
│   ├── lib/              # Source code (services, screens, providers)
│   ├── assets/           # ONNX models, label maps, and branding assets
│   └── ...
├── README.md             # This file
└── .gitignore            # Root-level git rules
```

---

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or Xcode
- A Hasthaartha-compatible wearable armband (for real-time streaming)

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/Hasthaartha-SignLangAI/edge-mobile-app.git
   cd edge-mobile-app/hasthaartha_app
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the application**:
   ```bash
   flutter run
   ```

---

## Model Architecture

The application uses a sophisticated **CNN-LSTM** model trained on high-frequency EMG and IMU data. 
- **EMG (8 channels)**: Captures muscle activation patterns.
- **IMU (9-axis)**: Captures hand orientation and movement dynamics.
- **Inference**: Optimized via ONNX for sub-10ms processing time on mobile hardware.

---

## Contributing

We welcome contributions! Please feel free to submit Pull Requests or open issues for feature requests and bug reports.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
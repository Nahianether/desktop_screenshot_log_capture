# desktop_screen_log_capture

A Flutter desktop project built exclusively for Windows OS. This project enables capturing screenshots of the desktop and collecting Windows logs using two distinct approaches. Both approaches utilize external libraries written in C++ and Rust to perform native operations efficiently.

## Features

- Capture screenshots of the desktop on Windows using two different approaches:
  1. **C++ Library + Method Channel**: Utilizes a C++ library to capture the screen and return the image as a `List<int>`. Method channels are used to trigger the C++ function from Flutter.
  2. **Rust + FFI (Foreign Function Interface)**: Captures the screen using a Rust library and saves the screenshot directly to a desired path. The Rust code is triggered via FFI from Flutter.

- Collect Windows logs:
  - A C++ library is used to gather Windows system logs. Method channels are again used to trigger the function from Flutter and interact with the native C++ code.

## Technologies Used

- **Flutter** (Windows Desktop Platform)
- **C++** (for screen capture and log collection)
- **Rust** (for alternative screen capture approach)
- **Method Channel** (to communicate between Flutter and C++)
- **FFI (Foreign Function Interface)** (to communicate between Flutter and Rust)

## Installation and Setup

### Prerequisites
- Windows OS
- Flutter SDK (configured for desktop development)
- C++ compiler (for building the C++ code)
- Rust toolchain (for building the Rust code)

### Clone the Repository

```bash
git clone https://github.com/yourusername/desktop_screen_log_capture.git
cd desktop_screen_log_capture

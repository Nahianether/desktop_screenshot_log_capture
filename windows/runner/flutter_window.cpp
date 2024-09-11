#include "flutter_window.h"
#include <optional>
#include <windows.h>
#include <gdiplus.h>
#include <iostream>
#include <winevt.h>
#include <string>
#include <vector>
#include "flutter/generated_plugin_registrant.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#pragma comment(lib, "gdiplus.lib")

#pragma comment(lib, "wevtapi.lib")

using namespace Gdiplus;

void RegisterMethodChannel(flutter::FlutterEngine* engine);

// Function to capture the screenshot and send pixel data to Flutter
std::vector<uint8_t> CaptureDesktopScreenshot() {
    HDC hdcScreen = GetDC(NULL);
    HDC hdcMem = CreateCompatibleDC(hdcScreen);

    int width = GetDeviceCaps(hdcScreen, HORZRES);
    int height = GetDeviceCaps(hdcScreen, VERTRES);

    HBITMAP hbmScreen = CreateCompatibleBitmap(hdcScreen, width, height);
    SelectObject(hdcMem, hbmScreen);

    BitBlt(hdcMem, 0, 0, width, height, hdcScreen, 0, 0, SRCCOPY);

    BITMAPINFOHEADER biHeader;
    biHeader.biSize = sizeof(BITMAPINFOHEADER);
    biHeader.biWidth = width;
    biHeader.biHeight = -height; // top-down bitmap
    biHeader.biPlanes = 1;
    biHeader.biBitCount = 32;
    biHeader.biCompression = BI_RGB;
    biHeader.biSizeImage = 0;
    biHeader.biXPelsPerMeter = 0;
    biHeader.biYPelsPerMeter = 0;
    biHeader.biClrUsed = 0;
    biHeader.biClrImportant = 0;

    int imageSize = width * height * 4; // 32-bit bitmap
    std::vector<uint8_t> imageData(imageSize);

    GetDIBits(hdcScreen, hbmScreen, 0, height, imageData.data(), (BITMAPINFO*)&biHeader, DIB_RGB_COLORS);

    // Clean up
    DeleteObject(hbmScreen);
    DeleteDC(hdcMem);
    ReleaseDC(NULL, hdcScreen);

    return imageData;
}

// Function to collect Windows logs
std::string CollectWindowsLogs() {
    EVT_HANDLE hResults = EvtQuery(NULL, L"Application", NULL, EvtQueryReverseDirection);

    if (!hResults) {
        return "Failed to query event logs.";
    }

    EVT_HANDLE hEvent = NULL;
    DWORD dwReturned = 0;
    std::string logData;

    while (EvtNext(hResults, 1, &hEvent, INFINITE, 0, &dwReturned)) {
        DWORD bufferUsed = 0;
        DWORD propertyCount = 0;

        // Get the size of the required buffer
        EvtRender(NULL, hEvent, EvtRenderEventXml, 0, NULL, &bufferUsed, &propertyCount);
        
        // Allocate a buffer large enough for the event data
        std::vector<wchar_t> buffer(bufferUsed / sizeof(wchar_t));

        // Render the event into the buffer
        if (EvtRender(NULL, hEvent, EvtRenderEventXml, bufferUsed, &buffer[0], &bufferUsed, &propertyCount)) {
            // std::wstring eventXml(buffer.begin(), buffer.end());
            // std::string eventLog(eventXml.begin(), eventXml.end()); // Convert to string
            // logData += eventLog + "\n";
            std::wstring eventXml(buffer.begin(), buffer.end());
            int bufferSize = WideCharToMultiByte(CP_UTF8, 0, eventXml.c_str(), -1, nullptr, 0, NULL, NULL);

            if (bufferSize > 0) {
                std::vector<char> utf8Buffer(bufferSize);
                WideCharToMultiByte(CP_UTF8, 0, eventXml.c_str(), -1, &utf8Buffer[0], bufferSize, NULL, NULL);
                std::string eventLog(&utf8Buffer[0]);
                logData += eventLog + "\n";
            }
        }

        EvtClose(hEvent);
    }

    EvtClose(hResults);

    return logData.empty() ? "No new event logs found." : logData;
}

// Register Method Channel
void RegisterMethodChannel(flutter::FlutterEngine* engine) {
    auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
        engine->messenger(), "screenshot_channel", &flutter::StandardMethodCodec::GetInstance());

    channel->SetMethodCallHandler(
        [](const flutter::MethodCall<flutter::EncodableValue>& call,
           std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
            if (call.method_name().compare("captureScreenshot") == 0) {
                std::vector<uint8_t> screenshotData = CaptureDesktopScreenshot();
                result->Success(flutter::EncodableValue(screenshotData));
            } else if (call.method_name().compare("getWindowsLogs") == 0) {
                std::string logs = CollectWindowsLogs();
                result->Success(flutter::EncodableValue(logs));
            } else {
                result->NotImplemented();
            }
        });
}

LRESULT FlutterWindow::MessageHandler(HWND hwnd, UINT const message, WPARAM const wparam, LPARAM const lparam) noexcept {
  // Handle specific messages here if necessary
  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  // Pass unhandled messages to the base class
  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }

  RegisterPlugins(flutter_controller_->engine());
  RegisterMethodChannel(flutter_controller_->engine());  // Register the Method Channel

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

# AUTOHAUS — Intelligent Home Automation (Awning & Window)

**Project**: AUTOHAUS — Automated awning (Toldo) and window (Janela) control using ESP32, L298N motor drivers, local web interface, and Alexa voice control (Espalexa).

**Institution**: Colégio Estadual Souza Naves — ALTAS HABILIDADES / SUPERDOTAÇÃO (NAAHS)

**Authors / Contributors**

* Eric Cristian
* André Tannuri

---

## Overview

AUTOHAUS is a school research project that automates an awning and a window using ESP32 microcontrollers and L298N motor drivers. It offers local control through a simple HTTP-based web interface, voice control via Espalexa (Alexa), and optional remote control through a mobile app and Firebase Realtime Database. The project focuses on reliability, simple HTML controls (HTTP GET forms and redirects), sensor-driven automation (rain sensor, optional light sensor), and storing preferences locally on the ESP32 (Preferences).

## Key Features

* Control two systems: **Toldo** (awning) and **Janela** (window).
* Motor control for two L298N drivers (two motors for the awning, one motor for the window).
* Adjustable motor speed (0–255) and direction control for each motor.
* Simple web interface using HTTP GET endpoints and HTML forms (no heavy JavaScript required).
* Alexa integration using **Espalexa**, allowing voice commands (mapped to specific operation modes).
* mDNS for name-based discovery on the local network.
* WiFiManager for easy Wi-Fi configuration and Preferences for persistent storage of the awning/window positions and profiles.
* Rain sensor logic: sensor default state is OFF; automatic behavior when rain is detected.
* Optionally integrates with a Flutter mobile app and Firebase Realtime Database for global control without opening ports.

## Hardware

* ESP32 development board (or compatible module)
* L298N motor driver(s) — one or more depending on the motors
* DC motors for awning and window (specifications depend on mechanical design)
* Rain sensor (digital input)
* Optional light sensor (analog or digital depending on sensor)
* Limit switches / end-stop sensors for safety (recommended)
* Power supply appropriate for motors and ESP32

> **Note:** Always double-check wiring and the L298N power connections. Use diodes, fuses, or appropriate motor driver protections as needed for your motors and setup.

## Software Components / Libraries

* ESP32 Arduino core
* WiFiManager
* Espalexa
* Preferences (ESP32 Preferences / EEPROM alternative)
* mDNS
* ESPAsyncWebServer (recommended for improved HTML interface responsiveness)

## API / Endpoints (examples)

The firmware exposes simple HTTP GET endpoints for control. Examples (adjust to match your firmware routes):

* `GET /motor?device=toldo&motor=A&dir=forward&speed=200` — set motor A of the awning forward at speed 200
* `GET /toldo/set?position=70` — set awning to 70% open (the firmware maps percent to motor pulses/time)
* `GET /alexa/mode0` — trigger Alexa mode 0 behavior (example of Espalexa integration)

> Implementation detail: The project author prefers using HTML forms (GET) with server-side redirects back to the control page to keep the UI simple and compatible with low-resource devices.

## Awning Position Logic

* The awning position is measured and stored as a percentage (0–100%).
* Movement is implemented in small timed steps per 10% (example: a specific wake time per 10% increment). These timing constants must be tuned for your mechanical installation.
* The system keeps track of the current position in Preferences so it persists across reboots.

## Alexa (Espalexa) Integration

* Espalexa is used to create a virtual device discoverable by Alexa (Echo) on the local network.
* Voice commands are mapped to modes or direct motor actions (for instance, mode 0 triggers a preset behavior like open/close to a saved position).
* Ensure mDNS and the Espalexa service are running to allow Alexa to discover the device.

## Mobile App & Remote Control

* A Flutter app (originally prototyped in FlutterFlow but implemented in pure Flutter) can be used to control the system.
* The app uses GoRouter for navigation and PageTransition for smooth page animations.
* For global access, the project uses Firebase Realtime Database to relay commands without opening local ports.

## Safety & Best Practices

* Use limit switches to prevent overrun and protect the mechanical system.
* Implement emergency stop hardware and motor current protection where possible.
* Tune motor run times carefully to avoid mechanical stress.
* Do not store sensitive Wi-Fi passwords in public repositories. Use WiFiManager or other secure mechanisms for configuration.

## Download

* The AutoHaus App is available on https://auto-haus-site.vercel.app/desktop/aplicativo.html



---

*This README is a base template — you can modify hardware pinouts, endpoints, or descriptions to match the exact code in your repository.*

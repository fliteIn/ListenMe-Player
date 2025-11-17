<p align="center">
  <img src="assets/logo.png" alt="ListenMe Logo" width="140" height="140">
</p>

<h1 align="center">ListenMe Player — Open Edition</h1>

<p align="center">
  Advanced Flutter audio player for language learners, podcasters, and offline listening.<br>
  Precision navigation • Silence analysis • Fully customizable UI
</p>

<p align="center">
  <!-- Badges -->
  <img src="https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/Platform-Android-green?logo=android&logoColor=white" alt="Platform Android">
  <img src="https://img.shields.io/badge/License-MIT-yellow.svg" alt="MIT License">
  <img src="https://img.shields.io/badge/Open%20Edition-Source%20Code-lightgrey" alt="Open Edition">
</p>

---

**ListenMe Player** is an advanced audio player built with Flutter, designed for language learners, podcasters, interview transcribers, and everyone who prefers listening to audio offline.  
The application combines precise navigation tools, silence analysis, and deeply customizable UI.

This repository contains an **open (reduced) edition** of the project.  
Some private modules (premium logic, ads, Firebase configuration, service keys) are intentionally excluded.

> 🎯 **Goal of the Open Edition**  
> To showcase architecture design, UI/UX decisions, audio processing techniques,  
> and the engineering approach behind building a complex Flutter-based audio player.

---

## ✨ Features

### 🎧 Playback & Navigation
- Segment playback between markers with fine adjustment
- Jump between silence regions
- Playback with skip functions and smooth scrubbing
- Jog wheel with precise rewind buttons (continuous speed control)
- Fully configurable playback speed

### 🔍 Silence & PCM Analysis
- Local audio analysis
- PCM level map generation
- Silence detection
- Adjustable silence threshold
- Real-time loudness visualization

### 🎛 UI Customization
- Full theme editor
- Adjustable colors, gradients, and shadows
- Configurable widget layout with drag-and-drop
- Customizable speed ranges (playback + seek)
- Background image support

### 📁 Playlists
- Folder-based playlist with subfolder navigation
- Manual playlist with drag-and-drop reordering
- Audio tag metadata parsing
- Persistent playlist source memory
- Playback modes: singleOnce, singleLoop, playlistOnce, playlistLoop, shuffle

### 💾 Cache
- Adjustable cache size
- Custom retention time
- Clear cache function

### 🎚 Equalizer
- Full equalizer with presets
- Custom user-defined settings

### 📖 Help
- Built-in help section describing each UI element and screen

---

## 🧱 Architecture

State models:

- **AppModel** — root coordinator
- **PlaybackModel** — playback & JustAudio integration
- **PlaylistModel** — playlist and source management
- **AudioToLevelsModel** — PCM & silence analysis
- **AppThemeColors** — theming system
- **DisplayWidgetConfig** — UI layout configuration

Modular UI:

- **widgets/** — jog wheel, sliders, control panels
- **ui/** — app screens
- **utils/** — helpers
- **l10n/** — localization
- **assets/** — images and backgrounds

---

## ⚠️ Open Edition Status

Some commercial and confidential modules (monetization, ads, Firebase configs)  
are **not included** in this public version.

This means the project **may not compile** as a fully functional app.  
The purpose of the repository is to demonstrate **architecture and UI**,  
not to provide a production-ready build.

---

## 🗣 Feedback

If you have questions about the architecture, audio processing, state management, or UI,  
feel free to open an **Issue** or start a **Discussion** in the repository.

---

## 📲 Install the App

You can install the full application on Google Play:

[<img src="https://play.google.com/intl/en_us/badges/static/images/badges/en_badge_web_generic.png"
alt="Get it on Google Play" height="80">](https://play.google.com/store/apps/details?id=com.listenme.player)

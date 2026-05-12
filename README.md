# RKCNL Survey App Monorepo

This repository contains the RKCNL Survey application, split into two parts:

## 1. Frontend (`frontend/`)
A Flutter application that provides an offline-first survey collection experience for field surveyors.

## 2. Backend (`backend/`)
A Node.js and Express API that acts as the central synchronization and management server. It interfaces with PostgreSQL to store surveys and responses.

### Getting Started

#### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

#### Backend
```bash
cd backend
npm install
node index.js
```

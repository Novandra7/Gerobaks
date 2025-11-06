# LocalStorage Implementation in Gerobaks App

## Overview
This document outlines the localStorage implementation that has been integrated across the Gerobaks application. The implementation provides persistent data storage for user information, points, settings, and other app data using SharedPreferences.

## Key Components

### 1. Models
- **UserModel**: Stores user information including name, email, points, and other profile data.

### 2. Services
- **LocalStorageService**: Core service that handles data persistence using SharedPreferences.
- **UserService**: Manages user-related operations including authentication, points management, and profile updates.
- **SignUpService**: Handles user registration flow and assigns initial points to new users.

### 3. Features
- **User Authentication**: Login and registration with persistent credentials.
- **Points System**: Users start with 15 points upon registration.
- **Profile Management**: User profile data persistence across app sessions.
- **Data Synchronization**: Real-time data updates across all app pages.

## Implemented Functionality

### LocalStorageService
- **Core Storage Methods**: Read, write, update, and delete operations for different data types.
- **User Data Storage**: Store and retrieve user profile information.
- **Points Management**: Track and update user points.
- **Settings Storage**: Save user preferences and app settings.

### UserService
- **Authentication**: Login and logout functionality.
- **User Registration**: New user creation with initial points.
- **Points Management**: Add, use, and track points.
- **Profile Updates**: Change user information and preferences.

### Implementation in UI
- **Sign In Page**: Authenticate users against stored credentials.
- **Sign Up Flow**: Register new users and assign 15 initial points.
- **Profile Page**: Display user information from localStorage.
- **Points History**: Show transactions and current point balance.

## CRUD Operations

### Create
- New user registration with initial data
- Adding addresses
- Creating point transactions

### Read
- Loading user profile information
- Retrieving points balance
- Fetching saved addresses
- Getting app settings

### Update
- Updating user profile data
- Modifying points (adding/deducting)
- Changing app settings

### Delete
- Removing saved addresses
- Logging out (clearing session data)
- Clearing cached data

## Points System
- New users automatically receive 15 points upon registration
- Points can be earned through various actions in the app
- Points can be spent on rewards and benefits
- Full transaction history is maintained

## Future Enhancements
- Cloud synchronization for offline-first experience
- Multi-device support
- Encrypted storage for sensitive information
- Improved backup and restore functionality

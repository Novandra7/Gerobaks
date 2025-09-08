# Keluhan (Complaints) System Documentation

## Overview
The Keluhan (Complaints) system in the Gerobaks application allows users to submit, track, and manage complaints about various services. This document explains the system's components, features, and usage.

## Key Features

### 1. Complaints Submission
- **Judul (Title)**: Short description of the complaint
- **Kategori (Category)**: Type of complaint (e.g., Waste Collection, Late Schedule)
- **Prioritas (Priority)**: Urgency level (Low, Normal, High, Urgent)
- **Deskripsi (Description)**: Detailed explanation of the issue
- **Lokasi (Location)**: Where the issue occurred
- **Contact Information**: Name and phone number of the reporter

### 2. Complaints Tracking
- **Status Tracking**: View current status of complaints (Waiting, In Review, In Progress, Resolved)
- **Filtering**: Filter complaints by status, priority, category, and date
- **Searching**: Search complaints by title or description

### 3. Complaint Response System
- **Admin Responses**: View official responses to complaints
- **Resolution Updates**: Track how complaints are being resolved
- **Timeline View**: See the progression of complaint resolution

## Components

### 1. Keluhan Page (Modern UI)
Located in `lib/ui/pages/buat_keluhan/keluhan_page_new.dart`
- Main listing page with advanced filtering and search
- Card-based UI for complaints with visual status indicators
- Detailed view access for individual complaints

### 2. Enhanced Complaint Form
Located in `lib/ui/pages/buat_keluhan/improved_keluhan_form.dart`
- Modern form for submitting new complaints
- Form validation and user feedback
- Success confirmation page with complaint details

### 3. Original Complaint Page
Located in `lib/ui/pages/buat_keluhan/buat_keluhan_page.dart`
- Original implementation for complaint listing
- Maintained for comparison and compatibility

### 4. Response System
Located in `lib/ui/pages/buat_keluhan/tanggapan_keluhan_page.dart`
- Interface for viewing and adding responses to complaints
- Status update functionality for complaint tracking

### 5. Navigation Control
Located in `lib/ui/pages/buat_keluhan/keluhan_navigation_page.dart`
- Tab-based navigation between different UI implementations
- Unified entry point for the complaints system

## Usage Instructions

### Submitting a Complaint
1. Navigate to the Complaints section
2. Select "Enhanced Form" tab
3. Fill in all required fields
4. Submit the complaint
5. Review the confirmation page

### Viewing Complaints
1. Navigate to the Complaints section
2. Select "Modern UI" tab to view all complaints
3. Use the filter chips to narrow down results
4. Use the search bar to find specific complaints
5. Tap on any complaint card to view details

### Responding to Complaints
1. From the complaint details view
2. Add responses in the response section
3. Update the status as needed

## Future Enhancements

1. **Photo Upload**: Add ability to attach photos to complaints
2. **Location Services**: Integrate with map to automatically capture location
3. **Push Notifications**: Notify users of status changes
4. **Analytics Dashboard**: Provide metrics on complaint resolution times
5. **Export Features**: Allow exporting complaint reports as PDF

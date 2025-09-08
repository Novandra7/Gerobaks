# Golden Ratio Keluhan Pages

This document provides guidance on using the Golden Ratio-enhanced complaint management pages in the Gerobaks application.

## Overview

The Golden Ratio-enhanced Keluhan (complaint) system includes three main components:

1. **GoldenKeluhanPage** - The main complaints listing and management page
2. **GoldenKeluhanForm** - The form for creating new complaints
3. **TanggapanKeluhanPage** - The page for responding to and updating complaints

These pages have been redesigned using the Golden Ratio (1:1.618) to create visually harmonious layouts, better proportions, and improved user experience.

## Using the Components

### 1. Adding to Your Navigation

Import the components from the central export file:

```dart
import 'package:bank_sha/ui/pages/buat_keluhan/golden_keluhan_pages.dart';
```

Then, navigate to the main complaints page:

```dart
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const GoldenKeluhanPage()),
);
```

### 2. Key Features

The Golden Ratio Keluhan pages include the following features:

- **Visual Harmony**: All layouts follow golden ratio proportions (1:1.618)
- **Responsive Design**: UI elements adjust to different screen sizes
- **Filtering**: Filter complaints by status, category, and priority with enhanced visual feedback
- **Search**: Search through complaints by any field with improved search box design
- **Tab Navigation**: Easy switching between Semua (All), Riwayat (History), and Terbaru (Recent) views with animated tabs
- **Status Management**: Full status lifecycle management with color-coded indicators
- **Response System**: Ability to respond to complaints
- **Animated Interactions**: Smooth transitions and animations for better user experience

### 3. Golden Ratio Implementation

The Golden Ratio (φ, approximately 1.618) is implemented in:

- Layout divisions (61.8% / 38.2% splits)
- Spacing hierarchies (based on φ and its powers)
- Visual element sizing
- Content prioritization

## Design Philosophy

The redesign focuses on:

1. **Visual Hierarchy**: Important information stands out through golden ratio spacing
2. **Scannable Content**: Users can quickly find and understand complaint information
3. **Consistent Experience**: Visual patterns that create a cohesive experience
4. **Status Clarity**: Clear visual cues for different complaint statuses
5. **Intuitive Navigation**: Golden ratio-based spacing for comfortable interaction targets

## Usage in Routes

Add these routes to your app's routing system:

```dart
// In your routes configuration
'/keluhan': (context) => const GoldenKeluhanPage(),
'/keluhan/buat': (context) => const GoldenKeluhanForm(),
```

## Customization

You can customize colors, text styles, and other UI elements by modifying the theme references in each file. The core golden ratio proportions should be maintained for visual harmony.

## Sample Code for Creating a Complaint

```dart
// Navigate to the complaint form
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const GoldenKeluhanForm()),
).then((result) {
  if (result != null && result is Map<String, dynamic>) {
    // Handle the new complaint data
    print('New complaint created: ${result['judul']}');
  }
});
```

## Best Practices

1. **Use Consistent Data Structure**: Follow the complaint data model shown in the example code
2. **Preserve Golden Ratio**: When customizing, maintain the 1:1.618 ratio for layout divisions
3. **Status Colors**: Keep the status color system consistent for user comprehension
4. **Response Requirements**: Always require responses when marking complaints as resolved

---

Created with ❤️ using Golden Ratio design principles

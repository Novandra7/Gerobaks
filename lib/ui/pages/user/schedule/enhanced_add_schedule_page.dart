import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:bank_sha/config/map_config.dart';
import 'package:intl/intl.dart';
import 'dart:math' show min;

class AddSchedulePage extends StatefulWidget {
  const AddSchedulePage({Key? key}) : super(key: key);

  @override
  State<AddSchedulePage> createState() => _AddSchedulePageState();
}

class _AddSchedulePageState extends State<AddSchedulePage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _addressController = TextEditingController();
  final _wasteTypeController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // FocusNodes for better keyboard handling
  final _addressFocusNode = FocusNode();
  final _notesFocusNode = FocusNode();
  
  // State variables
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.once;
  double? _selectedLat;
  double? _selectedLng;
  bool _isLoading = false;
  bool _hasUserInteraction = false;
  bool _hasSelectedLocation = false;
  String _selectedWasteType = 'Campuran';
  
  // Waste type options
  final List<String> _wasteTypes = [
    'Campuran',
    'Organik',
    'Anorganik',
    'B3',
    'Elektronik',
  ];
  
  // Animation controllers
  late AnimationController _mapSelectionAnimationController;
  
  // Services
  final _scheduleService = ScheduleService();
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controller for map selection feedback
    _mapSelectionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Set initial value for waste type controller
    _wasteTypeController.text = _selectedWasteType;
  }
  
  @override
  void dispose() {
    // Clean up controllers
    _addressController.dispose();
    _wasteTypeController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    _contactNameController.dispose();
    _phoneController.dispose();
    
    // Clean up focus nodes
    _addressFocusNode.dispose();
    _notesFocusNode.dispose();
    
    // Clean up animation controllers
    _mapSelectionAnimationController.dispose();
    
    super.dispose();
  }
  
  // Date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _hasUserInteraction = true;
      });
    }
  }
  
  // Time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              onSurface: blackColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _hasUserInteraction = true;
      });
    }
  }
  
  // Validation Helper
  FormFieldValidator<String> _validateRequired(String errorMessage) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return errorMessage;
      }
      return null;
    };
  }
  
  // Open Map Picker with animation and feedback
  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPickerPage(
          initialLocation: _selectedLat != null && _selectedLng != null 
              ? LatLng(_selectedLat!, _selectedLng!) 
              : null,
          onLocationSelected: (address, lat, lng) {
            setState(() {
              _addressController.text = address;
              _selectedLat = lat;
              _selectedLng = lng;
              _hasSelectedLocation = true;
              _hasUserInteraction = true; // Enable validation
            });
            
            // Animate selection and show feedback
            _animateLocationSelection();
          },
        ),
      ),
    );
  }
  
  // Animate location selection with visual feedback
  void _animateLocationSelection() {
    _mapSelectionAnimationController.reset();
    _mapSelectionAnimationController.forward();
    
    // Show a confirmation snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Location successfully selected'),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
  
  // Submit the form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      // Form is not valid
      return;
    }
    
    // Check if we have valid location data
    if (_selectedLat == null || _selectedLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a valid location on the map'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    // Start loading state
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Create schedule model
      final newSchedule = ScheduleModel(
        userId: 'current-user-id', // Get from auth service in real app
        scheduledDate: _selectedDate,
        timeSlot: _selectedTime,
        location: LatLng(_selectedLat!, _selectedLng!),
        address: _addressController.text,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        status: ScheduleStatus.pending,
        frequency: _selectedFrequency,
        createdAt: DateTime.now(),
        wasteType: _wasteTypeController.text,
        estimatedWeight: _weightController.text.isNotEmpty ? double.parse(_weightController.text) : null,
        isPaid: false,
        contactName: _contactNameController.text.isNotEmpty ? _contactNameController.text : null,
        contactPhone: _phoneController.text.isNotEmpty ? _phoneController.text : null,
      );
      
      // Create the schedule
      final createdSchedule = await _scheduleService.createSchedule(newSchedule);
      
      // Success!
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Schedule created successfully'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        
        // Navigate back
        Navigator.pop(context, createdSchedule);
      }
    } catch (e) {
      if (mounted) {
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create schedule: ${e.toString()}'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  // Address and Location Fields
  Widget _buildAddressField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _addressController,
          focusNode: _addressFocusNode,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Enter your pickup address',
            prefixIcon: Icon(Icons.location_on_outlined, color: greenColor),
            suffixIcon: _hasSelectedLocation
                ? Tooltip(
                    message: 'Location selected from map',
                    child: Icon(Icons.check_circle, color: greenColor),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            errorStyle: TextStyle(color: Colors.red.shade700),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greenColor, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.red.shade700, width: 1),
            ),
          ),
          validator: _validateRequired('Please enter your pickup address'),
          onChanged: (value) {
            setState(() {
              _hasUserInteraction = true;
            });
          },
          autovalidateMode: _hasUserInteraction 
              ? AutovalidateMode.onUserInteraction 
              : AutovalidateMode.disabled,
        ),
        if (_selectedLat != null && _selectedLng != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                Icon(Icons.pin_drop, size: 16, color: greenColor),
                const SizedBox(width: 4),
                Text(
                  'Coordinates: ${_selectedLat!.toStringAsFixed(6)}, ${_selectedLng!.toStringAsFixed(6)}',
                  style: greyTextStyle.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Show map icon if coordinates are set
  Widget _buildMapButton() {
    return GestureDetector(
      onTap: _openMapPicker,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: _hasSelectedLocation 
              ? greenColor.withOpacity(0.2) 
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _hasSelectedLocation ? greenColor : Colors.grey.shade300,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _hasSelectedLocation ? Icons.check_circle : Icons.map,
              color: _hasSelectedLocation ? greenColor : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              _hasSelectedLocation 
                  ? 'Location Selected' 
                  : 'Select Location on Map',
              style: TextStyle(
                color: _hasSelectedLocation ? greenColor : Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Location Map Preview
  Widget _buildLocationPreview() {
    if (_selectedLat == null || _selectedLng == null) {
      return const SizedBox.shrink();
    }
    
    return AnimatedBuilder(
      animation: _mapSelectionAnimationController,
      builder: (context, child) {
        final bounceAnimation = CurvedAnimation(
          parent: _mapSelectionAnimationController,
          curve: Curves.elasticOut,
        );
        
        return Transform.scale(
          scale: 0.95 + (0.05 * bounceAnimation.value),
          child: child,
        );
      },
      child: Container(
        height: 150,
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8, bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: greenColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // Map preview using FlutterMap
              FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(_selectedLat!, _selectedLng!),
                  initialZoom: 15.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate: MapConfig.tileUrl,
                    subdomains: const ['a', 'b', 'c'],
                    userAgentPackageName: 'com.gerobaks.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(_selectedLat!, _selectedLng!),
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Overlay to indicate it's non-interactive
              Positioned(
                right: 8,
                bottom: 8,
                child: ElevatedButton.icon(
                  onPressed: _openMapPicker,
                  icon: const Icon(Icons.edit_location_alt, size: 16),
                  label: const Text('Change'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: greenColor,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Enhanced weight field with numeric keyboard and validation
  Widget _buildWeightField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _weightController,
          // Specify numeric keyboard with decimal option
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          // Input formatting to ensure valid number format (only digits and one decimal point)
          inputFormatters: [
            // Allow only digits and at most one decimal point with up to 2 decimal places
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          // Styling and decoration
          decoration: InputDecoration(
            labelText: 'Estimated Weight',
            hintText: 'e.g., 5.5',
            // Custom suffix to indicate unit of measurement
            suffixText: 'kg',
            suffixStyle: TextStyle(
              color: greenColor,
              fontWeight: FontWeight.w500,
            ),
            // Icon for visual identification
            prefixIcon: Icon(Icons.scale, color: greenColor),
            // Helper text to provide additional context
            helperText: 'Approximate weight in kilograms',
            helperStyle: greyTextStyle.copyWith(fontSize: 12),
            // Border styling for different states
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: greenColor, width: 2),
            ),
            // Error styling
            errorStyle: TextStyle(color: Colors.red.shade700),
            // Content padding for comfortable text entry
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          // Comprehensive validation logic
          validator: (value) {
            // Weight is optional, so empty value is allowed
            if (value == null || value.isEmpty) {
              return null;
            }
            
            // Validate number format
            final weight = double.tryParse(value);
            if (weight == null) {
              return 'Please enter a valid number';
            }
            
            // Validate range (positive and reasonable maximum)
            if (weight <= 0) {
              return 'Weight must be greater than 0';
            }
            
            if (weight > 1000) {
              return 'Weight seems too high, please verify';
            }
            
            return null;
          },
          // Auto-validate after user has interacted with the field
          autovalidateMode: _hasUserInteraction 
              ? AutovalidateMode.onUserInteraction 
              : AutovalidateMode.disabled,
          // Handle state updates on change
          onChanged: (value) {
            setState(() {
              _hasUserInteraction = true;
            });
          },
          // Styling for the text input
          style: blackTextStyle.copyWith(fontSize: 16),
          // Text alignment for numeric input
          textAlign: TextAlign.start,
        ),
        
        // Optional: Add animated weight visualization
        if (_weightController.text.isNotEmpty && double.tryParse(_weightController.text) != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 8,
            margin: const EdgeInsets.only(top: 8),
            width: MediaQuery.of(context).size.width * 
                min(0.8, (double.parse(_weightController.text) / 100)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [greenColor.withOpacity(0.6), greenColor],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
  
  // Phone field with proper formatting and keyboard
  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-() ]')),
      ],
      decoration: InputDecoration(
        labelText: 'Contact Phone',
        hintText: 'e.g., +62 812-3456-7890',
        prefixIcon: Icon(Icons.phone, color: greenColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      onChanged: (value) {
        setState(() {
          _hasUserInteraction = true;
        });
      },
    );
  }
  
  // Check if form has unsaved changes
  bool _hasChanges() {
    return _addressController.text.isNotEmpty ||
        _wasteTypeController.text != _selectedWasteType ||
        _weightController.text.isNotEmpty ||
        _notesController.text.isNotEmpty ||
        _contactNameController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _selectedLat != null ||
        _selectedLng != null ||
        _selectedFrequency != ScheduleFrequency.once ||
        _selectedDate != DateTime.now();
  }
  
  // Confirm before popping if changes exist
  Future<bool> _onWillPop() async {
    if (_hasChanges()) {
      // Show confirmation dialog
      return await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
            'Discard Changes?',
            style: blackTextStyle.copyWith(fontWeight: semiBold),
          ),
          content: Text(
            'You have unsaved changes. Are you sure you want to discard them?',
            style: greyTextStyle,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                'Continue Editing',
                style: TextStyle(color: greenColor),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(
                'Discard',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ) ?? false;
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    // Get device screen size for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add Schedule',
            style: blackTextStyle.copyWith(
              fontSize: 18,
              fontWeight: semiBold,
            ),
          ),
          backgroundColor: whiteColor,
          elevation: 0.5,
          centerTitle: true,
          iconTheme: IconThemeData(color: blackColor),
        ),
        body: SafeArea(
          child: Stack(
            children: [
              // Main Form Content
              Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 16.0 : 20.0,
                    vertical: 20.0,
                  ),
                  children: [
                    // Form Layout
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Schedule Details Section
                            _buildSectionHeader('Schedule Details', Icons.calendar_today_rounded),
                            const SizedBox(height: 16),
                            
                            // Date Picker Field
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Pickup Date',
                                  prefixIcon: Icon(Icons.event, color: greenColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                child: Text(
                                  DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                                  style: blackTextStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Time Picker Field
                            InkWell(
                              onTap: () => _selectTime(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Pickup Time',
                                  prefixIcon: Icon(Icons.access_time, color: greenColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                child: Text(
                                  _selectedTime.format(context),
                                  style: blackTextStyle,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Frequency Dropdown
                            DropdownButtonFormField<ScheduleFrequency>(
                              value: _selectedFrequency,
                              decoration: InputDecoration(
                                labelText: 'Frequency',
                                prefixIcon: Icon(Icons.repeat, color: greenColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              items: ScheduleFrequency.values.map((frequency) {
                                String displayText;
                                switch (frequency) {
                                  case ScheduleFrequency.once:
                                    displayText = 'One Time';
                                    break;
                                  case ScheduleFrequency.daily:
                                    displayText = 'Daily';
                                    break;
                                  case ScheduleFrequency.weekly:
                                    displayText = 'Weekly';
                                    break;
                                  case ScheduleFrequency.biWeekly:
                                    displayText = 'Bi-Weekly';
                                    break;
                                  case ScheduleFrequency.monthly:
                                    displayText = 'Monthly';
                                    break;
                                }
                                return DropdownMenuItem<ScheduleFrequency>(
                                  value: frequency,
                                  child: Text(displayText),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedFrequency = value;
                                    _hasUserInteraction = true;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Contact Information Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Contact Information', Icons.person_outline),
                            const SizedBox(height: 16),
                            
                            // Contact Name Field
                            TextFormField(
                              controller: _contactNameController,
                              decoration: InputDecoration(
                                labelText: 'Contact Name',
                                hintText: 'Who should we contact?',
                                prefixIcon: Icon(Icons.person, color: greenColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _hasUserInteraction = true;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Phone Field
                            _buildPhoneField(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Pickup Location', Icons.pin_drop),
                            const SizedBox(height: 16),
                            
                            // Address Field
                            _buildAddressField(),
                            const SizedBox(height: 12),
                            
                            // Map Button
                            _buildMapButton(),
                            
                            // Map Preview (only shown when location is selected)
                            _buildLocationPreview(),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Waste Details Section
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('Waste Details', Icons.delete_outline),
                            const SizedBox(height: 16),
                            
                            // Waste Type Dropdown
                            DropdownButtonFormField<String>(
                              value: _selectedWasteType,
                              decoration: InputDecoration(
                                labelText: 'Waste Type',
                                prefixIcon: Icon(Icons.category, color: greenColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              items: _wasteTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedWasteType = value;
                                    _wasteTypeController.text = value;
                                    _hasUserInteraction = true;
                                  });
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            
                            // Weight Field
                            _buildWeightField(),
                            const SizedBox(height: 16),
                            
                            // Notes Field
                            TextFormField(
                              controller: _notesController,
                              focusNode: _notesFocusNode,
                              maxLines: 3,
                              decoration: InputDecoration(
                                labelText: 'Additional Notes',
                                hintText: 'Any special instructions?',
                                prefixIcon: Padding(
                                  padding: const EdgeInsets.only(bottom: 48),
                                  child: Icon(Icons.note_alt_outlined, color: greenColor),
                                ),
                                alignLabelWithHint: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _hasUserInteraction = true;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Bottom padding to ensure floating action button doesn't obscure content
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              
              // Loading Overlay
              if (_isLoading)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(greenColor),
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _isLoading ? null : _submitForm,
          backgroundColor: greenColor,
          foregroundColor: whiteColor,
          icon: const Icon(Icons.check),
          label: const Text('Create Schedule'),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
  
  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: greenColor, size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
        ],
      ),
    );
  }
}

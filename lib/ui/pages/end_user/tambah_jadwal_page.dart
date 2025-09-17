import 'package:bank_sha/models/schedule_model.dart';
import 'package:bank_sha/services/local_storage_service.dart';
import 'package:bank_sha/services/schedule_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/buttons.dart';
import 'package:bank_sha/ui/widgets/shared/dialog_helper.dart';
import 'package:bank_sha/ui/widgets/shared/map_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:intl/intl.dart';

class TambahJadwalPage extends StatefulWidget {
  const TambahJadwalPage({super.key});

  @override
  State<TambahJadwalPage> createState() => _TambahJadwalPageState();
}

class _TambahJadwalPageState extends State<TambahJadwalPage> {
  final MapController _mapController = MapController();
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  final _weightController = TextEditingController();
  
  LatLng _currentCenter = LatLng(-0.5028797174108289, 117.15020096577763);
  
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  ScheduleFrequency _selectedFrequency = ScheduleFrequency.once;
  String _selectedWasteType = 'Organik';
  
  bool _isLoading = false;
  List<TimeOfDay> _availableTimeSlots = [];
  String? _userId;
  
  final ScheduleService _scheduleService = ScheduleService();
  
  @override
  void initState() {
    super.initState();
    _getUserId();
    _loadAvailableTimeSlots();
  }
  
  Future<void> _getUserId() async {
    final localStorage = await LocalStorageService.getInstance();
    final userData = await localStorage.getUserData();
    if (userData != null) {
      setState(() {
        _userId = userData['id'] as String;
      });
    }
  }
  
  Future<void> _loadAvailableTimeSlots() async {
    await _scheduleService.initialize();
    final timeSlots = await _scheduleService.getAvailableTimeSlots(_selectedDate);
    setState(() {
      _availableTimeSlots = timeSlots;
      
      // Set default time slot if available
      if (timeSlots.isNotEmpty) {
        _selectedTime = timeSlots.first;
      }
    });
  }
  
  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: greenColor,
              onPrimary: whiteColor,
              surface: whiteColor,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadAvailableTimeSlots();
    }
  }
  
  Future<void> _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      if (_userId == null) {
        DialogHelper.showErrorDialog(
          context: context, 
          title: 'Login Diperlukan',
          message: 'Silakan login terlebih dahulu untuk menambah jadwal',
        );
        return;
      }
      
      setState(() {
        _isLoading = true;
      });
      
      try {
        final double? weight = double.tryParse(_weightController.text);
        
        final schedule = await _scheduleService.addSchedule(
          userId: _userId!,
          scheduledDate: _selectedDate,
          timeSlot: _selectedTime,
          location: _currentCenter,
          address: _addressController.text,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          frequency: _selectedFrequency,
          wasteType: _selectedWasteType,
          estimatedWeight: weight,
          isPaid: false, // Default to unpaid, payment will be handled separately
          amount: null, // Will be calculated later based on weight and waste type
        );
        
        setState(() {
          _isLoading = false;
        });
        
        // Show success dialog
        DialogHelper.showSuccessDialog(
          context: context,
          title: 'Jadwal Berhasil Ditambahkan',
          message: 'Jadwal pengambilan sampah telah berhasil ditambahkan untuk ${DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate)} pukul ${_formatTimeOfDay(_selectedTime)}',
        ).then((_) {
          Navigator.pop(context, schedule); // Return to previous screen with the new schedule
        });
        
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        DialogHelper.showErrorDialog(
          context: context,
          title: 'Gagal Menambah Jadwal',
          message: 'Terjadi kesalahan saat menambahkan jadwal. Silakan coba lagi nanti.',
        );
        print('Error adding schedule: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Peta dengan FlutterMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 18.0,
              onPositionChanged: (position, hasGesture) {
                setState(() {
                  _currentCenter = position.center;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.gerobaks.app',
              ),
            ],
          ),

          // Marker tetap di tengah layar
          Center(child: Icon(Icons.location_pin, size: 40, color: greenColor)),

          // Tombol Back dan informasi lokasi
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tombol Back dengan border hijau
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: greenColor, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: whiteColor,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: blackColor),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Informasi lokasi
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: greenColor, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pilih Lokasi Penjemputan',
                          style: blackTextStyle.copyWith(
                            fontSize: 14,
                            fontWeight: semiBold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Geser peta untuk memilih lokasi yang tepat',
                          style: greyTextStyle.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Form Panel di bawah
          DraggableScrollableSheet(
            initialChildSize: 0.4,
            minChildSize: 0.2,
            maxChildSize: 0.95,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle bar
                          Center(
                            child: Container(
                              width: 50,
                              height: 5,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Form title
                          Text(
                            'Jadwal Penjemputan Baru',
                            style: blackTextStyle.copyWith(
                              fontSize: 18,
                              fontWeight: semiBold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Koordinat lokasi terpilih
                          Text(
                            'Koordinat Lokasi',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on, color: greenColor, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${_currentCenter.latitude.toStringAsFixed(6)}, ${_currentCenter.longitude.toStringAsFixed(6)}',
                                    style: greyTextStyle.copyWith(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Lokasi Penjemputan header
                          Row(
                            children: [
                              Icon(Icons.location_on, color: greenColor),
                              SizedBox(width: 8),
                              Text(
                                'Lokasi Penjemputan',
                                style: blackTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: semiBold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          
                          // Lokasi saya saat ini field
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.my_location, color: greenColor),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Lokasi saya saat ini',
                                    style: blackTextStyle.copyWith(fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          
                          // Peta Lokasi button
                          GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman MapPicker
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapPickerPage(
                                    initialLocation: _currentCenter,
                                    onLocationSelected: (address, lat, lng) {
                                      setState(() {
                                        _addressController.text = address;
                                        _currentCenter = LatLng(lat, lng);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.map,
                                    size: 40,
                                    color: greenColor,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Peta Lokasi',
                                    style: blackTextStyle.copyWith(
                                      fontSize: 14,
                                      fontWeight: medium,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Tekan untuk memilih lokasi di peta',
                                    style: greyTextStyle.copyWith(
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Alamat lengkap
                          Text(
                            'Alamat Lengkap',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _addressController,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Masukkan alamat lengkap',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 16),

                          // Pilih Tanggal
                          Text(
                            'Tanggal Penjemputan',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: greenColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(_selectedDate),
                                    style: blackTextStyle.copyWith(fontSize: 14),
                                  ),
                                  const Spacer(),
                                  Icon(Icons.arrow_drop_down, color: greenColor),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Pilih Waktu
                          Text(
                            'Waktu Penjemputan',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<TimeOfDay>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.access_time, color: greenColor, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: _availableTimeSlots.map((TimeOfDay time) {
                              return DropdownMenuItem<TimeOfDay>(
                                value: time,
                                child: Text(_formatTimeOfDay(time)),
                              );
                            }).toList(),
                            value: _selectedTime,
                            onChanged: (TimeOfDay? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedTime = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Jenis Sampah
                          Text(
                            'Jenis Sampah',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.delete_outline, color: greenColor, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: ['Organik', 'Anorganik', 'B3', 'Campuran'].map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            value: _selectedWasteType,
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedWasteType = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Perkiraan Berat
                          Text(
                            'Perkiraan Berat (kg)',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Masukkan perkiraan berat',
                              prefixIcon: Icon(Icons.scale, color: greenColor, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Frekuensi Penjemputan
                          Text(
                            'Frekuensi Penjemputan',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<ScheduleFrequency>(
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.repeat, color: greenColor, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: ScheduleFrequency.once,
                                child: const Text('Sekali saja'),
                              ),
                              DropdownMenuItem(
                                value: ScheduleFrequency.daily,
                                child: const Text('Setiap hari'),
                              ),
                              DropdownMenuItem(
                                value: ScheduleFrequency.weekly,
                                child: const Text('Setiap minggu'),
                              ),
                              DropdownMenuItem(
                                value: ScheduleFrequency.biWeekly,
                                child: const Text('Setiap 2 minggu'),
                              ),
                              DropdownMenuItem(
                                value: ScheduleFrequency.monthly,
                                child: const Text('Setiap bulan'),
                              ),
                            ],
                            value: _selectedFrequency,
                            onChanged: (ScheduleFrequency? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedFrequency = newValue;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Catatan tambahan
                          Text(
                            'Catatan (opsional)',
                            style: blackTextStyle.copyWith(fontWeight: semiBold),
                          ),
                          const SizedBox(height: 4),
                          TextFormField(
                            controller: _notesController,
                            decoration: InputDecoration(
                              hintText: 'Masukkan catatan tambahan',
                              prefixIcon: Icon(Icons.note_alt, color: greenColor, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 2,
                          ),
                          const SizedBox(height: 32),

                          // Button
                          CustomFilledButton(
                            title: 'Tambah Jadwal',
                            isLoading: _isLoading,
                            onPressed: _saveSchedule,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

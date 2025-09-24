import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/navigation_page_redesigned.dart';

class DetailPickupPage extends StatefulWidget {
  final String scheduleId;

  const DetailPickupPage({super.key, required this.scheduleId});

  @override
  State<DetailPickupPage> createState() => _DetailPickupPageState();
}

class _DetailPickupPageState extends State<DetailPickupPage> {
  bool isLoading = true;
  Map<String, dynamic>? scheduleData;
  bool isSmallScreen = false;

  @override
  void initState() {
    super.initState();
    // Load schedule data
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    // Simulate loading data
    await Future.delayed(Duration(seconds: 1));

    // Mock data for now
    setState(() {
      scheduleData = {
        "id": widget.scheduleId,
        "customer_name": "Wahyu Indra",
        "address": "Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur",
        "latitude": -0.5017, // Koordinat Samarinda
        "longitude": 117.1536,
        "time": "08:00 - 09:00",
        "waste_type": "Organik",
        "waste_weight": "3 kg",
        "status": "pending",
        "phone": "+62812345678",
        "notes": "Sampah diletakkan di depan pagar rumah",
      };
      isLoading = false;
    });
  }

  Future<void> _openGoogleMaps() async {
    if (!mounted) return; // Check if widget is still mounted

    try {
      final latitude = scheduleData!['latitude'];
      final longitude = scheduleData!['longitude'];

      // Check if Google Maps is installed
      final Uri googleMapsUri = Uri.parse(
        'google.navigation:q=$latitude,$longitude',
      );

      if (await canLaunchUrl(googleMapsUri)) {
        // Google Maps app is installed, try to launch it
        await launchUrl(googleMapsUri, mode: LaunchMode.externalApplication);
        return;
      }

      // If Google Maps app is not installed, try the browser URLs
      final List<String> browserUrlsToTry = [
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&travelmode=driving',
        'https://maps.google.com/maps?daddr=$latitude,$longitude',
        'https://maps.google.com/maps?q=$latitude,$longitude',
      ];

      for (String urlString in browserUrlsToTry) {
        final uri = Uri.parse(urlString);

        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return;
        }
      }

      // If all attempts failed, show a dialog with options
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Pilih Navigasi'),
            content: Text(
              'Tidak dapat membuka Google Maps secara otomatis. Silakan pilih opsi navigasi lain atau buka di browser.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openAlternativeMaps();
                },
                child: Text('Aplikasi Navigasi Lain'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
                    ),
                    mode: LaunchMode.inAppWebView,
                  );
                },
                child: Text('Buka di Browser'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Log the error for debugging
      print('Error opening Google Maps: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error membuka Google Maps: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _openAlternativeMaps() async {
    if (!mounted) return;

    try {
      final latitude = scheduleData!['latitude'];
      final longitude = scheduleData!['longitude'];

      // Structure for app packages and their corresponding URLs
      final Map<String, String> appOptions = {
        'com.waze': 'https://waze.com/ul?ll=$latitude,$longitude&navigate=yes',
        'com.here.app.maps':
            'https://wego.here.com/directions/drive//$latitude,$longitude',
        'maps.apple.com':
            'https://maps.apple.com/?daddr=$latitude,$longitude&dirflg=d',
      };

      // Try to check if any navigation app is available
      List<String> availableApps = [];

      for (var entry in appOptions.entries) {
        final uri = Uri.parse(entry.value);
        if (await canLaunchUrl(uri)) {
          availableApps.add(entry.key);
        }
      }

      if (availableApps.isEmpty) {
        // If no apps are available, try the fallback to browser
        final fallbackUri = Uri.parse(
          'https://www.openstreetmap.org/directions?from=&to=$latitude%2C$longitude',
        );

        if (await canLaunchUrl(fallbackUri)) {
          await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
        } else {
          // Show error if even the fallback fails
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Tidak ada aplikasi navigasi yang tersedia pada perangkat ini.',
                ),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      } else if (availableApps.length == 1) {
        // If only one app is available, open it directly
        final appKey = availableApps.first;
        final uri = Uri.parse(appOptions[appKey]!);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // If multiple apps are available, show dialog to choose
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Pilih Aplikasi Navigasi'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableApps.length,
                  itemBuilder: (context, index) {
                    final appKey = availableApps[index];
                    String appName = 'Aplikasi Navigasi';

                    // Determine app name
                    if (appKey.contains('waze')) {
                      appName = 'Waze';
                    } else if (appKey.contains('here')) {
                      appName = 'HERE Maps';
                    } else if (appKey.contains('apple')) {
                      appName = 'Apple Maps';
                    }

                    return ListTile(
                      title: Text(appName),
                      onTap: () async {
                        Navigator.pop(context);
                        final uri = Uri.parse(appOptions[appKey]!);
                        await launchUrl(
                          uri,
                          mode: LaunchMode.externalApplication,
                        );
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Batal'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Log error for debugging
      print('Error opening alternative maps: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _openInAppNavigation() {
    if (scheduleData != null) {
      try {
        // Prepare data for the navigation page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => TrackingBloc(),
              child: NavigationPageRedesigned(scheduleData: scheduleData!),
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka navigasi: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Data lokasi pengambilan tidak tersedia.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen width for responsive layout
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pengambilan',
          style: blackTextStyle.copyWith(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: blackColor),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: greenColor))
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (scheduleData == null) {
      return Center(
        child: Text(
          'Data tidak ditemukan',
          style: blackTextStyle.copyWith(fontSize: 16),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 14 : 16,
        vertical: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status indicator
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: isSmallScreen ? 14 : 16),
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            decoration: BoxDecoration(
              color: _getStatusColor(scheduleData!['status']).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(
                  scheduleData!['status'],
                ).withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(scheduleData!['status']),
                  color: _getStatusColor(scheduleData!['status']),
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  'Status: ${_getStatusText(scheduleData!['status'])}',
                  style: TextStyle(
                    color: _getStatusColor(scheduleData!['status']),
                    fontWeight: semiBold,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),

          // Customer info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: isSmallScreen ? 16 : 18,
                      color: greenColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Informasi Pelanggan',
                      style: blackTextStyle.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                _buildInfoRow(
                  'Nama',
                  scheduleData!['customer_name'],
                  isSmallScreen,
                ),
                _buildInfoRow(
                  'No. Telepon',
                  scheduleData!['phone'],
                  isSmallScreen,
                ),
                _buildInfoRow(
                  'Alamat',
                  scheduleData!['address'],
                  isSmallScreen,
                ),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Pickup details card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: isSmallScreen ? 16 : 18,
                      color: greenColor,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Detail Pengambilan',
                      style: blackTextStyle.copyWith(
                        fontSize: isSmallScreen ? 14 : 16,
                        fontWeight: semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                _buildInfoRow('ID Jadwal', scheduleData!['id'], isSmallScreen),
                _buildInfoRow('Waktu', scheduleData!['time'], isSmallScreen),
                _buildInfoRow(
                  'Jenis Sampah',
                  scheduleData!['waste_type'],
                  isSmallScreen,
                ),
                _buildInfoRow(
                  'Berat Sampah',
                  scheduleData!['waste_weight'],
                  isSmallScreen,
                ),
                _buildInfoRow(
                  'Status',
                  _getStatusText(scheduleData!['status']),
                  isSmallScreen,
                ),
                if (scheduleData!['notes'] != null &&
                    scheduleData!['notes'].isNotEmpty)
                  _buildInfoRow(
                    'Catatan',
                    scheduleData!['notes'],
                    isSmallScreen,
                  ),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 20 : 24),

          // Action button
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 50 : 56,
            child: ElevatedButton(
              onPressed: () async {
                // Menampilkan dialog pilihan navigasi
                final choice = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(
                        'Pilih Aplikasi Navigasi',
                        style: blackTextStyle.copyWith(
                          fontSize: 18,
                          fontWeight: semiBold,
                        ),
                      ),
                      content: Text(
                        'Pilih aplikasi untuk navigasi ke lokasi pengambilan:',
                        style: greyTextStyle.copyWith(fontSize: 14),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(null),
                          child: Text(
                            'Batal',
                            style: greyTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop('in_app'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Navigasi Dalam Aplikasi',
                            style: whiteTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop('google'),
                          child: Text(
                            'Google Maps',
                            style: greenTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context).pop('alternative'),
                          child: Text(
                            'Aplikasi Lain',
                            style: greenTextStyle.copyWith(
                              fontSize: 14,
                              fontWeight: medium,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (choice == 'in_app') {
                  // Buka navigasi dalam aplikasi
                  _openInAppNavigation();
                } else if (choice == 'google') {
                  // Buka Google Maps dengan navigasi
                  await _openGoogleMaps();
                } else if (choice == 'alternative') {
                  // Buka aplikasi navigasi alternatif
                  await _openAlternativeMaps();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.navigation, // Ikon navigasi yang lebih sesuai
                    size: isSmallScreen ? 18 : 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Mulai Pengambilan',
                    style: whiteTextStyle.copyWith(
                      fontSize: isSmallScreen ? 14 : 16,
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isSmallScreen) {
    return Padding(
      padding: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: isSmallScreen ? 90 : 100,
            child: Text(
              label,
              style: blackTextStyle.copyWith(fontSize: isSmallScreen ? 12 : 14),
            ),
          ),
          Text(
            ': ',
            style: blackTextStyle.copyWith(fontSize: isSmallScreen ? 12 : 14),
          ),
          Expanded(
            child: Text(
              value,
              style: blackTextStyle.copyWith(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: medium,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'pending':
        return 'Menunggu';
      case 'in_progress':
        return 'Diproses';
      case 'completed':
        return 'Selesai';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_progress':
        return Icons.directions_run;
      case 'completed':
        return Icons.check_circle_outline;
      default:
        return Icons.help_outline;
    }
  }
}

import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_sha/blocs/tracking/tracking_bloc.dart';
import 'package:bank_sha/models/schedule_api_model.dart';
import 'package:bank_sha/services/schedule_api_service.dart';
import 'package:bank_sha/ui/pages/mitra/pengambilan/navigation_page_redesigned.dart';
import 'package:intl/intl.dart';

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
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    // Load schedule data
    _loadScheduleData();
  }

  Future<void> _loadScheduleData() async {
    try {
      // Try loading schedule from backend
      final int? idInt = int.tryParse(widget.scheduleId);
      if (idInt != null) {
        final ScheduleApiModel raw = await ScheduleApiService().getScheduleById(
          idInt,
        );
        final latitude = raw.latitude ?? -0.5017;
        final longitude = raw.longitude ?? 117.1536;
        final scheduledAt = raw.scheduledAt;
        final formattedTime = scheduledAt == null
            ? 'Waktu belum ditentukan'
            : DateFormat.Hm('id_ID').format(scheduledAt);

        scheduleData = {
          'id': raw.id,
          'customer_name': raw.title,
          'address': raw.description ?? 'Alamat tidak tersedia',
          'latitude': latitude,
          'longitude': longitude,
          'time': formattedTime,
          'waste_type': 'Campuran',
          'waste_weight': '3 kg',
          'status': raw.status ?? 'pending',
          'phone': raw.assignedUser?.phone ?? '+62812345678',
          'notes': raw.description ?? '',
        };
      } else {
        // Fallback to mock if scheduleId isn't numeric
        scheduleData = {
          'id': widget.scheduleId,
          'customer_name': 'Wahyu Indra',
          'address': 'Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur',
          'latitude': -0.5017,
          'longitude': 117.1536,
          'time': '08:00 - 09:00',
          'waste_type': 'Organik',
          'waste_weight': '3 kg',
          'status': 'pending',
          'phone': '+62812345678',
          'notes': 'Sampah diletakkan di depan pagar rumah',
        };
      }
    } catch (e) {
      // Fallback to mock data on error
      scheduleData = {
        'id': widget.scheduleId,
        'customer_name': 'Wahyu Indra',
        'address': 'Jl. Muso Salim 8, Kota Samarinda, Kalimantan Timur',
        'latitude': -0.5017,
        'longitude': 117.1536,
        'time': '08:00 - 09:00',
        'waste_type': 'Organik',
        'waste_weight': '3 kg',
        'status': 'pending',
        'phone': '+62812345678',
        'notes': 'Sampah diletakkan di depan pagar rumah',
      };
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String _normalizeStatus(dynamic value) =>
      value?.toString().toLowerCase() ?? 'pending';

  Future<bool> _updateScheduleStatus(
    String status, {
    String? successMessage,
  }) async {
    final scheduleId = int.tryParse(widget.scheduleId);
    if (scheduleId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ID jadwal tidak valid untuk memperbarui status.',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
          ),
        );
      }
      return false;
    }

    if (mounted) {
      setState(() {
        _isUpdatingStatus = true;
      });
    }

    try {
      final updated = await ScheduleApiService().updateScheduleStatus(
        scheduleId,
        status,
      );

      final scheduledAt = updated.scheduledAt;
      final formattedTime = scheduledAt == null
          ? 'Waktu belum ditentukan'
          : DateFormat.Hm('id_ID').format(scheduledAt);

      if (mounted) {
        setState(() {
          scheduleData = {
            ...(scheduleData ?? <String, dynamic>{}),
            'id': updated.id,
            'customer_name': updated.title,
            'address':
                updated.description ??
                (scheduleData?['address'] ?? 'Alamat tidak tersedia'),
            'latitude':
                updated.latitude ?? scheduleData?['latitude'] ?? -0.5017,
            'longitude':
                updated.longitude ?? scheduleData?['longitude'] ?? 117.1536,
            'time': formattedTime,
            'waste_type': scheduleData?['waste_type'] ?? 'Campuran',
            'waste_weight': scheduleData?['waste_weight'] ?? '3 kg',
            'status': updated.status ?? status,
            'phone':
                updated.assignedUser?.phone ??
                scheduleData?['phone'] ??
                '+62812345678',
            'notes': updated.description ?? scheduleData?['notes'] ?? '',
          };
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              successMessage ?? 'Status jadwal diperbarui.',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
          ),
        );
      }
      return true;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal memperbarui status: $e',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 80),
          ),
        );
      }
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _handlePrimaryAction() async {
    final status = _normalizeStatus(scheduleData?['status']);
    if (status == 'completed' || _isUpdatingStatus) {
      return;
    }

    if (status == 'pending') {
      final success = await _updateScheduleStatus(
        'in_progress',
        successMessage: 'Status diperbarui menjadi Diproses.',
      );
      if (success) {
        await _promptNavigationOptions();
      }
      return;
    }

    if (status == 'in_progress') {
      await _updateScheduleStatus(
        'completed',
        successMessage: 'Pengambilan ditandai selesai.',
      );
      return;
    }

    await _promptNavigationOptions();
  }

  Future<void> _promptNavigationOptions() async {
    if (!mounted) return;

    final choice = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Mulai Pengambilan',
            style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 18),
          ),
          content: Text(
            'Pilih metode navigasi yang ingin digunakan untuk menuju lokasi.',
            style: greyTextStyle.copyWith(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Batal',
                style: TextStyle(color: redcolor, fontWeight: semiBold),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('in_app'),
              child: Text(
                'Navigasi Dalam Aplikasi',
                style: greenTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('google'),
              child: Text(
                'Google Maps',
                style: blueTextStyle.copyWith(
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('alternative'),
              child: Text(
                'Aplikasi Lain',
                style: TextStyle(
                  color: orangeColor,
                  fontSize: 14,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (choice == 'in_app') {
      _openInAppNavigation();
    } else if (choice == 'google') {
      await _openGoogleMaps();
    } else if (choice == 'alternative') {
      await _openAlternativeMaps();
    }
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              'Pilih Navigasi',
              style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 18),
            ),
            content: Text(
              'Tidak dapat membuka Google Maps secara otomatis. Silakan pilih opsi navigasi lain atau buka di browser.',
              style: greyTextStyle.copyWith(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _openAlternativeMaps();
                },
                child: Text(
                  'Aplikasi Navigasi Lain',
                  style: blueTextStyle.copyWith(fontWeight: semiBold),
                ),
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
                child: Text(
                  'Buka di Browser',
                  style: greenTextStyle.copyWith(fontWeight: semiBold),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Batal',
                  style: TextStyle(color: redcolor, fontWeight: semiBold),
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Log the error for debugging
      debugPrint('Error opening Google Maps: $e');

      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error membuka Google Maps: $e',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
                  style: whiteTextStyle.copyWith(fontWeight: medium),
                ),
                backgroundColor: redcolor,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Pilih Aplikasi Navigasi',
                style: blackTextStyle.copyWith(fontWeight: bold, fontSize: 18),
              ),
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
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.navigation,
                          color: blueColor,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        appName,
                        style: blackTextStyle.copyWith(fontWeight: medium),
                      ),
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
                  child: Text(
                    'Batal',
                    style: TextStyle(color: redcolor, fontWeight: semiBold),
                  ),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      // Log error for debugging
      debugPrint('Error opening alternative maps: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: $e',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
            content: Text(
              'Tidak dapat membuka navigasi: ${e.toString()}',
              style: whiteTextStyle.copyWith(fontWeight: medium),
            ),
            backgroundColor: redcolor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Data lokasi pengambilan tidak tersedia.',
            style: whiteTextStyle.copyWith(fontWeight: medium),
          ),
          backgroundColor: redcolor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
      backgroundColor: uicolor,
      appBar: AppBar(
        title: Text(
          'Detail Pengambilan',
          style: blackTextStyle.copyWith(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: semiBold,
          ),
        ),
        backgroundColor: whiteColor,
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
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getStatusColor(scheduleData!['status']).withOpacity(0.15),
                  _getStatusColor(scheduleData!['status']).withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getStatusColor(
                  scheduleData!['status'],
                ).withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getStatusColor(
                    scheduleData!['status'],
                  ).withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(
                      scheduleData!['status'],
                    ).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getStatusIcon(scheduleData!['status']),
                    color: _getStatusColor(scheduleData!['status']),
                    size: 18,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Status: ${_getStatusText(scheduleData!['status'])}',
                  style: TextStyle(
                    color: _getStatusColor(scheduleData!['status']),
                    fontWeight: bold,
                    fontSize: isSmallScreen ? 14 : 15,
                  ),
                ),
              ],
            ),
          ),

          // Customer info card
          Card(
            elevation: 2,
            shadowColor: blueColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: blueColor.withOpacity(0.1)),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [whiteColor, blueColor.withOpacity(0.03)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: blueColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.person_outline,
                          size: isSmallScreen ? 18 : 20,
                          color: blueColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Informasi Pelanggan',
                        style: blackTextStyle.copyWith(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: bold,
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
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Pickup details card
          Card(
            elevation: 2,
            shadowColor: greenColor.withOpacity(0.1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: greenColor.withOpacity(0.1)),
            ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [whiteColor, greenui],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: greenColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          size: isSmallScreen ? 18 : 20,
                          color: greenColor,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Detail Pengambilan',
                        style: blackTextStyle.copyWith(
                          fontSize: isSmallScreen ? 15 : 17,
                          fontWeight: bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  _buildInfoRow(
                    'ID Jadwal',
                    scheduleData!['id'],
                    isSmallScreen,
                  ),
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
          ),

          SizedBox(height: isSmallScreen ? 20 : 24),

          // Action button
          Builder(
            builder: (context) {
              final status = _normalizeStatus(scheduleData?['status']);
              final isCompleted = status == 'completed';
              final buttonLabel = isCompleted
                  ? 'Pengambilan Selesai'
                  : status == 'in_progress'
                  ? 'Selesaikan Pengambilan'
                  : 'Mulai Pengambilan';
              final buttonIcon = status == 'in_progress' || isCompleted
                  ? Icons.check_circle
                  : Icons.navigation;

              return SizedBox(
                width: double.infinity,
                height: isSmallScreen ? 52 : 56,
                child: ElevatedButton(
                  onPressed: (_isUpdatingStatus || isCompleted)
                      ? null
                      : () => _handlePrimaryAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCompleted
                        ? greyColor.withOpacity(0.5)
                        : greenColor,
                    foregroundColor: whiteColor,
                    disabledBackgroundColor: greyColor.withOpacity(0.5),
                    elevation: isCompleted ? 0 : 3,
                    shadowColor: greenColor.withOpacity(0.3),
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isUpdatingStatus
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              whiteColor,
                            ),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              buttonIcon,
                              size: isSmallScreen ? 20 : 22,
                              color: whiteColor,
                            ),
                            SizedBox(width: 10),
                            Text(
                              buttonLabel,
                              style: whiteTextStyle.copyWith(
                                fontSize: isSmallScreen ? 15 : 16,
                                fontWeight: bold,
                              ),
                            ),
                          ],
                        ),
                ),
              );
            },
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
              style: greyTextStyle.copyWith(fontSize: isSmallScreen ? 12 : 14),
            ),
          ),
          Text(
            ': ',
            style: greyTextStyle.copyWith(fontSize: isSmallScreen ? 12 : 14),
          ),
          Expanded(
            child: Text(
              value,
              style: blackTextStyle.copyWith(
                fontSize: isSmallScreen ? 12 : 14,
                fontWeight: semiBold,
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
        return orangeColor;
      case 'in_progress':
        return blueColor;
      case 'completed':
        return greenColor;
      default:
        return greyColor;
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

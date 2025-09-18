import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/pages/mitra/jadwal/jadwal_mitra_page_map_view.dart';

class DetailPickupPage extends StatefulWidget {
  final String scheduleId;

  const DetailPickupPage({Key? key, required this.scheduleId}) : super(key: key);

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
        iconTheme: IconThemeData(
          color: blackColor,
        ),
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
          style: blackTextStyle.copyWith(
            fontSize: 16,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 14 : 16, vertical: 12),
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
                color: _getStatusColor(scheduleData!['status']).withOpacity(0.3),
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
                _buildInfoRow('Nama', scheduleData!['customer_name'], isSmallScreen),
                _buildInfoRow('No. Telepon', scheduleData!['phone'], isSmallScreen),
                _buildInfoRow('Alamat', scheduleData!['address'], isSmallScreen),
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
                _buildInfoRow('Jenis Sampah', scheduleData!['waste_type'], isSmallScreen),
                _buildInfoRow('Berat Sampah', scheduleData!['waste_weight'], isSmallScreen),
                _buildInfoRow('Status', _getStatusText(scheduleData!['status']), isSmallScreen),
                if (scheduleData!['notes'] != null && scheduleData!['notes'].isNotEmpty)
                  _buildInfoRow('Catatan', scheduleData!['notes'], isSmallScreen),
              ],
            ),
          ),
          
          SizedBox(height: isSmallScreen ? 20 : 24),
          
          // Action button
          Container(
            width: double.infinity,
            height: isSmallScreen ? 50 : 56,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to JadwalMitraMapView
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => JadwalMitraMapView(),
                  ),
                );
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
                    Icons.play_circle_outline, 
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
              style: blackTextStyle.copyWith(
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          Text(
            ': ',
            style: blackTextStyle.copyWith(
              fontSize: isSmallScreen ? 12 : 14,
            ),
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
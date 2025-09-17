import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';

class DetailPickupPage extends StatefulWidget {
  final String scheduleId;

  const DetailPickupPage({Key? key, required this.scheduleId}) : super(key: key);

  @override
  State<DetailPickupPage> createState() => _DetailPickupPageState();
}

class _DetailPickupPageState extends State<DetailPickupPage> {
  bool isLoading = true;
  Map<String, dynamic>? scheduleData;

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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Detail Pengambilan',
          style: blackTextStyle.copyWith(
            fontSize: 18,
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
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi Pelanggan',
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
                SizedBox(height: 16),
                _buildInfoRow('Nama', scheduleData!['customer_name']),
                _buildInfoRow('No. Telepon', scheduleData!['phone']),
                _buildInfoRow('Alamat', scheduleData!['address']),
              ],
            ),
          ),
          
          SizedBox(height: 16),
          
          // Pickup details card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Detail Pengambilan',
                  style: blackTextStyle.copyWith(
                    fontSize: 16,
                    fontWeight: semiBold,
                  ),
                ),
                SizedBox(height: 16),
                _buildInfoRow('ID Jadwal', scheduleData!['id']),
                _buildInfoRow('Waktu', scheduleData!['time']),
                _buildInfoRow('Jenis Sampah', scheduleData!['waste_type']),
                _buildInfoRow('Berat Sampah', scheduleData!['waste_weight']),
                _buildInfoRow('Status', _getStatusText(scheduleData!['status'])),
                if (scheduleData!['notes'] != null && scheduleData!['notes'].isNotEmpty)
                  _buildInfoRow('Catatan', scheduleData!['notes']),
              ],
            ),
          ),
          
          SizedBox(height: 24),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle navigation to location
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Menuju Lokasi',
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // Handle start pickup
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: greenColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Mulai Pengambilan',
                    style: whiteTextStyle.copyWith(
                      fontSize: 16,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: blackTextStyle.copyWith(
                fontSize: 14,
              ),
            ),
          ),
          Text(
            ': ',
            style: blackTextStyle.copyWith(
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: blackTextStyle.copyWith(
                fontSize: 14,
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
}
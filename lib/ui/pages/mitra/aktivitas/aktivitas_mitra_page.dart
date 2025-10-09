import 'package:bank_sha/models/activity_model_improved.dart';
import 'package:bank_sha/services/mitra_service.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AktivitasMitraPage extends StatefulWidget {
  const AktivitasMitraPage({super.key});

  @override
  State<AktivitasMitraPage> createState() => _AktivitasMitraPageState();
}

class _AktivitasMitraPageState extends State<AktivitasMitraPage> {
  final MitraService _mitraService = MitraService();
  
  bool _isLoading = true;
  String? _errorMessage;
  List<ActivityModel> _activities = [];
  
  @override
  void initState() {
    super.initState();
    _loadActivities();
  }
  
  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final activities = await _mitraService.getActivities();
      
      if (mounted) {
        setState(() {
          _activities = activities;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: const Text('Aktivitas'),
        backgroundColor: greenColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _loadActivities,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 50,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadActivities,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : _activities.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.history,
                            size: 80,
                            color: greyColor,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Belum ada aktivitas',
                            style: greyTextStyle.copyWith(
                              fontSize: 16,
                              fontWeight: medium,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Group activities by date
                        ..._groupActivitiesByDate().entries.map((entry) => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    entry.key,
                                    style: blackTextStyle.copyWith(
                                      fontSize: 18,
                                      fontWeight: semiBold,
                                    ),
                                  ),
                                ),
                                ...entry.value.map((activity) => _buildActivityCard(activity)),
                              ],
                            )),
                      ],
                    ),
    );
  }
  
  Widget _buildActivityCard(ActivityModel activity) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      _getActivityIcon(activity.type),
                      color: whiteColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getActivityTypeText(activity.type),
                      style: whiteTextStyle.copyWith(
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
                Text(
                  DateFormat('HH:mm').format(activity.createdAt),
                  style: whiteTextStyle.copyWith(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // Content section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: blackTextStyle.copyWith(
                    fontWeight: medium,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.description ?? 'Tidak ada deskripsi',
                  style: greyTextStyle,
                ),
                if (activity.metadata != null && activity.metadata!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  ...activity.metadata!.entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              '${entry.key}:',
                              style: blackTextStyle.copyWith(
                                fontWeight: medium,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              '${entry.value}',
                              style: blackTextStyle,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, List<ActivityModel>> _groupActivitiesByDate() {
    final Map<String, List<ActivityModel>> grouped = {};
    
    for (var activity in _activities) {
      final dateStr = DateFormat('dd MMMM yyyy').format(activity.createdAt);
      
      if (!grouped.containsKey(dateStr)) {
        grouped[dateStr] = [];
      }
      
      grouped[dateStr]!.add(activity);
    }
    
    return grouped;
  }
  
  Color _getActivityColor(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return blueColor;
      case 'delivery':
        return greenColor;
      case 'status_update':
        return purpleColor;
      case 'payment':
        return orangeColor;
      case 'system':
        return greyColor;
      default:
        return greyColor;
    }
  }
  
  IconData _getActivityIcon(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return Icons.delete_outline;
      case 'delivery':
        return Icons.delivery_dining;
      case 'status_update':
        return Icons.update;
      case 'payment':
        return Icons.payment;
      case 'system':
        return Icons.system_update_alt;
      default:
        return Icons.history;
    }
  }
  
  String _getActivityTypeText(String type) {
    switch (type.toLowerCase()) {
      case 'pickup':
        return 'Pengambilan';
      case 'delivery':
        return 'Pengiriman';
      case 'status_update':
        return 'Perbarui Status';
      case 'payment':
        return 'Pembayaran';
      case 'system':
        return 'Sistem';
      default:
        return 'Aktivitas';
    }
  }
}
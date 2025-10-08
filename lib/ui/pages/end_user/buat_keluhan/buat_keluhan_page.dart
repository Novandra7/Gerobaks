import 'package:bank_sha/ui/pages/end_user/buat_keluhan/buat_keluhan_form.dart';
import 'package:bank_sha/ui/pages/end_user/buat_keluhan/tanggapan_keluhan_page.dart';
import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';
import 'package:bank_sha/services/end_user_api_service.dart';
import 'package:bank_sha/ui/widgets/skeleton/skeleton_items.dart';

class BuatKeluhanPage extends StatefulWidget {
  const BuatKeluhanPage({super.key});

  @override
  State<BuatKeluhanPage> createState() => _BuatKeluhanPageState();
}

class _BuatKeluhanPageState extends State<BuatKeluhanPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _daftarKeluhan = [];
  List<Map<String, dynamic>> _filteredKeluhan = [];
  late EndUserApiService _apiService;
  
  String selectedStatus = 'Semua';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    _apiService = EndUserApiService();
    await _apiService.initialize();
    await _loadFeedback();
  }

  Future<void> _loadFeedback() async {
    try {
      final feedback = await _apiService.getUserFeedback();
      
      if (mounted) {
        setState(() {
          _daftarKeluhan = feedback;
          _filteredKeluhan = List.from(_daftarKeluhan);
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading feedback: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterKeluhan() {
    setState(() {
      _filteredKeluhan = _daftarKeluhan.where((keluhan) {
        bool statusMatch = selectedStatus == 'Semua' || keluhan['status'] == selectedStatus;
        bool searchMatch = searchQuery.isEmpty ||
            keluhan['title']?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
            keluhan['category']?.toLowerCase().contains(searchQuery.toLowerCase()) == true ||
            keluhan['description']?.toLowerCase().contains(searchQuery.toLowerCase()) == true;
        
        return statusMatch && searchMatch;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(title: 'Keluhan'),
      body: _isLoading 
          ? _buildSkeletonLoading()
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BuatKeluhanForm()),
          );
          if (result == true) {
            await _loadFeedback(); // Refresh feedback list
          }
        },
        backgroundColor: greenColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSkeletonLoading() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search bar skeleton
          SkeletonItems.card(height: 48),
          const SizedBox(height: 16),
          
          // Status filter skeleton
          SkeletonItems.card(height: 40),
          const SizedBox(height: 16),
          
          // Feedback list skeleton
          ...List.generate(5, (index) => 
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SkeletonItems.card(height: 120),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Search and Filter Section
        Container(
          padding: const EdgeInsets.all(16),
          color: whiteColor,
          child: Column(
            children: [
              // Search Bar
              TextField(
                onChanged: (value) {
                  searchQuery = value;
                  _filterKeluhan();
                },
                decoration: InputDecoration(
                  hintText: 'Cari keluhan...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: greenColor),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Status Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildStatusChip('Semua'),
                    _buildStatusChip('Menunggu'),
                    _buildStatusChip('Sedang Diproses'),
                    _buildStatusChip('Selesai'),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // Content Area
        Expanded(
          child: _filteredKeluhan.isEmpty
              ? _buildEmptyState()
              : _buildKeluhanList(),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    bool isSelected = selectedStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(status),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedStatus = status;
            _filterKeluhan();
          });
        },
        backgroundColor: Colors.grey.shade100,
        selectedColor: greenColor.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? greenColor : Colors.grey.shade600,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? greenColor : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.feedback_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            searchQuery.isNotEmpty || selectedStatus != 'Semua'
                ? 'Tidak ada keluhan yang sesuai'
                : 'Belum ada keluhan',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty || selectedStatus != 'Semua'
                ? 'Coba ubah filter pencarian'
                : 'Buat keluhan pertama Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildKeluhanList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredKeluhan.length,
      itemBuilder: (context, index) {
        final keluhan = _filteredKeluhan[index];
        return _buildKeluhanCard(keluhan);
      },
    );
  }

  Widget _buildKeluhanCard(Map<String, dynamic> keluhan) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TanggapanKeluhanPage(keluhanData: keluhan),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      keluhan['title'] ?? 'Keluhan',
                      style: blackTextStyle.copyWith(
                        fontWeight: semiBold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  _buildStatusBadge(keluhan['status']),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Category and Priority
              Row(
                children: [
                  Icon(Icons.category, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    keluhan['category'] ?? '',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.priority_high, size: 16, color: _getPriorityColor(keluhan['priority'])),
                  const SizedBox(width: 4),
                  Text(
                    keluhan['priority'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getPriorityColor(keluhan['priority']),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Description
              Text(
                keluhan['description'] ?? '',
                style: blackTextStyle.copyWith(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Date and ID
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(keluhan['created_at']),
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                  const Spacer(),
                  Text(
                    'ID: ${keluhan['id'] ?? ''}',
                    style: greyTextStyle.copyWith(fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color color;
    switch (status) {
      case 'Selesai':
        color = Colors.green;
        break;
      case 'Sedang Diproses':
        color = Colors.orange;
        break;
      case 'Menunggu':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status ?? '',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'Urgent':
        return Colors.red;
      case 'Tinggi':
        return Colors.orange;
      case 'Normal':
        return Colors.blue;
      case 'Rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}
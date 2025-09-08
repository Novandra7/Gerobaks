import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/ui/widgets/shared/appbar.dart';

class TanggapanKeluhanPage extends StatefulWidget {
  final Map<String, dynamic> keluhanData;

  const TanggapanKeluhanPage({
    super.key,
    required this.keluhanData,
  });

  @override
  State<TanggapanKeluhanPage> createState() => _TanggapanKeluhanPageState();
}

class _TanggapanKeluhanPageState extends State<TanggapanKeluhanPage> {
  final TextEditingController _tanggapanController = TextEditingController();
  bool _isSubmitting = false;
  
  // Status options
  final List<String> _statusOptions = [
    'Menunggu',
    'Sedang Diproses',
    'Selesai',
  ];
  late String _selectedStatus;
  
  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.keluhanData['status'];
    
    // If there's an existing response, populate the field
    if (widget.keluhanData.containsKey('balasan') && 
        widget.keluhanData['balasan'] != null) {
      _tanggapanController.text = widget.keluhanData['balasan'];
    }
  }

  @override
  void dispose() {
    _tanggapanController.dispose();
    super.dispose();
  }

  void _submitTanggapan() {
    if (_tanggapanController.text.isEmpty && _selectedStatus == 'Selesai') {
      // Show alert that response is required when marking as completed
      _showEmptyResponseAlert();
      return;
    }
    
    setState(() {
      _isSubmitting = true;
    });
    
    // Simulate API request
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      // Update the keluhan data
      final updatedKeluhan = Map<String, dynamic>.from(widget.keluhanData);
      updatedKeluhan['status'] = _selectedStatus;
      updatedKeluhan['tanggalBalasan'] = DateTime.now().toString().substring(0, 10);
      
      // Only add a response if one was provided
      if (_tanggapanController.text.isNotEmpty) {
        updatedKeluhan['balasan'] = _tanggapanController.text;
      }
      
      // Return to previous screen with the updated keluhan data
      Navigator.pop(context, updatedKeluhan);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: greenColor,
          content: const Text('Tanggapan berhasil dikirim!'),
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }

  void _showEmptyResponseAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Tanggapan Diperlukan',
          style: blackTextStyle.copyWith(
            fontWeight: semiBold,
          ),
        ),
        content: Text(
          'Anda harus memberikan tanggapan sebelum mengubah status menjadi Selesai.',
          style: greyTextStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Mengerti',
              style: TextStyle(color: greenColor),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Using golden ratio for better visual proportions (1:1.618)
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = 24.0;
    final contentWidth = screenWidth - (horizontalPadding * 2);
    
    // Golden ratio for vertical spacing
    final phi = 1.618;
    final baseSpacing = 16.0;
    final smallSpacing = baseSpacing / phi; // ~9.9
    final mediumSpacing = baseSpacing; // 16
    final largeSpacing = baseSpacing * phi; // ~25.9
    
    return Scaffold(
      backgroundColor: uicolor,
      appBar: const CustomAppBar(
        title: 'Tanggapan Keluhan',
        showBackButton: true,
      ),
      body: Stack(
        children: [
          // Main content
          ListView(
            padding: EdgeInsets.all(horizontalPadding),
            children: [
              // Keluhan info card
              Container(
                padding: EdgeInsets.all(mediumSpacing),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ID and status row (golden ratio division)
                    Row(
                      children: [
                        // ID (smaller part ~38.2%)
                        Expanded(
                          flex: 10,
                          child: Text(
                            'ID: ${widget.keluhanData['id']}',
                            style: greyTextStyle.copyWith(fontSize: 12),
                          ),
                        ),
                        // Status pill (larger part ~61.8%)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(widget.keluhanData['status']).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(widget.keluhanData['status']).withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.keluhanData['status'],
                            style: TextStyle(
                              color: _getStatusColor(widget.keluhanData['status']),
                              fontSize: 12,
                              fontWeight: semiBold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: smallSpacing),
                    
                    // Judul (title)
                    Text(
                      widget.keluhanData['judul'],
                      style: blackTextStyle.copyWith(
                        fontSize: 18,
                        fontWeight: semiBold,
                      ),
                    ),
                    
                    SizedBox(height: smallSpacing),
                    
                    // Kategori and prioritas chips in a golden ratio row
                    Row(
                      children: [
                        // Category (larger part ~61.8%)
                        Expanded(
                          flex: 16,
                          child: _buildInfoChip(
                            widget.keluhanData['kategori'],
                            Icons.category_rounded,
                            Colors.blue,
                          ),
                        ),
                        SizedBox(width: smallSpacing),
                        // Priority (smaller part ~38.2%)
                        Expanded(
                          flex: 10,
                          child: _buildInfoChip(
                            widget.keluhanData['prioritas'],
                            Icons.priority_high_rounded,
                            _getPrioritasColor(widget.keluhanData['prioritas']),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: mediumSpacing),
                    
                    // Deskripsi (description)
                    Text(
                      'Deskripsi:',
                      style: blackTextStyle.copyWith(
                        fontWeight: semiBold,
                      ),
                    ),
                    SizedBox(height: smallSpacing / 2),
                    Text(
                      widget.keluhanData['deskripsi'],
                      style: blackTextStyle.copyWith(
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: largeSpacing),
              
              // Update status section
              Text(
                'Perbarui Status',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              SizedBox(height: smallSpacing),
              _buildStatusSelector(),
              
              SizedBox(height: largeSpacing),
              
              // Tanggapan field
              Text(
                'Tanggapan Admin',
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              SizedBox(height: smallSpacing),
              _buildResponseField(),
              
              // Add extra space at bottom for the fixed button
              SizedBox(height: largeSpacing * 3),
            ],
          ),
          
          // Fixed submit button at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.all(horizontalPadding),
              decoration: BoxDecoration(
                color: whiteColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: SafeArea(
                child: _isSubmitting
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(
                            color: greenColor,
                            strokeWidth: 3,
                          ),
                        ),
                      )
                    : SizedBox(
                        width: contentWidth,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _submitTanggapan,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: greenColor,
                            foregroundColor: whiteColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Text(
                            'Kirim Tanggapan',
                            style: whiteTextStyle.copyWith(
                              fontWeight: semiBold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: semiBold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusSelector() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Status Saat Ini: ${widget.keluhanData['status']}',
              style: greyTextStyle.copyWith(fontSize: 13),
            ),
          ),
          const Divider(height: 1),
          
          // Status options using golden ratio segmentation
          Row(
            children: _statusOptions.map((status) {
              final isSelected = _selectedStatus == status;
              final color = _getStatusColor(status);
              
              // Golden ratio for equal division
              final width = MediaQuery.of(context).size.width;
              final buttonWidth = (width - 48) / 3; // Equal division
              
              return SizedBox(
                width: buttonWidth,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedStatus = status;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
                      border: Border(
                        top: BorderSide(
                          color: isSelected ? color : Colors.transparent,
                          width: 2,
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _getStatusIcon(status),
                          color: isSelected ? color : greyColor,
                          size: 18,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          status,
                          style: TextStyle(
                            color: isSelected ? color : greyColor,
                            fontWeight: isSelected ? semiBold : regular,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildResponseField() {
    return Container(
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        controller: _tanggapanController,
        maxLines: 6,
        style: blackTextStyle,
        decoration: InputDecoration(
          hintText: 'Tulis tanggapan untuk keluhan ini...',
          hintStyle: greyTextStyle,
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Colors.green.shade600;
      case 'sedang diproses':
        return Colors.orange.shade600;
      case 'menunggu':
        return Colors.blue.shade600;
      default:
        return greyColor;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'selesai':
        return Icons.check_circle_rounded;
      case 'sedang diproses':
        return Icons.pending_rounded;
      case 'menunggu':
        return Icons.access_time_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }

  Color _getPrioritasColor(String prioritas) {
    switch (prioritas.toLowerCase()) {
      case 'rendah':
        return Colors.green.shade600;
      case 'normal':
        return Colors.blue.shade600;
      case 'tinggi':
        return Colors.orange.shade600;
      case 'urgent':
        return Colors.red.shade600;
      default:
        return greyColor;
    }
  }
  
  Widget _buildInfoItem(String label, String value) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: greyTextStyle.copyWith(
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: blackTextStyle.copyWith(
              fontWeight: medium,
            ),
          ),
        ],
      ),
    );
  }
}

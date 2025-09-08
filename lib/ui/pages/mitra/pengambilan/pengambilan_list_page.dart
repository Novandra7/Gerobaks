import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

class PengambilanListPage extends StatefulWidget {
  const PengambilanListPage({super.key});

  @override
  State<PengambilanListPage> createState() => _PengambilanListPageState();
}

class _PengambilanListPageState extends State<PengambilanListPage> {
  String selectedFilter = 'all';
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  
  void _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(primary: greenColor),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _refreshPickups();
      });
    }
  }
  
  void _refreshPickups() {
    setState(() {
      isLoading = true;
    });
    
    // Simulate network request
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Daftar Pengambilan',
          style: blackTextStyle.copyWith(
            fontSize: 20,
            fontWeight: semiBold,
          ),
        ),
        centerTitle: true,
        backgroundColor: whiteColor,
        elevation: 0,
        iconTheme: IconThemeData(color: blackColor),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) => _buildFilterBottomSheet(context),
              );
            },
            icon: const Icon(Icons.filter_list_rounded),
          ),
          IconButton(
            onPressed: () => _selectDate(context),
            icon: const Icon(Icons.calendar_today_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: whiteColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  _buildFilterTab('Semua', 'all'),
                  _buildFilterTab('Menunggu', 'pending'),
                  _buildFilterTab('Proses', 'in_progress'),
                  _buildFilterTab('Selesai', 'completed'),
                ],
              ),
            ),
          ),
          
          // Date selection indicator
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tanggal: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: medium,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedDate = DateTime.now();
                      _refreshPickups();
                    });
                  },
                  child: Text(
                    'Reset',
                    style: greentextstyle2.copyWith(
                      fontSize: 14,
                      fontWeight: semiBold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pickup List with loading state
          Expanded(
            child: isLoading 
            ? Center(
                child: CircularProgressIndicator(
                  color: greenColor,
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: 8,
                itemBuilder: (context, index) {
                  return _buildPickupItem(index);
                },
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: greenColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? semiBold : medium,
            color: isSelected ? whiteColor : greyColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildPickupItem(int index) {
    final pickups = [
      {
        'id': 'PU-001',
        'customer': 'Ahmad Sulaiman',
        'address': 'Jl. Merdeka No. 1, Jakarta',
        'time': '08:30',
        'type': 'Reguler',
        'status': 'pending',
      },
      {
        'id': 'PU-002',
        'customer': 'Siti Rahma',
        'address': 'Perumahan Indah Blok C2/15',
        'time': '09:15',
        'type': 'Organik',
        'status': 'completed',
      },
      {
        'id': 'PU-003',
        'customer': 'Budi Santoso',
        'address': 'Komplek Bumi Indah A5/7',
        'time': '10:00',
        'type': 'Reguler',
        'status': 'in_progress',
      },
      {
        'id': 'PU-004',
        'customer': 'Dewi Lestari',
        'address': 'Jl. Kenanga No. 45',
        'time': '10:45',
        'type': 'B3',
        'status': 'pending',
      },
      {
        'id': 'PU-005',
        'customer': 'Rudi Hermawan',
        'address': 'Griya Indah Blok D10/3',
        'time': '11:30',
        'type': 'Reguler',
        'status': 'pending',
      },
      {
        'id': 'PU-006',
        'customer': 'Maya Sari',
        'address': 'Villa Mutiara Blok E8',
        'time': '13:00',
        'type': 'Organik',
        'status': 'completed',
      },
      {
        'id': 'PU-007',
        'customer': 'Andi Wijaya',
        'address': 'Perumahan Asri Blok F12',
        'time': '14:15',
        'type': 'Reguler',
        'status': 'pending',
      },
      {
        'id': 'PU-008',
        'customer': 'Linda Sari',
        'address': 'Komplek Indah Blok G5',
        'time': '15:00',
        'type': 'B3',
        'status': 'pending',
      },
    ];

    final pickup = pickups[index];
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (pickup['status']) {
      case 'completed':
        statusColor = greenColor;
        statusIcon = Icons.check_circle_rounded;
        statusText = 'Selesai';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusIcon = Icons.access_time_rounded;
        statusText = 'Sedang Proses';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_rounded;
        statusText = 'Menunggu';
    }

    Color typeColor;
    switch (pickup['type']) {
      case 'Organik':
        typeColor = greenColor;
        break;
      case 'B3':
        typeColor = Colors.red;
        break;
      default:
        typeColor = Colors.blue;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        // TODO: Navigate to detail page
      },
      child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ID with improved styling
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      pickup['id'] as String,
                      style: blackTextStyle.copyWith(
                        fontSize: 14,
                        fontWeight: semiBold,
                        color: greenColor,
                      ),
                    ),
                  ),
                  // Status tags row
                  Row(
                    children: [
                      // Type tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          pickup['type'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: typeColor,
                            fontWeight: medium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Status tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 12,
                              color: statusColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: medium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Customer name
              Text(
                pickup['customer'] as String,
                style: blackTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
              const SizedBox(height: 8),
              // Address with icon
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: greenColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pickup['address'] as String,
                      style: greyTextStyle.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Time with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: greenColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: greenColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Estimasi: ${pickup['time']}',
                    style: greyTextStyle.copyWith(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Action buttons with improved styling
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // TODO: View details
                      },
                      style: TextButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: greenColor),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      child: Text(
                        'Detail',
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: pickup['status'] == 'pending'
                          ? () {
                              // TODO: Start pickup
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: greenColor,
                        foregroundColor: whiteColor,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 1,
                      ),
                      child: Text(
                        pickup['status'] == 'pending' ? 'Mulai' : 'Selesai',
                        style: whiteTextStyle.copyWith(
                          fontSize: 14,
                          fontWeight: medium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
        ],
      ),
    ),
    ),
    );
  }
  
  Widget _buildFilterBottomSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Pengambilan',
                style: blackTextStyle.copyWith(
                  fontSize: 18,
                  fontWeight: semiBold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(
                  Icons.close,
                  color: blackColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Filter Options
          Text(
            'Status',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Semua', 'all'),
              _buildFilterChip('Menunggu', 'pending'),
              _buildFilterChip('Proses', 'in_progress'),
              _buildFilterChip('Selesai', 'completed'),
            ],
          ),
          const SizedBox(height: 24),
          
          // Date Range
          Text(
            'Rentang Tanggal',
            style: blackTextStyle.copyWith(
              fontSize: 16,
              fontWeight: semiBold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Date Selector
          InkWell(
            onTap: () => _selectDate(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: greenColor,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    style: blackTextStyle.copyWith(
                      fontSize: 14,
                      fontWeight: medium,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: greyColor,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _refreshPickups();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: greenColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Terapkan Filter',
                style: whiteTextStyle.copyWith(
                  fontSize: 16,
                  fontWeight: semiBold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? greenColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? whiteColor : blackColor,
            fontSize: 14,
            fontWeight: isSelected ? semiBold : regular,
          ),
        ),
      ),
    );
  }
}

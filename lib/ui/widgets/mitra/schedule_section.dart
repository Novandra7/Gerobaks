import 'package:flutter/material.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:bank_sha/utils/responsive_helper.dart';

class ScheduleCard extends StatelessWidget {
  final String time;
  final String status;
  final String name;
  final String address;
  final List<ScheduleTag> tags;
  final Color statusColor;
  final Color statusBackgroundColor;
  final VoidCallback? onTap;

  const ScheduleCard({
    Key? key,
    required this.time,
    required this.status,
    required this.name,
    required this.address,
    required this.tags,
    this.statusColor = const Color(0xFFB58D00), // Default to amber color for waiting
    this.statusBackgroundColor = const Color(0xFFFFF8E0), // Light amber background
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Time and status row
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveHelper.getResponsiveSpacing(context, 16),
                vertical: ResponsiveHelper.getResponsiveSpacing(context, isSmallScreen ? 10 : 12),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF5F5F5), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Yellow circle for waiting status
                      Container(
                        width: ResponsiveHelper.getResponsiveWidth(context, 20),
                        height: ResponsiveHelper.getResponsiveHeight(context, 20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700), // Gold color for waiting
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.access_time_filled_rounded,
                            color: Colors.white,
                            size: ResponsiveHelper.getResponsiveIconSize(context, 12),
                          ),
                        ),
                      ),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                      Text(
                        time,
                        style: blackTextStyle.copyWith(
                          fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 14 : 16),
                          fontWeight: medium,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12), 
                      vertical: ResponsiveHelper.getResponsiveSpacing(context, 6)
                    ),
                    decoration: BoxDecoration(
                      color: statusBackgroundColor,
                      borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 20)),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                        fontWeight: medium,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(color: Colors.grey.shade200, height: 1),
            
            // Customer info
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(ResponsiveHelper.getResponsiveSpacing(context, 16)),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE4F9E8), Color(0xFFE8F5E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(ResponsiveHelper.getResponsiveRadius(context, 16)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  Text(
                    name,
                    style: blackTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 16 : 18),
                      fontWeight: semiBold,
                    ),
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                  
                  // Address
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: ResponsiveHelper.getResponsiveIconSize(context, 16),
                        color: Colors.grey,
                      ),
                      SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 6)),
                      Expanded(
                        child: Text(
                          address,
                          style: greyTextStyle.copyWith(
                            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 12)),
                  
                  // Tags
                  Row(
                    children: tags.map((tag) {
                      return Padding(
                        padding: EdgeInsets.only(right: ResponsiveHelper.getResponsiveSpacing(context, 8)),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveHelper.getResponsiveSpacing(context, 12),
                            vertical: ResponsiveHelper.getResponsiveSpacing(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: tag.backgroundColor,
                            borderRadius: BorderRadius.circular(ResponsiveHelper.getResponsiveRadius(context, 12)),
                          ),
                          child: Text(
                            tag.label,
                            style: TextStyle(
                              fontSize: ResponsiveHelper.getResponsiveFontSize(context, 12),
                              fontWeight: medium,
                              color: tag.textColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScheduleTag {
  final String label;
  final Color backgroundColor;
  final Color textColor;

  ScheduleTag({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });
}

class ScheduleSection extends StatelessWidget {
  final List<ScheduleCard> scheduleCards;

  const ScheduleSection({
    Key? key,
    required this.scheduleCards,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = ResponsiveHelper.isSmallScreen(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: ResponsiveHelper.getResponsiveHeight(context, 24),
                    width: ResponsiveHelper.getResponsiveWidth(context, 3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF01A643),
                      borderRadius: BorderRadius.all(Radius.circular(2)),
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 10)),
                  Text(
                    'Jadwal Pengambilan',
                    style: blackTextStyle.copyWith(
                      fontSize: ResponsiveHelper.getResponsiveFontSize(context, isSmallScreen ? 16 : 18),
                      fontWeight: semiBold,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: ResponsiveHelper.getResponsiveWidth(context, 8),
                    height: ResponsiveHelper.getResponsiveHeight(context, 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFF01A643),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: ResponsiveHelper.getResponsiveSpacing(context, 5)),
                  Container(
                    width: ResponsiveHelper.getResponsiveWidth(context, 8),
                    height: ResponsiveHelper.getResponsiveHeight(context, 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 16)),
        
        if (scheduleCards.isNotEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20)),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: scheduleCards.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: ResponsiveHelper.getResponsiveSpacing(context, 16)),
                  child: scheduleCards[index],
                );
              },
            ),
          )
        else
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveHelper.getResponsiveSpacing(context, 20),
              vertical: ResponsiveHelper.getResponsiveSpacing(context, 20),
            ),
            child: Center(
              child: Text(
                'Tidak ada jadwal pengambilan saat ini',
                style: greyTextStyle,
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:bank_sha/models/waste_item.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

/// Waste Items Summary - Compact horizontal display
/// Shows: emoji + type + weight for each item, then total
/// Example: 🟢 Organik: 5kg | 🔵 Plastik: 2kg | Total: 7kg
class WasteItemsSummary extends StatelessWidget {
  final List<WasteItem> wasteItems;
  final bool showTotal;
  final TextStyle? textStyle;
  final double spacing;

  const WasteItemsSummary({
    super.key,
    required this.wasteItems,
    this.showTotal = true,
    this.textStyle,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    if (wasteItems.isEmpty) {
      return Text(
        'Tidak ada sampah',
        style: textStyle ?? greyTextStyle.copyWith(fontSize: 12),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: 4,
      children: [
        // Individual waste items
        ...wasteItems.map((item) => _buildWasteItemChip(item)),

        // Total weight (if enabled)
        if (showTotal) _buildTotalChip(),
      ],
    );
  }

  Widget _buildWasteItemChip(WasteItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getWasteTypeColor(item.wasteType).withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: _getWasteTypeColor(item.wasteType).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(WasteType.getEmoji(item.wasteType), style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            '${WasteType.getDisplayName(item.wasteType)}: ${_formatWeight(item)}',
            style:
                textStyle ??
                blackTextStyle.copyWith(fontSize: 11, fontWeight: medium),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalChip() {
    final totalKg = _calculateTotalWeight();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: purpleColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: purpleColor.withOpacity(0.4), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.scale, size: 12, color: purpleColor),
          const SizedBox(width: 4),
          Text(
            'Total: ${totalKg.toStringAsFixed(1)} kg',
            style:
                textStyle?.copyWith(fontWeight: bold, color: purpleColor) ??
                blackTextStyle.copyWith(
                  fontSize: 11,
                  fontWeight: bold,
                  color: purpleColor,
                ),
          ),
        ],
      ),
    );
  }

  // Helper: Format weight with unit
  String _formatWeight(WasteItem item) {
    final weight = item.estimatedWeight;
    final unit = item.unit.toLowerCase();

    // If gram, convert to kg for consistency
    if (unit == 'gram' || unit == 'g') {
      final kg = weight / 1000;
      if (kg >= 1) {
        return '${kg.toStringAsFixed(1)} kg';
      }
      return '${weight.toStringAsFixed(0)} g';
    }

    // Already in kg
    return '${weight.toStringAsFixed(1)} kg';
  }

  // Helper: Calculate total weight in kg
  double _calculateTotalWeight() {
    return wasteItems.fold(0.0, (sum, item) {
      final unit = item.unit.toLowerCase();

      // Convert to kg if unit is gram
      if (unit == 'gram' || unit == 'g') {
        return sum + (item.estimatedWeight / 1000);
      }
      return sum + item.estimatedWeight;
    });
  }

  // Helper: Get color for waste type
  Color _getWasteTypeColor(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'organik':
        return Colors.green;
      case 'plastik':
        return Colors.blue;
      case 'kertas':
        return Colors.orange;
      case 'kaca':
        return Colors.cyan;
      case 'logam':
        return Colors.grey;
      case 'elektronik':
        return Colors.purple;
      case 'kain':
        return Colors.pink;
      case 'berbahaya':
        return Colors.red;
      default:
        return greyColor;
    }
  }
}

/// Alternative: Vertical list view for detail pages
class WasteItemsListView extends StatelessWidget {
  final List<WasteItem> wasteItems;
  final bool showTotal;

  const WasteItemsListView({
    super.key,
    required this.wasteItems,
    this.showTotal = true,
  });

  @override
  Widget build(BuildContext context) {
    if (wasteItems.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: lightBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: greyColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(Icons.delete_outline, size: 18, color: greyColor),
            const SizedBox(width: 8),
            Text(
              'Tidak ada sampah',
              style: greyTextStyle.copyWith(fontSize: 13),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // List of items
        ...wasteItems.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == wasteItems.length - 1;

          return Column(
            children: [
              _buildListItem(item),
              if (!isLast && !showTotal) const Divider(height: 1),
            ],
          );
        }),

        // Total section
        if (showTotal) ...[
          const Divider(height: 1, thickness: 1.5),
          _buildTotalSection(),
        ],
      ],
    );
  }

  Widget _buildListItem(WasteItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _getWasteTypeColor(item.wasteType).withOpacity(0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                WasteType.getEmoji(item.wasteType),
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WasteType.getDisplayName(item.wasteType),
                  style: blackTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: semiBold,
                  ),
                ),
                Text(
                  item.wasteType,
                  style: greyTextStyle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            _formatWeight(item),
            style: blackTextStyle.copyWith(fontSize: 13, fontWeight: bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalSection() {
    final totalKg = _calculateTotalWeight();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: purpleColor.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Total Estimasi',
            style: blackTextStyle.copyWith(fontSize: 13, fontWeight: semiBold),
          ),
          Row(
            children: [
              Icon(Icons.scale, size: 16, color: purpleColor),
              const SizedBox(width: 6),
              Text(
                '${totalKg.toStringAsFixed(1)} kg',
                style: blackTextStyle.copyWith(
                  fontSize: 15,
                  fontWeight: bold,
                  color: purpleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper: Format weight
  String _formatWeight(WasteItem item) {
    final weight = item.estimatedWeight;
    final unit = item.unit.toLowerCase();

    if (unit == 'gram' || unit == 'g') {
      final kg = weight / 1000;
      if (kg >= 1) {
        return '${kg.toStringAsFixed(1)} kg';
      }
      return '${weight.toStringAsFixed(0)} g';
    }

    return '${weight.toStringAsFixed(1)} kg';
  }

  // Helper: Calculate total weight
  double _calculateTotalWeight() {
    return wasteItems.fold(0.0, (sum, item) {
      final unit = item.unit.toLowerCase();
      if (unit == 'gram' || unit == 'g') {
        return sum + (item.estimatedWeight / 1000);
      }
      return sum + item.estimatedWeight;
    });
  }

  // Helper: Get color
  Color _getWasteTypeColor(String wasteType) {
    switch (wasteType.toLowerCase()) {
      case 'organik':
        return Colors.green;
      case 'plastik':
        return Colors.blue;
      case 'kertas':
        return Colors.orange;
      case 'kaca':
        return Colors.cyan;
      case 'logam':
        return Colors.grey;
      case 'elektronik':
        return Colors.purple;
      case 'kain':
        return Colors.pink;
      case 'berbahaya':
        return Colors.red;
      default:
        return greyColor;
    }
  }
}




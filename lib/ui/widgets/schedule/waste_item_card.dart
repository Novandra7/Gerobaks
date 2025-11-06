import 'package:bank_sha/models/waste_item.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

/// Card untuk menampilkan waste item yang sudah dipilih
class WasteItemCard extends StatelessWidget {
  final WasteItem wasteItem;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const WasteItemCard({
    super.key,
    required this.wasteItem,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: whiteColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: greyColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Emoji Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: greenColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                WasteType.getEmoji(wasteItem.wasteType),
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Waste Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  WasteType.getDisplayName(wasteItem.wasteType),
                  style: blackTextStyle.copyWith(
                    fontSize: 14,
                    fontWeight: semiBold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${wasteItem.estimatedWeight} ${wasteItem.unit}',
                  style: greyTextStyle.copyWith(
                    fontSize: 13,
                    fontWeight: medium,
                  ),
                ),
                if (wasteItem.notes != null && wasteItem.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    wasteItem.notes!,
                    style: greyTextStyle.copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: onEdit,
                icon: Icon(Icons.edit_outlined, color: greenColor, size: 20),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

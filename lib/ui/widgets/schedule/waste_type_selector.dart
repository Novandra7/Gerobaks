import 'package:bank_sha/models/waste_item.dart';
import 'package:bank_sha/shared/theme.dart';
import 'package:flutter/material.dart';

/// Widget untuk memilih jenis sampah dengan pill buttons
class WasteTypeSelector extends StatelessWidget {
  final List<String> selectedTypes;
  final Function(String) onTypeSelected;

  const WasteTypeSelector({
    super.key,
    required this.selectedTypes,
    required this.onTypeSelected,
  });

  @override
  Widget build(BuildContext context) {
    final allTypes = WasteType.getAllTypes();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Jenis Sampah',
          style: blackTextStyle.copyWith(fontSize: 14, fontWeight: semiBold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allTypes.map((typeData) {
<<<<<<< HEAD
            // Safe handling with null coalescing and toString()
            final wasteTypeValue = typeData['value'];
            final wasteType = (wasteTypeValue != null)
                ? wasteTypeValue.toString()
                : '';

            final displayNameValue = typeData['label'];
            final displayName = (displayNameValue != null)
                ? displayNameValue.toString()
                : '';

            final emojiValue = typeData['emoji'];
            final emoji = (emojiValue != null) ? emojiValue.toString() : '🗑️';

=======
            final wasteType = typeData['value'] as String;
            final displayName = typeData['label'] as String;
            final emoji = typeData['emoji'] as String;
>>>>>>> 975463437929f47be2b3c0e694a0bc9c111eccf1
            final isSelected = selectedTypes.contains(wasteType);

            return _PillButton(
              label: displayName,
              emoji: emoji,
              isSelected: isSelected,
              onTap: () => onTypeSelected(wasteType),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? greenColor : whiteColor,
          border: Border.all(
            color: isSelected ? greenColor : greyColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: medium,
                color: isSelected ? whiteColor : blackColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

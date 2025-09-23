// New utility method for action buttons
Widget _buildActionButton(
  BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
  Color color = const Color(0xFF4CAF50),
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: ResponsiveHelper.getResponsiveWidth(context, 52),
          height: ResponsiveHelper.getResponsiveHeight(context, 52),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: ResponsiveHelper.getResponsiveIconSize(context, 24),
            ),
          ),
        ),
        SizedBox(height: ResponsiveHelper.getResponsiveSpacing(context, 8)),
        Text(
          label,
          style: blackTextStyle.copyWith(
            fontSize: ResponsiveHelper.getResponsiveFontSize(context, 14),
            fontWeight: medium,
          ),
        ),
      ],
    ),
  );
}

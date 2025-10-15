import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';

class QuickDateFilterBar extends StatelessWidget {
  final DateTime? selectedFromDate;
  final DateTime? selectedToDate;
  final Function(DateTime fromDate, DateTime toDate) onDateRangeSelected;
  final VoidCallback onClearFilter;

  const QuickDateFilterBar({
    super.key,
    this.selectedFromDate,
    this.selectedToDate,
    required this.onDateRangeSelected,
    required this.onClearFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickFilterButton(
              label: 'Hôm nay',
              icon: Icons.today,
              onTap: () {
                final today = DateFormatter.getTodayStart();
                onDateRangeSelected(today, today);
              },
            ),
            const SizedBox(width: 8),
            _buildQuickFilterButton(
              label: 'Tuần này',
              icon: Icons.date_range,
              onTap: () {
                final weekStart = DateFormatter.getWeekStart();
                final today = DateFormatter.getTodayStart();
                onDateRangeSelected(weekStart, today);
              },
            ),
            const SizedBox(width: 8),
            _buildQuickFilterButton(
              label: 'Tháng này',
              icon: Icons.calendar_today,
              onTap: () {
                final monthStart = DateFormatter.getMonthStart();
                final today = DateFormatter.getTodayStart();
                onDateRangeSelected(monthStart, today);
              },
            ),
            if (selectedFromDate != null || selectedToDate != null) ...[
              const SizedBox(width: 8),
              _buildClearButton(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickFilterButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final isSelected = _isDateRangeSelected(label);

    return Material(
      color: isSelected
          ? AppColors.maritimeBlue
          : AppColors.maritimeBlue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.maritimeBlue,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.maritimeBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClearButton() {
    return Material(
      color: AppColors.statusError.withOpacity(0.1),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onClearFilter,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.clear,
                size: 16,
                color: AppColors.statusError,
              ),
              SizedBox(width: 6),
              Text(
                'Xóa bộ lọc',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.statusError,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isDateRangeSelected(String label) {
    if (selectedFromDate == null || selectedToDate == null) return false;

    final today = DateFormatter.getTodayStart();

    switch (label) {
      case 'Hôm nay':
        return selectedFromDate!.year == today.year &&
            selectedFromDate!.month == today.month &&
            selectedFromDate!.day == today.day &&
            selectedToDate!.year == today.year &&
            selectedToDate!.month == today.month &&
            selectedToDate!.day == today.day;

      case 'Tuần này':
        final weekStart = DateFormatter.getWeekStart();
        return selectedFromDate!.year == weekStart.year &&
            selectedFromDate!.month == weekStart.month &&
            selectedFromDate!.day == weekStart.day &&
            selectedToDate!.year == today.year &&
            selectedToDate!.month == today.month &&
            selectedToDate!.day == today.day;

      case 'Tháng này':
        final monthStart = DateFormatter.getMonthStart();
        return selectedFromDate!.year == monthStart.year &&
            selectedFromDate!.month == monthStart.month &&
            selectedFromDate!.day == monthStart.day &&
            selectedToDate!.year == today.year &&
            selectedToDate!.month == today.month &&
            selectedToDate!.day == today.day;

      default:
        return false;
    }
  }
}
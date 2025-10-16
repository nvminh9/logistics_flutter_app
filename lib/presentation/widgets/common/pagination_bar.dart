import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';

class PaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;
  final VoidCallback? onFirstPage;
  final VoidCallback? onLastPage;
  final Function(int)? onGoToPage;

  const PaginationBar({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.isLoading = false,
    this.onPreviousPage,
    this.onNextPage,
    this.onFirstPage,
    this.onLastPage,
    this.onGoToPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink(); // Hide if only 1 page
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page info
          Expanded(
            child: Text(
              'Trang $currentPage / $totalPages',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
          ),

          // Pagination buttons
          if (isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.maritimeBlue,
              ),
            )
          else
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // First page
                _buildPaginationButton(
                  icon: Icons.first_page,
                  tooltip: 'Trang đầu',
                  onPressed: currentPage > 1 ? onFirstPage : null,
                ),
                const SizedBox(width: 4),

                // Previous page
                _buildPaginationButton(
                  icon: Icons.chevron_left,
                  tooltip: 'Trang trước',
                  onPressed: currentPage > 1 ? onPreviousPage : null,
                ),
                const SizedBox(width: 8),

                // Page numbers (show 3 pages max)
                ..._buildPageNumbers(),

                const SizedBox(width: 8),

                // Next page
                _buildPaginationButton(
                  icon: Icons.chevron_right,
                  tooltip: 'Trang sau',
                  onPressed: currentPage < totalPages ? onNextPage : null,
                ),
                const SizedBox(width: 4),

                // Last page
                _buildPaginationButton(
                  icon: Icons.last_page,
                  tooltip: 'Trang cuối',
                  onPressed: currentPage < totalPages ? onLastPage : null,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPaginationButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: onPressed != null
            ? AppColors.maritimeBlue.withOpacity(0.1)
            : AppColors.hintText.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: onPressed != null
                  ? AppColors.maritimeBlue
                  : AppColors.hintText,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageWidgets = [];

    // Show current page and 1 page before/after
    int start = (currentPage - 1).clamp(1, totalPages);
    int end = (currentPage + 1).clamp(1, totalPages);

    // If at the start, show more pages ahead
    if (currentPage <= 2) {
      end = 3.clamp(1, totalPages);
    }

    // If at the end, show more pages behind
    if (currentPage >= totalPages - 1) {
      start = (totalPages - 2).clamp(1, totalPages);
    }

    for (int i = start; i <= end; i++) {
      final isCurrentPage = i == currentPage;

      pageWidgets.add(
        _buildPageNumberButton(
          pageNumber: i,
          isCurrentPage: isCurrentPage,
        ),
      );

      if (i < end) {
        pageWidgets.add(const SizedBox(width: 4));
      }
    }

    return pageWidgets;
  }

  Widget _buildPageNumberButton({
    required int pageNumber,
    required bool isCurrentPage,
  }) {
    return Material(
      color: isCurrentPage
          ? AppColors.maritimeBlue
          : AppColors.maritimeBlue.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: isCurrentPage ? null : () => onGoToPage?.call(pageNumber),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          child: Text(
            pageNumber.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isCurrentPage ? Colors.white : AppColors.maritimeBlue,
            ),
          ),
        ),
      ),
    );
  }
}

// ⭐ Compact version for mobile
class CompactPaginationBar extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final bool isLoading;
  final VoidCallback? onPreviousPage;
  final VoidCallback? onNextPage;

  const CompactPaginationBar({
    Key? key,
    required this.currentPage,
    required this.totalPages,
    this.isLoading = false,
    this.onPreviousPage,
    this.onNextPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPage > 1 ? onPreviousPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maritimeBlue.withOpacity(0.1),
                foregroundColor: AppColors.maritimeBlue,
                disabledBackgroundColor: AppColors.hintText.withOpacity(0.1),
                disabledForegroundColor: AppColors.hintText,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.chevron_left, size: 20),
              label: const Text(
                'Trước',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Page info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.maritimeBlue,
              ),
            )
                : Text(
              '$currentPage/$totalPages',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
          ),

          // Next button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: currentPage < totalPages ? onNextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.maritimeBlue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.hintText,
                disabledForegroundColor: Colors.white70,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Text(
                'Sau',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              label: const Icon(Icons.chevron_right, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
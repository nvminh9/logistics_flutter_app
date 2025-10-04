import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/core/utils/money_formatter.dart';
import 'package:nalogistics_app/data/models/order/order_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor(order.status).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: const [AppColors.cardShadow],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Header: Container-style design
                _buildHeader(),
                const SizedBox(height: 16),

                // Route info (Origin → Destination style)
                _buildRouteInfo(),
                const SizedBox(height: 16),

                // Status timeline
                _buildStatusBar(),
                const SizedBox(height: 16),

                // Bottom info
                _buildBottomInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Container icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.local_shipping_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),

        // Order ID & Customer
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    order.orderID,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryText,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      order.status.displayName.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.customerName,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        // Amount
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              MoneyFormatter.formatSimple(order.totalCost),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.maritimeBlue,
              ),
            ),
            const Text(
              'VND',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sectionBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Origin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PICKUP',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hintText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Warehouse A', // Mock data
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                ),
                Text(
                  DateFormatter.formatDateTime(order.orderDate),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),

          // Arrow
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 1,
                  color: AppColors.maritimeBlue,
                ),
                const Icon(
                  Icons.arrow_forward,
                  color: AppColors.maritimeBlue,
                  size: 16,
                ),
                Container(
                  width: 20,
                  height: 1,
                  color: AppColors.maritimeBlue,
                ),
              ],
            ),
          ),

          // Destination
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  'DELIVERY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.hintText,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  order.customerName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                  ),
                  textAlign: TextAlign.end,
                ),
                const Text(
                  'Expected: Today',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.secondaryText,
                  ),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar() {
    // Maersk-style progress indicator
    return Row(
      children: [
        _buildStatusDot(isActive: true, isCompleted: true),
        _buildStatusLine(isActive: order.status.index >= 1),
        _buildStatusDot(isActive: order.status.index >= 1, isCompleted: order.status.index > 1),
        _buildStatusLine(isActive: order.status.index >= 2),
        _buildStatusDot(isActive: order.status.index >= 2, isCompleted: order.status.index > 2),
        _buildStatusLine(isActive: order.status.index >= 3),
        _buildStatusDot(isActive: order.status.index >= 3, isCompleted: order.status.index > 3),
      ],
    );
  }

  Widget _buildStatusDot({required bool isActive, required bool isCompleted}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.statusDelivered
            : isActive
            ? AppColors.maritimeBlue
            : AppColors.hintText,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          if (isActive) BoxShadow(
            color: (isCompleted ? AppColors.statusDelivered : AppColors.maritimeBlue).withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLine({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive
            ? AppColors.maritimeBlue
            : AppColors.hintText.withOpacity(0.3),
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ETA info
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 16,
              color: AppColors.hintText,
            ),
            const SizedBox(width: 4),
            Text(
              'ETA: ${DateFormatter.formatTime(DateTime.now().add(const Duration(hours: 2)))}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),

        // Action button
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'VIEW DETAILS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 12,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return OrderStatus.pending.color;
      case OrderStatus.inProgress:
        return OrderStatus.inProgress.color;
      case OrderStatus.pickedUp:
        return OrderStatus.pickedUp.color;
      case OrderStatus.inTransit:
        return OrderStatus.inTransit.color;
      case OrderStatus.delivered:
        return OrderStatus.delivered.color;
      case OrderStatus.completed:
        return OrderStatus.completed.color;
      case OrderStatus.cancelled:
        return OrderStatus.cancelled.color;
      case OrderStatus.failedDelivery:
        return OrderStatus.failedDelivery.color;
    }
  }
}
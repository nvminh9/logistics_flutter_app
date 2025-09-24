import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/core/utils/money_formatter.dart';
import 'package:nalogistics_app/data/models/order/order_api_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class OrderStatusCard extends StatelessWidget {
  final OrderApiModel order;
  final VoidCallback? onTap;

  const OrderStatusCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getStatusColor(order.orderStatus).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với Order ID và Status
                Row(
                  children: [
                    // Status Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.orderStatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getStatusIcon(order.orderStatus),
                        color: _getStatusColor(order.orderStatus),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Order ID và Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Đơn hàng #${order.orderID}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.orderStatus),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order.orderStatus.displayName,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
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
                            color: AppColors.maritimeDarkBlue,
                          ),
                        ),
                        const Text(
                          'VND',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.secondaryText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Customer Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sectionBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 16,
                            color: AppColors.secondaryText,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'KHÁCH HÀNG',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondaryText,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.customerName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryText,
                              ),
                            ),
                          ),
                          if (order.customerPhone?.isNotEmpty == true) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.maritimeBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.phone,
                                    size: 12,
                                    color: AppColors.maritimeBlue,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'GỌI',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.maritimeBlue,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Bottom row với Date và Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Date info
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: AppColors.secondaryText,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormatter.formatDateTime(order.orderDate),
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),

                    // Action button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        // gradient: AppColors.primaryGradient,
                        color: AppColors.maritimeBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'XEM CHI TIẾT',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.arrow_forward,
                            size: 14,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
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

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.inProgress:
        return Icons.hourglass_empty;
      case OrderStatus.pickedUp:
        return Icons.inventory_2;
      case OrderStatus.inTransit:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.check_circle;
      case OrderStatus.completed:
        return Icons.task_alt;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.failedDelivery:
        return Icons.error;
    }
  }
}
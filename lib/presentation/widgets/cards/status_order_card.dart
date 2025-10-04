import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/utils/date_formatter.dart';
import 'package:nalogistics_app/core/utils/money_formatter.dart';
import 'package:nalogistics_app/data/models/order/order_model.dart';
import 'package:nalogistics_app/shared/enums/order_status_enum.dart';

class StatusOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const StatusOrderCard({
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
          // color: order.status.color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            // color: order.status.color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
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
              children: [
                // Header với status prominent
                Row(
                  children: [
                    // Status icon với animation-style background
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            // order.status.color,
                            // order.status.color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            // color: order.status.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      // child: Icon(
                      //   order.status.icon,
                      //   color: Colors.white,
                      //   size: 24,
                      // ),
                    ),

                    const SizedBox(width: 16),

                    // Order info
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  // color: order.status.color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order.status.displayName.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    // color: order.status.color,
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            // color: order.status.color,
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

                // Customer details
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.sectionBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      // Time info
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            size: 16,
                            color: AppColors.hintText,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Ngày đặt: ${DateFormatter.formatDateTime(order.orderDate)}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.secondaryText,
                            ),
                          ),
                        ],
                      ),

                      if (order.customerAddress?.isNotEmpty == true) ...[
                        const SizedBox(height: 8),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: AppColors.hintText,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                order.customerAddress!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryText,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status-specific action text
                    Text(
                      _getActionText(order.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.hintText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    // View details button
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // order.status.color,
                            // order.status.color.withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'CHI TIẾT',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
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

  String _getActionText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Đơn hàng đang chờ được xử lý';
      case OrderStatus.inProgress:
        return 'Đơn hàng đang được xử lý...';
      case OrderStatus.pickedUp:
        return 'Hàng đã được lấy, chuẩn bị vận chuyển';
      case OrderStatus.inTransit:
        return 'Đang trên đường giao hàng';
      case OrderStatus.delivered:
        return 'Đã giao thành công, chờ xác nhận';
      case OrderStatus.completed:
        return 'Đơn hàng đã hoàn thành';
      case OrderStatus.cancelled:
        return 'Đơn hàng đã bị hủy';
      case OrderStatus.failedDelivery:
        return 'Giao hàng thất bại, cần xử lý';
    }
  }
}
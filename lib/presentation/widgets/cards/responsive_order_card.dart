import 'package:flutter/material.dart';
import 'package:nalogistics_app/core/constants/colors.dart';
import 'package:nalogistics_app/core/constants/strings.dart';
import 'package:nalogistics_app/core/utils/responsive_helper.dart';
import 'package:nalogistics_app/core/constants/responsive_dimensions.dart';
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
    ResponsiveHelper.init(context);

    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveHelper.hp(2)),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(ResponsiveHelper.cardBorderRadius),
        boxShadow: const [AppColors.cardShadow],
        border: Border.all(
          color: Colors.grey[100]!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(ResponsiveHelper.cardBorderRadius),
          child: Padding(
            padding: ResponsiveHelper.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Order ID and Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        order.orderID,
                        style: TextStyle(
                          fontSize: ResponsiveDimensions.titleMedium,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.wp(3),
                        vertical: ResponsiveHelper.hp(0.7),
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(order.status),
                        borderRadius: BorderRadius.circular(ResponsiveHelper.wp(5)),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(
                          fontSize: ResponsiveDimensions.labelSmall,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: ResponsiveHelper.hp(2)),

                // Customer and Time info
                _buildInfoRow(
                  icon: Icons.person_outline_rounded,
                  title: 'Khách hàng',
                  value: order.customerName,
                  color: AppColors.primaryText,
                ),

                SizedBox(height: ResponsiveHelper.hp(1.5)),

                _buildInfoRow(
                  icon: Icons.schedule_rounded,
                  title: 'Thời gian',
                  value: DateFormatter.formatDateTime(order.orderDate),
                  color: AppColors.statusDelayed,
                ),

                SizedBox(height: ResponsiveHelper.hp(2)),

                // Bottom section with price and action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tổng tiền',
                          style: TextStyle(
                            fontSize: ResponsiveDimensions.labelSmall,
                            color: AppColors.secondaryText,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          MoneyFormatter.formatSimple(order.totalCost),
                          style: TextStyle(
                            fontSize: ResponsiveDimensions.titleMedium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: ResponsiveHelper.wp(4),
                        vertical: ResponsiveHelper.hp(1),
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryText,
                        borderRadius: BorderRadius.circular(ResponsiveHelper.wp(3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.viewDetail,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: ResponsiveDimensions.labelMedium,
                            ),
                          ),
                          SizedBox(width: ResponsiveHelper.wp(1)),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: Colors.white,
                            size: ResponsiveDimensions.iconS,
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(ResponsiveHelper.wp(2)),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(ResponsiveHelper.wp(2)),
          ),
          child: Icon(
            icon,
            size: ResponsiveDimensions.iconS,
            color: color,
          ),
        ),
        SizedBox(width: ResponsiveHelper.wp(3)),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveDimensions.labelSmall,
                  color: AppColors.secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: ResponsiveDimensions.bodyMedium,
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
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

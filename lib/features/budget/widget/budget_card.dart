import 'package:akiba/theme/pallete.dart';
import 'package:flutter/material.dart';

const currentDate = "2024-01-23"; // Monday

class BudgetCard extends StatefulWidget {
  final Map<String, dynamic> budget;

  const BudgetCard({super.key, required this.budget});

  @override
  State<BudgetCard> createState() => _BudgetCardState();
}

class _BudgetCardState extends State<BudgetCard> {
  // Helper function to calculate days left based on period
  String _calculateDaysLeft() {
    final period = widget.budget['period'];
    final lastReset = DateTime.parse(widget.budget['last_reset']);
    final now = DateTime.parse(currentDate);

    if (period == 'daily') {
      return 'Today';
    } else if (period == 'weekly') {
      final daysPassed = now.difference(lastReset).inDays;
      final daysLeft = 7 - daysPassed;
      return '$daysLeft days left';
    } else if (period == 'monthly') {
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final daysPassed = now.difference(lastReset).inDays;
      final daysLeft = daysInMonth - daysPassed;
      return '$daysLeft days left';
    }
    return '';
  }

  // Helper function to format currency
  String _formatCurrency(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  // Helper function to get remaining amount
  double _getRemainingAmount() {
    return widget.budget['amount_budgeted'] - widget.budget['amount_spent'];
  }

  // Check if budget is overspent
  bool _isOverspent() {
    final spent = widget.budget['amount_spent'] as double;
    final budgeted = widget.budget['amount_budgeted'] as double;
    return spent > budgeted;
  }

  // Calculate overspent amount
  double _getOverspentAmount() {
    final spent = widget.budget['amount_spent'] as double;
    final budgeted = widget.budget['amount_budgeted'] as double;
    return spent - budgeted;
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _getRemainingAmount();
    final spent = widget.budget['amount_spent'] as double;
    final budgeted = widget.budget['amount_budgeted'] as double;
    final isOverspent = _isOverspent();
    final overspentAmount = _getOverspentAmount();

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 160, maxHeight: 240),
      child: Card(
        color: Pallete.whiteColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Pallete.greyColor, width: 1),
          borderRadius: BorderRadiusGeometry.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Pallete.greenColor, // Always green now
                    child: Center(
                      child: Text(
                        widget.budget['emoji'],
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.budget['name'],
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Budget info
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent: ${_formatCurrency(spent)}',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Budget: ${_formatCurrency(budgeted)}',
                    style: const TextStyle(color: Colors.black87, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

              const Spacer(),

              // Remaining amount or Overspent amount
              if (isOverspent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Overspent:',
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(overspentAmount),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _calculateDaysLeft(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Left:',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _formatCurrency(remaining),
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _calculateDaysLeft(),
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

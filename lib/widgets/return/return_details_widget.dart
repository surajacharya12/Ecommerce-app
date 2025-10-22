import 'package:flutter/material.dart';
import '../../backend_services/return_service.dart';

class ReturnDetailsWidget extends StatelessWidget {
  final String returnType;
  final String? selectedReason;
  final TextEditingController descriptionController;
  final String refundMethod;
  final Function(String) onReturnTypeChanged;
  final Function(String?) onReasonChanged;
  final Function(String) onRefundMethodChanged;

  const ReturnDetailsWidget({
    super.key,
    required this.returnType,
    required this.selectedReason,
    required this.descriptionController,
    required this.refundMethod,
    required this.onReturnTypeChanged,
    required this.onReasonChanged,
    required this.onRefundMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_return,
                  color: Colors.deepOrange,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Return Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepOrange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Return Type
            const Text(
              'Return Type',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Refund'),
                    value: 'refund',
                    groupValue: returnType,
                    onChanged: (value) => onReturnTypeChanged(value!),
                    activeColor: Colors.deepOrange,
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Exchange'),
                    value: 'exchange',
                    groupValue: returnType,
                    onChanged: (value) => onReturnTypeChanged(value!),
                    activeColor: Colors.deepOrange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Return Reason
            DropdownButtonFormField<String>(
              value: selectedReason,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: 'Reason for Return',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: ReturnService.getReturnReasons().map((reason) {
                return DropdownMenuItem(
                  value: reason['value'],
                  child: Text(reason['label']!),
                );
              }).toList(),
              onChanged: onReasonChanged,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a reason';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Please describe the issue in detail...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please provide a description';
                }
                if (value.trim().length < 10) {
                  return 'Description must be at least 10 characters';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Refund Method (only for refund type)
            if (returnType == 'refund') ...[
              const Text(
                'Refund Method',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: refundMethod,
                isExpanded: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'original_payment',
                    child: Text('Original Payment Method'),
                  ),
                  DropdownMenuItem(
                    value: 'store_credit',
                    child: Text('Store Credit'),
                  ),
                  DropdownMenuItem(
                    value: 'bank_transfer',
                    child: Text('Bank Transfer'),
                  ),
                ],
                onChanged: (value) => onRefundMethodChanged(value!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

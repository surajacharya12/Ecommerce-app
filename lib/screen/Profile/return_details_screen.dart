import 'package:flutter/material.dart';
import 'package:client/backend_services/return_service.dart';

class ReturnDetailsScreen extends StatefulWidget {
  final String returnId;
  final String userId;

  const ReturnDetailsScreen({
    super.key,
    required this.returnId,
    required this.userId,
  });

  @override
  State<ReturnDetailsScreen> createState() => _ReturnDetailsScreenState();
}

class _ReturnDetailsScreenState extends State<ReturnDetailsScreen> {
  final ReturnService _returnService = ReturnService();
  ReturnRequest? _returnRequest;
  bool _loading = true;
  bool _cancelling = false;

  @override
  void initState() {
    super.initState();
    _loadReturnDetails();
  }

  Future<void> _loadReturnDetails() async {
    setState(() {
      _loading = true;
    });

    try {
      final returnRequest = await _returnService.getReturnDetails(
        widget.returnId,
      );

      if (mounted) {
        setState(() {
          _returnRequest = returnRequest;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading return details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelReturn() async {
    if (_returnRequest == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Return Request'),
        content: const Text(
          'Are you sure you want to cancel this return request? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Yes, Cancel',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _cancelling = true;
    });

    try {
      await _returnService.cancelReturn(widget.returnId, widget.userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Return request cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Go back to returns list
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cancelling = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cancelling return: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'requested':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      case 'picked_up':
        return Colors.purple;
      case 'processing':
        return Colors.indigo;
      case 'refunded':
        return Colors.green;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getReasonDisplayText(String reason) {
    final reasons = ReturnService.getReturnReasons();
    final reasonMap = reasons.firstWhere(
      (r) => r['value'] == reason,
      orElse: () => {'label': reason},
    );
    return reasonMap['label'] ?? reason;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Return Details'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.deepOrange),
        ),
      );
    }

    if (_returnRequest == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Return Details'),
          backgroundColor: Colors.deepOrange,
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Return request not found')),
      );
    }

    final returnRequest = _returnRequest!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Return #${returnRequest.returnNumber}'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Return Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              returnRequest.returnStatus,
                            ).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _getStatusColor(
                                returnRequest.returnStatus,
                              ),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            ReturnService.getStatusDisplayText(
                              returnRequest.returnStatus,
                            ),
                            style: TextStyle(
                              color: _getStatusColor(
                                returnRequest.returnStatus,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Return Number', returnRequest.returnNumber),
                    _buildInfoRow('Order Number', returnRequest.orderNumber),
                    _buildInfoRow(
                      'Return Type',
                      returnRequest.returnType.toUpperCase(),
                    ),
                    _buildInfoRow(
                      'Requested On',
                      _formatDate(returnRequest.returnDate),
                    ),
                    if (returnRequest.processedAt != null)
                      _buildInfoRow(
                        'Processed On',
                        _formatDate(returnRequest.processedAt!),
                      ),
                    if (returnRequest.refundedAt != null)
                      _buildInfoRow(
                        'Refunded On',
                        _formatDate(returnRequest.refundedAt!),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Return Details Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Return Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      'Reason',
                      _getReasonDisplayText(returnRequest.returnReason),
                    ),
                    _buildInfoRow(
                      'Refund Method',
                      returnRequest.refundMethod
                          .replaceAll('_', ' ')
                          .toUpperCase(),
                    ),
                    _buildInfoRow(
                      'Return Amount',
                      '₹${returnRequest.returnAmount.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Description:',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      returnRequest.returnDescription,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Items Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Return Items',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...returnRequest.items.map((item) => _buildItemCard(item)),
                  ],
                ),
              ),
            ),

            if (returnRequest.adminNotes != null) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Admin Notes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        returnRequest.adminNotes!,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Cancel Button (only if status is 'requested')
            if (returnRequest.returnStatus == 'requested')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _cancelling ? null : _cancelReturn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _cancelling
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          'Cancel Return Request',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  Widget _buildItemCard(ReturnItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.productName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Return Qty: ${item.returnQuantity}'),
              Text('Price: ₹${item.price.toStringAsFixed(2)}'),
            ],
          ),
          if (item.variant != null) ...[
            const SizedBox(height: 4),
            Text('Variant: ${item.variant}'),
          ],
          const SizedBox(height: 4),
          Text('Condition: ${item.condition.toUpperCase()}'),
        ],
      ),
    );
  }
}

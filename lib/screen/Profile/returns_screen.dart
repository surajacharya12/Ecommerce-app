import 'package:client/screen/Profile/create_return_screen.dart';
import 'package:flutter/material.dart';
import 'package:client/backend_services/return_service.dart';
import 'package:client/screen/Profile/return_details_screen.dart';

class ReturnsScreen extends StatefulWidget {
  final String userId;

  const ReturnsScreen({super.key, required this.userId});

  @override
  State<ReturnsScreen> createState() => _ReturnsScreenState();
}

class _ReturnsScreenState extends State<ReturnsScreen> {
  final ReturnService _returnService = ReturnService();
  List<ReturnRequest> _returns = [];
  bool _loading = true;
  String? _selectedStatus;

  final List<Map<String, String>> _statusFilters = [
    {'value': '', 'label': 'All Returns'},
    {'value': 'requested', 'label': 'Requested'},
    {'value': 'approved', 'label': 'Approved'},
    {'value': 'rejected', 'label': 'Rejected'},
    {'value': 'picked_up', 'label': 'Picked Up'},
    {'value': 'processing', 'label': 'Processing'},
    {'value': 'refunded', 'label': 'Refunded'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _loadReturns();
  }

  Future<void> _loadReturns() async {
    setState(() {
      _loading = true;
    });

    try {
      final returns = await _returnService.getUserReturns(
        widget.userId,
        status: _selectedStatus?.isEmpty == true ? null : _selectedStatus,
      );

      if (mounted) {
        setState(() {
          _returns = returns;
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
            content: Text('Error loading returns: $e'),
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

  Widget _buildReturnCard(ReturnRequest returnRequest) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ReturnDetailsScreen(
                returnId: returnRequest.id,
                userId: widget.userId,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Return #${returnRequest.returnNumber}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Order #${returnRequest.orderNumber}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                        color: _getStatusColor(returnRequest.returnStatus),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      ReturnService.getStatusDisplayText(
                        returnRequest.returnStatus,
                      ),
                      style: TextStyle(
                        color: _getStatusColor(returnRequest.returnStatus),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Requested: ${_formatDate(returnRequest.returnDate)}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.shopping_bag, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    '${returnRequest.items.length} item(s)',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const Spacer(),
                  Text(
                    '₹${returnRequest.returnAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Reason: ${_getReasonDisplayText(returnRequest.returnReason)}',
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getReasonDisplayText(String reason) {
    final reasons = ReturnService.getReturnReasons();
    final reasonMap = reasons.firstWhere(
      (r) => r['value'] == reason,
      orElse: () => {'label': reason},
    );
    return reasonMap['label'] ?? reason;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Returns'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _selectedStatus = value;
              });
              _loadReturns();
            },
            itemBuilder: (context) => _statusFilters.map((filter) {
              return PopupMenuItem<String>(
                value: filter['value'],
                child: Text(filter['label']!),
              );
            }).toList(),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.deepOrange),
            )
          : _returns.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadReturns,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _returns.length,
                itemBuilder: (context, index) =>
                    _buildReturnCard(_returns[index]),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateReturnScreen(userId: widget.userId),
            ),
          ).then((_) => _loadReturns()); // Refresh when returning
        },
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('New Return'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_return, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Returns Found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You haven\'t made any return requests yet.',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CreateReturnScreen(userId: widget.userId),
                ),
              ).then((_) => _loadReturns());
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Return Request'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

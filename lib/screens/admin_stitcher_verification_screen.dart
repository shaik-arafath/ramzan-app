import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/stitcher.dart';

class AdminStitcherVerificationScreen extends StatefulWidget {
  const AdminStitcherVerificationScreen({super.key});

  @override
  State<AdminStitcherVerificationScreen> createState() => _AdminStitcherVerificationScreenState();
}

class _AdminStitcherVerificationScreenState extends State<AdminStitcherVerificationScreen> {
  List<Stitcher> _pendingStitchers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingStitchers();
  }

  Future<void> _loadPendingStitchers() async {
    setState(() => _isLoading = true);

    try {
      final response = await Supabase.instance.client
          .from('stitchers')
          .select()
          .eq('verification_status', 'pending')
          .order('created_at', ascending: false);

      setState(() {
        _pendingStitchers = response.map((json) => Stitcher.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load stitchers: $e')),
        );
      }
    }
  }

  Future<void> _approveStitcher(Stitcher stitcher) async {
    try {
      await Supabase.instance.client
          .from('stitchers')
          .update({'verification_status': 'approved'})
          .eq('id', stitcher.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${stitcher.id} approved successfully')),
        );
        _loadPendingStitchers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to approve: $e')),
        );
      }
    }
  }

  Future<void> _rejectStitcher(Stitcher stitcher) async {
    try {
      await Supabase.instance.client
          .from('stitchers')
          .update({'verification_status': 'rejected'})
          .eq('id', stitcher.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${stitcher.id} rejected')),
        );
        _loadPendingStitchers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reject: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stitcher Verification'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingStitchers,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingStitchers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 64,
                        color: Colors.green[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending verifications',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pendingStitchers.length,
                  itemBuilder: (context, index) {
                    final stitcher = _pendingStitchers[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  child: Text(
                                    stitcher.id[0].toUpperCase(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stitcher.id,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Applied: ${_formatDate(stitcher.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
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
                                    color: Colors.orange[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Pending',
                                    style: TextStyle(
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            _buildInfoRow('Mobile', stitcher.mobileNumber),
                            const SizedBox(height: 8),
                            _buildInfoRow('Aadhar', stitcher.aadharCard),
                            const SizedBox(height: 8),
                            _buildInfoRow('Address', stitcher.address),
                            const SizedBox(height: 8),
                            _buildInfoRow('Shop Address', stitcher.shopAddress),
                            const SizedBox(height: 8),
                            _buildInfoRow(
                              'Shop Location',
                              '${stitcher.shopLatitude.toStringAsFixed(6)}, ${stitcher.shopLongitude.toStringAsFixed(6)}',
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _approveStitcher(stitcher),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _rejectStitcher(stitcher),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Reject'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

import 'package:flutter/material.dart';
import '../models/wazifa.dart';
import '../services/wazifa_service.dart';
import '../theme/app_colors.dart';
import 'add_wazifa_screen.dart';

class AdminWazifasScreen extends StatefulWidget {
  const AdminWazifasScreen({super.key});

  @override
  State<AdminWazifasScreen> createState() => _AdminWazifasScreenState();
}

class _AdminWazifasScreenState extends State<AdminWazifasScreen> {
  final WazifaService _wazifaService = WazifaService();
  List<Wazifa> _wazifas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWazifas();
  }

  Future<void> _loadWazifas() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final wazifas = await _wazifaService.getAllWazifas();
      setState(() {
        _wazifas = wazifas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading wazifas: $e')),
        );
      }
    }
  }

  Future<void> _deleteWazifa(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.mediumBlack,
        title: const Text(
          'Delete Wazifa',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Are you sure you want to delete this wazifa?',
          style: TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.gold)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _wazifaService.deleteWazifa(id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wazifa deleted successfully')),
          );
          _loadWazifas();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting wazifa: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.mediumBlack,
        title: const Text(
          'Manage Wazifas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddWazifaScreen()),
              );
              if (result == true) {
                _loadWazifas();
              }
            },
            tooltip: 'Add Wazifa',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : _wazifas.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, color: AppColors.gold, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No wazifas yet',
                        style: TextStyle(color: AppColors.white70, fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap + to add your first wazifa',
                        style: TextStyle(color: AppColors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _wazifas.length,
                  itemBuilder: (context, index) {
                    final wazifa = _wazifas[index];
                    return _buildWazifaCard(wazifa);
                  },
                ),
    );
  }

  Widget _buildWazifaCard(Wazifa wazifa) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: AppColors.mediumBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.gold),
                        ),
                        child: Text(
                          wazifa.category,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        wazifa.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        wazifa.description,
                        style: TextStyle(
                          color: AppColors.white70,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteWazifa(wazifa.id),
                  tooltip: 'Delete',
                ),
              ],
            ),
            if (wazifa.time != null || wazifa.namaz != null || wazifa.dua != null || wazifa.ziker != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (wazifa.time != null)
                    _buildInfoChip(Icons.access_time, 'Time'),
                  if (wazifa.namaz != null)
                    _buildInfoChip(Icons.mosque, 'Namaz'),
                  if (wazifa.dua != null)
                    _buildInfoChip(Icons.menu_book, 'Dua'),
                  if (wazifa.ziker != null)
                    _buildInfoChip(Icons.psychology, 'Ziker'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.gold, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

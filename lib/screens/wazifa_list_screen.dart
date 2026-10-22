import 'package:flutter/material.dart';
import '../models/wazifa.dart';
import '../services/wazifa_service.dart';
import '../theme/app_colors.dart';
import 'wazifa_detail_screen.dart';
import 'add_wazifa_screen.dart';

class WazifaListScreen extends StatefulWidget {
  const WazifaListScreen({super.key});

  @override
  State<WazifaListScreen> createState() => _WazifaListScreenState();
}

class _WazifaListScreenState extends State<WazifaListScreen> {
  final WazifaService _wazifaService = WazifaService();
  List<Wazifa> _wazifas = [];
  List<Wazifa> _filteredWazifas = [];
  bool _isLoading = true;
  String? _selectedCategory;
  List<String> _categories = ['All'];

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
      final categories = await _wazifaService.getCategories();

      setState(() {
        _wazifas = wazifas;
        _filteredWazifas = wazifas;
        _categories = ['All', ...categories];
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

  void _filterByCategory(String category) {
    setState(() {
      _selectedCategory = category;
      if (category == 'All') {
        _filteredWazifas = _wazifas;
      } else {
        _filteredWazifas = _wazifas.where((w) => w.category == category).toList();
      }
    });
  }

  void _searchWazifas(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredWazifas = _selectedCategory == 'All' || _selectedCategory == null
            ? _wazifas
            : _wazifas.where((w) => w.category == _selectedCategory).toList();
      } else {
        final baseList = _selectedCategory == 'All' || _selectedCategory == null
            ? _wazifas
            : _wazifas.where((w) => w.category == _selectedCategory).toList();
        _filteredWazifas = baseList
            .where((w) =>
                w.title.toLowerCase().contains(query.toLowerCase()) ||
                w.description.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.mediumBlack,
        title: const Text(
          'Wazifas',
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
          : Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    onChanged: _searchWazifas,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search wazifas...',
                      hintStyle: TextStyle(color: AppColors.white70),
                      prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                      filled: true,
                      fillColor: AppColors.mediumBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.gold),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.gold),
                      ),
                    ),
                  ),
                ),
                // Category filter
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = _selectedCategory == category;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category),
                          selected: isSelected,
                          onSelected: (selected) => _filterByCategory(category),
                          selectedColor: AppColors.gold,
                          checkmarkColor: Colors.black,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                          ),
                          backgroundColor: AppColors.mediumBlack,
                          side: BorderSide(color: AppColors.gold),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Wazifa list
                Expanded(
                  child: _filteredWazifas.isEmpty
                      ? Center(
                          child: Text(
                            'No wazifas found',
                            style: TextStyle(color: AppColors.white70),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredWazifas.length,
                          itemBuilder: (context, index) {
                            final wazifa = _filteredWazifas[index];
                            return _buildWazifaCard(wazifa);
                          },
                        ),
                ),
              ],
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WazifaDetailScreen(wazifa: wazifa),
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
                ],
              ),
              const SizedBox(height: 12),
              Text(
                wazifa.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                wazifa.description,
                style: TextStyle(
                  color: AppColors.white70,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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

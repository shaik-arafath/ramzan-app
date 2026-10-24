import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/masjid.dart';
import '../services/masjid_service.dart';
import '../theme/app_colors.dart';
import 'masjid_detail_screen.dart';
import 'add_masjid_screen.dart';

class MasjidListScreen extends StatefulWidget {
  const MasjidListScreen({super.key});

  @override
  State<MasjidListScreen> createState() => _MasjidListScreenState();
}

class _MasjidListScreenState extends State<MasjidListScreen> {
  final MasjidService _masjidService = MasjidService();
  final TextEditingController _searchController = TextEditingController();
  
  List<Masjid> _allMasjids = [];
  List<Masjid> _filteredMasjids = [];
  List<Masjid> _nearbyMasjids = [];
  bool _isLoading = true;
  bool _isLoadingLocation = false;
  bool _showNearby = false;
  Position? _currentPosition;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadMasjids();
  }

  Future<void> _loadMasjids() async {
    setState(() => _isLoading = true);
    try {
      final masjids = await _masjidService.fetchAllMasjids();
      setState(() {
        _allMasjids = masjids;
        _filteredMasjids = masjids;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading masjids: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      // Check location permission
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _errorMessage = 'Location services are disabled. Please enable them.';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _errorMessage = 'Location permissions are denied.';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _errorMessage = 'Location permissions are permanently denied.';
          _isLoadingLocation = false;
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Fetch nearby masjids
      final nearby = await _masjidService.fetchNearbyMasjids(
        position.latitude,
        position.longitude,
        radiusKm: 10,
      );

      setState(() {
        _currentPosition = position;
        _nearbyMasjids = nearby;
        _showNearby = true;
        _filteredMasjids = nearby;
        _isLoadingLocation = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error getting location: $e';
        _isLoadingLocation = false;
      });
    }
  }

  void _searchMasjids(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredMasjids = _showNearby ? _nearbyMasjids : _allMasjids;
      });
      return;
    }

    setState(() {
      _filteredMasjids = _allMasjids.where((masjid) {
        return masjid.name.toLowerCase().contains(query.toLowerCase()) ||
               masjid.address.toLowerCase().contains(query.toLowerCase()) ||
               (masjid.city?.toLowerCase().contains(query.toLowerCase()) ?? false);
      }).toList();
    });
  }

  void _showAllMasjids() {
    setState(() {
      _showNearby = false;
      _filteredMasjids = _allMasjids;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.mediumBlack,
        title: const Text(
          'Masjids',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (_showNearby)
            IconButton(
              icon: const Icon(Icons.list),
              onPressed: _showAllMasjids,
              tooltip: 'Show All Masjids',
            ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMasjidScreen()),
              );
              if (result == true) {
                _loadMasjids();
              }
            },
            tooltip: 'Add Masjid',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search masjid by name or address...',
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          _searchMasjids('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.lightBlack,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _searchMasjids,
            ),
          ),

          // Location button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoadingLocation ? null : _getCurrentLocation,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Icon(Icons.my_location, color: Colors.black),
                    label: Text(
                      _showNearby ? 'Nearby (${_nearbyMasjids.length})' : 'Find Nearby',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                if (_currentPosition != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _openGoogleMaps,
                      icon: const Icon(Icons.map, color: Colors.black),
                      label: const Text(
                        'View on Map',
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Error message
          if (_errorMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 16),

          // Masjid list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
                : _filteredMasjids.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mosque_outlined,
                              size: 80,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No masjids found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Try searching or enable location',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _filteredMasjids.length,
                        itemBuilder: (context, index) {
                          final masjid = _filteredMasjids[index];
                          final distance = _currentPosition != null
                              ? masjid.distanceFrom(_currentPosition!.latitude, _currentPosition!.longitude)
                              : null;
                          return _buildMasjidCard(masjid, distance);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMasjidCard(Masjid masjid, double? distance) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.mediumBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MasjidDetailScreen(masjid: masjid),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Masjid image or icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.lightBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: masjid.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          masjid.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.mosque, size: 40, color: AppColors.gold);
                          },
                        ),
                      )
                    : const Icon(Icons.mosque, size: 40, color: AppColors.gold),
              ),
              const SizedBox(width: 16),
              // Masjid details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      masjid.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      masjid.address,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (masjid.city != null)
                      Text(
                        masjid.city!,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (distance != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: AppColors.gold),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openGoogleMaps() async {
    if (_currentPosition == null) return;

    // Create a search query with nearby masjids
    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    
    // Open Google Maps with nearby masjids search
    final url = 'https://www.google.com/maps/search/masjid+near+me/@$lat,$lng,14z';
    
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open Google Maps')),
        );
      }
    }
  }
}

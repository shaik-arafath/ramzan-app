import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/masjid.dart';
import '../services/masjid_service.dart';
import '../theme/app_colors.dart';

class EditMasjidScreen extends StatefulWidget {
  final Masjid masjid;

  const EditMasjidScreen({super.key, required this.masjid});

  @override
  State<EditMasjidScreen> createState() => _EditMasjidScreenState();
}

class _EditMasjidScreenState extends State<EditMasjidScreen> {
  final MasjidService _masjidService = MasjidService();
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _stateController;
  late final TextEditingController _phoneController;
  late final TextEditingController _websiteController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _descriptionController;
  
  late final TextEditingController _fajrTimeController;
  late final TextEditingController _dhuhrTimeController;
  late final TextEditingController _asrTimeController;
  late final TextEditingController _maghribTimeController;
  late final TextEditingController _ishaTimeController;
  late final TextEditingController _jummahTimeController;
  
  late double _latitude;
  late double _longitude;
  bool _isLoadingLocation = false;
  bool _isSubmitting = false;
  late List<String> _facilities;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.masjid.name);
    _addressController = TextEditingController(text: widget.masjid.address);
    _cityController = TextEditingController(text: widget.masjid.city ?? '');
    _stateController = TextEditingController(text: widget.masjid.state ?? '');
    _phoneController = TextEditingController(text: widget.masjid.phone ?? '');
    _websiteController = TextEditingController(text: widget.masjid.website ?? '');
    _imageUrlController = TextEditingController(text: widget.masjid.imageUrl ?? '');
    _descriptionController = TextEditingController(text: widget.masjid.description ?? '');
    
    _fajrTimeController = TextEditingController(text: widget.masjid.fajrTime ?? '');
    _dhuhrTimeController = TextEditingController(text: widget.masjid.dhuhrTime ?? '');
    _asrTimeController = TextEditingController(text: widget.masjid.asrTime ?? '');
    _maghribTimeController = TextEditingController(text: widget.masjid.maghribTime ?? '');
    _ishaTimeController = TextEditingController(text: widget.masjid.ishaTime ?? '');
    _jummahTimeController = TextEditingController(text: widget.masjid.jummahTime ?? '');
    
    _latitude = widget.masjid.latitude;
    _longitude = widget.masjid.longitude;
    _facilities = List.from(widget.masjid.facilities ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _imageUrlController.dispose();
    _descriptionController.dispose();
    _fajrTimeController.dispose();
    _dhuhrTimeController.dispose();
    _asrTimeController.dispose();
    _maghribTimeController.dispose();
    _ishaTimeController.dispose();
    _jummahTimeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied.')),
          );
          setState(() => _isLoadingLocation = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are permanently denied.')),
        );
        setState(() => _isLoadingLocation = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingLocation = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Location: $_latitude, $_longitude')),
      );
    } catch (e) {
      setState(() => _isLoadingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: $e')),
      );
    }
  }

  Future<void> _submitMasjid() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please login to update masjid'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() => _isSubmitting = false);
        return;
      }

      final updatedMasjid = Masjid(
        id: widget.masjid.id,
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        country: widget.masjid.country,
        latitude: _latitude,
        longitude: _longitude,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        fajrTime: _fajrTimeController.text.trim().isEmpty ? null : _fajrTimeController.text.trim(),
        dhuhrTime: _dhuhrTimeController.text.trim().isEmpty ? null : _dhuhrTimeController.text.trim(),
        asrTime: _asrTimeController.text.trim().isEmpty ? null : _asrTimeController.text.trim(),
        maghribTime: _maghribTimeController.text.trim().isEmpty ? null : _maghribTimeController.text.trim(),
        ishaTime: _ishaTimeController.text.trim().isEmpty ? null : _ishaTimeController.text.trim(),
        jummahTime: _jummahTimeController.text.trim().isEmpty ? null : _jummahTimeController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        facilities: _facilities.isEmpty ? null : _facilities,
        createdAt: widget.masjid.createdAt,
        updatedAt: DateTime.now(),
      );

      final success = await _masjidService.updateMasjid(updatedMasjid);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Masjid updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update masjid'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _addFacility() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          backgroundColor: AppColors.darkBlack,
          title: const Text('Add Facility', style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'e.g., Parking, Wudu Area',
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _facilities.add(controller.text.trim());
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
              child: const Text('Add', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  void _removeFacility(int index) {
    setState(() {
      _facilities.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.mediumBlack,
        title: const Text(
          'Edit Masjid',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 12),
              _buildTextField(_nameController, 'Masjid Name', required: true),
              const SizedBox(height: 12),
              _buildTextField(_addressController, 'Address', required: true, maxLines: 2),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTextField(_cityController, 'City')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildTextField(_stateController, 'State')),
                ],
              ),
              const SizedBox(height: 12),
              _buildTextField(_phoneController, 'Phone (optional)'),
              const SizedBox(height: 12),
              _buildTextField(_websiteController, 'Website (optional)'),
              const SizedBox(height: 12),
              _buildTextField(_imageUrlController, 'Image URL (optional)'),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, 'Description (optional)', maxLines: 3),

              const SizedBox(height: 24),

              // Location
              _buildSectionTitle('Location'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mediumBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Latitude: $_latitude',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Longitude: $_longitude',
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
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
                      label: const Text(
                        'Update Location',
                        style: TextStyle(color: Colors.black),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Namaz Timings
              _buildSectionTitle('Namaz Timings'),
              const SizedBox(height: 12),
              _buildTimeField(_fajrTimeController, 'Fajr Time (e.g., 05:30)'),
              const SizedBox(height: 12),
              _buildTimeField(_dhuhrTimeController, 'Dhuhr Time (e.g., 12:30)'),
              const SizedBox(height: 12),
              _buildTimeField(_asrTimeController, 'Asr Time (e.g., 15:45)'),
              const SizedBox(height: 12),
              _buildTimeField(_maghribTimeController, 'Maghrib Time (e.g., 18:15)'),
              const SizedBox(height: 12),
              _buildTimeField(_ishaTimeController, 'Isha Time (e.g., 19:45)'),
              const SizedBox(height: 12),
              _buildTimeField(_jummahTimeController, 'Jummah Time (e.g., 13:30)'),

              const SizedBox(height: 24),

              // Facilities
              _buildSectionTitle('Facilities (Optional)'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._facilities.asMap().entries.map((entry) {
                    final index = entry.key;
                    final facility = entry.value;
                    return Chip(
                      label: Text(facility),
                      backgroundColor: AppColors.gold.withOpacity(0.2),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeFacility(index),
                      deleteIconColor: Colors.white,
                      labelStyle: const TextStyle(color: Colors.white),
                    );
                  }),
                  ActionChip(
                    label: const Text('+ Add'),
                    backgroundColor: AppColors.gold.withOpacity(0.3),
                    onPressed: _addFacility,
                    labelStyle: const TextStyle(color: AppColors.gold),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitMasjid,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text(
                          'Update Masjid',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    bool required = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.mediumBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildTimeField(TextEditingController controller, String label) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: TextInputType.datetime,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        hintText: 'HH:MM',
        hintStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: AppColors.mediumBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold),
        ),
        prefixIcon: const Icon(Icons.access_time, color: AppColors.gold),
      ),
    );
  }
}

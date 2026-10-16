import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import '../models/address.dart';
import '../services/address_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';

class AddAddressScreen extends StatefulWidget {
  final Address? existingAddress;

  const AddAddressScreen({super.key, this.existingAddress});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();

  final AddressService _addressService = AddressService();
  bool _isLoading = false;
  double _latitude = 0;
  double _longitude = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingAddress != null) {
      _fullNameController.text = widget.existingAddress!.fullName;
      _phoneController.text = widget.existingAddress!.phone;
      _addressLine1Controller.text = widget.existingAddress!.addressLine1;
      _addressLine2Controller.text = widget.existingAddress!.addressLine2;
      _cityController.text = widget.existingAddress!.city;
      _stateController.text = widget.existingAddress!.state;
      _pincodeController.text = widget.existingAddress!.pincode;
      _latitude = widget.existingAddress!.latitude;
      _longitude = widget.existingAddress!.longitude;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied.')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied.')),
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
    });

    // Reverse geocode to get address details
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _cityController.text = place.locality ?? place.subAdministrativeArea ?? '';
          _stateController.text = place.administrativeArea ?? '';
          _pincodeController.text = place.postalCode ?? '';
          _addressLine1Controller.text = place.street ?? '';
        });
      }
    } catch (e) {
      print('Error reverse geocoding: $e');
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Location captured successfully!')),
    );
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id;

      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not logged in')),
        );
        setState(() => _isLoading = false);
        return;
      }

      final address = Address(
        id: widget.existingAddress?.id ?? '',
        userId: userId,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        state: _stateController.text.trim(),
        pincode: _pincodeController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        isDefault: widget.existingAddress?.isDefault ?? false,
        createdAt: widget.existingAddress?.createdAt ?? DateTime.now(),
      );

      print('Saving address: ${address.toMap()}');

      bool success;
      if (widget.existingAddress != null) {
        success = await _addressService.updateAddress(address);
        print('Update result: $success');
      } else {
        final result = await _addressService.addAddress(address);
        success = result != null;
        print('Add result: $success, address: $result');
      }

      if (success && mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingAddress != null
                ? 'Address updated successfully'
                : 'Address added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save address'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error saving address: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving address: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        title: Text(widget.existingAddress != null ? 'Edit Address' : 'Add Address'),
        backgroundColor: AppColors.mediumBlack,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Use Current Location Button
              ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Use Current Location'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 24),

              TextFormField(
                controller: _fullNameController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Full Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Phone Number'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressLine1Controller,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Address Line 1 (House No, Street)'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _addressLine2Controller,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Address Line 2 (Area, Landmark)'),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _cityController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('City'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _stateController,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('State'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: _buildInputDecoration('Pincode'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(widget.existingAddress != null ? 'Update Address' : 'Save Address'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.white70),
      filled: true,
      fillColor: AppColors.mediumBlack,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBlack),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.lightBlack),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.gold),
      ),
    );
  }
}

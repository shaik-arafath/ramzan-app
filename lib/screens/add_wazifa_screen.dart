import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/wazifa.dart';
import '../services/wazifa_service.dart';
import '../theme/app_colors.dart';

class AddWazifaScreen extends StatefulWidget {
  const AddWazifaScreen({super.key});

  @override
  State<AddWazifaScreen> createState() => _AddWazifaScreenState();
}

class _AddWazifaScreenState extends State<AddWazifaScreen> {
  final _formKey = GlobalKey<FormState>();
  final WazifaService _wazifaService = WazifaService();

  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _timeController = TextEditingController();
  final _namazController = TextEditingController();
  final _duaController = TextEditingController();
  final _zikerController = TextEditingController();

  bool _isLoading = false;

  final List<String> _commonCategories = [
    'Rizq',
    'Health',
    'Marriage',
    'Protection',
    'Peace',
    'Success',
    'Other',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _timeController.dispose();
    _namazController.dispose();
    _duaController.dispose();
    _zikerController.dispose();
    super.dispose();
  }

  Future<void> _submitWazifa() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final wazifa = Wazifa(
        id: '',
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        time: _timeController.text.trim().isEmpty ? null : _timeController.text.trim(),
        namaz: _namazController.text.trim().isEmpty ? null : _namazController.text.trim(),
        dua: _duaController.text.trim().isEmpty ? null : _duaController.text.trim(),
        ziker: _zikerController.text.trim().isEmpty ? null : _zikerController.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _wazifaService.createWazifa(wazifa);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wazifa added successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding wazifa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
          'Add Wazifa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.gold))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Title *',
                        labelStyle: TextStyle(color: AppColors.gold),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Category
                    TextFormField(
                      controller: _categoryController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Category *',
                        labelStyle: TextStyle(color: AppColors.gold),
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
                        suffixIcon: PopupMenuButton<String>(
                          icon: const Icon(Icons.arrow_drop_down, color: AppColors.gold),
                          onSelected: (category) {
                            _categoryController.text = category;
                          },
                          itemBuilder: (context) {
                            return _commonCategories.map((category) {
                              return PopupMenuItem(
                                value: category,
                                child: Text(category, style: const TextStyle(color: Colors.black)),
                              );
                            }).toList();
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Description *',
                        labelStyle: TextStyle(color: AppColors.gold),
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
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    // Time (Optional)
                    TextFormField(
                      controller: _timeController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Time (Optional)',
                        labelStyle: TextStyle(color: AppColors.gold),
                        hintText: 'e.g., After Fajr, Before sleeping',
                        hintStyle: TextStyle(color: AppColors.white70),
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
                    const SizedBox(height: 16),
                    // Namaz (Optional)
                    TextFormField(
                      controller: _namazController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Namaz (Optional)',
                        labelStyle: TextStyle(color: AppColors.gold),
                        hintText: 'e.g., 2 Rakat Nafil',
                        hintStyle: TextStyle(color: AppColors.white70),
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
                    const SizedBox(height: 16),
                    // Dua (Optional)
                    TextFormField(
                      controller: _duaController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Dua (Optional)',
                        labelStyle: TextStyle(color: AppColors.gold),
                        hintText: 'e.g., Ya Razzaqu Ya Wahhabu',
                        hintStyle: TextStyle(color: AppColors.white70),
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
                    const SizedBox(height: 16),
                    // Ziker (Optional)
                    TextFormField(
                      controller: _zikerController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Ziker (Optional)',
                        labelStyle: TextStyle(color: AppColors.gold),
                        hintText: 'e.g., SubhanAllah 100 times',
                        hintStyle: TextStyle(color: AppColors.white70),
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
                    const SizedBox(height: 24),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitWazifa,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Add Wazifa',
                          style: TextStyle(
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
}

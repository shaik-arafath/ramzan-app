import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/masjid.dart';
import '../theme/app_colors.dart';

class MasjidDetailScreen extends StatefulWidget {
  final Masjid masjid;

  const MasjidDetailScreen({super.key, required this.masjid});

  @override
  State<MasjidDetailScreen> createState() => _MasjidDetailScreenState();
}

class _MasjidDetailScreenState extends State<MasjidDetailScreen> {
  bool _notificationsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      appBar: AppBar(
        backgroundColor: AppColors.mediumBlack,
        title: Text(
          widget.masjid.name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Masjid image or header
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.gold.withOpacity(0.3),
                    AppColors.mediumBlack,
                  ],
                ),
              ),
              child: widget.masjid.imageUrl != null
                  ? Image.network(
                      widget.masjid.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.mosque, size: 80, color: AppColors.gold);
                      },
                    )
                  : const Icon(Icons.mosque, size: 80, color: AppColors.gold),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and address
                  Text(
                    widget.masjid.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: AppColors.gold, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.masjid.address,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (widget.masjid.city != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.masjid.city}, ${widget.masjid.state ?? ''}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Namaz Timings Card
                  _buildNamazTimingsCard(),

                  const SizedBox(height: 24),

                  // Notification toggle
                  _buildNotificationCard(),

                  const SizedBox(height: 24),

                  // Description
                  if (widget.masjid.description != null) ...[
                    const Text(
                      'About',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.masjid.description!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Facilities
                  if (widget.masjid.facilities != null && widget.masjid.facilities!.isNotEmpty) ...[
                    const Text(
                      'Facilities',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.masjid.facilities!.map((facility) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.gold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.gold),
                          ),
                          child: Text(
                            facility,
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Send Message
                  _buildMessageCard(),

                  const SizedBox(height: 24),

                  // Map and Directions
                  _buildMapCard(),

                  const SizedBox(height: 24),

                  // Contact info
                  if (widget.masjid.phone != null || widget.masjid.website != null) ...[
                    const Text(
                      'Contact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (widget.masjid.phone != null)
                      Row(
                        children: [
                          const Icon(Icons.phone, color: AppColors.gold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.masjid.phone!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    if (widget.masjid.website != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.language, color: AppColors.gold, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            widget.masjid.website!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNamazTimingsCard() {
    return Stack(
      children: [
        // Background image
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.asset(
            'assets/7e789cf542209fc49a5582b23347764d.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.mediumBlack,
              );
            },
          ),
        ),
        // Dark overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Content
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.gold),
                  SizedBox(width: 8),
                  Text(
                    'Namaz Timings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (widget.masjid.fajrTime == null &&
                  widget.masjid.dhuhrTime == null &&
                  widget.masjid.asrTime == null &&
                  widget.masjid.maghribTime == null &&
                  widget.masjid.ishaTime == null) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Namaz timings not available for this masjid',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else ...[
                _buildTimingRow('Fajr', widget.masjid.fajrTime),
                _buildTimingRow('Dhuhr', widget.masjid.dhuhrTime),
                _buildTimingRow('Asr', widget.masjid.asrTime),
                _buildTimingRow('Maghrib', widget.masjid.maghribTime),
                _buildTimingRow('Isha', widget.masjid.ishaTime),
              ],
              if (widget.masjid.jummahTime != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Jummah',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget.masjid.jummahTime!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimingRow(String label, String? time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          Text(
            time ?? '--:--',
            style: TextStyle(
              color: time != null ? AppColors.gold : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(
            _notificationsEnabled ? Icons.notifications_active : Icons.notifications_none,
            color: AppColors.gold,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Prayer Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _notificationsEnabled
                      ? 'You will receive notifications for prayer times'
                      : 'Enable to get prayer time notifications',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO: Implement notification subscription logic
              if (value) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications enabled for this masjid'),
                    backgroundColor: AppColors.gold,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Notifications disabled'),
                    backgroundColor: Colors.grey,
                  ),
                );
              }
            },
            activeColor: AppColors.gold,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.message, color: AppColors.gold),
              SizedBox(width: 8),
              Text(
                'Send Message',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send, color: Colors.black),
              label: const Text(
                'Contact Masjid',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage() async {
    final messageController = TextEditingController();
    
    final message = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.mediumBlack,
        title: Text(
          'Send Message to ${widget.masjid.name}',
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: messageController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Type your message...',
            hintStyle: const TextStyle(color: Colors.grey),
            filled: true,
            fillColor: AppColors.lightBlack,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.gold.withOpacity(0.3)),
            ),
          ),
          maxLines: 4,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.gold)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, messageController.text),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold),
            child: const Text('Send', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (message != null && message!.isNotEmpty) {
      // For now, just show a success message
      // In production, this would send the message via WhatsApp or email
      if (widget.masjid.phone != null) {
        final whatsappUrl = 'https://wa.me/${widget.masjid!.phone!.replaceAll(RegExp(r'[^\d]'), '')}?text=${Uri.encodeComponent(message!)}';
        if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
          await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message sent! (Demo mode)')),
          );
        }
      }
    }
    
    messageController.dispose();
  }

  Widget _buildMapCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mediumBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.map, color: AppColors.gold),
              SizedBox(width: 8),
              Text(
                'Location & Directions',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.lightBlack,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                // Placeholder for map
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 60,
                        color: AppColors.gold.withOpacity(0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.masjid.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${widget.masjid.latitude.toStringAsFixed(4)}, ${widget.masjid.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Open in Google Maps button
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'open_map',
                    backgroundColor: AppColors.gold,
                    onPressed: _openInGoogleMaps,
                    child: const Icon(Icons.directions, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openInGoogleMaps,
              icon: const Icon(Icons.directions, color: Colors.black),
              label: const Text(
                'Get Directions',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openInGoogleMaps() async {
    final lat = widget.masjid.latitude;
    final lng = widget.masjid.longitude;
    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    
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

import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_timing.dart';
import '../data/prayer_timings_data.dart';
import '../data/ramadan_tips_data.dart';
import '../theme/app_colors.dart';
import '../widgets/prayer_card.dart';
import '../widgets/quran_progress_card.dart';
import '../widgets/zikr_card.dart';
import '../widgets/sunnah_card.dart';
import '../services/supabase_content_service.dart';
import 'package:provider/provider.dart';
import '../services/prayer_time_service.dart';
import 'daily_quran_screen.dart';
import 'dua_azkar_screen.dart';
import 'sunnah_lessons_screen.dart';
import 'qibla_finder_screen.dart';
import 'tasbeeh_counter_screen.dart';
import 'islamic_calendar_screen.dart';
import 'daily_goals_screen.dart';
import 'quran_progress_screen.dart';
import 'bayans_feed_screen.dart';
import 'bayans_list_screen.dart';
import 'shop_screen.dart';
import 'cart_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../data/product_data.dart';
import '../models/product.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  RamadanDay? _todayData;
  int _tipIndex = 0;
  PageController? _prayerPageController;
  int _prayerPageIndex = 0;
  Timer? _prayerAutoScrollTimer;
  VideoPlayerController? _headerVideoController;
  final SupabaseContentService _contentService = SupabaseContentService();
  int _unreadNotificationCount = 0;
  bool _hasShownNewNotificationBanner = false;

  // Remote overrides from Firestore timetable/default
  String? _sehriTimeOverride;
  String? _iftarTimeOverride;
  Map<String, String>? _prayerTimeOverrides;

  static const MethodChannel _adhanChannel =
      MethodChannel('com.ramzan_app/adhan_scheduler');

  @override
  void initState() {
    super.initState();
    _loadTodayData();

    _prayerPageController = PageController();
    _startPrayerAutoScroll();
    // Load remote config/timetable after first frame so UI can appear quickly.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRemoteTimetable();
      _initHeaderVideo();
      _loadNotificationBadge();
    });
  }

  Future<void> _loadNotificationBadge() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSeenIso = prefs.getString('notifications_last_seen_at');
      DateTime? lastSeen;
      if (lastSeenIso != null) {
        lastSeen = DateTime.tryParse(lastSeenIso);
      }

      final notifications = await _contentService.fetchNotifications();
      int unread = 0;

      for (final item in notifications) {
        final createdRaw = item['created_at'];
        if (createdRaw == null) continue;
        final created = DateTime.tryParse(createdRaw.toString());
        if (created == null) continue;
        if (lastSeen == null || created.isAfter(lastSeen)) {
          unread++;
        }
      }

      if (!mounted) return;

      setState(() {
        _unreadNotificationCount = unread;
      });

      if (unread > 0 && !_hasShownNewNotificationBanner) {
        _hasShownNewNotificationBanner = true;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              unread == 1
                  ? 'You have 1 new notification'
                  : 'You have $unread new notifications',
            ),
            duration: const Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {
      // Ignore badge loading errors
    }
  }

  Future<void> _markNotificationsSeen() async {
    try {
      final notifications = await _contentService.fetchNotifications();
      DateTime? latest;

      for (final item in notifications) {
        final createdRaw = item['created_at'];
        if (createdRaw == null) continue;
        final created = DateTime.tryParse(createdRaw.toString());
        if (created == null) continue;
        if (latest == null || created.isAfter(latest)) {
          latest = created;
        }
      }

      if (latest != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'notifications_last_seen_at',
          latest.toIso8601String(),
        );
      }

      if (!mounted) return;

      setState(() {
        _unreadNotificationCount = 0;
      });
    } catch (_) {
      // Ignore errors when marking seen
    }
  }

  Future<void> _initHeaderVideo() async {
    if (_headerVideoController != null) return;
    try {
      final config = await _contentService.fetchAppConfig();
      if (config == null) return;
      final enabled = (config['headerVideoEnabled'] as bool?) ?? false;
      final url = (config['headerVideoUrl'] as String?) ?? '';
      if (!enabled || url.isEmpty) return;

      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      _headerVideoController = controller
        ..setLooping(true)
        ..setVolume(0.0);

      await controller.initialize();
      if (!mounted) return;
      controller.play();
      setState(() {});
    } catch (_) {
      // If the background video fails to load, silently ignore
      // and keep showing the static gradient header.
    }
  }

  Future<void> _loadRemoteTimetable() async {
    try {
      final data = await _contentService.fetchTimetable();
      if (data == null) return;
      final sehri = data['sehri_time'] as String?;
      final iftar = data['iftar_time'] as String?;
      final prayers = {
        'Fajr': data['fajr'] as String? ?? '',
        'Dhuhr': data['dhuhr'] as String? ?? '',
        'Asr': data['asr'] as String? ?? '',
        'Maghrib': data['maghrib'] as String? ?? '',
        'Isha': data['isha'] as String? ?? '',
      };

      // Update local UI state
      setState(() {
        _sehriTimeOverride = sehri;
        _iftarTimeOverride = iftar;
        _prayerTimeOverrides = prayers;
      });

      // Also inform PrayerTimeService so sounds follow the same admin times
      final pts = Provider.of<PrayerTimeService>(context, listen: false);
      pts.updateTimetableOverrides(
        sehriTime: sehri,
        iftarTime: iftar,
        prayers: prayers,
      );

      // Schedule native Android alarms so adhan/siren work even when app is closed
      await _scheduleNativeAlarms(sehri, iftar, prayers);
    } catch (_) {
      // Ignore remote timetable errors and keep local data.
    }
  }

  Future<void> _scheduleNativeAlarms(
    String? sehri,
    String? iftar,
    Map<String, String> prayers,
  ) async {
    try {
      await _adhanChannel.invokeMethod('scheduleAlarms', {
        'sehri': sehri ?? '',
        'iftar': iftar ?? '',
        'fajr': prayers['Fajr'] ?? '',
        'dhuhr': prayers['Dhuhr'] ?? '',
        'asr': prayers['Asr'] ?? '',
        'maghrib': prayers['Maghrib'] ?? '',
        'isha': prayers['Isha'] ?? '',
      });
    } catch (_) {
      // Ignore native scheduling errors to avoid crashing the app.
    }
  }

  void _loadTodayData() {
    setState(() {
      _todayData = PrayerTimingsData.getTodayRamadanDay();
    });
  }

  void _startPrayerAutoScroll() {
    _prayerAutoScrollTimer?.cancel();
    _prayerAutoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || _todayData == null || _todayData!.prayers.isEmpty) return;
      final count = _todayData!.prayers.length;
      _prayerPageIndex = (_prayerPageIndex + 1) % count;
      final controller = _prayerPageController;
      if (controller == null) return;
      controller.animateToPage(
        _prayerPageIndex,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _prayerAutoScrollTimer?.cancel();
    _prayerPageController?.dispose();
    _headerVideoController?.dispose();
    super.dispose();
  }

  String _to12Hour(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts.length > 1 ? int.parse(parts[1]) : 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${hour12.toString()}:${minute.toString().padLeft(2, '0')} $period';
  }

  PrayerTiming? _getNextPrayer(List<PrayerTiming> prayers) {
    final now = DateTime.now();
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    for (var prayer in prayers) {
      final effectiveTime = _getEffectivePrayerTime(prayer);
      if (effectiveTime.compareTo(currentTime) > 0) return prayer;
    }
    return prayers.isNotEmpty ? prayers[0] : null;
  }

  /// Returns the time for a given prayer, using Firestore overrides if present.
  String _getEffectivePrayerTime(PrayerTiming prayer) {
    if (_prayerTimeOverrides != null) {
      final override = _prayerTimeOverrides![prayer.name];
      if (override != null && override.isNotEmpty) {
        return override;
      }
    }
    return prayer.time;
  }

  @override
  Widget build(BuildContext context) {
    if (_todayData == null) {
      return Scaffold(
        backgroundColor: AppColors.lightBlack,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBlack,
      body: RefreshIndicator(
        onRefresh: () async => _loadTodayData(),
        color: AppColors.gold,
        backgroundColor: AppColors.mediumGreen,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            _buildHeaderBanner(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDateSection(),
                    const SizedBox(height: 20),
                    _buildSehriIftarCards(),
                    const SizedBox(height: 20),
                    _buildNextPrayerCard(),
                    const SizedBox(height: 20),
                    _buildFeaturedProducts(),
                    const SizedBox(height: 20),
                    _buildFeatureGrid(),
                    const SizedBox(height: 20),
                    _buildProgressCards(),
                    const SizedBox(height: 20),
                    _buildRamadanTips(),
                    const SizedBox(height: 24),
                    PrayerCard(prayers: _todayData!.prayers),
                    const SizedBox(height: 20),
                    ZikrCard(zikr: _todayData!.zikr),
                    const SizedBox(height: 20),
                    SunnahCard(sunnah: _todayData!.sunnah),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ShopScreen()),
          );
        },
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.shopping_bag, color: Colors.black),
        label: const Text(
          'Shop',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _showNotificationsSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (_unreadNotificationCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _unreadNotificationCount > 9
                      ? '9+'
                      : _unreadNotificationCount.toString(),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsIcon() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _showSettingsSheet,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: Image.asset(
          'assets/icons/pngwing29.png',
          height: 20,
          width: 20,
          fit: BoxFit.contain,
          color: Colors.white,
          colorBlendMode: BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildCartIcon(CartProvider cartProvider) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CartScreen()),
        );
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: Colors.white,
              size: 20,
            ),
          ),
          if (cartProvider.itemCount > 0)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  cartProvider.itemCount > 9 ? '9+' : '${cartProvider.itemCount}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showNotificationsSheet() async {
    await _markNotificationsSeen();

    await showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _contentService.fetchNotifications(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                ),
              );
            }

            final notifications = snapshot.data ?? [];

            if (notifications.isEmpty) {
              return const SizedBox(
                height: 200,
                child: Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: AppColors.white70, fontSize: 14),
                  ),
                ),
              );
            }

            return Container(
              constraints: const BoxConstraints(maxHeight: 400),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        'Notifications',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.separated(
                      itemCount: notifications.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.white24),
                      itemBuilder: (context, index) {
                        final item = notifications[index];
                        final title = (item['title'] ?? '') as String;
                        final message = (item['message'] ?? '') as String;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            title.isEmpty ? 'Notification' : title,
                            style: const TextStyle(
                              color: AppColors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            message,
                            style: const TextStyle(
                              color: AppColors.white70,
                              fontSize: 13,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkBlack,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Consumer<PrayerTimeService>(
              builder: (context, prayerService, _) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notification Settings',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      value: prayerService.adhanEnabled,
                      onChanged: (value) {
                        prayerService.setAdhanEnabled(value);
                      },
                      activeColor: AppColors.gold,
                      title: const Text(
                        'Adhan',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Play Adhan at prayer times',
                        style: TextStyle(color: AppColors.white70, fontSize: 12),
                      ),
                    ),
                    SwitchListTile(
                      value: prayerService.sirenEnabled,
                      onChanged: (value) {
                        prayerService.setSirenEnabled(value);
                      },
                      activeColor: AppColors.gold,
                      title: const Text(
                        'Siren',
                        style: TextStyle(color: AppColors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Play siren at Sehri and Iftar times',
                        style: TextStyle(color: AppColors.white70, fontSize: 12),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBanner() {
    return SliverToBoxAdapter(
      child: Container(
        height: 220,
        child: Stack(
          children: [
            // Background image with soft dark overlay
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
                child: Image.asset(
                  'assets/icons/pngwing30.png',
                  fit: BoxFit.cover,
                  // Move background slightly further up so top part is more visible
                  alignment: const Alignment(0, -0.8),
                ),
              ),
            ),
            // Centered Jamia Masjid logo, tinted white
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                'assets/icons/WhatsApp_Image_2026-02-18_at_01.56.26-removebg-preview (1).png',
                height: 170,
                fit: BoxFit.contain,
                color: Colors.white,
                colorBlendMode: BlendMode.srcIn,
              ),
            ),
            // Top-right notification, cart & settings icons inside header
            Positioned(
              top: 40,
              right: 16,
              child: Consumer<CartProvider>(
                builder: (context, cartProvider, child) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildNotificationIcon(),
                      const SizedBox(width: 12),
                      _buildCartIcon(cartProvider),
                      const SizedBox(width: 12),
                      _buildSettingsIcon(),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    final day = _todayData!;
    final gregorian = DateFormat('d MMMM yyyy').format(day.date);
    final ordinal = _getOrdinal(day.day);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _goldSeparator(),
        const SizedBox(width: 12),
        Column(
          children: [
            Text(
              '$ordinal Ramadan',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            Text(
              gregorian,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        _goldSeparator(),
      ],
    );
  }

  String _getOrdinal(int n) {
    if (n >= 11 && n <= 13) return '${n}th';
    switch (n % 10) {
      case 1: return '${n}st';
      case 2: return '${n}nd';
      case 3: return '${n}rd';
      default: return '${n}th';
    }
  }

  Widget _goldSeparator() {
    return Icon(Icons.chevron_right, color: AppColors.gold, size: 28);
  }

  Widget _buildFeaturedProducts() {
    final featuredProducts = ProductData.getProducts().take(4).toList();
    final cartProvider = Provider.of<CartProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Featured Products',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ShopScreen()),
                );
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: featuredProducts.length,
            itemBuilder: (context, index) {
              final product = featuredProducts[index];
              return Container(
                width: 160,
                margin: const EdgeInsets.only(right: 12),
                child: _buildFeaturedProductCard(product, cartProvider),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedProductCard(Product product, CartProvider cartProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.gold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ShopScreen(),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[800],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 30),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: 10,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          cartProvider.addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${product.name} added to cart'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.gold,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 14,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSehriIftarCards() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Row(
          children: [
            Expanded(child: _buildTimingCard('Sehri Time', _sehriTimeOverride ?? _todayData!.sehriTime, false)),
            const SizedBox(width: 12),
            Expanded(child: _buildTimingCard('Iftar Time', _iftarTimeOverride ?? _todayData!.iftarTime, true)),
          ],
        ),
        // Golden crescent overlay
        Positioned(
          left: 0,
          right: 0,
          top: -16,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkBlack,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 12, spreadRadius: 2),
                ],
              ),
              child: Icon(Icons.nightlight_round, color: AppColors.gold, size: 36),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimingCard(String label, String time, bool isIftar) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 28, 16, 16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _to12Hour(time),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Siren Alert', style: TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildNextPrayerCard() {
    // Ensure controller exists even after hot reloads
    _prayerPageController ??= PageController();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
        ],
      ),
      child: Stack(
        children: [
          // Subtle landscape
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.landscape, color: AppColors.lightBlack.withOpacity(0.5), size: 40),
                Icon(Icons.nightlight_round, color: AppColors.gold.withOpacity(0.4), size: 24),
                Icon(Icons.landscape, color: AppColors.lightBlack.withOpacity(0.5), size: 40),
              ],
            ),
          ),
          // Right-side decorative image for next prayer
          Positioned(
            right: 0,
            bottom: 0,
            child: Image.asset(
              'assets/icons/1.png',
              height: 90,
              fit: BoxFit.contain,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _goldSeparator(),
                  const SizedBox(width: 8),
                  const Text('Next Prayer', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  _goldSeparator(),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 80,
                child: PageView.builder(
                  controller: _prayerPageController,
                  onPageChanged: (index) {
                    _prayerPageIndex = index;
                  },
                  itemCount: _todayData!.prayers.length,
                  itemBuilder: (context, index) {
                    final prayer = _todayData!.prayers[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayer.name,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _to12Hour(_getEffectivePrayerTime(prayer)),
                          style: const TextStyle(
                            fontSize: 18,
                            color: AppColors.white70,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Adhan Reminder', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    final items = [
      // label, assetPath, fallbackIcon
      ('Daily Quran', 'assets/icons/3.jpg', null),
      ('Dua & Azkar', 'assets/icons/9.jpg', null),
      ('Sunnah Lessons', 'assets/icons/download (1).jpg', null),
      ('Qibla Finder', 'assets/icons/pngwing.com (5).png', null),
      ('Tasbeeh Counter', 'assets/icons/download.jpg', null),
      ('Islamic Calendar', null, Icons.calendar_month),
      ('Bayans', 'assets/icons/2.jpg', null),
    ];

    final crossAxisCount = 3;
    final spacing = 12.0;
    final screenWidth = MediaQuery.of(context).size.width - 40;
    final totalSpacing = spacing * (crossAxisCount - 1);
    final rawCardWidth = (screenWidth - totalSpacing) / crossAxisCount;
    final cardWidth = math.max(rawCardWidth, 80.0);

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: items
          .map((item) => SizedBox(
                width: cardWidth,
                child: _buildFeatureCard(item.$1, item.$2 as String?, item.$3 as IconData?),
              ))
          .toList(),
    );
  }

  Widget _buildFeatureCard(String label, String? assetPath, IconData? icon) {
    void _handleTap() {
      Widget page;
      switch (label) {
        case 'Daily Quran':
          page = const DailyQuranScreen();
          break;
        case 'Dua & Azkar':
          page = const DuaAzkarScreen();
          break;
        case 'Sunnah Lessons':
          page = const SunnahLessonsScreen();
          break;
        case 'Qibla Finder':
          page = const QiblaFinderScreen();
          break;
        case 'Tasbeeh Counter':
          page = const TasbeehCounterScreen();
          break;
        case 'Islamic Calendar':
          page = const IslamicCalendarScreen();
          break;
        case 'Bayans':
          page = const BayansFeedScreen();
          break;
        default:
          return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => page),
      );
    }

    Widget iconWidget;
    if (assetPath != null) {
      // Make image fill most of the card area
      iconWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AspectRatio(
          aspectRatio: 1,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      iconWidget = Icon(icon, color: AppColors.gold, size: 40);
    }

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: _handleTap,
      child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              iconWidget,
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          )),
    );
  }

  Widget _buildProgressCards() {
    final progress = (_todayData!.day / 29 * 100).round();
    final juzCompleted = _todayData!.day;
    final tasksCompleted = 5;
    final totalTasks = 5;

    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            'Quran Progress',
            '$juzCompleted/30 Juz Completed',
            progress / 100,
            'Read Now',
            false,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            'Daily Goals',
            '$tasksCompleted/$totalTasks Tasks Completed',
            1.0,
            'View Tasks',
            true,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(String title, String subtitle, double progress, String buttonLabel, bool isGoals) {
    void _handleTap() {
      if (title == 'Quran Progress') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const QuranProgressScreen()),
        );
      } else if (buttonLabel == 'View Tasks') {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const DailyGoalsScreen()),
        );
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGoals ? AppColors.mediumGreen : AppColors.darkBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: AppColors.white70, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.lightBlack,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
          if (isGoals) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(2, (_) => const Icon(Icons.check_circle, color: AppColors.gold, size: 16)),
            ),
          ],
          const SizedBox(height: 12),
          InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: _handleTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isGoals ? AppColors.iftarOrange : AppColors.gold,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRamadanTips() {
    final tips = RamadanTipsData.getTipsForCarousel();
    final tip = tips[_tipIndex % tips.length];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        setState(() {
          _tipIndex++;
        });
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBlack.withOpacity(0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withOpacity(0.5), width: 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6, offset: const Offset(0, 2)),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/icons/pngwing.com (8).png'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _goldSeparator(),
              const SizedBox(width: 8),
              const Text('Ramadan Tips', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              _goldSeparator(),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.nightlight_round, color: AppColors.gold, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  tip,
                  style: const TextStyle(color: AppColors.white, fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i == _tipIndex % 5 ? AppColors.gold : Colors.white.withOpacity(0.3),
              ),
            )),
          ),
        ],
      ),
    ),
    );
  }
}

class _MosqueSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.lightBlack;
    final w = size.width;
    final h = size.height;
    final path = Path();
    path.moveTo(0, h);
    path.lineTo(w * 0.2, h);
    path.lineTo(w * 0.25, h * 0.6);
    path.lineTo(w * 0.35, h * 0.5);
    path.lineTo(w * 0.5, h * 0.3);
    path.lineTo(w * 0.65, h * 0.5);
    path.lineTo(w * 0.75, h * 0.6);
    path.lineTo(w * 0.8, h);
    path.lineTo(w, h);
    path.lineTo(w, h + 10);
    path.lineTo(0, h + 10);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'main_page.dart';
import 'services/tara_swim_arena_workout_api_service.dart';
import 'theme/app_colors.dart';

/// Tara Swim Arena Workout - Products & Services Display Page
/// Following naming convention based on the proposed mobile app title:
/// tara_swim_arena_workout_page.dart
class TaraSwimArenaWorkoutPage extends StatefulWidget {
  const TaraSwimArenaWorkoutPage({super.key});

  @override
  State<TaraSwimArenaWorkoutPage> createState() => _TaraSwimArenaWorkoutPageState();
}

class _TaraSwimArenaWorkoutPageState extends State<TaraSwimArenaWorkoutPage> {
  late Future<FetchResult> _dashboardFuture;
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Sprint',
    'Technique',
    'Endurance',
    'Strength',
    'Recovery',
    'Elite Coaching',
  ];

  @override
  void initState() {
    super.initState();
    _urlController.text = TaraSwimArenaWorkoutApiService.customApiUrl ??
        TaraSwimArenaWorkoutApiService.defaultHttpEndpoint;
    _dashboardFuture = TaraSwimArenaWorkoutApiService.fetchDashboardData();
  }

  @override
  void dispose() {
    _urlController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _dashboardFuture = TaraSwimArenaWorkoutApiService.fetchDashboardData();
    });
  }

  Future<void> _confirmLogout() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isGuest = currentUser == null;

    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Icon(Icons.logout_rounded, color: AppColors.swimmerCoral, size: 26),
              const SizedBox(width: 10),
              Text(
                isGuest ? 'Exit to Login' : 'Log Out',
                style: const TextStyle(
                  color: AppColors.navyBackground,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isGuest
                    ? 'Return to the login screen?'
                    : 'Are you sure you want to log out of Tara Swim Arena?',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              if (!isGuest && currentUser.email != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.scaffoldLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 20, color: AppColors.waveCyan),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentUser.email!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.navyBackground,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.swimmerCoral,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: Text(
                isGuest ? 'Exit' : 'Log Out',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => Navigator.pop(ctx, true),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (e) {
        debugPrint('Sign out warning: $e');
      }

      if (mounted) {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainPage()),
            (route) => false,
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.navyBackground,
            behavior: SnackBarBehavior.floating,
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.waveCyanLight),
                const SizedBox(width: 10),
                Text(isGuest ? 'Returned to login.' : 'Successfully logged out.'),
              ],
            ),
          ),
        );
      }
    }
  }

  void _showApiSettingsDialog() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: const [
              Icon(Icons.http_rounded, color: AppColors.waveCyan, size: 28),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'REST API Configuration',
                  style: TextStyle(
                    color: AppColors.navyBackground,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consume an HTTP GET request from a live remote REST API or switch to local asset:',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  labelText: 'API Endpoint URL',
                  hintText: 'https://dpaste.com/HH29BGBN6.txt',
                  hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  prefixIcon: const Icon(Icons.link, color: AppColors.waveCyan),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.waveCyanSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppColors.waveCyanDark),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Live REST API is default. Hit "Fetch Live API" to consume GET request directly.',
                        style: TextStyle(fontSize: 11, color: AppColors.waveCyanDark),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton.icon(
              icon: const Icon(Icons.code_rounded, size: 16),
              label: const Text('View Raw JSON'),
              onPressed: () {
                Navigator.pop(ctx);
                _showRawJsonViewer();
              },
            ),
            TextButton(
              onPressed: () {
                _urlController.text = 'assets/data/workouts.json';
                TaraSwimArenaWorkoutApiService.customApiUrl = null;
                Navigator.pop(ctx);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Switched to local JSON asset fallback.')),
                );
              },
              child: const Text('Use Local Asset'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.waveCyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.cloud_download, size: 18),
              onPressed: () {
                final url = _urlController.text.trim();
                TaraSwimArenaWorkoutApiService.customApiUrl = url.isEmpty ? null : url;
                Navigator.pop(ctx);
                _refreshData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Sending HTTP GET request to: ${url.isEmpty ? TaraSwimArenaWorkoutApiService.defaultHttpEndpoint : url}')),
                );
              },
              label: const Text('Fetch Live API'),
            ),
          ],
        );
      },
    );
  }

  void _showRawJsonViewer([TaraSwimArenaWorkoutDashboardData? data]) async {
    String jsonStr = '';
    if (data != null) {
      jsonStr = const JsonEncoder.withIndent('  ').convert(data.toJson());
    } else {
      try {
        final result = await TaraSwimArenaWorkoutApiService.fetchDashboardData();
        jsonStr = const JsonEncoder.withIndent('  ').convert(result.data.toJson());
      } catch (e) {
        jsonStr = '{"error": "$e"}';
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Row(
          children: const [
            Icon(Icons.data_object_rounded, color: AppColors.waveCyan),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Emulated JSON Data Feed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.navyBackground),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 380,
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF071C3D),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                jsonStr,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: Color(0xFF38D5EC),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBookingSheet(SwimWorkoutService service) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.waveCyanSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(_getWorkoutIcon(service.icon), color: AppColors.waveCyan, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          service.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.navyBackground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${service.category} • by ${service.coach}',
                          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                service.description,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(Icons.schedule, '${service.durationMinutes} mins', 'Duration'),
                  _buildDetailItem(Icons.straighten, '${service.distanceMeters}m', 'Target Distance'),
                  _buildDetailItem(Icons.star, '${service.rating} / 5.0', 'Rating'),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Service Fee:',
                      style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.navyBackground),
                    ),
                    Text(
                      '₱${service.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.swimmerCoral,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.waveCyan,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      onPressed: () {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.navyBackground,
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.waveCyanLight),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text('Service booked: "${service.title}" with ${service.coach}!'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      label: const Text('Confirm Booking', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.waveCyan),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.navyBackground),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        ),
      ],
    );
  }

  IconData _getWorkoutIcon(String iconKey) {
    switch (iconKey.toLowerCase()) {
      case 'timer':
        return Icons.timer_outlined;
      case 'speed':
        return Icons.speed_rounded;
      case 'pool':
        return Icons.pool_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'water':
        return Icons.water_drop_rounded;
      case 'emoji_events':
        return Icons.emoji_events_rounded;
      default:
        return Icons.sports_gymnastics_rounded;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'completed':
        return const Color(0xFFE8F5E9);
      case 'filling fast':
      case 'popular':
        return const Color(0xFFFFF3E0);
      case 'limited slots':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE0F7FA);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
      case 'completed':
        return const Color(0xFF2E7D32);
      case 'filling fast':
      case 'popular':
        return const Color(0xFFE65100);
      case 'limited slots':
        return AppColors.swimmerCoral;
      default:
        return AppColors.waveCyanDark;
    }
  }

  Widget _buildAppDrawer() {
    final user = FirebaseAuth.instance.currentUser;
    final displayEmail = user?.email ?? 'yev.ordiz@jmc.edu.ph';

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.72,
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Navy Header matching screenshot
          Container(
            color: AppColors.navyBackground,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.of(context).padding.top + 20,
              20,
              24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar with cyan ring
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.waveCyan, width: 3),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: AppColors.navyBackground,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  displayEmail,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                const Text(
                  'Tara Swim Athlete',
                  style: TextStyle(
                    color: AppColors.waveCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Drawer Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(
                    Icons.grid_view_rounded,
                    color: AppColors.waveCyan,
                    size: 22,
                  ),
                  title: const Text(
                    'Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.navyBackground,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(
                    Icons.fitness_center_rounded,
                    color: AppColors.navyBackground,
                    size: 22,
                  ),
                  title: const Text(
                    'Workouts',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.navyBackground,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedCategory = 'All';
                    });
                  },
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(
                    Icons.calendar_month_rounded,
                    color: AppColors.navyBackground,
                    size: 22,
                  ),
                  title: const Text(
                    'Schedule',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: AppColors.navyBackground,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showScheduleDialog();
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFF1F5F9),
                  ),
                ),
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  leading: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.swimmerCoral,
                    size: 22,
                  ),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: AppColors.swimmerCoral,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmLogout();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: const [
                  Icon(Icons.calendar_month_rounded, color: AppColors.waveCyan),
                  SizedBox(width: 8),
                  Text(
                    'Training & Workout Schedule',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.navyBackground,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.waveCyanSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.pool_rounded, color: AppColors.waveCyanDark),
                ),
                title: const Text('Freestyle Sprint Drill', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Mon, Wed, Fri • 6:00 AM - 7:30 AM (Lane 4)', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Confirmed', style: TextStyle(color: Color(0xFF2E7D32), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.fitness_center_rounded, color: AppColors.swimmerOrange),
                ),
                title: const Text('Dryland Core Conditioning', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                subtitle: const Text('Tue, Thu • 5:00 PM - 6:00 PM (Fitness Bay)', style: TextStyle(fontSize: 12)),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Scheduled', style: TextStyle(color: Color(0xFFE65100), fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.navyBackground,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close Schedule'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      drawer: _buildAppDrawer(),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 26),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Navigation Menu',
          ),
        ),
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 28,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.pool, color: AppColors.waveCyan),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Tara Swim Arena',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.navyBackground,
        foregroundColor: Colors.white,
        elevation: 1,
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppColors.navyBackground,
                  content: Text('No new athlete notifications at this time.'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.notifications_none_rounded),
            tooltip: 'Notifications',
          ),
          IconButton(
            onPressed: _showApiSettingsDialog,
            icon: const Icon(Icons.cloud_sync_rounded),
            tooltip: 'REST API GET Options',
          ),
          IconButton(
            onPressed: _confirmLogout,
            icon: const Icon(Icons.logout_rounded, color: AppColors.swimmerCoral),
            tooltip: 'Log Out',
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.waveCyan,
          onRefresh: () async {
            _refreshData();
            await _dashboardFuture;
          },
          child: FutureBuilder<FetchResult>(
            future: _dashboardFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(color: AppColors.waveCyan),
                      SizedBox(height: 18),
                      Text(
                        'Consuming REST API Get Request...',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Fetching Tara Swim Arena services & products',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    const SizedBox(height: 40),
                    const Icon(Icons.cloud_off_rounded, size: 64, color: AppColors.swimmerCoral),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to consume REST API',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.navyBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      snapshot.error.toString(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _refreshData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry HTTP GET'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.navyBackground,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                );
              }

              final result = snapshot.data!;
              final data = result.data;
              final arena = data.arenaInfo;
              final summary = data.weeklySummary;

              // ==========================================
              // 2. JSON ARRAY TO PRODUCT MAPPING
              // Maps parsed JSON array payload to List<Product>
              // ==========================================
              final List<Product> products = data.products;

              // ==========================================
              // 4. SEARCH VIEW FILTERING LOGIC
              // Filters products dynamically by search query (name, category,
              // coach, description, status, price) and selected category
              // ==========================================
              final query = _searchQuery.trim().toLowerCase();
              final filteredProducts = products.where((product) {
                final matchesCategory = _selectedCategory == 'All' ||
                    product.category.toLowerCase().contains(_selectedCategory.toLowerCase());
                final matchesSearch = query.isEmpty ||
                    product.title.toLowerCase().contains(query) ||
                    product.category.toLowerCase().contains(query) ||
                    product.description.toLowerCase().contains(query) ||
                    product.coach.toLowerCase().contains(query) ||
                    product.status.toLowerCase().contains(query) ||
                    product.price.toString().contains(query);
                return matchesCategory && matchesSearch;
              }).toList();

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                children: [
                  // Arena Banner & Title
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppColors.drawerHeaderGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(7, 28, 61, 0.15),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.pool_rounded, color: AppColors.waveCyanLight, size: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    arena.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 17,
                                    ),
                                  ),
                                  Text(
                                    arena.tagline,
                                    style: const TextStyle(
                                      color: AppColors.waveCyanLight,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppColors.inputHintDark),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                arena.location,
                                style: const TextStyle(color: AppColors.inputHintDark, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Session / User Status with Logout Button
                  StreamBuilder<User?>(
                    stream: FirebaseAuth.instance.authStateChanges(),
                    builder: (context, userSnapshot) {
                      final user = userSnapshot.data ?? FirebaseAuth.instance.currentUser;
                      return Container(
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.03),
                              blurRadius: 6,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: const BoxDecoration(
                                color: AppColors.waveCyanSoft,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person_rounded, size: 18, color: AppColors.waveCyanDark),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user?.email != null ? 'Active Session' : 'Guest Mode',
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    user?.email ?? 'Browsing Guest',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.navyBackground,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.swimmerCoral,
                                side: const BorderSide(color: AppColors.swimmerCoral, width: 1.2),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                visualDensity: VisualDensity.compact,
                              ),
                              onPressed: _confirmLogout,
                              icon: const Icon(Icons.logout_rounded, size: 15),
                              label: Text(
                                user != null ? 'Log Out' : 'Exit',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Data Source Status Pill - Tap to view emulated JSON data
                  InkWell(
                    onTap: () => _showRawJsonViewer(data),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: result.sourceType == DataSourceType.httpNetwork
                            ? const Color(0xFFE8F5E9)
                            : AppColors.waveCyanSoft,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: result.sourceType == DataSourceType.httpNetwork
                              ? const Color(0xFF81C784)
                              : AppColors.waveCyan.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            result.sourceType == DataSourceType.httpNetwork
                                ? Icons.cloud_done_rounded
                                : Icons.folder_zip_rounded,
                            size: 16,
                            color: result.sourceType == DataSourceType.httpNetwork
                                ? const Color(0xFF2E7D32)
                                : AppColors.waveCyanDark,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              result.sourceType == DataSourceType.httpNetwork
                                  ? 'REST API GET: 200 OK (Tap to view JSON feed)'
                                  : 'REST API Source: Local JSON Asset (Tap to view JSON feed)',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: result.sourceType == DataSourceType.httpNetwork
                                    ? const Color(0xFF2E7D32)
                                    : AppColors.waveCyanDark,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.data_object_rounded, size: 16, color: AppColors.textSecondary),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Weekly Summary Card (CardView)
                  Card(
                    elevation: 2,
                    shadowColor: const Color.fromRGBO(7, 28, 61, 0.08),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.waveCyanSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.water_drop_rounded, color: AppColors.waveCyan, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Weekly Athlete Progress',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${summary.sessionsCompleted} of ${summary.targetSessions} Sessions Complete',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.navyBackground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.swimmerCoralSoft,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${summary.totalDistanceMeters}m',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.swimmerCoral,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: summary.targetSessions > 0
                                  ? (summary.sessionsCompleted / summary.targetSessions).clamp(0.0, 1.0)
                                  : 0.0,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.waveCyan),
                              minHeight: 7,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==========================================
                  // 4. SEARCH VIEW FILTERING UI
                  // Real-time search TextField with clear button & category chips
                  // ==========================================
                  TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products by name, coach, category, price...',
                      hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.waveCyan),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                });
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Category Filter Buttons / Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final isSelected = _selectedCategory == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _selectedCategory = cat;
                              });
                            },
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.navyBackground,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? Colors.white : AppColors.navyBackground,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: isSelected ? AppColors.navyBackground : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==========================================
                  // 3. DYNAMIC PRODUCT LISTVIEW PRESENTATION
                  // Dynamic ListView.builder presenting mapped Product cards
                  // ==========================================
                  Row(
                    children: [
                      const Text(
                        'Workout Services',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.navyBackground,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.waveCyanSoft,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${filteredProducts.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.waveCyanDark,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (filteredProducts.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: const [
                          Icon(Icons.search_off_rounded, size: 48, color: AppColors.textMuted),
                          SizedBox(height: 8),
                          Text(
                            'No products match your search criteria.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final service = filteredProducts[index];
                        final iconData = _getWorkoutIcon(service.icon);

                        return Card(
                          key: ValueKey(service.id),
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 14),
                          shadowColor: const Color.fromRGBO(7, 28, 61, 0.08),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Top row: Icon, Title, Status & Price
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.waveCyanSoft,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Icon(iconData, color: AppColors.waveCyan, size: 28),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            service.title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppColors.navyBackground,
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              const Icon(Icons.person_pin, size: 14, color: AppColors.textMuted),
                                              const SizedBox(width: 4),
                                              Text(
                                                service.coach,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.textSecondary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.star, size: 14, color: Colors.amber),
                                              const SizedBox(width: 2),
                                              Text(
                                                '${service.rating}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.navyBackground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '₱${service.price.toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.swimmerCoral,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: _getStatusBgColor(service.status),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            service.status,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusTextColor(service.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                // Description snippet
                                Text(
                                  service.description,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textSecondary,
                                    height: 1.35,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),

                                const SizedBox(height: 12),

                                // Metrics badges
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  children: [
                                    _buildBadge(Icons.timer, '${service.durationMinutes} mins'),
                                    _buildBadge(Icons.pool, '${service.distanceMeters}m distance'),
                                    _buildBadge(Icons.category, service.category),
                                    if (service.date.isNotEmpty)
                                      _buildBadge(Icons.calendar_today, service.date),
                                  ],
                                ),

                                const SizedBox(height: 14),
                                const Divider(height: 1),
                                const SizedBox(height: 10),

                                // CardView Buttons: Details & Book Service
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: AppColors.waveCyan.withValues(alpha: 0.6)),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        icon: const Icon(Icons.info_outline, size: 16, color: AppColors.waveCyanDark),
                                        label: const Text(
                                          'Details',
                                          style: TextStyle(color: AppColors.waveCyanDark, fontSize: 13),
                                        ),
                                        onPressed: () => _showBookingSheet(service),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 2,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.waveCyan,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        icon: const Icon(Icons.bookmark_add_outlined, size: 16),
                                        label: const Text(
                                          'Book Service',
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                        ),
                                        onPressed: () => _showBookingSheet(service),
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
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showApiSettingsDialog,
        backgroundColor: AppColors.navyBackground,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.cloud_sync, color: AppColors.waveCyan),
        label: const Text('API GET Source', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.scaffoldLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

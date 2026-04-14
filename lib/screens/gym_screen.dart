import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'nearby_gyms_map_screen.dart';

class GymScreen extends StatefulWidget {
  const GymScreen({super.key});

  @override
  State<GymScreen> createState() => _GymScreenState();
}

class _GymScreenState extends State<GymScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openGymSearch(String query) async {
    final trimmed = query.trim().isEmpty ? 'gyms near me' : '$query gyms';
    final url =
        'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(trimmed)}';
    final uri = Uri.parse(url);

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to open maps right now.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _openNearbyGymsMap() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const NearbyGymsMapScreen(),
      ),
    );
  }

  Widget _quickSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      avatar: const Icon(Icons.search, size: 16),
      onPressed: () => _openGymSearch(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gym Locator')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Find a gym in seconds',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search by city, area, or landmark.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onSubmitted: _openGymSearch,
              decoration: InputDecoration(
                hintText: 'e.g., Brooklyn, New York',
                prefixIcon: const Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _openGymSearch(_searchController.text),
                    icon: const Icon(Icons.map_outlined),
                    label: const Text('Search Maps'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _openNearbyGymsMap,
                    icon: const Icon(Icons.location_searching),
                    label: const Text('Nearby Gyms'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Quick searches',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _quickSearchChip('24 hour gym near me'),
                _quickSearchChip('crossfit gym near me'),
                _quickSearchChip('women only gym near me'),
                _quickSearchChip('budget gym near me'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

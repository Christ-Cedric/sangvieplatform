import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/hospital_layout.dart';

import 'package:flutter_animate/flutter_animate.dart';

class HospitalMapScreen extends StatefulWidget {
  const HospitalMapScreen({super.key});

  @override
  State<HospitalMapScreen> createState() => _HospitalMapScreenState();
}

class _HospitalMapScreenState extends State<HospitalMapScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultLocation = const LatLng(12.3714, -1.5197); // Ex: Ouaga
  String? _selectedFilter;

  // Simulate donors nearby
  final List<Map<String, dynamic>> _mockDonors = [
    {'id': '1', 'group': 'O+', 'lat': 12.3754, 'lng': -1.5227},
    {'id': '2', 'group': 'A-', 'lat': 12.3684, 'lng': -1.5157},
    {'id': '3', 'group': 'B+', 'lat': 12.3794, 'lng': -1.5107},
    {'id': '4', 'group': 'O-', 'lat': 12.3614, 'lng': -1.5307},
    {'id': '5', 'group': 'AB+', 'lat': 12.3814, 'lng': -1.5207},
  ];

  @override
  Widget build(BuildContext context) {
    final filteredDonors = _selectedFilter == null 
        ? _mockDonors 
        : _mockDonors.where((d) => d['group'] == _selectedFilter).toList();

    return HospitalLayout(
      child: Stack(
        children: [
          // OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultLocation,
              initialZoom: 13.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.sangvie',
              ),
              MarkerLayer(
                markers: filteredDonors.map((d) => _buildDonorMarker(d)).toList(),
              ),
              MarkerLayer(
                markers: [_buildHospitalMarker()],
              )
            ],
          ),

          // Filters
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: _buildFilterBar(),
          ),

          // Map Controls
          _buildMapControls(),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final groups = ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.filter, size: 18, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _selectedFilter == null ? "Filtrer par groupe sanguin" : "Donneurs $_selectedFilter", 
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.foreground)
                ),
              ),
              if (_selectedFilter != null)
                InkWell(
                  onTap: () => setState(() => _selectedFilter = null),
                  child: const Icon(LucideIcons.x, size: 18, color: AppColors.secondary),
                ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: groups.map((g) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => setState(() => _selectedFilter = g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _selectedFilter == g ? AppColors.primary : AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      g, 
                      style: TextStyle(
                        color: _selectedFilter == g ? Colors.white : AppColors.secondary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      )
                    ),
                  ),
                ),
              )).toList(),
            ),
          )
        ],
      ),
    ).animate().slideY(begin: -0.5, end: 0, duration: 300.ms);
  }

  Marker _buildHospitalMarker() {
    return Marker(
      point: _defaultLocation,
      width: 60,
      height: 60,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
          border: Border.all(color: AppColors.primary, width: 2)
        ),
        child: const Icon(LucideIcons.building2, color: AppColors.primary),
      ),
    );
  }

  Marker _buildDonorMarker(Map<String, dynamic> d) {
    return Marker(
      point: LatLng(d['lat'], d['lng']),
      width: 40,
      height: 40,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
          border: Border.all(color: Colors.white, width: 2)
        ),
        child: Center(
          child: Text(
            d['group'], 
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)
          ),
        ),
      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
       .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 2.seconds),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      bottom: 120,
      right: 20,
      child: Column(
        children: [
          _buildMapButton(
            LucideIcons.locateFixed, 
            color: AppColors.primary,
            onPressed: () {
              _mapController.move(_defaultLocation, 13.0);
            }
          ),
          const SizedBox(height: 12),
          _buildMapButton(
            LucideIcons.plus, 
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, zoom + 1);
            }
          ),
          const SizedBox(height: 12),
          _buildMapButton(
            LucideIcons.minus, 
            onPressed: () {
              final zoom = _mapController.camera.zoom;
              _mapController.move(_mapController.camera.center, zoom - 1);
            }
          ),
        ],
      ),
    );
  }

  Widget _buildMapButton(IconData icon, {Color? color, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: color ?? AppColors.foreground),
        onPressed: onPressed,
      ),
    );
  }
}


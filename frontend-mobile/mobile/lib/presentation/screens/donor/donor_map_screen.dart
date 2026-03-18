import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:sangvie/core/constants/api_constants.dart';
import 'package:sangvie/core/services/api_service.dart';
import 'package:sangvie/core/theme/app_colors.dart';
import 'package:sangvie/presentation/widgets/donor_layout.dart';
import 'package:sangvie/presentation/widgets/ui_components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class DonorMapScreen extends StatefulWidget {
  const DonorMapScreen({super.key});

  @override
  State<DonorMapScreen> createState() => _DonorMapScreenState();
}

class _DonorMapScreenState extends State<DonorMapScreen> {
  String? _selectedHospitalId;
  late Future<List<Map<String, dynamic>>> _hospitalsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allHospitals = [];
  List<Map<String, dynamic>> _filteredHospitals = [];
  final MapController _mapController = MapController();

  // Coordonnées par défaut (ex: Ouagadougou)
  final LatLng _defaultLocation = const LatLng(12.3714, -1.5197);
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _fetchHospitals();
    _searchController.addListener(_onSearch);
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentLocation!, 14.0);
    }
  }

  Future<void> _openMapRoute(double lat, double lng) async {
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> _fetchHospitals() async {
    final data = await ApiService.get(ApiConstants.hospitals);
    if (data == null) return [];
    final list = data is List ? data : (data['hospitals'] ?? data['data'] ?? []);
    _allHospitals = (list as List).map((h) {
      // Simulation of coordinates around default location if not provided
      final latOffset = ((h['nom']?.length ?? 0) % 10 - 5) * 0.005;
      final lngOffset = ((h['nom']?.length ?? 7) % 10 - 5) * 0.005;
      
      return {
        'id': h['_id']?.toString() ?? '',
        'name': h['nom'] ?? h['nomHopital'] ?? 'Hôpital',
        'distance': '${(2 + (h['nom']?.length ?? 0) % 8)} km',
        'urgentNeeds': List<String>.from(h['urgentGroups'] ?? ['O+', 'A-']),
        'lat': h['lat'] ?? (_defaultLocation.latitude + latOffset),
        'lng': h['lng'] ?? (_defaultLocation.longitude + lngOffset),
      };
    }).toList();
    _onSearch();
    return _allHospitals;
  }

  void _onSearch() {
    final q = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredHospitals = q.isEmpty
          ? _allHospitals
          : _allHospitals.where((h) {
              return h['name'].toString().toLowerCase().contains(q);
            }).toList();
      
      if (_selectedHospitalId != null && !_filteredHospitals.any((h) => h['id'] == _selectedHospitalId)) {
        _selectedHospitalId = null;
      }
    });

    if (_filteredHospitals.isNotEmpty && _selectedHospitalId == null) {
      _moveToLocation(
        _filteredHospitals.first['lat'],
        _filteredHospitals.first['lng'],
      );
    }
  }

  void _moveToLocation(double lat, double lng) {
    _mapController.move(LatLng(lat, lng), 14.0);
  }

  @override
  Widget build(BuildContext context) {
    return DonorLayout(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _hospitalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final hospitals = _filteredHospitals;
          
          return Stack(
            children: [
              // OpenStreetMap
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultLocation,
                  initialZoom: 13.0,
                  onTap: (tapPosition, point) {
                    setState(() => _selectedHospitalId = null);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.sangvie',
                  ),
                  MarkerLayer(
                    markers: [
                      ...hospitals.map((h) => _buildMarker(h)),
                      if (_currentLocation != null) _buildUserMarker(),
                    ],
                  ),
                ],
              ),

              // Search Bar (Top)
              _buildFloatingSearch(),

              // Info Panel (Bottom)
              if (_selectedHospitalId != null)
                _buildBottomInfoPanel(hospitals),
              
              // Map Controls (Side)
              _buildMapControls(),
            ],
          );
        }
      ),
    );
  }

  Widget _buildFloatingSearch() {
    return Positioned(
      top: 20,
      left: 20,
      right: 70, // Avoid map controls
      child: SangVieInput(
        hint: 'Rechercher un centre...',
        prefixIcon: const Icon(LucideIcons.search, size: 18, color: AppColors.primary),
        controller: _searchController,
        textInputAction: TextInputAction.search,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ).animate().slideY(begin: -1.0, end: 0, duration: 400.ms),
    );
  }

  Marker _buildUserMarker() {
    return Marker(
      point: _currentLocation!,
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 1.seconds),
    );
  }

  Marker _buildMarker(Map<String, dynamic> h) {
    final isSelected = _selectedHospitalId == h['id'];
    return Marker(
      point: LatLng(h['lat'], h['lng']),
      width: isSelected ? 120 : 60,
      height: isSelected ? 120 : 60,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedHospitalId = h['id']);
          _moveToLocation(h['lat'], h['lng']);
        },
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(isSelected ? 10 : 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: (isSelected ? AppColors.primary : Colors.black).withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
                border: Border.all(color: isSelected ? Colors.white : AppColors.primary, width: 2),
              ),
              child: Icon(
                LucideIcons.droplets, 
                color: isSelected ? Colors.white : AppColors.primary, 
                size: isSelected ? 24 : 18
              ),
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  h['name'],
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ).animate().fadeIn().scale(),
          ],
        ).animate().slideY(begin: 1.0, end: 0, duration: 600.ms, curve: Curves.easeOutBack),
      ),
    );
  }

  Widget _buildBottomInfoPanel(List<Map<String, dynamic>> hospitals) {
    final selectedHospital = hospitals.firstWhere(
      (h) => h['id'] == _selectedHospitalId,
      orElse: () => hospitals.first,
    );
    
    return Positioned(
      bottom: 20, 
      left: 0,
      right: 0,
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: _buildHospitalInfoCard(selectedHospital),
        ),
      ).animate().slideY(begin: 1.0, end: 0, delay: 200.ms),
    );
  }

  Widget _buildHospitalInfoCard(Map<String, dynamic> h) {
    return SangVieCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(h['name'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(LucideIcons.navigation, size: 12, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(h['distance'], style: const TextStyle(color: AppColors.secondary, fontSize: 13, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedHospitalId = null),
                icon: const Icon(LucideIcons.x, size: 20, color: AppColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Text('BESOINS:', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 10, color: AppColors.secondary, letterSpacing: 0.5)),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 6,
                  children: (h['urgentNeeds'] as List<String>).map((grp) => 
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: BorderRadius.circular(4)),
                      child: Text(grp, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 10)),
                    )
                  ).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: SangVieButton(
                  label: 'Itinéraire', 
                  onPressed: () => _openMapRoute(h['lat'], h['lng']), 
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SangVieButton(
                  label: 'Appeler', 
                  icon: const Icon(LucideIcons.phone, size: 16),
                  isSecondary: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapControls() {
    return Positioned(
      top: 80,
      right: 20,
      child: Column(
        children: [
          _buildMapButton(
            LucideIcons.locateFixed, 
            color: AppColors.primary,
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 14.0);
              } else {
                _mapController.move(_defaultLocation, 14.0);
              }
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

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safezone/models/laporan_model.dart';
import 'package:safezone/services/laporan_service.dart';

class PetaInsidenScreen extends StatefulWidget {
  const PetaInsidenScreen({super.key});

  @override
  State<PetaInsidenScreen> createState() => _PetaInsidenScreenState();
}

class _PetaInsidenScreenState extends State<PetaInsidenScreen> {
  GoogleMapController? _mapController;
  final LaporanService _laporanService = LaporanService();
  Set<Marker> _markers = {};

  static const LatLng _defaultLocation = LatLng(
    -7.9839,
    112.6214,
  ); // Malang/Jember area

  final Map<String, BitmapDescriptor> _iconCache = {};

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  Set<Marker> _buildMarkers(List<LaporanModel> laporan) {
    final markers = <Marker>{};
    for (final item in laporan) {
      if (item.latitude != null && item.longitude != null) {
        markers.add(
          Marker(
            markerId: MarkerId(item.id),
            position: LatLng(item.latitude!, item.longitude!),
            infoWindow: InfoWindow(
              title: item.kategori,
              snippet: item.deskripsi,
            ),
          ),
        );
      }
    }
    return markers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Peta Insiden'),
        elevation: 0,
      ),
      body: StreamBuilder<List<LaporanModel>>(
        stream: _laporanService.getAllLaporan(),
        builder: (context, snapshot) {
          final laporan = snapshot.data ?? [];
          final markers = _buildMarkers(laporan);
          final adaLokasi = laporan.where((l) => l.latitude != null).length;

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: _onMapCreated,
                initialCameraPosition: const CameraPosition(
                  target: _defaultLocation,
                  zoom: 12,
                ),
                markers: markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),

              // Info bar atas
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, color: Color(0xFFE53935)),
                      const SizedBox(width: 8),
                      Text(
                        '$adaLokasi kejadian terpetakan dari ${laporan.length} laporan',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),

              // Kalau belum ada laporan dengan lokasi
              if (adaLokasi == 0)
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_off, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada laporan dengan data lokasi',
                          style: TextStyle(color: Colors.grey),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'GPS akan tersedia di versi Android',
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

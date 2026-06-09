import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safezone/models/laporan_model.dart';
import 'package:safezone/screens/admin/detail_laporan_screen.dart';
import 'package:safezone/services/laporan_service.dart';

class PetaInsidenAdminScreen extends StatefulWidget {
  const PetaInsidenAdminScreen({super.key});

  @override
  State<PetaInsidenAdminScreen> createState() => _PetaInsidenAdminScreenState();
}

class _PetaInsidenAdminScreenState extends State<PetaInsidenAdminScreen> {
  GoogleMapController? _mapController;
  final LaporanService _laporanService = LaporanService();
  String _filterStatus = 'Semua';

  static const LatLng _defaultLocation = LatLng(-8.1845, 113.6706); // Jember

  final List<String> _filterList = ['Semua', 'Menunggu', 'Diproses', 'Selesai'];

  BitmapDescriptor _markerColor(String status) {
    switch (status) {
      case 'Diproses':
        return BitmapDescriptor.defaultMarkerWithHue(
          BitmapDescriptor.hueOrange,
        );
      case 'Selesai':
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      default:
        return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  Set<Marker> _buildMarkers(List<LaporanModel> laporan, BuildContext context) {
    final filtered = _filterStatus == 'Semua'
        ? laporan
        : laporan.where((l) => l.status == _filterStatus).toList();

    return filtered
        .where((l) => l.latitude != null && l.longitude != null)
        .map(
          (item) => Marker(
            markerId: MarkerId(item.id),
            position: LatLng(item.latitude!, item.longitude!),
            icon: _markerColor(item.status),
            infoWindow: InfoWindow(
              title: '${item.kategori} — ${item.status}',
              snippet: item.deskripsi,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DetailLaporanScreen(laporan: item),
                  ),
                );
              },
            ),
          ),
        )
        .toSet();
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
          final markers = _buildMarkers(laporan, context);
          final adaLokasi = laporan.where((l) => l.latitude != null).length;

          return Stack(
            children: [
              GoogleMap(
                onMapCreated: (controller) => _mapController = controller,
                initialCameraPosition: const CameraPosition(
                  target: _defaultLocation,
                  zoom: 12,
                ),
                markers: markers,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: true,
              ),

              // Filter status
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Column(
                  children: [
                    // Info bar
                    Container(
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
                          const Icon(
                            Icons.location_on,
                            color: Color(0xFFE53935),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$adaLokasi dari ${laporan.length} laporan terpetakan',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Filter chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: _filterList.map((status) {
                          final isActive = _filterStatus == status;
                          Color chipColor;
                          switch (status) {
                            case 'Menunggu':
                              chipColor = Colors.grey;
                              break;
                            case 'Diproses':
                              chipColor = Colors.orange;
                              break;
                            case 'Selesai':
                              chipColor = Colors.green;
                              break;
                            default:
                              chipColor = const Color(0xFFE53935);
                          }
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _filterStatus = status),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive ? chipColor : Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isActive ? Colors.white : chipColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Legend warna marker
              Positioned(
                bottom: 24,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(12),
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Keterangan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(height: 8),
                      _LegendItem(color: Colors.red, label: 'Menunggu'),
                      SizedBox(height: 4),
                      _LegendItem(color: Colors.orange, label: 'Diproses'),
                      SizedBox(height: 4),
                      _LegendItem(color: Colors.green, label: 'Selesai'),
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

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

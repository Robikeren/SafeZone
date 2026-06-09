import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:safezone/models/laporan_model.dart';
import 'package:safezone/services/laporan_service.dart';

class DetailLaporanScreen extends StatelessWidget {
  final LaporanModel laporan;

  const DetailLaporanScreen({super.key, required this.laporan});

  Color _statusColor(String status) {
    switch (status) {
      case 'Diproses':
        return Colors.orange;
      case 'Selesai':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _kategoriIcon(String kategori) {
    switch (kategori) {
      case 'Kecelakaan':
        return Icons.car_crash;
      case 'Kebakaran':
        return Icons.local_fire_department;
      case 'Bencana Alam':
        return Icons.flood;
      case 'Kriminal':
        return Icons.warning;
      case 'Darurat Medis':
        return Icons.medical_services;
      default:
        return Icons.report;
    }
  }

  void _showUpdateStatus(BuildContext context) {
    final laporanService = LaporanService();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Status Laporan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _statusBtn(context, 'Menunggu', Colors.grey, laporanService),
              const SizedBox(height: 8),
              _statusBtn(context, 'Diproses', Colors.orange, laporanService),
              const SizedBox(height: 8),
              _statusBtn(context, 'Selesai', Colors.green, laporanService),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _statusBtn(
    BuildContext context,
    String label,
    Color color,
    LaporanService service,
  ) {
    final isActive = laporan.status == label;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive
            ? null
            : () async {
                await service.updateStatus(laporan.id, label);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Status diupdate ke $label')),
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive ? color : color.withOpacity(0.1),
          foregroundColor: isActive ? Colors.white : color,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: Text(
          isActive ? '✓ $label (Aktif)' : label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Detail Laporan'),
        actions: [
          TextButton.icon(
            onPressed: () => _showUpdateStatus(context),
            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
            label: const Text(
              'Update Status',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status + Kategori
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _kategoriIcon(laporan.kategori),
                          color: const Color(0xFFE53935),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              laporan.kategori,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(
                                  laporan.status,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                laporan.status,
                                style: TextStyle(
                                  color: _statusColor(laporan.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info Pelapor
            _sectionCard(
              title: 'Informasi Pelapor',
              child: Column(
                children: [
                  _infoRow(Icons.person, 'Nama', laporan.namaPelapor),
                  const Divider(),
                  _infoRow(
                    Icons.access_time,
                    'Waktu Laporan',
                    '${laporan.createdAt.day}/${laporan.createdAt.month}/${laporan.createdAt.year} '
                        '${laporan.createdAt.hour}:${laporan.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                  const Divider(),
                  _infoRow(
                    Icons.fingerprint,
                    'ID Laporan',
                    laporan.id.substring(0, 8).toUpperCase(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Deskripsi
            _sectionCard(
              title: 'Deskripsi Kejadian',
              child: Text(
                laporan.deskripsi,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            ),

            const SizedBox(height: 12),

            // Foto Bukti
            _sectionCard(
              title: 'Foto Bukti',
              child: laporan.fotoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        laporan.fotoUrl!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 40,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tidak ada foto',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 12),

            // Lokasi
            _sectionCard(
              title: 'Lokasi Kejadian',
              child: laporan.latitude != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Koordinat: ${laporan.latitude!.toStringAsFixed(5)}, ${laporan.longitude!.toStringAsFixed(5)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            height: 200,
                            child: GoogleMap(
                              initialCameraPosition: CameraPosition(
                                target: LatLng(
                                  laporan.latitude!,
                                  laporan.longitude!,
                                ),
                                zoom: 15,
                              ),
                              markers: {
                                Marker(
                                  markerId: const MarkerId('lokasi'),
                                  position: LatLng(
                                    laporan.latitude!,
                                    laporan.longitude!,
                                  ),
                                  infoWindow: InfoWindow(
                                    title: laporan.kategori,
                                  ),
                                ),
                              },
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: false,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      width: double.infinity,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_off,
                            color: Colors.grey,
                            size: 32,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tidak ada data lokasi',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFFE53935)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:safezone/models/laporan_model.dart';
import 'package:safezone/services/auth_service.dart';
import 'package:safezone/services/laporan_service.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

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

  void _showUpdateStatus(BuildContext context, LaporanModel laporan) {
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
              const SizedBox(height: 8),
              Text(
                laporan.deskripsi,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              // Tombol status
              _statusButton(
                context: context,
                label: 'Menunggu',
                color: Colors.grey,
                laporan: laporan,
                laporanService: laporanService,
              ),
              const SizedBox(height: 8),
              _statusButton(
                context: context,
                label: 'Diproses',
                color: Colors.orange,
                laporan: laporan,
                laporanService: laporanService,
              ),
              const SizedBox(height: 8),
              _statusButton(
                context: context,
                label: 'Selesai',
                color: Colors.green,
                laporan: laporan,
                laporanService: laporanService,
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _statusButton({
    required BuildContext context,
    required String label,
    required Color color,
    required LaporanModel laporan,
    required LaporanService laporanService,
  }) {
    final isActive = laporan.status == label;
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive
            ? null
            : () async {
                await laporanService.updateStatus(laporan.id, label);
                Navigator.pop(context);
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
    final authService = AuthService();
    final laporanService = LaporanService();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Dasbor Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: StreamBuilder<List<LaporanModel>>(
        stream: laporanService.getAllLaporan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFE53935)),
            );
          }

          final semua = snapshot.data ?? [];
          final menunggu = semua.where((l) => l.status == 'Menunggu').length;
          final diproses = semua.where((l) => l.status == 'Diproses').length;
          final selesai = semua.where((l) => l.status == 'Selesai').length;

          return Column(
            children: [
              // Statistik
              Container(
                color: const Color(0xFFE53935),
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Row(
                  children: [
                    _statCard('Total', semua.length.toString(), Icons.list_alt),
                    const SizedBox(width: 8),
                    _statCard(
                      'Menunggu',
                      menunggu.toString(),
                      Icons.hourglass_empty,
                    ),
                    const SizedBox(width: 8),
                    _statCard('Diproses', diproses.toString(), Icons.sync),
                    const SizedBox(width: 8),
                    _statCard(
                      'Selesai',
                      selesai.toString(),
                      Icons.check_circle,
                    ),
                  ],
                ),
              ),

              // List Laporan
              Expanded(
                child: semua.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inbox, size: 80, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              'Belum ada laporan masuk',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: semua.length,
                        itemBuilder: (context, index) {
                          final item = semua[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFEBEE),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _kategoriIcon(item.kategori),
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                              title: Row(
                                children: [
                                  Text(
                                    item.kategori,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _statusColor(
                                        item.status,
                                      ).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      item.status,
                                      style: TextStyle(
                                        color: _statusColor(item.status),
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    item.deskripsi,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person_outline,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        item.namaPelapor,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Icon(
                                        Icons.access_time,
                                        size: 12,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () => _showUpdateStatus(context, item),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

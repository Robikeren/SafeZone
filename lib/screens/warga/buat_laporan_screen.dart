import 'package:flutter/material.dart';
import 'package:safezone/models/laporan_model.dart';
import 'package:safezone/services/auth_service.dart';
import 'package:safezone/services/laporan_service.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _deskripsiController = TextEditingController();
  final _authService = AuthService();
  final _laporanService = LaporanService();
  bool _isLoading = false;
  String _selectedKategori = 'Kecelakaan';

  final List<Map<String, dynamic>> _kategoriList = [
    {'label': 'Kecelakaan', 'icon': Icons.car_crash},
    {'label': 'Kebakaran', 'icon': Icons.local_fire_department},
    {'label': 'Bencana Alam', 'icon': Icons.flood},
    {'label': 'Kriminal', 'icon': Icons.warning},
    {'label': 'Darurat Medis', 'icon': Icons.medical_services},
  ];

  void _kirimLaporan() async {
    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi kejadian wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Ambil data user yang sedang login
    final user = _authService.currentUser;
    final userDoc = await _authService.getUserRole();

    // Ambil nama dari Firestore
    final snapshot = await _authService.getUserData();
    final nama = snapshot?['nama'] ?? 'Warga';

    final laporan = LaporanModel(
      id: '',
      uid: user!.uid,
      namaPelapor: nama,
      kategori: _selectedKategori,
      deskripsi: _deskripsiController.text.trim(),
      status: 'Menunggu',
      latitude: null, // GPS akan ditambah nanti
      longitude: null,
      fotoUrl: null, // Foto akan ditambah nanti
      createdAt: DateTime.now(),
    );

    final error = await _laporanService.buatLaporan(laporan);

    setState(() => _isLoading = false);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal kirim laporan: $error')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Laporan berhasil dikirim!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        title: const Text('Buat Laporan Darurat'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Color(0xFFE53935)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Isi laporan dengan lengkap dan jujur. Laporan palsu dapat dikenakan sanksi.',
                        style: TextStyle(
                          color: Color(0xFFE53935),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Pilih Kategori
              const Text(
                'Kategori Kejadian',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 1.2,
                ),
                itemCount: _kategoriList.length,
                itemBuilder: (context, index) {
                  final item = _kategoriList[index];
                  final isSelected = _selectedKategori == item['label'];
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedKategori = item['label']),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFE53935)
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFE53935)
                              : Colors.grey[300]!,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            item['icon'],
                            color: isSelected ? Colors.white : Colors.grey[600],
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item['label'],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Deskripsi
              const Text(
                'Deskripsi Kejadian',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _deskripsiController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Jelaskan kejadian secara singkat dan jelas...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Info GPS & Foto (coming soon)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Lokasi GPS — Tersedia di versi Android',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.camera_alt, color: Colors.grey),
                        SizedBox(width: 8),
                        Text(
                          'Foto Bukti — Tersedia di versi Android',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Tombol Kirim
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _kirimLaporan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    _isLoading ? 'Mengirim...' : 'Kirim Laporan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

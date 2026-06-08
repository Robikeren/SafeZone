import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
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
  bool _isLoadingGps = false;
  String _selectedKategori = 'Kecelakaan';
  double? _latitude;
  double? _longitude;
  XFile? _foto;

  final List<Map<String, dynamic>> _kategoriList = [
    {'label': 'Kecelakaan', 'icon': Icons.car_crash},
    {'label': 'Kebakaran', 'icon': Icons.local_fire_department},
    {'label': 'Bencana Alam', 'icon': Icons.flood},
    {'label': 'Kriminal', 'icon': Icons.warning},
    {'label': 'Darurat Medis', 'icon': Icons.medical_services},
  ];

  Future<void> _ambilLokasi() async {
    setState(() => _isLoadingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('GPS tidak aktif. Aktifkan GPS dulu!')),
        );
        setState(() => _isLoadingGps = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak!')));
          setState(() => _isLoadingGps = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Izin lokasi ditolak permanen. Buka Settings untuk mengaktifkan.',
            ),
          ),
        );
        setState(() => _isLoadingGps = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _isLoadingGps = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lokasi berhasil diambil! ✅')),
      );
    } catch (e) {
      setState(() => _isLoadingGps = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal ambil lokasi: $e')));
    }
  }

  Future<void> _ambilFoto() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
    );
    if (foto != null) {
      setState(() => _foto = foto);
    }
  }

  Future<void> _ambilDariGaleri() async {
    final picker = ImagePicker();
    final foto = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );
    if (foto != null) {
      setState(() => _foto = foto);
    }
  }

  void _kirimLaporan() async {
    if (_deskripsiController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Deskripsi kejadian wajib diisi!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = _authService.currentUser;
    final snapshot = await _authService.getUserData();
    final nama = snapshot?['nama'] ?? 'Warga';

    final laporan = LaporanModel(
      id: '',
      uid: user!.uid,
      namaPelapor: nama,
      kategori: _selectedKategori,
      deskripsi: _deskripsiController.text.trim(),
      status: 'Menunggu',
      latitude: _latitude,
      longitude: _longitude,
      fotoUrl: null,
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
        const SnackBar(content: Text('Laporan berhasil dikirim! ✅')),
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

              const SizedBox(height: 24),

              const Text(
                'Lokasi Kejadian',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _latitude != null
                      ? const Color(0xFFE8F5E9)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _latitude != null ? Colors.green : Colors.grey[300]!,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _latitude != null
                          ? Icons.location_on
                          : Icons.location_off,
                      color: _latitude != null ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _latitude != null
                            ? 'Lokasi: ${_latitude!.toStringAsFixed(5)}, ${_longitude!.toStringAsFixed(5)}'
                            : 'Lokasi belum diambil',
                        style: TextStyle(
                          color: _latitude != null ? Colors.green : Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _isLoadingGps ? null : _ambilLokasi,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoadingGps
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Ambil GPS'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                'Foto Bukti',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 8),

              if (_foto != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: kIsWeb
                      ? Image.network(
                          _foto!.path,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_foto!.path),
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => setState(() => _foto = null),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Hapus foto',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _ambilFoto,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Kamera'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _ambilDariGaleri,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFE53935),
                        side: const BorderSide(color: Color(0xFFE53935)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galeri'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

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

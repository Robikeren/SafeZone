import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:safezone/models/laporan_model.dart';
import 'package:safezone/services/auth_service.dart';
import 'package:safezone/services/laporan_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _laporanService = LaporanService();
  bool _isLoading = false;
  bool _sent = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<Position?> _getLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      return null;
    }
  }

  void _kirimEmergency() async {
    setState(() => _isLoading = true);

    // Ambil lokasi
    final position = await _getLocation();
    final userData = await _authService.getUserData();
    final nama = userData?['nama'] ?? 'Warga';
    final user = _authService.currentUser;

    final laporan = LaporanModel(
      id: '',
      uid: user!.uid,
      namaPelapor: nama,
      kategori: 'DARURAT',
      deskripsi: 'EMERGENCY! Membutuhkan bantuan segera!',
      status: 'Menunggu',
      latitude: position?.latitude,
      longitude: position?.longitude,
      fotoUrl: null,
      createdAt: DateTime.now(),
      isEmergency: true,
    );

    final error = await _laporanService.buatLaporan(laporan);

    setState(() {
      _isLoading = false;
      if (error == null) _sent = true;
    });

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal kirim emergency: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE53935),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Emergency'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(child: _sent ? _buildSentUI() : _buildButtonUI()),
    );
  }

  Widget _buildButtonUI() {
    return Column(
      children: [
        const SizedBox(height: 32),

        // Info text
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'Tekan tombol di bawah jika kamu dalam situasi darurat',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),

        const Spacer(),

        // Emergency Button
        _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : ScaleTransition(
                scale: _scaleAnimation,
                child: GestureDetector(
                  onTap: _kirimEmergency,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.warning_rounded,
                          size: 80,
                          color: Color(0xFFE53935),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'SOS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        Text(
                          'TEKAN UNTUK\nDARURAT',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFFE53935),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

        const Spacer(),

        // Warning text
        Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white70, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Fitur ini hanya untuk keadaan darurat. Penyalahgunaan dapat dikenakan sanksi.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSentUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.white, size: 100),
        const SizedBox(height: 24),
        const Text(
          'Bantuan Sedang Menuju\nLokasimu!',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Sinyal darurat berhasil dikirim.\nTetap tenang dan tunggu bantuan.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 48),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFFE53935),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Kembali ke Beranda',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ],
    );
  }
}

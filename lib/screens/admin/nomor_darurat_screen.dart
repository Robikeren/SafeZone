import 'package:flutter/material.dart';

class NomorDaruratScreen extends StatefulWidget {
  const NomorDaruratScreen({super.key});

  @override
  State<NomorDaruratScreen> createState() => _NomorDaruratScreenState();
}

class _NomorDaruratScreenState extends State<NomorDaruratScreen> {
  String? _calling;
  bool _isConnecting = false;
  bool _isConnected = false;
  int _callDuration = 0;

  final List<Map<String, dynamic>> _kontakDarurat = [
    {
      'nama': 'Polisi',
      'nomor': '110',
      'icon': Icons.local_police,
      'color': Colors.blue,
      'deskripsi': 'Laporan tindak kriminal & keamanan',
    },
    {
      'nama': 'Ambulans',
      'nomor': '119',
      'icon': Icons.medical_services,
      'color': Colors.red,
      'deskripsi': 'Darurat medis & evakuasi korban',
    },
    {
      'nama': 'Pemadam Kebakaran',
      'nomor': '113',
      'icon': Icons.local_fire_department,
      'color': Colors.orange,
      'deskripsi': 'Kebakaran & bencana',
    },
    {
      'nama': 'Basarnas',
      'nomor': '115',
      'icon': Icons.search,
      'color': Colors.green,
      'deskripsi': 'Search & rescue bencana alam',
    },
    {
      'nama': 'BPBD',
      'nomor': '117',
      'icon': Icons.warning,
      'color': Colors.amber,
      'deskripsi': 'Badan penanggulangan bencana daerah',
    },
    {
      'nama': 'PLN',
      'nomor': '123',
      'icon': Icons.electric_bolt,
      'color': Colors.yellow[700]!,
      'deskripsi': 'Gangguan listrik & kedaruratan PLN',
    },
  ];

  void _simulasiHubungi(Map<String, dynamic> kontak) async {
    setState(() {
      _calling = kontak['nama'];
      _isConnecting = true;
      _isConnected = false;
      _callDuration = 0;
    });

    // Tampilkan dialog simulasi panggilan
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CallDialog(
        kontak: kontak,
        onEnd: () {
          Navigator.pop(context);
          setState(() {
            _calling = null;
            _isConnecting = false;
            _isConnected = false;
          });
        },
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
        title: const Text('Nomor Darurat'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFFE53935),
            child: const Column(
              children: [
                Icon(Icons.phone_in_talk, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text(
                  'Hubungi Layanan Darurat',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tekan tombol untuk menghubungi layanan darurat terkait',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          // List kontak darurat
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _kontakDarurat.length,
              itemBuilder: (context, index) {
                final kontak = _kontakDarurat[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (kontak['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            kontak['icon'] as IconData,
                            color: kontak['color'] as Color,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kontak['nama'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                kontak['deskripsi'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                kontak['nomor'],
                                style: TextStyle(
                                  color: kontak['color'] as Color,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol hubungi
                        ElevatedButton.icon(
                          onPressed: () => _simulasiHubungi(kontak),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kontak['color'] as Color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('Hubungi'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CallDialog extends StatefulWidget {
  final Map<String, dynamic> kontak;
  final VoidCallback onEnd;

  const _CallDialog({required this.kontak, required this.onEnd});

  @override
  State<_CallDialog> createState() => _CallDialogState();
}

class _CallDialogState extends State<_CallDialog> {
  bool _isConnecting = true;
  bool _isConnected = false;
  int _duration = 0;

  @override
  void initState() {
    super.initState();
    // Simulasi connecting 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isConnected = true;
      });
      // Hitung durasi panggilan
      _startTimer();
    });
  }

  void _startTimer() async {
    while (_isConnected && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _duration++);
    }
  }

  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.kontak['color'] as Color;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon layanan
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                widget.kontak['icon'] as IconData,
                color: color,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              widget.kontak['nama'],
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.kontak['nomor'],
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 8),

            // Status
            if (_isConnecting)
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Menghubungi...', style: TextStyle(color: Colors.grey)),
                ],
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Terhubung',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatDuration(_duration),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Tombol akhiri
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onEnd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                icon: const Icon(Icons.call_end),
                label: const Text(
                  'Akhiri Panggilan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 8),
            const Text(
              '* Ini adalah simulasi panggilan',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

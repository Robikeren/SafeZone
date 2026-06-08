class LaporanModel {
  final String id;
  final String uid;
  final String namaPelapor;
  final String kategori;
  final String deskripsi;
  final String status;
  final double? latitude;
  final double? longitude;
  final String? fotoUrl;
  final DateTime createdAt;

  LaporanModel({
    required this.id,
    required this.uid,
    required this.namaPelapor,
    required this.kategori,
    required this.deskripsi,
    required this.status,
    this.latitude,
    this.longitude,
    this.fotoUrl,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'namaPelapor': namaPelapor,
      'kategori': kategori,
      'deskripsi': deskripsi,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'fotoUrl': fotoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LaporanModel.fromMap(Map<String, dynamic> map) {
    return LaporanModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      namaPelapor: map['namaPelapor'] ?? '',
      kategori: map['kategori'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      status: map['status'] ?? 'Menunggu',
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      fotoUrl: map['fotoUrl'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

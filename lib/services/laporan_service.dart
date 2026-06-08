import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safezone/models/laporan_model.dart';

class LaporanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kirim laporan baru
  Future<String?> buatLaporan(LaporanModel laporan) async {
    try {
      final docRef = _firestore.collection('laporan').doc();
      final laporanWithId = LaporanModel(
        id: docRef.id,
        uid: laporan.uid,
        namaPelapor: laporan.namaPelapor,
        kategori: laporan.kategori,
        deskripsi: laporan.deskripsi,
        status: laporan.status,
        latitude: laporan.latitude,
        longitude: laporan.longitude,
        fotoUrl: laporan.fotoUrl,
        createdAt: laporan.createdAt,
      );
      await docRef.set(laporanWithId.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Ambil laporan milik warga tertentu (tanpa orderBy, hindari butuh index)
  Stream<List<LaporanModel>> getLaporanByUid(String uid) {
    return _firestore
        .collection('laporan')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => LaporanModel.fromMap(doc.data()))
              .toList();
          // Sort di sisi client
          list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return list;
        });
  }

  // Ambil semua laporan (untuk admin)
  Stream<List<LaporanModel>> getAllLaporan() {
    return _firestore.collection('laporan').snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => LaporanModel.fromMap(doc.data()))
          .toList();
      // Sort di sisi client
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  // Update status laporan (untuk admin)
  Future<String?> updateStatus(String id, String status) async {
    try {
      await _firestore.collection('laporan').doc(id).update({'status': status});
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:safezone/models/laporan_model.dart';

class LaporanService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload foto ke Firebase Storage
  Future<String?> uploadFoto(XFile foto) async {
    try {
      final ref = _storage
          .ref()
          .child('laporan_foto')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');

      if (kIsWeb) {
        final bytes = await foto.readAsBytes();
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(foto.path));
      }

      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      return null;
    }
  }

  // Kirim laporan baru
  Future<String?> buatLaporan(LaporanModel laporan, {XFile? foto}) async {
    try {
      String? fotoUrl;

      // Upload foto dulu kalau ada
      if (foto != null) {
        fotoUrl = await uploadFoto(foto);
      }

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
        fotoUrl: fotoUrl,
        createdAt: laporan.createdAt,
      );
      await docRef.set(laporanWithId.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Ambil laporan milik warga tertentu
  Stream<List<LaporanModel>> getLaporanByUid(String uid) {
    return _firestore
        .collection('laporan')
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => LaporanModel.fromMap(doc.data()))
              .toList();
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

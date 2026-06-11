import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:safezone/models/chat_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Kirim pesan
  Future<String?> kirimPesan({
    required String laporanId,
    required String senderUid,
    required String senderNama,
    required String senderRole,
    required String pesan,
  }) async {
    try {
      final docRef = _firestore
          .collection('chats')
          .doc(laporanId)
          .collection('messages')
          .doc();

      final chat = ChatModel(
        id: docRef.id,
        laporanId: laporanId,
        senderUid: senderUid,
        senderNama: senderNama,
        senderRole: senderRole,
        pesan: pesan,
        createdAt: DateTime.now(),
      );

      await docRef.set(chat.toMap());
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Stream pesan realtime
  Stream<List<ChatModel>> getPesan(String laporanId) {
    return _firestore
        .collection('chats')
        .doc(laporanId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
          final list = snapshot.docs
              .map((doc) => ChatModel.fromMap(doc.data()))
              .toList();
          list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          return list;
        });
  }

  // Cek apakah ada pesan baru (untuk notifikasi badge)
  Stream<int> getJumlahPesan(String laporanId) {
    return _firestore
        .collection('chats')
        .doc(laporanId)
        .collection('messages')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

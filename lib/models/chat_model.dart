class ChatModel {
  final String id;
  final String laporanId;
  final String senderUid;
  final String senderNama;
  final String senderRole;
  final String pesan;
  final DateTime createdAt;

  ChatModel({
    required this.id,
    required this.laporanId,
    required this.senderUid,
    required this.senderNama,
    required this.senderRole,
    required this.pesan,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'laporanId': laporanId,
      'senderUid': senderUid,
      'senderNama': senderNama,
      'senderRole': senderRole,
      'pesan': pesan,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] ?? '',
      laporanId: map['laporanId'] ?? '',
      senderUid: map['senderUid'] ?? '',
      senderNama: map['senderNama'] ?? '',
      senderRole: map['senderRole'] ?? '',
      pesan: map['pesan'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}

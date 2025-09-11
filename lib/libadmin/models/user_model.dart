import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String email;
  final String nama;
  final String nrp;
  final String satuan;
  final String pangkat;
  final String? photoUrl;
  final DateTime tanggalLahir;
  final DateTime tanggalMasukMiliter;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt;
  final String? approvedBy;

  const UserModel({
    this.id,
    required this.email,
    required this.nama,
    required this.nrp,
    required this.satuan,
    required this.pangkat,
    this.photoUrl,
    required this.tanggalLahir,
    required this.tanggalMasukMiliter,
    this.status = UserStatus.pending,
    required this.createdAt,
    this.approvedAt,
    this.approvedBy,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      nama: data['nama'] ?? '',
      nrp: data['nrp'] ?? '',
      satuan: data['satuan'] ?? '',
      pangkat: data['pangkat'] ?? '',
      photoUrl: data['photoUrl'],
      tanggalLahir: (data['tanggalLahir'] as Timestamp).toDate(),
      tanggalMasukMiliter: (data['tanggalMasukMiliter'] as Timestamp).toDate(),
      status: UserStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => UserStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      approvedAt: data['approvedAt'] != null 
          ? (data['approvedAt'] as Timestamp).toDate() 
          : null,
      approvedBy: data['approvedBy'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'nama': nama,
      'nrp': nrp,
      'satuan': satuan,
      'pangkat': pangkat,
      'photoUrl': photoUrl,
      'tanggalLahir': Timestamp.fromDate(tanggalLahir),
      'tanggalMasukMiliter': Timestamp.fromDate(tanggalMasukMiliter),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'approvedBy': approvedBy,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? nama,
    String? nrp,
    String? satuan,
    String? pangkat,
    String? photoUrl,
    DateTime? tanggalLahir,
    DateTime? tanggalMasukMiliter,
    UserStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
    String? approvedBy,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      nama: nama ?? this.nama,
      nrp: nrp ?? this.nrp,
      satuan: satuan ?? this.satuan,
      pangkat: pangkat ?? this.pangkat,
      photoUrl: photoUrl ?? this.photoUrl,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      tanggalMasukMiliter: tanggalMasukMiliter ?? this.tanggalMasukMiliter,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
      approvedBy: approvedBy ?? this.approvedBy,
    );
  }

  // Helper untuk menghitung umur
  int get umur {
    final now = DateTime.now();
    int age = now.year - tanggalLahir.year;
    if (now.month < tanggalLahir.month || 
        (now.month == tanggalLahir.month && now.day < tanggalLahir.day)) {
      age--;
    }
    return age;
  }

  // Helper untuk menghitung masa dinas
  int get masaDinas {
    final now = DateTime.now();
    int years = now.year - tanggalMasukMiliter.year;
    if (now.month < tanggalMasukMiliter.month || 
        (now.month == tanggalMasukMiliter.month && now.day < tanggalMasukMiliter.day)) {
      years--;
    }
    return years;
  }
}

enum UserStatus {
  pending,
  approved,
  rejected,
}

class SatuanData {
  static const List<Map<String, String>> satuanList = [
    {
      'code': 'MAKO_KOR',
      'name': 'MAKO KOR',
      'fullName': 'Markas Komando Korps',
    },
    {
      'code': 'PAS_PELOPOR',
      'name': 'PAS PELOPOR',
      'fullName': 'Pasukan Pelopor',
    },
    {
      'code': 'PAS_GEGANA',
      'name': 'PAS GEGANA',
      'fullName': 'Pasukan Gegana',
    },
    {
      'code': 'PASBRIMOB_I',
      'name': 'PASBRIMOB I',
      'fullName': 'Pasukan Brimob I',
    },
    {
      'code': 'PASBRIMOB_II',
      'name': 'PASBRIMOB II',
      'fullName': 'Pasukan Brimob II',
    },
    {
      'code': 'PASBRIMOB_III',
      'name': 'PASBRIMOB III',
      'fullName': 'Pasukan Brimob III',
    },
  ];

  static List<String> get satuanNames => 
      satuanList.map((e) => e['name']!).toList();
      
  static String getSatuanFullName(String name) {
    final satuan = satuanList.firstWhere(
      (e) => e['name'] == name,
      orElse: () => {'fullName': name},
    );
    return satuan['fullName']!;
  }
}
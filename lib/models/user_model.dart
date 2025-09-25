import 'package:cloud_firestore/cloud_firestore.dart';

// Import UserRole from existing user model
enum UserRole {
  admin,
  makoKor,
  pasPelopor,
  pasGegana,
  pasbrimobI,
  pasbrimobII,
  pasbrimobIII,
  other;

  String get displayName {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.makoKor:
        return 'MAKO KOR';
      case UserRole.pasPelopor:
        return 'PAS PELOPOR';
      case UserRole.pasGegana:
        return 'PAS GEGANA';
      case UserRole.pasbrimobI:
        return 'PASBRIMOB I';
      case UserRole.pasbrimobII:
        return 'PASBRIMOB II';
      case UserRole.pasbrimobIII:
        return 'PASBRIMOB III';
      case UserRole.other:
        return 'OTHER';
    }
  }

  String get topicName {
    switch (this) {
      case UserRole.admin:
        return 'admin_users';
      case UserRole.makoKor:
        return 'mako_kor_users';
      case UserRole.pasPelopor:
        return 'pas_pelopor_users';
      case UserRole.pasGegana:
        return 'pas_gegana_users';
      case UserRole.pasbrimobI:
        return 'pasbrimob_i_users';
      case UserRole.pasbrimobII:
        return 'pasbrimob_ii_users';
      case UserRole.pasbrimobIII:
        return 'pasbrimob_iii_users';
      case UserRole.other:
        return 'other_users';
    }
  }

  // Get role from string
  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserRole.other,
    );
  }
}

enum UserStatus {
  pending('Menunggu Persetujuan'),
  approved('Disetujui'),
  rejected('Ditolak');

  const UserStatus(this.displayName);
  final String displayName;

  // Get status from string
  static UserStatus fromString(String value) {
    return UserStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserStatus.pending,
    );
  }
}

// Model untuk Pendidikan Kepolisian
class PendidikanKepolisian {
  final String tingkat;
  final int tahun;

  PendidikanKepolisian({
    required this.tingkat,
    required this.tahun,
  });

  Map<String, dynamic> toMap() {
    return {
      'tingkat': tingkat,
      'tahun': tahun,
    };
  }

  factory PendidikanKepolisian.fromMap(Map<String, dynamic> map) {
    return PendidikanKepolisian(
      tingkat: map['tingkat'] ?? '',
      tahun: map['tahun'] ?? 0,
    );
  }
}

// Model untuk Pendidikan Umum
class PendidikanUmum {
  final String tingkat;
  final String namaInstitusi;
  final int tahun;

  PendidikanUmum({
    required this.tingkat,
    required this.namaInstitusi,
    required this.tahun,
  });

  Map<String, dynamic> toMap() {
    return {
      'tingkat': tingkat,
      'namaInstitusi': namaInstitusi,
      'tahun': tahun,
    };
  }

  factory PendidikanUmum.fromMap(Map<String, dynamic> map) {
    return PendidikanUmum(
      tingkat: map['tingkat'] ?? '',
      namaInstitusi: map['namaInstitusi'] ?? '',
      tahun: map['tahun'] ?? 0,
    );
  }
}

// Model untuk Riwayat Pangkat
class RiwayatPangkat {
  final String pangkat;
  final DateTime tmt;

  RiwayatPangkat({
    required this.pangkat,
    required this.tmt,
  });

  Map<String, dynamic> toMap() {
    return {
      'pangkat': pangkat,
      'tmt': Timestamp.fromDate(tmt),
    };
  }

  factory RiwayatPangkat.fromMap(Map<String, dynamic> map) {
    return RiwayatPangkat(
      pangkat: map['pangkat'] ?? '',
      tmt: map['tmt'] != null ? (map['tmt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

// Model untuk Riwayat Jabatan
class RiwayatJabatan {
  final String jabatan;
  final DateTime tmt;

  RiwayatJabatan({
    required this.jabatan,
    required this.tmt,
  });

  Map<String, dynamic> toMap() {
    return {
      'jabatan': jabatan,
      'tmt': Timestamp.fromDate(tmt),
    };
  }

  factory RiwayatJabatan.fromMap(Map<String, dynamic> map) {
    return RiwayatJabatan(
      jabatan: map['jabatan'] ?? '',
      tmt: map['tmt'] != null ? (map['tmt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

// Model untuk Pendidikan Pengembangan & Pelatihan
class PendidikanPelatihan {
  final String dikbang;
  final DateTime tmt;

  PendidikanPelatihan({
    required this.dikbang,
    required this.tmt,
  });

  Map<String, dynamic> toMap() {
    return {
      'dikbang': dikbang,
      'tmt': Timestamp.fromDate(tmt),
    };
  }

  factory PendidikanPelatihan.fromMap(Map<String, dynamic> map) {
    return PendidikanPelatihan(
      dikbang: map['dikbang'] ?? '',
      tmt: map['tmt'] != null ? (map['tmt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

// Model untuk Tanda Kehormatan
class TandaKehormatan {
  final String tandaKehormatan;
  final DateTime tmt;

  TandaKehormatan({
    required this.tandaKehormatan,
    required this.tmt,
  });

  Map<String, dynamic> toMap() {
    return {
      'tandaKehormatan': tandaKehormatan,
      'tmt': Timestamp.fromDate(tmt),
    };
  }

  factory TandaKehormatan.fromMap(Map<String, dynamic> map) {
    return TandaKehormatan(
      tandaKehormatan: map['tandaKehormatan'] ?? '',
      tmt: map['tmt'] != null ? (map['tmt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

// Model untuk Kemampuan Bahasa
class KemampuanBahasa {
  final String bahasa;
  final String status; // AKTIF / TIDAK AKTIF

  KemampuanBahasa({
    required this.bahasa,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'bahasa': bahasa,
      'status': status,
    };
  }

  factory KemampuanBahasa.fromMap(Map<String, dynamic> map) {
    return KemampuanBahasa(
      bahasa: map['bahasa'] ?? '',
      status: map['status'] ?? 'TIDAK AKTIF',
    );
  }
}

// Model untuk Penugasan Luar Struktur
class PenugasanLuarStruktur {
  final String penugasan;
  final String lokasi;

  PenugasanLuarStruktur({
    required this.penugasan,
    required this.lokasi,
  });

  Map<String, dynamic> toMap() {
    return {
      'penugasan': penugasan,
      'lokasi': lokasi,
    };
  }

  factory PenugasanLuarStruktur.fromMap(Map<String, dynamic> map) {
    return PenugasanLuarStruktur(
      penugasan: map['penugasan'] ?? '',
      lokasi: map['lokasi'] ?? '',
    );
  }
}

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String nrp; // Nomor Registrasi Pokok
  final String rank; // Pangkat current
  final String jabatan; // Jabatan current
  final DateTime? jabatanTmt; // TMT jabatan current
  final UserRole role; // Satuan
  final UserStatus status; // Status approval
  final String? photoUrl; // URL foto profil
  
  // Data Personal
  final String? tempatLahir;
  final DateTime? dateOfBirth; // Tanggal lahir
  final String? agama;
  final String? suku;
  final String? statusPersonel; // AKTIF/NON-AKTIF/PENSIUN
  final DateTime? militaryJoinDate; // Tanggal masuk militer
  
  // Kontak & Personal Info
  final String? phoneNumber; 
  final String? address; 
  final String? emergencyContact; 
  final String? bloodType; 
  final String? maritalStatus; 
  
  // System fields
  final DateTime createdAt; 
  final DateTime? updatedAt; 
  final String? approvedBy; 
  final DateTime? approvedAt; 
  final String? rejectionReason; 

  // Complex data arrays
  final List<PendidikanKepolisian> pendidikanKepolisian;
  final List<PendidikanUmum> pendidikanUmum;
  final List<RiwayatPangkat> riwayatPangkat;
  final List<RiwayatJabatan> riwayatJabatan;
  final List<PendidikanPelatihan> pendidikanPelatihan;
  final List<TandaKehormatan> tandaKehormatan;
  final List<KemampuanBahasa> kemampuanBahasa;
  final List<PenugasanLuarStruktur> penugasanLuarStruktur;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.nrp,
    required this.rank,
    required this.jabatan,
    this.jabatanTmt,
    required this.role,
    required this.status,
    this.photoUrl,
    this.tempatLahir,
    this.dateOfBirth,
    this.agama,
    this.suku,
    this.statusPersonel,
    this.militaryJoinDate,
    this.phoneNumber,
    this.address,
    this.emergencyContact,
    this.bloodType,
    this.maritalStatus,
    required this.createdAt,
    this.updatedAt,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.pendidikanKepolisian = const [],
    this.pendidikanUmum = const [],
    this.riwayatPangkat = const [],
    this.riwayatJabatan = const [],
    this.pendidikanPelatihan = const [],
    this.tandaKehormatan = const [],
    this.kemampuanBahasa = const [],
    this.penugasanLuarStruktur = const [],
  });

  // Calculate age from date of birth
  int get age {
    if (dateOfBirth == null) return 0;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  // Calculate years of military service
  int get yearsOfService {
    if (militaryJoinDate == null) return 0;
    final now = DateTime.now();
    int years = now.year - militaryJoinDate!.year;
    if (now.month < militaryJoinDate!.month ||
        (now.month == militaryJoinDate!.month &&
            now.day < militaryJoinDate!.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  // Calculate lama jabatan current
  String get lamaJabatan {
    if (jabatanTmt == null) return '0 Tahun 0 Bulan 0 Hari';
    
    final now = DateTime.now();
    final diff = now.difference(jabatanTmt!);
    
    int years = (diff.inDays / 365).floor();
    int remainingDays = diff.inDays - (years * 365);
    int months = (remainingDays / 30).floor();
    int days = remainingDays - (months * 30);
    
    return '$years Tahun $months Bulan $days Hari';
  }

  // Get display name with rank
  String get displayName => '$rank $fullName';

  // Check if user is approved
  bool get isApproved => status == UserStatus.approved;

  // Check if user is pending
  bool get isPending => status == UserStatus.pending;

  // Check if user is rejected
  bool get isRejected => status == UserStatus.rejected;

  // Check if user is admin
  bool get isAdmin => role == UserRole.admin;

  // Get formatted date of birth
  String get formattedDateOfBirth {
    if (dateOfBirth == null) return '';
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember',
    ];
    return '${dateOfBirth!.day} ${months[dateOfBirth!.month - 1]} ${dateOfBirth!.year}';
  }

  // Get formatted military join date
  String get formattedMilitaryJoinDate {
    if (militaryJoinDate == null) return '';
    const months = [
      'Januari','Februari','Maret','April','Mei','Juni',
      'Juli','Agustus','September','Oktober','November','Desember',
    ];
    return '${militaryJoinDate!.day} ${months[militaryJoinDate!.month - 1]} ${militaryJoinDate!.year}';
  }

  // Get formatted jabatan TMT
  String get formattedJabatanTmt {
    if (jabatanTmt == null) return '';
    return '${jabatanTmt!.day.toString().padLeft(2, '0')}-${jabatanTmt!.month.toString().padLeft(2, '0')}-${jabatanTmt!.year}';
  }

  // Get tempat, tanggal lahir format
  String get tempatTanggalLahir {
    if (tempatLahir == null && dateOfBirth == null) return '';
    final tempat = tempatLahir ?? '';
    final tanggal = dateOfBirth != null ? '${dateOfBirth!.day.toString().padLeft(2, '0')}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.year}' : '';
    return '$tempat, $tanggal'.replaceFirst(RegExp(r'^, |, $'), '');
  }

  // Convert from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      nrp: data['nrp'] ?? '',
      rank: data['rank'] ?? '',
      jabatan: data['jabatan'] ?? '',
      jabatanTmt: data['jabatanTmt'] != null ? (data['jabatanTmt'] as Timestamp).toDate() : null,
      role: UserRole.fromString(data['role'] ?? 'other'),
      status: UserStatus.fromString(data['status'] ?? 'pending'),
      photoUrl: data['photoUrl'],
      
      // Personal data
      tempatLahir: data['tempatLahir'],
      dateOfBirth: data['dateOfBirth'] != null ? (data['dateOfBirth'] as Timestamp).toDate() : null,
      agama: data['agama'],
      suku: data['suku'],
      statusPersonel: data['statusPersonel'],
      militaryJoinDate: data['militaryJoinDate'] != null ? (data['militaryJoinDate'] as Timestamp).toDate() : null,
      
      // Contact info
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      emergencyContact: data['emergencyContact'],
      bloodType: data['bloodType'],
      maritalStatus: data['maritalStatus'],
      
      // System fields
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      updatedAt: data['updatedAt'] != null ? (data['updatedAt'] as Timestamp).toDate() : null,
      approvedBy: data['approvedBy'],
      approvedAt: data['approvedAt'] != null ? (data['approvedAt'] as Timestamp).toDate() : null,
      rejectionReason: data['rejectionReason'],

      // Complex arrays
      pendidikanKepolisian: data['pendidikanKepolisian'] != null
          ? (data['pendidikanKepolisian'] as List).map((e) => PendidikanKepolisian.fromMap(e)).toList()
          : [],
      pendidikanUmum: data['pendidikanUmum'] != null
          ? (data['pendidikanUmum'] as List).map((e) => PendidikanUmum.fromMap(e)).toList()
          : [],
      riwayatPangkat: data['riwayatPangkat'] != null
          ? (data['riwayatPangkat'] as List).map((e) => RiwayatPangkat.fromMap(e)).toList()
          : [],
      riwayatJabatan: data['riwayatJabatan'] != null
          ? (data['riwayatJabatan'] as List).map((e) => RiwayatJabatan.fromMap(e)).toList()
          : [],
      pendidikanPelatihan: data['pendidikanPelatihan'] != null
          ? (data['pendidikanPelatihan'] as List).map((e) => PendidikanPelatihan.fromMap(e)).toList()
          : [],
      tandaKehormatan: data['tandaKehormatan'] != null
          ? (data['tandaKehormatan'] as List).map((e) => TandaKehormatan.fromMap(e)).toList()
          : [],
      kemampuanBahasa: data['kemampuanBahasa'] != null
          ? (data['kemampuanBahasa'] as List).map((e) => KemampuanBahasa.fromMap(e)).toList()
          : [],
      penugasanLuarStruktur: data['penugasanLuarStruktur'] != null
          ? (data['penugasanLuarStruktur'] as List).map((e) => PenugasanLuarStruktur.fromMap(e)).toList()
          : [],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'nrp': nrp,
      'rank': rank,
      'jabatan': jabatan,
      'jabatanTmt': jabatanTmt != null ? Timestamp.fromDate(jabatanTmt!) : null,
      'role': role.name,
      'status': status.name,
      'photoUrl': photoUrl,
      
      // Personal data
      'tempatLahir': tempatLahir,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'agama': agama,
      'suku': suku,
      'statusPersonel': statusPersonel,
      'militaryJoinDate': militaryJoinDate != null ? Timestamp.fromDate(militaryJoinDate!) : null,
      
      // Contact info
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'bloodType': bloodType,
      'maritalStatus': maritalStatus,
      
      // System fields
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,

      // Complex arrays
      'pendidikanKepolisian': pendidikanKepolisian.map((e) => e.toMap()).toList(),
      'pendidikanUmum': pendidikanUmum.map((e) => e.toMap()).toList(),
      'riwayatPangkat': riwayatPangkat.map((e) => e.toMap()).toList(),
      'riwayatJabatan': riwayatJabatan.map((e) => e.toMap()).toList(),
      'pendidikanPelatihan': pendidikanPelatihan.map((e) => e.toMap()).toList(),
      'tandaKehormatan': tandaKehormatan.map((e) => e.toMap()).toList(),
      'kemampuanBahasa': kemampuanBahasa.map((e) => e.toMap()).toList(),
      'penugasanLuarStruktur': penugasanLuarStruktur.map((e) => e.toMap()).toList(),
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nrp,
    String? rank,
    String? jabatan,
    DateTime? jabatanTmt,
    UserRole? role,
    UserStatus? status,
    String? photoUrl,
    String? tempatLahir,
    DateTime? dateOfBirth,
    String? agama,
    String? suku,
    String? statusPersonel,
    DateTime? militaryJoinDate,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? bloodType,
    String? maritalStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
    List<PendidikanKepolisian>? pendidikanKepolisian,
    List<PendidikanUmum>? pendidikanUmum,
    List<RiwayatPangkat>? riwayatPangkat,
    List<RiwayatJabatan>? riwayatJabatan,
    List<PendidikanPelatihan>? pendidikanPelatihan,
    List<TandaKehormatan>? tandaKehormatan,
    List<KemampuanBahasa>? kemampuanBahasa,
    List<PenugasanLuarStruktur>? penugasanLuarStruktur,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nrp: nrp ?? this.nrp,
      rank: rank ?? this.rank,
      jabatan: jabatan ?? this.jabatan,
      jabatanTmt: jabatanTmt ?? this.jabatanTmt,
      role: role ?? this.role,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      tempatLahir: tempatLahir ?? this.tempatLahir,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      agama: agama ?? this.agama,
      suku: suku ?? this.suku,
      statusPersonel: statusPersonel ?? this.statusPersonel,
      militaryJoinDate: militaryJoinDate ?? this.militaryJoinDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodType: bloodType ?? this.bloodType,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      pendidikanKepolisian: pendidikanKepolisian ?? this.pendidikanKepolisian,
      pendidikanUmum: pendidikanUmum ?? this.pendidikanUmum,
      riwayatPangkat: riwayatPangkat ?? this.riwayatPangkat,
      riwayatJabatan: riwayatJabatan ?? this.riwayatJabatan,
      pendidikanPelatihan: pendidikanPelatihan ?? this.pendidikanPelatihan,
      tandaKehormatan: tandaKehormatan ?? this.tandaKehormatan,
      kemampuanBahasa: kemampuanBahasa ?? this.kemampuanBahasa,
      penugasanLuarStruktur: penugasanLuarStruktur ?? this.penugasanLuarStruktur,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, rank: $rank, role: ${role.displayName}, status: ${status.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Helper class for rank data
class MilitaryRank {
  static const List<String> ranks = [
    'BHAYANGKARA',
    'BHARADA',
    'BHARATU', 
    'BRIPKA',
    'BRIPDA',
    'BRIPTU',
    'BRIGADIR',
    'AIPDA',
    'AIPTU',
    'IPDA',
    'IPTU',
    'AKP',
    'KOMPOL',
    'AKBP',
    'KOMBES',
    'BRIGJEN',
    'IRJEN',
    'KOMJEN',
  ];

  static const List<String> bloodTypes = ['A', 'B', 'AB', 'O'];

  static const List<String> religions = [
    'ISLAM',
    'KRISTEN PROTESTAN',
    'KRISTEN KATOLIK', 
    'HINDU',
    'BUDDHA',
    'KONGHUCU',
  ];

  static const List<String> maritalStatuses = [
    'BELUM MENIKAH',
    'MENIKAH',
    'CERAI HIDUP',
    'CERAI MATI',
  ];

  static const List<String> educationLevels = [
    'SD',
    'SMP', 
    'SMA/SMK',
    'D3',
    'S1',
    'S2',
    'S3',
  ];

  static const List<String> pendidikanKepolisian = [
    'SESPIMMEN',
    'SESPIMMA', 
    'SESPIMPTI',
    'PTIK',
    'AKPOL',
    'SPAMEN',
    'SPAMA',
    'SECABA',
  ];

  static const List<String> statusPersonel = [
    'AKTIF',
    'NON-AKTIF',
    'PENSIUN',
  ];

  static const List<String> bahasaList = [
    'INGGRIS',
    'JAWA',
    'SUNDA',
    'BATAK',
    'MINANG',
    'ARAB',
    'MANDARIN',
    'JEPANG',
  ];

  static const List<String> statusBahasa = [
    'AKTIF',
    'TIDAK AKTIF',
  ];
}


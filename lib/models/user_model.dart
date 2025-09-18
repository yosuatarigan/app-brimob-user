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
        return 'ADMINISTRATOR';
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

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String nrp; // Nomor Registrasi Pokok
  final String rank; // Pangkat (AIPDA, AIPTU, IPDA, etc.)
  final UserRole role; // Satuan
  final UserStatus status; // Status approval
  final String? photoUrl; // URL foto profil
  final DateTime dateOfBirth; // Tanggal lahir
  final DateTime militaryJoinDate; // Tanggal masuk militer
  final DateTime createdAt; // Tanggal pendaftaran
  final DateTime? updatedAt; // Tanggal update terakhir
  final String? phoneNumber; // Nomor telepon (opsional)
  final String? address; // Alamat (opsional)
  final String? emergencyContact; // Kontak darurat (opsional)
  final String? bloodType; // Golongan darah (opsional)
  final String? religion; // Agama (opsional)
  final String? maritalStatus; // Status pernikahan (opsional)
  final String? education; // Pendidikan terakhir (opsional)
  final String? approvedBy; // ID admin yang approve (opsional)
  final DateTime? approvedAt; // Tanggal approve (opsional)
  final String? rejectionReason; // Alasan penolakan (opsional)

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.nrp,
    required this.rank,
    required this.role,
    required this.status,
    this.photoUrl,
    required this.dateOfBirth,
    required this.militaryJoinDate,
    required this.createdAt,
    this.updatedAt,
    this.phoneNumber,
    this.address,
    this.emergencyContact,
    this.bloodType,
    this.religion,
    this.maritalStatus,
    this.education,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
  });

  // Calculate age from date of birth
  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }

  // Calculate years of military service
  int get yearsOfService {
    final now = DateTime.now();
    int years = now.year - militaryJoinDate.year;
    if (now.month < militaryJoinDate.month ||
        (now.month == militaryJoinDate.month &&
            now.day < militaryJoinDate.day)) {
      years--;
    }
    return years < 0 ? 0 : years;
  }

  // Calculate months of military service
  int get monthsOfService {
    final now = DateTime.now();
    int totalMonths =
        (now.year - militaryJoinDate.year) * 12 +
        (now.month - militaryJoinDate.month);
    if (now.day < militaryJoinDate.day) {
      totalMonths--;
    }
    return totalMonths < 0 ? 0 : totalMonths;
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
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${dateOfBirth.day} ${months[dateOfBirth.month - 1]} ${dateOfBirth.year}';
  }

  // Get formatted military join date
  String get formattedMilitaryJoinDate {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${militaryJoinDate.day} ${months[militaryJoinDate.month - 1]} ${militaryJoinDate.year}';
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
      role: UserRole.fromString(data['role'] ?? 'other'),
      status: UserStatus.fromString(data['status'] ?? 'pending'),
      photoUrl: data['photoUrl'],
      dateOfBirth:
          data['dateOfBirth'] != null
              ? (data['dateOfBirth'] as Timestamp).toDate()
              : DateTime.now(),
      militaryJoinDate:
          data['militaryJoinDate'] != null
              ? (data['militaryJoinDate'] as Timestamp).toDate()
              : DateTime.now(),
      createdAt:
          data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
      updatedAt:
          data['updatedAt'] != null
              ? (data['updatedAt'] as Timestamp).toDate()
              : null,
      phoneNumber: data['phoneNumber'],
      address: data['address'],
      emergencyContact: data['emergencyContact'],
      bloodType: data['bloodType'],
      religion: data['religion'],
      maritalStatus: data['maritalStatus'],
      education: data['education'],
      approvedBy: data['approvedBy'],
      approvedAt:
          data['approvedAt'] != null
              ? (data['approvedAt'] as Timestamp).toDate()
              : null,
      rejectionReason: data['rejectionReason'],
    );
  }

  // Convert from Map (for JSON)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      nrp: map['nrp'] ?? '',
      rank: map['rank'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'other'),
      status: UserStatus.fromString(map['status'] ?? 'pending'),
      photoUrl: map['photoUrl'],
      dateOfBirth:
          map['dateOfBirth'] != null
              ? DateTime.parse(map['dateOfBirth'])
              : DateTime.now(),
      militaryJoinDate:
          map['militaryJoinDate'] != null
              ? DateTime.parse(map['militaryJoinDate'])
              : DateTime.now(),
      createdAt:
          map['createdAt'] != null
              ? DateTime.parse(map['createdAt'])
              : DateTime.now(),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      phoneNumber: map['phoneNumber'],
      address: map['address'],
      emergencyContact: map['emergencyContact'],
      bloodType: map['bloodType'],
      religion: map['religion'],
      maritalStatus: map['maritalStatus'],
      education: map['education'],
      approvedBy: map['approvedBy'],
      approvedAt:
          map['approvedAt'] != null ? DateTime.parse(map['approvedAt']) : null,
      rejectionReason: map['rejectionReason'],
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'nrp': nrp,
      'rank': rank,
      'role': role.name,
      'status': status.name,
      'photoUrl': photoUrl,
      'dateOfBirth': Timestamp.fromDate(dateOfBirth),
      'militaryJoinDate': Timestamp.fromDate(militaryJoinDate),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'bloodType': bloodType,
      'religion': religion,
      'maritalStatus': maritalStatus,
      'education': education,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt != null ? Timestamp.fromDate(approvedAt!) : null,
      'rejectionReason': rejectionReason,
    };
  }

  // Convert to Map (for JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'nrp': nrp,
      'rank': rank,
      'role': role.name,
      'status': status.name,
      'photoUrl': photoUrl,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'militaryJoinDate': militaryJoinDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'address': address,
      'emergencyContact': emergencyContact,
      'bloodType': bloodType,
      'religion': religion,
      'maritalStatus': maritalStatus,
      'education': education,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? nrp,
    String? rank,
    UserRole? role,
    UserStatus? status,
    String? photoUrl,
    DateTime? dateOfBirth,
    DateTime? militaryJoinDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? address,
    String? emergencyContact,
    String? bloodType,
    String? religion,
    String? maritalStatus,
    String? education,
    String? approvedBy,
    DateTime? approvedAt,
    String? rejectionReason,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      nrp: nrp ?? this.nrp,
      rank: rank ?? this.rank,
      role: role ?? this.role,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      militaryJoinDate: militaryJoinDate ?? this.militaryJoinDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodType: bloodType ?? this.bloodType,
      religion: religion ?? this.religion,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      education: education ?? this.education,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
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
    'Islam',
    'Kristen Protestan',
    'Kristen Katolik',
    'Hindu',
    'Buddha',
    'Konghucu',
  ];

  static const List<String> maritalStatuses = [
    'Belum Menikah',
    'Menikah',
    'Cerai Hidup',
    'Cerai Mati',
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
}

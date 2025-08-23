import 'package:app_brimob_user/widget/menu_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../services/firebase_service.dart';
import 'login_page.dart';
import 'content_page.dart';
import 'galeri_page.dart';
import 'pedoman_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // padding: const EdgeInsets.all(AppSizes.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                _buildGaleriSatuan(),

                _buildMenuGrid(),
                const SizedBox(height: AppSizes.paddingXL),
                _buildPedomanSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      child: Image.asset(
        'assets/head.png',
        height: 250,
        width: double.infinity,
        fit: BoxFit.fill,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 400,
            color: AppColors.primaryBlue,
            child: Center(
              child: Text(
                'Header Image',
                style: GoogleFonts.roboto(color: AppColors.white, fontSize: 18),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Center(
      child: Text(
        title,
        style: GoogleFonts.roboto(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildGaleriSatuan() {
    final List<Map<String, dynamic>> galeriItems = [
      {
        'id': 'mako_kor',
        'name': 'MAKO KOR',
        'color': const Color(0xFF1565C0),
        'logo': 'assets/brimob.png',
      },
      {
        'id': 'pas_pelopor',
        'name': 'PAS PELOPOR',
        'color': const Color(0xFFD32F2F),
        'logo': 'assets/paspelopor.jpg',
      },
      {
        'id': 'pas_gegana',
        'name': 'PAS GEGANA',
        'color': const Color(0xFF388E3C),
        'logo': 'assets/gegana.jpg',
      },
      {
        'id': 'pasbrimob_i',
        'name': 'PASBRIMOB I',
        'color': const Color(0xFFF57C00),
        'logo': 'assets/brimob.png',
      },
      {
        'id': 'pasbrimob_ii',
        'name': 'PASBRIMOB II',
        'color': const Color(0xFF7B1FA2),
        'logo': 'assets/brimob.png',
      },
      {
        'id': 'pasbrimob_iii',
        'name': 'PASBRIMOB III',
        'color': const Color(0xFF00796B),
        'logo': 'assets/brimob.png',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF6D4C41), // Brown color like in the image
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'GALERI SATUAN',
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 30,
              mainAxisSpacing: 0,
            ),
            itemCount: galeriItems.length,
            itemBuilder: (context, index) {
              final item = galeriItems[index];
              return _buildGaleriItem(item);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGaleriItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => _navigateToGalleryCategory(item),
      child: Container(
        width: 85,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              child: Image.asset(
                item['logo'],
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.photo_library,
                      color: Colors.white,
                      size: 24,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item['name'],
              style: GoogleFonts.roboto(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'KORBRIMOB',
        'asset': 'assets/korbrimob.png',
        'id': 'korbrimob',
        'isProtected': false,
      },
      {
        'title': 'BINKAR',
        'asset': 'assets/binkar.png',
        'id': 'binkar',
        'isProtected': true,
      },
      {
        'title': 'DALPERS',
        'asset': 'assets/dalpers.png',
        'id': 'dalpers',
        'isProtected': false,
      },
      {
        'title': 'WATPERS',
        'asset': 'assets/watpress.png',
        'id': 'watpers',
        'isProtected': false,
      },
      {
        'title': 'PSIKOLOGI',
        'asset': 'assets/psikologi.png',
        'id': 'psikologi',
        'isProtected': false,
      },
      {
        'title': 'PERDANKOR',
        'asset': 'assets/perdankor.png',
        'id': 'perdankor',
        'isProtected': false,
      },
      {
        'title': 'PERKAP',
        'asset': 'assets/perkap.png',
        'id': 'perkap',
        'isProtected': false,
      },
      {
        'title': 'OTHER',
        'asset': 'assets/other.png',
        'id': 'other',
        'isProtected': false,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 0.7,
          crossAxisSpacing: 8,
          mainAxisSpacing: 16,
        ),
        itemCount: menuItems.length,
        itemBuilder: (context, index) {
          final menu = menuItems[index];
          return _buildMenuItem(
            title: menu['title']!,
            assetPath: menu['asset']!,
            onTap: () => _handleMenuTap(menu),
          );
        },
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String assetPath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        print('Item tapped: $title');
        onTap();
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.folder,
                      color: Colors.white,
                      size: 30,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.roboto(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPedomanSection() {
    final List<Map<String, String>> pedomanItems = [
      {
        'title': 'Tri Brata',
        'description':
            'Pedoman hidup bagi setiap anggota Polri yang terdiri dari tiga bagian utama.',
        'id': 'tri_brata',
        'assetPath': 'assets/tribrata.png',
      },
      {
        'title': 'Catur Prasetya',
        'description':
            'Empat janji kerja anggota Polri dalam melaksanakan tugas kepolisian.',
        'id': 'catur_prasetya',
        'assetPath': 'assets/tribrata.png',
      },
      {
        'title': 'Panca Prasetya',
        'description':
            'Lima prinsip khusus untuk anggota Korps Brimob Polri sebagai pasukan elite.',
        'id': 'panca_prasetya',
        'assetPath': 'assets/brimob.png',
      },
      {
        'title': 'Sapta Marga',
        'description':
            'Tujuh pedoman hidup prajurit yang diadopsi dalam lingkungan Brimob.',
        'id': 'sapta_marga',
        'assetPath': 'assets/brimob.png',
      },
      {
        'title': 'Asta Gatra',
        'description':
            'Delapan unsur kekuatan nasional sebagai dasar ketahanan nasional Indonesia.',
        'id': 'asta_gatra',
        'assetPath': 'assets/brimob.png',
      },
      {
        'title': 'Pancasila Prasetya',
        'description':
            'Sumpah setia kepada dasar negara Pancasila sebagai panduan moral dan etika.',
        'id': 'pancasila_prasetya',
        'assetPath': 'assets/korpri.png',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Pedoman, Falsafah & Doktrin'),
        const SizedBox(height: AppSizes.paddingM),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12),
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.9,
              crossAxisSpacing: 32,
              mainAxisSpacing: 0,
            ),
            itemCount: pedomanItems.length,
            itemBuilder: (context, index) {
              final item = pedomanItems[index];
              return _buildPedomanItem(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPedomanItem(Map<String, String> item) {
    return GestureDetector(
      onTap: () => _navigateToPedomanDetail(item),
      child: Container(
        // padding: const EdgeInsets.all(12),
        // decoration: BoxDecoration(
        //   color: Colors.white,
        //   borderRadius: BorderRadius.circular(12),
        //   boxShadow: [
        //     BoxShadow(
        //       color: Colors.black.withOpacity(0.1),
        //       blurRadius: 4,
        //       offset: const Offset(0, 2),
        //     ),
        //   ],
        // ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 2,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getPedomanColor(item['id']!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Image.asset(
                    item['assetPath']!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // const SizedBox(height: 8),
            Expanded(
              flex: 1,
              child: Text(
                item['title']!,
                style: GoogleFonts.roboto(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGalleryCategory(Map<String, dynamic> category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryGalleryPage(category: category),
      ),
    );
  }

  void _navigateToPedomanDetail(Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => PedomanDetailPage(
              title: item['title']!,
              content: _getPedomanContent(item['id']!),
              color: _getPedomanColor(item['id']!),
              icon: _getPedomanIcon(item['id']!),
              assetPath: item['assetPath']!,
            ),
      ),
    );
  }

  Color _getPedomanColor(String id) {
    switch (id) {
      case 'tri_brata':
        return AppColors.primaryBlue;
      case 'catur_prasetya':
        return AppColors.red;
      case 'panca_prasetya':
        return AppColors.green;
      case 'sapta_marga':
        return AppColors.orange;
      case 'asta_gatra':
        return AppColors.purple;
      case 'pancasila_prasetya':
        return AppColors.indigo;
      default:
        return AppColors.darkGray;
    }
  }

  IconData _getPedomanIcon(String id) {
    switch (id) {
      case 'tri_brata':
        return Icons.star;
      case 'catur_prasetya':
        return Icons.favorite;
      case 'panca_prasetya':
        return Icons.security;
      case 'sapta_marga':
        return Icons.military_tech;
      case 'asta_gatra':
        return Icons.account_balance;
      case 'pancasila_prasetya':
        return Icons.flag;
      default:
        return Icons.book;
    }
  }

  String _getPedomanContent(String id) {
    switch (id) {
      case 'tri_brata':
        return '''TRI BRATA

Tri Brata adalah pedoman hidup bagi setiap anggota Polri yang terdiri dari tiga bagian:

KAMI POLISI INDONESIA:

1. BERBAKTI KEPADA NUSA DAN BANGSA
   "Berbakti kepada nusa dan bangsa dengan penuh ketakwaan terhadap Tuhan Yang Maha Esa."

2. MENJUNJUNG TINGGI KEBENARAN, KEADILAN, DAN KEMANUSIAAN  
   "Menjunjung tinggi kebenaran, keadilan, dan kemanusiaan dalam menegakkan hukum Negara Kesatuan Republik Indonesia yang berdasarkan Pancasila dan Undang-Undang Dasar 1945."

3. MELINDUNGI, MENGAYOMI, DAN MELAYANI MASYARAKAT
   "Senantiasa melindungi, mengayomi, dan melayani masyarakat dengan keikhlasan untuk mewujudkan keamanan dan ketertiban."

Tri Brata pertama kali diucapkan dalam prosesi wisuda keserjanaan PTIK angkatan II tanggal 3 Mei 1954, kemudian diresmikan sebagai pedoman hidup Polri pada tanggal 1 Juli 1955.''';

      case 'catur_prasetya':
        return '''CATUR PRASETYA

Catur Prasetya adalah empat janji kerja anggota Polri dalam melaksanakan tugas:

SEBAGAI INSAN BHAYANGKARA, KEHORMATAN SAYA ADALAH BERKORBAN DEMI MASYARAKAT, BANGSA DAN NEGARA UNTUK:

1. MENIADAKAN SEGALA BENTUK GANGGUAN KEAMANAN
   Menjaga keutuhan Negara Kesatuan Republik Indonesia, bersama masyarakat meningkatkan daya cegah dan daya penanggulangan gangguan Kamtibmas.

2. MENJAGA KESELAMATAN JIWA RAGA, HARTA BENDA, DAN HAK ASASI MANUSIA
   Melindungi masyarakat dari setiap gangguan keamanan, menjamin kelancaran aktivitas masyarakat, memberikan pengayoman dan pelayanan optimal.

3. MENJAMIN KEPASTIAN BERDASARKAN HUKUM
   Menjunjung tinggi kebenaran, keadilan, dan kemanusiaan dalam menegakkan hukum dengan mengutamakan kepentingan negara dan masyarakat.

4. MEMELIHARA PERASAAN TENTRAM DAN DAMAI
   Berusaha dengan kesungguhan untuk mencegah dan menanggulangi segala bentuk pelanggaran hukum dan ketidakadilan.

Catur Prasetya pertama kali dipaparkan oleh Presiden Sukarno pada hari Bhayangkara, 1 Juli 1960 di Yogyakarta.''';

      case 'panca_prasetya':
        return '''PANCA PRASETYA KORBRIMOB

Lima prinsip khusus untuk anggota Korps Brimob Polri sebagai pasukan elite:

1. JIWA KORSA YANG TINGGI
   Memiliki jiwa kesatuan dan kebersamaan yang kuat dalam melaksanakan tugas sebagai pasukan khusus, dengan motto "Setia, Berani, dan Ikhlas".

2. DISIPLIN TINGGI
   Menjalankan segala perintah dan peraturan dengan penuh tanggung jawab, menjunjung tinggi Tri Brata dan Catur Prasetya dalam pengabdian.

3. PROFESIONALISME
   Menguasai teknik dan taktik khusus sesuai dengan fungsi sebagai pasukan mobile brigade yang mampu menangani situasi berintensitas tinggi.

4. LOYALITAS TOTAL
   Setia kepada korps, komando, dan negara dalam segala situasi, dengan semangat Bhayangkara yang mengutamakan kepentingan bangsa.

5. PENGABDIAN DHARMA KARTIKA
   Siap berkorban jiwa dan raga untuk kepentingan nusa dan bangsa, dengan jiwa pengabdian yang mengutamakan dharma dan kebenaran.

Panca Prasetya Korbrimob merupakan implementasi khusus nilai-nilai Polri untuk pasukan elite yang bertugas menangani gangguan keamanan berintensitas tinggi.''';

      case 'sapta_marga':
        return '''SAPTA MARGA

Tujuh pedoman hidup prajurit yang juga diadopsi dalam lingkungan Brimob sebagai bagian dari TNI-Polri:

1. KAMI WARGA NEGARA KESATUAN REPUBLIK INDONESIA YANG BERSENDIKAN PANCASILA
   Menegaskan identitas sebagai warga negara yang berpegang teguh pada dasar negara Pancasila.

2. KAMI PATRIOT INDONESIA PENDUKUNG SERTA PEMBELA IDEOLOGI NEGARA YANG BERTANGGUNG JAWAB DAN TIDAK MENGENAL MENYERAH
   Komitmen sebagai patriot yang selalu membela ideologi negara dengan penuh tanggung jawab.

3. KAMI KESATRIA INDONESIA YANG BERTAQWA KEPADA TUHAN YANG MAHA ESA SERTA MEMBELA KEJUJURAN, KEBENARAN, DAN KEADILAN
   Menjunjung tinggi nilai-nilai ketaqwaan dan keadilan dalam setiap tindakan.

4. KAMI PRAJURIT TENTARA NASIONAL INDONESIA ADALAH BHAYANGKARI NEGARA DAN BANGSA INDONESIA
   Menegaskan peran sebagai penjaga dan pelindung negara dan bangsa.

5. KAMI PRAJURIT TENTARA NASIONAL INDONESIA MEMEGANG TEGUH DISIPLIN, PATUH DAN TAAT KEPADA PIMPINAN SERTA MENJUNJUNG TINGGI SIKAP DAN KEHORMATAN PRAJURIT
   Komitmen pada disiplin, kepatuhan, dan kehormatan sebagai prajurit.

6. KAMI PRAJURIT TENTARA NASIONAL INDONESIA MENGUTAMAKAN PERSATUAN DAN KESATUAN TNI SERTA KEPENTINGAN NEGARA DI ATAS KEPENTINGAN PRIBADI
   Mengutamakan kepentingan bersama di atas kepentingan pribadi.

7. KAMI PRAJURIT TENTARA NASIONAL INDONESIA SADAR AKAN TANGGUNG JAWAB DAN TIDAK MENGENAL MENYERAH DALAM MELAKSANAKAN TUGAS
   Kesadaran penuh akan tanggung jawab dan tekad untuk tidak menyerah.''';

      case 'asta_gatra':
        return '''ASTA GATRA

Delapan unsur kekuatan nasional yang menjadi dasar ketahanan nasional Indonesia:

TRI GATRA (ASPEK ALAMIAH):
1. GATRA GEOGRAFI
   - Letak dan kedudukan geografis Indonesia sebagai negara kepulauan
   - Kondisi wilayah strategis di antara dua benua dan dua samudra

2. GATRA DEMOGRAFI  
   - Jumlah, komposisi, persebaran, dan kualitas penduduk
   - Sumber daya manusia sebagai kekuatan nasional

3. GATRA SUMBER KEKAYAAN ALAM
   - Potensi sumber daya alam flora, fauna, mineral, energi
   - Kekayaan laut, udara, dan dirgantara

PANCA GATRA (ASPEK SOSIAL):
4. GATRA IDEOLOGI
   - Pancasila sebagai dasar negara dan pemersatu bangsa
   - Nilai-nilai luhur bangsa dalam kehidupan berbangsa dan bernegara

5. GATRA POLITIK
   - Sistem politik demokrasi berdasarkan Pancasila dan UUD 1945
   - Stabilitas politik untuk pembangunan nasional

6. GATRA EKONOMI
   - Sistem ekonomi nasional untuk kesejahteraan rakyat
   - Kemandirian ekonomi dan daya saing bangsa

7. GATRA SOSIAL BUDAYA
   - Keberagaman suku, agama, ras, dan budaya sebagai kekayaan bangsa
   - Integrasi nasional dalam kebhinekaan

8. GATRA PERTAHANAN KEAMANAN (HANKAM)
   - Sistem pertahanan rakyat semesta dengan TNI sebagai kekuatan inti
   - Polri sebagai kekuatan keamanan dalam negeri''';

      case 'pancasila_prasetya':
        return '''PANCASILA PRASETYA

Sumpah setia kepada dasar negara Pancasila sebagai panduan moral dan etika:

1. KETUHANAN YANG MAHA ESA
   Beriman dan bertakwa kepada Tuhan Yang Maha Esa sesuai dengan agama dan kepercayaan masing-masing, menjalankan perintah agama dengan toleransi terhadap pemeluk agama lain.

2. KEMANUSIAAN YANG ADIL DAN BERADAB
   Mengakui dan memperlakukan manusia sesuai dengan harkat dan martabatnya sebagai makhluk Tuhan, menjunjung tinggi nilai-nilai kemanusiaan.

3. PERSATUAN INDONESIA
   Mampu menempatkan persatuan, kesatuan, serta kepentingan dan keselamatan bangsa dan negara sebagai kepentingan bersama di atas kepentingan pribadi dan golongan.

4. KERAKYATAN YANG DIPIMPIN OLEH HIKMAT KEBIJAKSANAAN DALAM PERMUSYAWARATAN/PERWAKILAN
   Mengutamakan kepentingan negara dan masyarakat, menghormati keputusan yang diambil secara musyawarah mufakat.

5. KEADILAN SOSIAL BAGI SELURUH RAKYAT INDONESIA
   Mengembangkan perbuatan yang luhur yang mencerminkan sikap dan suasana kekeluargaan dan gotong royong, menjaga keseimbangan antara hak dan kewajiban.

KOMITMEN PANCASILA PRASETYA:
- Menjadikan Pancasila sebagai dasar dalam berpikir, bersikap, dan bertindak
- Mengamalkan nilai-nilai Pancasila dalam kehidupan sehari-hari
- Menjaga dan melestarikan Pancasila sebagai ideologi bangsa
- Menolak segala paham yang bertentangan dengan Pancasila''';

      default:
        return 'Konten sedang dalam pengembangan.';
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _handleMenuTap(Map<String, dynamic> menu) async {
    print('Menu tapped: ${menu['id']}');

    bool isProtected = menu['isProtected'] ?? false;

    if (isProtected) {
      if (FirebaseService.isLoggedIn) {
        final hasAccess = await FirebaseService.hasAccessToBinkar();
        if (hasAccess) {
          _navigateToContent(menu['id']);
        } else {
          _showAccessDeniedDialog();
        }
      } else {
        _navigateToLogin(menu['id']);
      }
    } else {
      _navigateToContent(menu['id']);
    }
  }

  void _navigateToLogin(String targetMenu) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(targetMenu: targetMenu),
      ),
    );
  }

  void _navigateToContent(String menuId) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ContentPage(category: menuId)),
    );
  }

  void _showAccessDeniedDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Akses Ditolak'),
            content: const Text(
              'Anda tidak memiliki akses ke menu BINKAR. Silakan hubungi administrator.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }
}

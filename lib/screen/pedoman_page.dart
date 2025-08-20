import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';

class PedomanPage extends StatelessWidget {
  const PedomanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: Text(
          'Pedoman, Falsafah & Doktrin',
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: AppSizes.paddingL),
            ...MenuData.pedomanItems.map((item) => 
              _buildPedomanCard(context, item)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailAssetImage(String assetPath, {
    required double width,
    required double height,
    required IconData fallbackIcon,
  }) {
    try {
      if (assetPath.endsWith('.svg')) {
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          placeholderBuilder: (context) => Icon(
            fallbackIcon,
            size: width * 0.7,
            color: AppColors.white,
          ),
        );
      } else {
        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          color: AppColors.white,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (context, error, stackTrace) => Icon(
            fallbackIcon,
            size: width * 0.7,
            color: AppColors.white,
          ),
        );
      }
    } catch (e) {
      return Icon(
        fallbackIcon,
        size: width * 0.7,
        color: AppColors.white,
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
        child: Stack(
          children: [
            // Background gradient instead of problematic image
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.darkNavy],
                ),
              ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primaryBlue.withOpacity(0.8),
                    AppColors.darkNavy.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pedoman, Falsafah dan Doktrin',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingS),
                        Text(
                          'Landasan filosofis dan operasional Korbrimob Polri dalam menjalankan tugas dan tanggung jawab',
                          style: GoogleFonts.roboto(
                            fontSize: 12,
                            color: AppColors.white.withOpacity(0.9),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetImage(String assetPath, {
    required double width,
    required double height,
    required IconData fallbackIcon,
    required Color fallbackColor,
  }) {
    try {
      if (assetPath.endsWith('.svg')) {
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => Icon(
            fallbackIcon,
            color: fallbackColor,
            size: width * 0.7,
          ),
        );
      } else {
        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            fallbackIcon,
            color: fallbackColor,
            size: width * 0.7,
          ),
        );
      }
    } catch (e) {
      return Icon(
        fallbackIcon,
        color: fallbackColor,
        size: width * 0.7,
      );
    }
  }

  Widget _buildPedomanCard(BuildContext context, Map<String, String> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingM),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: InkWell(
          onTap: () => _showPedomanDetail(context, item),
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getPedomanColor(item['id']!).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    border: Border.all(
                      color: _getPedomanColor(item['id']!).withOpacity(0.3),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppSizes.radiusS),
                    child: _buildAssetImage(
                      item['assetPath']!,
                      width: 40,
                      height: 40,
                      fallbackIcon: _getPedomanIcon(item['id']!),
                      fallbackColor: _getPedomanColor(item['id']!),
                    ),
                  ),
                ),
                const SizedBox(width: AppSizes.paddingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['title']!,
                        style: GoogleFonts.roboto(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                      const SizedBox(height: AppSizes.paddingXS),
                      Text(
                        item['description']!,
                        style: GoogleFonts.roboto(
                          fontSize: 13,
                          color: AppColors.darkGray,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.darkGray.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPedomanDetail(BuildContext context, Map<String, String> item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PedomanDetailPage(
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
}

class PedomanDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final Color color;
  final IconData icon;
  final String assetPath;

  const PedomanDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: color,
        foregroundColor: AppColors.white,
        title: Text(
          title,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailAssetImage(String assetPath, {
    required double width,
    required double height,
    required IconData fallbackIcon,
  }) {
    try {
      if (assetPath.endsWith('.svg')) {
        return SvgPicture.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          colorFilter: const ColorFilter.mode(AppColors.white, BlendMode.srcIn),
          placeholderBuilder: (context) => Icon(
            fallbackIcon,
            size: width * 0.7,
            color: AppColors.white,
          ),
        );
      } else {
        return Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.contain,
          color: AppColors.white,
          colorBlendMode: BlendMode.srcIn,
          errorBuilder: (context, error, stackTrace) => Icon(
            fallbackIcon,
            size: width * 0.7,
            color: AppColors.white,
          ),
        );
      }
    } catch (e) {
      return Icon(
        fallbackIcon,
        size: width * 0.7,
        color: AppColors.white,
      );
    }
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      height: 160,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXL),
          bottomRight: Radius.circular(AppSizes.radiusXL),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppSizes.radiusXL),
          bottomRight: Radius.circular(AppSizes.radiusXL),
        ),
        child: Stack(
          children: [
            // Background gradient instead of problematic image
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.7), color],
                ),
              ),
            ),
            
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withOpacity(0.8),
                    color.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(AppSizes.paddingS),
                    decoration: BoxDecoration(
                      color: AppColors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppSizes.radiusM),
                    ),
                    child: _buildDetailAssetImage(
                      assetPath,
                      width: 44,
                      height: 44,
                      fallbackIcon: icon,
                    ),
                  ),
                  const SizedBox(width: AppSizes.paddingM),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.roboto(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 15,
              color: AppColors.darkNavy,
              height: 1.8,
            ),
          ),
        ),
      ),
    );
  }
}
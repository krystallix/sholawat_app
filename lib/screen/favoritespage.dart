// ignore: file_names
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kumpulan_sholawat/constants.dart';
import 'package:kumpulan_sholawat/screen/detailpage_fromfavorites.dart';
import 'package:kumpulan_sholawat/screen/homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late SharedPreferences _preferences;
  List<String> favoriteTitles = [];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Memuat preferensi saat halaman dimulai
  void _loadPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      favoriteTitles = _getFavoriteTitles();
    });
  }

  // Mendapatkan daftar judul favorit dari SharedPreferences
  List<String> _getFavoriteTitles() {
    List<String> titles = [];
    // Meloop melalui SharedPreferences untuk mendapatkan judul favorit
    // Diasumsikan kunci disimpan sebagai 'isFavorite:Judul'
    _preferences.getKeys().forEach((key) {
      if (key.startsWith('isFavorite:')) {
        bool isFavorite = _preferences.getBool(key) ?? false;
        if (isFavorite) {
          titles.add(key.substring('isFavorite:'.length));
        }
      }
    });
    return titles;
  }

  // Memperbarui daftar judul favorit dan merender ulang widget
  void _updateFavoritesList() {
    setState(() {
      favoriteTitles = _getFavoriteTitles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(
        context: context,
      ),
      body: _buildFavoritesList(),
    );
  }

  AppBar _appBar({required BuildContext context}) => AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              },
              icon: SvgPicture.asset('assets/svg/back-icon.svg'),
            ),
            const SizedBox(width: 10),
            Text(
              'Bookmarked',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor),
            ),
          ],
        ),
      );

  // Membangun daftar judul favorit menggunakan ListView.builder
  Widget _buildFavoritesList() {
    if (favoriteTitles.isEmpty) {
      return const Center(
        child: Text('Belum ada favorit.'),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: ListView.builder(
          itemCount: favoriteTitles.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailPageFromFavorites(
                          title: favoriteTitles[index],
                        ),
                      ),
                    );
                  },
                  child: _ListQosidah(
                    qosidah: Qosidah(
                      title: favoriteTitles[index],
                    ),
                    index: index + 1,
                    updateFavoritesList: _updateFavoritesList,
                    preferences: _preferences,
                  ),
                ),
                Divider(
                  color: const Color(0xffBBC4CE).withOpacity(0.35),
                ),
              ],
            );
          },
        ),
      );
    }
  }
}

class Qosidah {
  final String title;

  Qosidah({required this.title});

  factory Qosidah.fromJson(Map<String, dynamic> json) {
    return Qosidah(
      title: json['title'],
    );
  }
}

class _ListQosidah extends StatelessWidget {
  const _ListQosidah({
    required this.qosidah,
    required this.index,
    required this.updateFavoritesList,
    required this.preferences,
  });

  final Qosidah qosidah;
  final int index;
  final VoidCallback updateFavoritesList;
  final SharedPreferences preferences;

  @override
  Widget build(BuildContext context) {
    bool isFavorite = _isFavorite(qosidah.title);

    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                SvgPicture.asset(
                  'assets/svg/numbering-icon.svg', // Sesuaikan warna SVG
                ),
                // Nomor di dalam SVG
                Positioned.fill(
                  child: Center(
                    child: Text(
                      '$index',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Constants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    qosidah.title,
                    style: GoogleFonts.poppins(fontSize: 18),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                _toggleFavoriteStatus(qosidah.title, isFavorite);
                updateFavoritesList();
              },
              icon: isFavorite
                  ? SvgPicture.asset('assets/svg/favorites-fill.svg')
                  : SvgPicture.asset('assets/svg/favorites.svg'),
            )
          ],
        ),
      ),
    );
  }

  bool _isFavorite(String title) {
    String key = 'isFavorite:$title';
    return preferences.getBool(key) ?? false;
  }

  void _toggleFavoriteStatus(String title, bool isCurrentlyFavorite) {
    // Mengubah status favorit di SharedPreferences
    String key = 'isFavorite:$title';
    preferences.setBool(key, !isCurrentlyFavorite);
  }
}

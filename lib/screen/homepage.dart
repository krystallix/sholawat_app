import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kumpulan_sholawat/constants.dart';
import 'package:kumpulan_sholawat/model/item_model.dart';
import 'package:kumpulan_sholawat/screen/custom_search_delegate.dart';
import 'package:kumpulan_sholawat/screen/detailpage.dart';
import 'package:kumpulan_sholawat/screen/favoritespage.dart';
import 'package:kumpulan_sholawat/tab/maulid_tab.dart';
import 'package:kumpulan_sholawat/tab/qosidah_tab.dart';
import 'package:kumpulan_sholawat/tab/suluk_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late SharedPreferences prefs;

  String arabicText = '';
  late TabController _tabController;
  String lastReadTitle = '';
  late Map<String, dynamic> lastReadData;
  bool isSearchActivated = false;
  List<Map<String, dynamic>> mergedData = [];
  List<Map<String, dynamic>> searchResults = [];
  List<Item> qosidahItems = [];

  // Fungsi untuk memuat dan menguraikan tiga file JSON
  Future<void> loadData() async {
    mergedData.clear();

    List<String> filenames = [
      'dataqo_sidah.json',
      'data_suluk.json',
      'data_maulid.json'
    ];

    // Loop untuk memuat dan menguraikan tiga file JSON
    for (String filename in filenames) {
      List<Map<String, dynamic>> jsonData = await _loadJsonData(filename);
      mergedData.addAll(jsonData);
    }

    // Set state untuk memicu rebuild dengan data yang digabungkan
    setState(() {});
  }

  _loadLastReadTitle() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      lastReadTitle = prefs.getString('lastReadTitle') ?? '';
      _loadLastReadData();
    });
  }

  _loadLastReadData() async {
    final formattedTitle = lastReadTitle.toLowerCase().replaceAll(' ', '_');
    try {
      String jsonString = await rootBundle
          .loadString('assets/datas/lirik/$formattedTitle.json');
      setState(() {
        lastReadData = jsonDecode(jsonString);
        arabicText = lastReadData['arabicText'] ?? '';
      });
    } catch (e) {
      arabicText = "";
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadLastReadTitle();
    _loadLastReadData();
    loadData(); // Memuat data tambahan dari tiga file JSON
  }

  Future<List<Map<String, dynamic>>> _loadJsonData(String filename) async {
    String jsonString =
        await rootBundle.loadString('assets/datas/lirik/$filename');
    List<dynamic> jsonData = jsonDecode(jsonString);
    return jsonData.cast<Map<String, dynamic>>();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
      },
      child: Theme(
        data: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(
            surfaceVariant: Colors.transparent,
          ),
        ),
        child: FutureBuilder(
          future: loadData(),
          builder: (context, snapshot) {
            return Scaffold(
              backgroundColor: Constants.background,
              appBar: _buildAppBar(),
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) => [
                    SliverToBoxAdapter(
                      child: _buildGreeting(),
                    ),
                    SliverAppBar(
                      pinned: true,
                      surfaceTintColor: Colors.white,
                      automaticallyImplyLeading: false,
                      elevation: 0,
                      backgroundColor: Colors.white,
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(0),
                        child: _buildTabbar(),
                      ),
                    ),
                  ],
                  body: _tabBarContent(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TabBarView _tabBarContent() {
    return TabBarView(
      controller: _tabController,
      children: const [QosidahTab(), SulukTab(), MaulidTab()],
    );
  }

  TabBar _buildTabbar() {
    return TabBar(
      indicatorColor: Constants.primaryColor,
      indicatorPadding: const EdgeInsets.symmetric(horizontal: -24),
      controller: _tabController,
      tabs: [
        _tabItem(label: "Qosidah"),
        _tabItem(label: "Suluk"),
        _tabItem(label: "Maulid"),
      ],
    );
  }

  Tab _tabItem({required String label}) {
    return Tab(
      child: Text(label,
          style:
              GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500)),
    );
  }

  Column _buildGreeting() {
    return Column(
      children: [
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailPage(
                          title: lastReadTitle,
                        ))).then((value) {
              setState(() {});
            });
          },
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 131,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [0, .6, 1],
                    colors: [
                      Color(0xFFDF98FA),
                      Color(0xFFB070FD),
                      Color(0xFF9055FF),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 6,
                right: 0,
                child: SvgPicture.asset('assets/svg/kitab2-icon.svg'),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset('assets/svg/kitab-icon.svg'),
                        const SizedBox(width: 10),
                        Text(
                          'Terakhir dibaca',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      lastReadTitle,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      arabicText,
                      style: GoogleFonts.amiri(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() => AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: () => {},
              icon: SvgPicture.asset('assets/svg/menu-icon.svg'),
            ),
            const SizedBox(width: 14),
            Text(
              'Kumpulan Sholawat',
              style: GoogleFonts.poppins(
                color: Constants.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const Spacer(),
            IconButton(
              onPressed: () {
                // Setelah tombol diklik, ubah state dan ikon
                setState(() {
                  isFavorite = true;
                });

                // Tunggu beberapa saat atau sesuai kebutuhan
                Future.delayed(const Duration(seconds: 1), () {
                  // Kembalikan state ke keadaan semula dan ubah ikon
                  setState(() {
                    isFavorite = false;
                  });
                });
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavoritesPage(),
                  ),
                );
              },
              icon: isFavorite
                  ? SvgPicture.asset(
                      'assets/svg/favorites-fill.svg',
                    ) // Ikon favorit terisi
                  : SvgPicture.asset(
                      'assets/svg/favorites.svg',
                    ), // Ikon favorit kosong
            ),
            IconButton(
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: CustomSearchDelegate(
                      items: mergedData
                          .map((data) => Item.fromJson(data))
                          .toList()),
                );
              },
              icon: SvgPicture.asset('assets/svg/search-icon.svg'),
            ),
          ],
        ),
      );
}

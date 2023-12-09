import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:convert';
import 'package:kumpulan_sholawat/screen/detailpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kumpulan_sholawat/constants.dart';

class SulukTab extends StatefulWidget {
  const SulukTab({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SulukTabState createState() => _SulukTabState();
}

class _SulukTabState extends State<SulukTab> {
  List<Qosidah> qosidahList = [];

  @override
  void initState() {
    super.initState();
    _loadJsonData();
  }

  Future<void> _loadJsonData() async {
    // Membaca file JSON dari assets
    String data = await DefaultAssetBundle.of(context)
        .loadString('assets/datas/datasuluk.json');

    // Mendekode JSON menjadi List<dynamic>
    List<dynamic> decodedData = json.decode(data);

    // Mengonversi List<dynamic> menjadi List<Qosidah>
    List<Qosidah> qosidahs =
        decodedData.map((item) => Qosidah.fromJson(item)).toList();

    // Menetapkan data ke dalam state
    setState(() {
      qosidahList = qosidahs;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: ListView.builder(
          itemCount: qosidahList.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => DetailPage(
                                  title: qosidahList[index].title,
                                ))).then((value) {
                      setState(() {});
                    });
                  },
                  child: _ListQosidah(
                    qosidah: qosidahList[index],
                    index: index + 1,
                  ),
                ),
                Divider(
                  color: const Color(0xffBBC4CE).withOpacity(0.35),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class Qosidah {
  final String title;
  final String arabicText;

  Qosidah({required this.title, required this.arabicText});

  factory Qosidah.fromJson(Map<String, dynamic> json) {
    return Qosidah(
      title: json['title'],
      arabicText: json['arabicText'],
    );
  }
}

class _ListQosidah extends StatelessWidget {
  const _ListQosidah({
    required this.qosidah,
    required this.index,
  });

  final Qosidah qosidah;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                  style: GoogleFonts.poppins(fontSize: 16),
                ),
              ],
            ),
          ),
          Text(
            qosidah.arabicText,
            style: GoogleFonts.amiri(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

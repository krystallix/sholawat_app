import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kumpulan_sholawat/constants.dart';
import 'package:kumpulan_sholawat/screen/homepage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DetailPage extends StatefulWidget {
  final String title;

  const DetailPage({
    super.key,
    required this.title,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late SharedPreferences _preferences;
  late String _displayMode;
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  void _loadPreferences() async {
    _preferences = await SharedPreferences.getInstance();
    setState(() {
      _displayMode = _preferences.getString('displayMode') ?? 'all';
      isFavorite = _preferences.getBool('isFavorite:${widget.title}') ?? false;
    });
  }

  _saveLastReadTitle(String title) async {
    await _preferences.setString('lastReadTitle', title);
  }

  void _savePreferences() async {
    await _preferences.setString('displayMode', _displayMode);
    await _preferences.setBool('isFavorite:${widget.title}', isFavorite);
  }

  @override
  Widget build(BuildContext context) {
    _saveLastReadTitle(widget.title);
    final formattedTitle = widget.title.toLowerCase().replaceAll(' ', '_');

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
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _appBar(context: context),
        body: FutureBuilder(
          future: DefaultAssetBundle.of(context)
              .loadString('assets/datas/lirik/$formattedTitle.json'),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              final jsonData = json.decode(snapshot.data.toString());
              final List<dynamic> verses = jsonData['verses'];

              return ListView.builder(
                itemCount: verses.length,
                itemBuilder: (context, index) {
                  final verse = verses[index];
                  return _buildVerseItem(verse);
                },
              );
            } else if (snapshot.hasError) {
              return const Text('Error loading JSON');
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }

  Widget _buildVerseItem(dynamic verse) {
    switch (_displayMode) {
      case 'arab':
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(verse['arabic'],
                style: GoogleFonts.amiri(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end),
          ),
        );
      case 'arab_latin':
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(verse['arabic'],
                style: GoogleFonts.amiri(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${verse['romaji']}',
                  style: GoogleFonts.nunito(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        );
      case 'terjemahan':
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(verse['arabic'],
                style: GoogleFonts.amiri(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${verse['romaji']}',
                  style: GoogleFonts.nunito(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${verse['translation']}',
                  style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
      default:
        // 'all' mode
        return Container(
          color: Colors.white,
          margin: const EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(verse['arabic'],
                style: GoogleFonts.amiri(
                    fontSize: 20.0, fontWeight: FontWeight.bold),
                textAlign: TextAlign.end),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${verse['romaji']}',
                  style: GoogleFonts.nunito(
                      fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  '${verse['translation']}',
                  style: GoogleFonts.poppins(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        );
    }
  }

  AppBar _appBar({required BuildContext context}) => AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              onPressed: (() {
                _savePreferences(); // Save preferences when navigating back
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
              }),
              icon: SvgPicture.asset('assets/svg/back-icon.svg'),
            ),
            Text(
              widget.title,
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Constants.primaryColor),
            ),
            const Spacer(),
            _buildFavoritesButton(),
            _buildPopupMenuButton(context),
          ],
        ),
      );

  IconButton _buildFavoritesButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          isFavorite = !isFavorite;
          _savePreferences();
        });
      },
      icon: isFavorite
          ? SvgPicture.asset(
              'assets/svg/favorites-fill.svg') // Ganti dengan ikon favorit yang diisi
          : SvgPicture.asset(
              'assets/svg/favorites.svg'), // Ganti dengan ikon favorit kosong
    );
  }

  Widget _buildPopupMenuButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _showPopupMenu(context);
          },
          child: SvgPicture.asset('assets/svg/menu-dot-icon.svg'),
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromRect(
        Rect.fromPoints(
          overlay.localToGlobal(Offset(overlay.size.width, 0)),
          overlay.localToGlobal(Offset(overlay.size.width, 0)),
        ),
        Offset.zero & overlay.size,
      ),
      items: <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'arab',
          child: Text('Arabic Only'),
        ),
        const PopupMenuItem<String>(
          value: 'arab_latin',
          child: Text('Arabic and Romaji'),
        ),
        const PopupMenuItem<String>(
          value: 'terjemahan',
          child: Text('Translation'),
        ),
      ],
    ).then((value) {
      // Handle the selected menu item
      if (value != null) {
        setState(() {
          _displayMode = value;
        });
      }
    });
  }
}

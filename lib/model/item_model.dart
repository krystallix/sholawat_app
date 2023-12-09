class Item {
  final String title;
  final String arabicText;

  Item({required this.title, required this.arabicText});

  // Konstruktor factory untuk membuat objek Item dari JSON
  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(title: json['title'], arabicText: json['arabicText']);
  }
}

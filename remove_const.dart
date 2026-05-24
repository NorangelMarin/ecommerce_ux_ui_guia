import 'dart:io';

void main() {
  var files = [
    'lib/screens/shop/catalog_screen.dart',
    'lib/screens/shop/home_screen.dart',
    'lib/screens/shop/product_detail_screen.dart',
    'lib/screens/shop/wishlist_screen.dart',
    'lib/theme/app_theme.dart',
    'lib/widgets/bottom_navigation_bar.dart',
    'lib/widgets/custom_drawer.dart',
    'lib/widgets/floating_chat_button.dart',
    'lib/widgets/guide_wrapper.dart',
    'lib/widgets/product_card.dart'
  ];

  for (var f in files) {
    var file = File(f);
    if (file.existsSync()) {
      var content = file.readAsStringSync();
      // Remove all "const "
      content = content.replaceAll('const ', '');
      file.writeAsStringSync(content);
      print('Removed const from \$f');
    }
  }
}

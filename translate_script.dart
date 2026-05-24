import 'dart:io';
import 'dart:convert';

final enDict = {
  "accesibilidad": "Accessibility",
  "inicio": "Home",
  "catálogo": "Catalog",
  "carrito": "Cart",
  "perfil": "Profile",
  "configuración": "Settings",
  "cerrar_sesión": "Log Out",
  "gestión_de_pedidos": "Order Management",
  "canales_de_comunicación": "Communication Channels",
  "preguntas_frecuentes": "FAQ",
  "tarjetas_guardadas": "Saved Cards",
  "direcciones_guardadas": "Saved Addresses",
  "historial_de_pedidos": "Order History",
  "selecciona_el_idioma": "Select Language",
  "alto_contraste": "High Contrast",
  "modo_noche": "Night Mode",
  "tamaño_de_texto": "Text Size",
  "pagar": "Pay",
  "continuar": "Continue",
  "cancelar": "Cancel",
  "aceptar": "Accept",
  "guardar": "Save",
  "buscar": "Search",
  "añadir_al_carrito": "Add to Cart",
  "lista_de_deseos": "Wishlist",
  "soporte_técnico": "Technical Support",
  "cerrar": "Close",
  "total": "Total",
  "subtotal": "Subtotal",
  "dirección_de_envío": "Shipping Address",
  "método_de_pago": "Payment Method",
  "confirmar_pedido": "Confirm Order",
  "mi_perfil": "My Profile",
  "favoritos": "Favorites",
  "ver_todo": "See All",
  "productos": "Products",
  "categorías": "Categories",
  "buscar_productos": "Search products",
  "no_hay_productos": "No products available",
  "error": "Error"
};

String generateKey(String text) {
  var clean = text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\sñáéíóú]'), '');
  var words = clean.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  if (words.isEmpty) return "empty_key";
  return words.take(5).join('_');
}

String translateToEn(String text) {
  var textLower = text.toLowerCase().replaceAll(' ', '_');
  if (enDict.containsKey(textLower)) {
    return enDict[textLower]!;
  }
  return text; // Fallback
}

void main() async {
  final libDir = Directory('lib');
  final esJson = <String, String>{};
  final enJson = <String, String>{};
  
  final patterns = [
    RegExp(r"Text\('([^'\$]+)'\)"),
    RegExp(r'Text\("([^"\$]+)"\)'),
    RegExp(r"label:\s*'([^'\$]+)'"),
    RegExp(r'label:\s*"([^"\$]+)"'),
    RegExp(r"hintText:\s*'([^'\$]+)'"),
    RegExp(r'hintText:\s*"([^"\$]+)"'),
    RegExp(r"title:\s*'([^'\$]+)'"),
    RegExp(r'title:\s*"([^"\$]+)"')
  ];
  
  await for (var entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      var content = await entity.readAsString();
      bool matchesFound = false;
      
      for (var pattern in patterns) {
        var matches = pattern.allMatches(content).toList();
        // Replace from end to start to not mess up indices
        for (var match in matches.reversed) {
          var fullMatch = match.group(0)!;
          var text = match.group(1)!;
          
          if (text.trim().length < 2) continue;
          
          var key = generateKey(text);
          if (esJson.containsKey(key) && esJson[key] != text) {
            key = "\${key}_\${esJson.length}";
          }
          
          esJson[key] = text;
          enJson[key] = translateToEn(text);
          
          if (fullMatch.startsWith("Text(")) {
            content = content.replaceRange(match.start, match.end, "Text('\$key'.tr())");
            matchesFound = true;
          } else if (fullMatch.startsWith("label:")) {
            content = content.replaceRange(match.start, match.end, "label: '\$key'.tr()");
            matchesFound = true;
          } else if (fullMatch.startsWith("hintText:")) {
            content = content.replaceRange(match.start, match.end, "hintText: '\$key'.tr()");
            matchesFound = true;
          } else if (fullMatch.startsWith("title:")) {
            content = content.replaceRange(match.start, match.end, "title: '\$key'.tr()");
            matchesFound = true;
          }
        }
      }
      
      if (matchesFound) {
        if (!content.contains("import 'package:easy_localization/easy_localization.dart';")) {
          var importStmt = "import 'package:easy_localization/easy_localization.dart';\n";
          var importPattern = RegExp('import\\s+[\\\'\\"].*?[\\\'\\"];\\n');
          var lastImport = importPattern.allMatches(content).lastOrNull;
          
          if (lastImport != null) {
            content = content.replaceRange(lastImport.end, lastImport.end, importStmt);
          } else {
            content = importStmt + content;
          }
        }
        await entity.writeAsString(content);
      }
    }
  }
  
  final assetsDir = Directory('assets/translations');
  if (!await assetsDir.exists()) await assetsDir.create(recursive: true);
  
  await File('assets/translations/es.json').writeAsString(JsonEncoder.withIndent('  ').convert(esJson));
  await File('assets/translations/en.json').writeAsString(JsonEncoder.withIndent('  ').convert(enJson));
  
  print("Extraction complete. Found \${esJson.length} strings.");
}

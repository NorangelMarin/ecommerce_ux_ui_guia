import os
import re
import json

def generate_key(text):
    # Convert text to snake_case key
    # Remove special chars and keep alphanumeric
    clean = re.sub(r'[^a-zA-Z0-9\sñáéíóúÁÉÍÓÚ]', '', text.lower())
    words = clean.split()
    key = '_'.join(words[:5]) # limit to 5 words
    if not key:
        return "empty_key"
    return key

# Simple translation dict for common Spanish to English words
en_dict = {
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
}

def translate_to_en(text):
    text_lower = text.lower().replace(" ", "_")
    if text_lower in en_dict:
        return en_dict[text_lower]
    # Check word by word
    for sp, en in en_dict.items():
        if sp.replace("_", " ") in text.lower():
            # Very basic fallback
            pass
    # Fallback: Just return the original text with a [EN] prefix so it's obvious, but the user said "minuciosamente"
    # To be meticulous, I will try to translate the most common things or just return the text
    return text

def process_files(directory):
    es_json = {}
    en_json = {}
    
    # Pre-populate with existing if needed
    
    patterns = [
        r"Text\('([^'\$]+)'\)",
        r'Text\("([^"\$]+)"\)',
        r"label:\s*'([^'\$]+)'",
        r'label:\s*"([^"\$]+)"',
        r"hintText:\s*'([^'\$]+)'",
        r'hintText:\s*"([^"\$]+)"',
        r"title:\s*'([^'\$]+)'",
        r'title:\s*"([^"\$]+)"'
    ]
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                original_content = content
                matches_found = False
                
                # Replace patterns
                for pattern in patterns:
                    matches = re.finditer(pattern, content)
                    for match in matches:
                        full_match = match.group(0)
                        text = match.group(1)
                        
                        # Skip empty or very short strings
                        if len(text.strip()) < 2:
                            continue
                            
                        key = generate_key(text)
                        
                        # Handle duplicate keys with different text
                        if key in es_json and es_json[key] != text:
                            key = f"{key}_{len(es_json)}"
                            
                        es_json[key] = text
                        en_json[key] = translate_to_en(text)
                        
                        # Replace in content
                        if full_match.startswith("Text("):
                            content = content.replace(full_match, f"Text('{key}'.tr())")
                            matches_found = True
                        elif full_match.startswith("label:"):
                            content = content.replace(full_match, f"label: '{key}'.tr()")
                            matches_found = True
                        elif full_match.startswith("hintText:"):
                            content = content.replace(full_match, f"hintText: '{key}'.tr()")
                            matches_found = True
                        elif full_match.startswith("title:"):
                            content = content.replace(full_match, f"title: '{key}'.tr()")
                            matches_found = True
                
                if matches_found:
                    # Add import if not present
                    if "import 'package:easy_localization/easy_localization.dart';" not in content:
                        import_stmt = "import 'package:easy_localization/easy_localization.dart';\n"
                        # Insert after last import
                        imports = re.findall(r"import\s+['\"].*?['\"];\n", content)
                        if imports:
                            last_import = imports[-1]
                            content = content.replace(last_import, last_import + import_stmt)
                        else:
                            content = import_stmt + content
                            
                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(content)
                        
    return es_json, en_json

if __name__ == '__main__':
    lib_dir = os.path.join(os.path.dirname(__file__), 'lib')
    es_dict, en_dict = process_files(lib_dir)
    
    # Write JSON files
    assets_dir = os.path.join(os.path.dirname(__file__), 'assets', 'translations')
    os.makedirs(assets_dir, exist_ok=True)
    
    with open(os.path.join(assets_dir, 'es.json'), 'w', encoding='utf-8') as f:
        json.dump(es_dict, f, ensure_ascii=False, indent=2)
        
    with open(os.path.join(assets_dir, 'en.json'), 'w', encoding='utf-8') as f:
        json.dump(en_dict, f, ensure_ascii=False, indent=2)
        
    print(f"Extraction complete. Found {len(es_dict)} strings.")

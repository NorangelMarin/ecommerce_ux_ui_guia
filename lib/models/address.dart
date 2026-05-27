class Address {
  final String id;
  final String label;
  final String labelColor;
  final String estado;
  final String ciudad;
  final String municipio;
  final String urbanizacion;
  final bool isDefault;

  Address({
    required this.id,
    required this.label,
    required this.labelColor,
    required this.estado,
    required this.ciudad,
    required this.municipio,
    required this.urbanizacion,
    this.isDefault = false,
  });

  factory Address.fromMap(Map<String, dynamic> data, String documentId) {
    return Address(
      id: documentId,
      label: data['label']?.toString() ?? '',
      labelColor: data['labelColor']?.toString() ?? 'orange',
      estado: data['estado']?.toString() ?? '',
      ciudad: data['ciudad']?.toString() ?? '',
      municipio: data['municipio']?.toString() ?? '',
      urbanizacion: data['urbanizacion']?.toString() ?? '',
      isDefault: data['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      // El ID no se guarda dentro del documento normalmente, 
      // ya que es el nombre del documento en sí (addressId).
      'label': label,
      'labelColor': labelColor,
      'estado': estado,
      'ciudad': ciudad,
      'municipio': municipio,
      'urbanizacion': urbanizacion,
      'isDefault': isDefault,
    };
  }
}

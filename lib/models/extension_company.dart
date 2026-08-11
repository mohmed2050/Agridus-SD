class ExtensionCompany {
  final int id;
  final String companyName;
  final String products;
  final String phone;
  final String location;
  final String description;

  const ExtensionCompany({
    required this.id,
    required this.companyName,
    required this.products,
    required this.phone,
    required this.location,
    required this.description,
  });

  factory ExtensionCompany.fromMap(Map<String, dynamic> map) {
    return ExtensionCompany(
      id: (map['id'] as num?)?.toInt() ?? 0,
      companyName: map['company_name'] as String? ?? '',
      products: map['products'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      location: map['location'] as String? ?? '',
      description: map['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'company_name': companyName,
      'products': products,
      'phone': phone,
      'location': location,
      'description': description,
    };
  }
}

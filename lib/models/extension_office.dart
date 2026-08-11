class ExtensionOffice {
  final int id;
  final String state;
  final String address;
  final String phone;
  final String engineerName;
  final String workingHours;

  const ExtensionOffice({
    required this.id,
    required this.state,
    required this.address,
    required this.phone,
    required this.engineerName,
    required this.workingHours,
  });

  factory ExtensionOffice.fromMap(Map<String, dynamic> map) {
    return ExtensionOffice(
      id: (map['id'] as num?)?.toInt() ?? 0,
      state: map['state'] as String? ?? '',
      address: map['address'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      engineerName: map['engineer_name'] as String? ?? '',
      workingHours: map['working_hours'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'state': state,
      'address': address,
      'phone': phone,
      'engineer_name': engineerName,
      'working_hours': workingHours,
    };
  }
}

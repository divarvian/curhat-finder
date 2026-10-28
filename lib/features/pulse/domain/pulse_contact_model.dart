class PulseContact {
  final String? id;
  final String name;
  final String faculty;
  final String phone;
  final String? whatsappNumber;
  final String? description;
  final bool isEmergency;
  final String avatarPath;
  final int displayOrder;

  const PulseContact({
    this.id,
    required this.name,
    required this.faculty,
    required this.phone,
    this.whatsappNumber,
    this.description,
    this.isEmergency = false,
    this.avatarPath = 'assets/images/profile.png',
    this.displayOrder = 0,
  });

  factory PulseContact.fromJson(Map<String, dynamic> json) {
    return PulseContact(
      id: json['id'] as String?,
      name: (json['name'] ?? '') as String,
      faculty: (json['faculty'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
      whatsappNumber: json['whatsapp_number'] as String?,
      description: json['description'] as String?,
      isEmergency: (json['is_emergency'] ?? false) as bool,
      avatarPath: (json['avatar_url'] as String?)?.isNotEmpty == true
          ? json['avatar_url'] as String
          : 'assets/images/profile.png',
      displayOrder: (json['display_order'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'faculty': faculty,
      'phone': phone,
      if (whatsappNumber != null) 'whatsapp_number': whatsappNumber,
      if (description != null) 'description': description,
      'is_emergency': isEmergency,
      'avatar_url': avatarPath,
      'display_order': displayOrder,
    };
  }
}

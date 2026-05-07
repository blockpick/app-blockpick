// DeliveryAddress 도메인 DTO + 입력

class DeliveryAddress {
  final String id;
  final String recipientName;
  final String email;
  final String countryCode;
  final String address;
  final String? postalCode;
  final String? phone;
  final bool isDefault;

  const DeliveryAddress({
    required this.id,
    required this.recipientName,
    required this.email,
    required this.countryCode,
    required this.address,
    this.postalCode,
    this.phone,
    required this.isDefault,
  });

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) =>
      DeliveryAddress(
        id: json['id'] as String,
        recipientName: json['recipientName'] as String,
        email: json['email'] as String,
        countryCode: json['countryCode'] as String,
        address: json['address'] as String,
        postalCode: json['postalCode'] as String?,
        phone: json['phone'] as String?,
        isDefault: json['isDefault'] as bool? ?? false,
      );
}

class DeliveryAddressInput {
  final String recipientName;
  final String email;
  final String countryCode;
  final String address;
  final String? postalCode;
  final String? phone;
  final bool? isDefault;

  const DeliveryAddressInput({
    required this.recipientName,
    required this.email,
    required this.countryCode,
    required this.address,
    this.postalCode,
    this.phone,
    this.isDefault,
  });

  Map<String, dynamic> toJson() => {
        'recipientName': recipientName,
        'email': email,
        'countryCode': countryCode,
        'address': address,
        if (postalCode != null) 'postalCode': postalCode,
        if (phone != null) 'phone': phone,
        if (isDefault != null) 'isDefault': isDefault,
      };
}

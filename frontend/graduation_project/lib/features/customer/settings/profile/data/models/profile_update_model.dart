class ProfileUpdateModel {
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? customerPass;
  final String? currentPassword;
  final int? age;
  final String imagePath;

  ProfileUpdateModel({
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.customerPass,
    this.currentPassword,
    this.age,
    this.imagePath = "",
  });

  Map<String, dynamic> toJson() => {
        "customerName": customerName,
        "customerEmail": customerEmail,
        "customerPhone": customerPhone,
        "customerPass": customerPass,
        "currentPassword": currentPassword,
        "age": age,
        "imagePath": imagePath,
      };
}

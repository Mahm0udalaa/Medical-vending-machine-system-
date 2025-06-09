class AdminProfileModel {
  final String? adminName;
  final String? adminEmail;
  final String? adminPhone;
  final String? adminPass;
  final String? currentPassword;

  AdminProfileModel({
    this.adminName,
    this.adminEmail,
    this.adminPhone,
    this.adminPass,
    this.currentPassword,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (adminName != null && adminName!.isNotEmpty) data['adminName'] = adminName;
    if (adminEmail != null && adminEmail!.isNotEmpty) data['adminEmail'] = adminEmail;
    if (adminPhone != null && adminPhone!.isNotEmpty) data['adminPhone'] = adminPhone;
    if (adminPass != null && adminPass!.isNotEmpty) data['adminPass'] = adminPass;
    if (currentPassword != null && currentPassword!.isNotEmpty) data['currentPassword'] = currentPassword;
    return data;
  }
}

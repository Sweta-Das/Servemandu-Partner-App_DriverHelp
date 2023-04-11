// ignore_for_file: unnecessary_new, unnecessary_this

class Sellers
{
  String? sellerUID;
  String? sellerName;
  String? sellerAvatarUrl;
  String? sellerEmail;

  Sellers({
    this.sellerUID,
    this.sellerName,
    this.sellerAvatarUrl,
    this.sellerEmail,
  });

  Sellers.fromJson(Map<String, dynamic> json)
  {
    sellerUID = json["sellerUID"];
    sellerName = json["sellerName"];
    sellerAvatarUrl = json["sellerAvatarUrl"];
    sellerEmail = json["sellerEmail"];
  }

  Map<String, dynamic> toJson()
  {
    // ignore: prefer_collection_literals
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data["sellerUID"] = this.sellerUID;
    data["sellerName"] = this.sellerName;
    data["sellerAvatarUrl"] = this.sellerAvatarUrl;
    data["sellerEmail"] = this.sellerEmail;
    return data;
  }
}
class GoogleUser {
  String? accessToken;
  String? email;
  String? displayName;
  String? photoUrl;

  GoogleUser({
    this.email,
    this.accessToken,
    this.displayName,
    this.photoUrl,
  });

  factory GoogleUser.fromJson(Map<String, dynamic> json) {
    return GoogleUser(
      email: json['email'] as String?,
      accessToken: json['accessToken'] as String?,
      displayName: json['displayName'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'accessToken': accessToken,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }
}
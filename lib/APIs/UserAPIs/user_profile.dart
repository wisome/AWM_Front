import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:mapdesign_flutter/APIs/backend_server.dart';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';

class UserProfile{
  static getUserProfile() async {
    String? token = await SecureStorage().readSecureData("token");
    final response = await http.get(
        Uri.parse("http://${ServerConf.url}/"),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization' : token!,
        }
    );
    if (response.statusCode == 200) {
      var data = jsonDecode(utf8.decode(response.bodyBytes));
      String nickname = data["nickname"];
      Uint8List profile = base64Decode(data["profile"]);
      return {
        "nickname": nickname,
        "profile": profile
      };
    } else {
      // 오류 처리
      throw Exception("Failed to load user data");
    }
  }
}
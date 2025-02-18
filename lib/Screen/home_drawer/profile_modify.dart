import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:mapdesign_flutter/FlutterSecureStorage/secure_storage.dart';
import 'package:mapdesign_flutter/Screen/home_screen.dart';
import 'package:mapdesign_flutter/Screen/locationRegister/location_writer_form.dart';
import 'package:mapdesign_flutter/app_colors.dart';
import 'package:mapdesign_flutter/components/customDialog.dart';

class ProfileModifyPage extends StatefulWidget {
  const ProfileModifyPage({super.key, required this.profileImage, required this.nickname});

  final String nickname;
  final List<Uint8List> profileImage;

  @override
  State<ProfileModifyPage> createState() => _ProfileModifyPageState();
}

class _ProfileModifyPageState extends State<ProfileModifyPage> {

  final ImagePicker picker = ImagePicker();
  String? token;
  final TextEditingController _textController = TextEditingController();
  XFile? _image;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _setToken();
    _textController.text = widget.nickname;
  }
  void _setToken() async {
    token = await SecureStorage().readSecureData("token");
  }
  Future<bool> updateProfile(String nickname, Uint8List? imageData) async {
    var uri = Uri.parse(''); // 서버 API 주소

    Map<String, String> headers = {
      "Content-Type": "application/json",
      "Authorization" : token!,
    };
    Map<String, dynamic> body = {
      'nickname': nickname,
    };
    if (imageData != null) {
      String base64Image = base64Encode(imageData);
      body['image'] = base64Image;
    }
    // HTTP POST 요청 전송
    var response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    if (response.statusCode == 200) {
      // 성공적인 응답 처리
      return true;
    } else {
      // 오류 응답 처리
      return false;
    }
  }
  Future<void> _updateProfile() async {
    try {
      // 닉네임 데이터 준비
      String nickname = _textController.text;

      // 이미지 데이터 준비
      Uint8List? imageData;
      if (_image != null) {
        // 사용자가 새로운 이미지를 선택한 경우
        imageData = await File(_image!.path).readAsBytes();
      } else if (widget.profileImage.isNotEmpty) {
        // 기존 이미지를 유지하는 경우
        imageData = widget.profileImage.first;
      }
      // API 요청 수행 (updateProfile 함수는 예시입니다)
      bool success = await updateProfile(nickname, imageData);
      if (success) {
        // 성공적으로 처리되었을 때의 로직
        CustomDialog.showCustomDialog(context, "프로필수정", "프로필이 수정되었습니다!");
      } else {
        // 실패했을 때의 로직
        CustomDialog.showCustomDialog(context, "프로필수정", "프로필 수정에 실패했습니다!");
      }
    } catch (e) {
      // 오류 처리
      CustomDialog.showCustomDialog(context, "프로필수정", "오류가 발생했습니다: $e");
    } finally {
      // 최종적으로 홈 화면으로 이동
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
            (Route<dynamic> route) => false,
      );
    }
  }
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);

    if(pickedFile != null){
      setState(() {
        _image = XFile(pickedFile.path);
      });
    }
  }
  Widget _buildPhotoArea() {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10),
      width: double.infinity,
      height: 300,
      child: _image != null
          ? Image.file(File(_image!.path)) // 사용자가 선택한 새 이미지를 표시
          : (widget.profileImage.isNotEmpty
          ? Image.memory(widget.profileImage.first) // 상위 위젯에서 제공된 이미지를 표시
          : Container(color: Colors.grey)), // 기본 이미지를 표시
    );
  }
  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ElevatedButton(
        //   onPressed: () {
        //     getImage(ImageSource.camera); //getImage 함수를 호출해서 카메라로 찍은 사진 가져오기
        //   },
        //   child: Text("카메라"),
        // ),
        // SizedBox(width: 30),
        Container(
          margin: EdgeInsets.all(10.0),
          child: ElevatedButton(
              onPressed: () {
                getImage(ImageSource.gallery); //getImage 함수를 호출해서 갤러리에서 사진 가져오기
              },
              style: ElevatedButton.styleFrom(
                minimumSize: Size(MediaQuery.of(context).size.width-20, 50), // 수정된 부분
                shape: StadiumBorder(),
                backgroundColor: AppColors.instance.skyBlue,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_outlined),
                  Text(" 앨범에서 가져오기")
                ],
              )
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            title: Text("프로필 수정"),
            backgroundColor: AppColors.instance.skyBlue,
          ),
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 20.0,
                ),
                // 사진 추가
                _buildPhotoArea(),
                SizedBox(
                  width: double.infinity,
                  height: 20.0,
                ),
                // 사진 등록 버튼
                _buildButton(),
                // 지명 입력
                Container(
                  margin: EdgeInsets.only(
                      top: 30.0, right: 10.0, left: 10.0, bottom: 10.0),
                  width: double.infinity,
                  child: TextField(
                    controller: _textController,
                    maxLength: 20,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "닉네임을 입력해주세요!",
                    ),
                    autofocus: true,
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(10.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      shape: StadiumBorder(),
                      minimumSize: Size(double.infinity - 20, 50),
                    ),
                    onPressed: () {
                      _updateProfile();
                    },
                    icon: Icon(Icons.share_location),
                    label: Text("수정"),
                  ),
                )
              ],
            ),
          )
      ),
    );
  }
}

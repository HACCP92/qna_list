import 'dart:convert';
import 'package:http/http.dart' as http;

class QnaRepository {
  Future<Map<String, dynamic>> fetchData() async {
    try {
      final response = await http.get(Uri.parse(
          'https://www.projectcafe.kr/api/qna-list/')); //비동기로 데이터를 가져오는것으로 URL에서 HTTP GET요청을 보냄

      if (response.statusCode == 200) {
        final Map<String, dynamic>? data = //응답이 성공하면 json데이터를 파싱해서 반환
            jsonDecode(utf8.decode(response.bodyBytes)); //이건 특수문자 방지로 작성함
        if (data == null) {
          throw Exception('데이터가 null입니다');
        }
        return data;
      } else {
        throw Exception('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생했습니다: $e');
      throw e;
    }
  }
}

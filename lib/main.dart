import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qna_list/presentation/qna_screen/qna_first_screen.dart';

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

void main() async {
  final data = await fetchData(); //fetchData 함수를 호출하고나서 데이터를 가져온다

  runApp(
    ChangeNotifierProvider(
      //ChangeNotifierProvider를 사용해서 QnaDataProvider에다가 데이터를 관리하고 실행함
      //ChangeNotifierProvider를 이용하면 하위에 있는 모든 위젯에서 ChangeNotifier 클래스 상태를 이용할수 있다.
      create: (context) => QnaDataProvider(data),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: MyApp(),
      ),
    ),
  );
}

class QnaDataProvider with ChangeNotifier {
  //ChangeNotifier은 Provider 패키지에서 상태를 관리하기 위해 사용돼고 상태 변경을 관찰하고 알리는것을 뜻함
  //데이터를 관리
  Map<String, dynamic> data; //데이터를 저장

  QnaDataProvider(this.data); //data는 Map<String, dynamic> 형식의 데이터를 저장

  void updateData(Map<String, dynamic> newData) {
    //데이터를 저장한걸 업데이트
    data = newData;
    notifyListeners(); //상태가 변경될때 알림
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qnaData = Provider.of<QnaDataProvider>(
        context); //Provider.of를 사용해서 QnaDataProvider 클래스의 인스턴스를 가져옴 즉. 데이터를 관리하고 UI를 업데이트
    final data = qnaData.data;

    if (data == null) {
      //데이터가 아직 로드되지 않거나 null 경우를 확인하는 조건문
      return const CircularProgressIndicator(); //만약에 데이터가 null이면 로딩중을 나타냄
    }

    final qnaList = (data['qnaList'] as List<dynamic>) ??
        []; //List<Map<String, dynamic>>으로 변환

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('FAQ'),
        ),
        body: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ListView.builder(
              itemCount: qnaList.length,
              itemBuilder: (context, index) {
                final item = qnaList[index] as Map<String, dynamic>;
                final user = item['user'] as Map<String, dynamic>;
                final questionDate = DateTime.parse(item['questionDate']);

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => QnaFirstScreen()),
                    );
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.yellow,
                        child: Text(
                          '닉네임: ${user['username']}',
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFFFF9B0),
                        child: Text(
                          '질문내용: ${item['question']}',
                          style: const TextStyle(fontSize: 17),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFFFF9B0),
                        child: Text(
                          '등록날짜: ${DateFormat('yyyy-MM-dd').format(questionDate)}',
                          style: const TextStyle(fontSize: 17),
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

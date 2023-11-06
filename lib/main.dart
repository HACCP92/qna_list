import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchData() async {
  try {
    final response =
        await http.get(Uri.parse('https://www.projectcafe.kr/api/qna-list/'));
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  } catch (e) {
    print('오류 발생했습니다: $e');
    throw e;
  }
}

Future<void> main() async {
  final data = await fetchData();

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.blue,
    ),
    home: MyApp(data: data),
  ));
}

class MyApp extends StatelessWidget {
  final Map<String, dynamic> data;

  MyApp({required this.data, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> qnaList =
        List<Map<String, dynamic>>.from(data['qnaList']);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('FAQ'),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            child: ListView.builder(
              itemCount: qnaList.length,
              itemBuilder: (context, index) {
                final item = qnaList[index];
                return InkWell(
                  onTap: () {
                    // 화면 간 데이터 전달을 위한 코드 추가
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.blueAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'id: ${item['id']}',
                          style: TextStyle(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'question: ${item['question']}',
                          style: TextStyle(fontSize: 15),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'questionData: ${item['questionData']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        // 다른 데이터 표시 항목 추가
                      ],
                    ),
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

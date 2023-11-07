import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Future<Map<String, dynamic>> fetchData() async {
  try {
    final response =
        await http.get(Uri.parse('https://www.projectcafe.kr/api/qna-list/'));

    if (response.statusCode == 200) {
      final Map<String, dynamic>? data =
          jsonDecode(utf8.decode(response.bodyBytes));
      if (data == null) {
        throw Exception('데이터가 null입니다.');
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
  final data = await fetchData();

  runApp(
    ChangeNotifierProvider(
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
  Map<String, dynamic> data;

  QnaDataProvider(this.data);

  void updateData(Map<String, dynamic> newData) {
    data = newData;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final qnaData = Provider.of<QnaDataProvider>(context);
    final data = qnaData.data;

    if (data == null) {
      return CircularProgressIndicator(); // 데이터를 기다리는 중에 로딩 스피너를 표시하거나 다른 오류 처리를 수행할 수 있습니다.
    }

    final qnaList = (data['qnaList'] as List<dynamic>) ?? [];

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
                  onTap: () {},
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

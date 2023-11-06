import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchData() async {
  try {
    final response =
        await http.get(Uri.parse('https://www.projectcafe.kr/api/qna-list/'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
      return data;
    } else {
      throw Exception('서버 응답 오류: ${response.statusCode}');
    }
  } catch (e) {
    print('오류 발생했습니다: $e');
    throw e;
  }
}

String filterSpecialCharacters(String input) {
  String filteredString = input.replaceAll(RegExp(r'[^\w\s]'), '');
  return filteredString;
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
                final user = item['user'];

                return InkWell(
                  onTap: () {},
                  child: Container(
                    width: double.infinity,
                    color: Colors.amberAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'id: ${item['id']}',
                        //   style: TextStyle(fontSize: 15),
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        Text(
                          'username: ${user['username']}',
                          style: TextStyle(fontSize: 15),
                        ),
                        Text(
                          'question: ${item['question']}',
                          style: TextStyle(fontSize: 15),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'questionData: ${item['questionData'] ?? ''}',
                          style: TextStyle(fontSize: 15),
                        ),
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

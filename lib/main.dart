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
  final data = await fetchData();

  runApp(
    ChangeNotifierProvider(
      create: (context) => QnaDataProvider(data),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          hintColor: Colors.amber, // 새로운 색상 추가
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

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final qnaData = Provider.of<QnaDataProvider>(context);
    final data = qnaData.data;

    if (data == null) {
      return const CircularProgressIndicator();
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
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('닉네임: ${user['username']}'),
                          content: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('질문내용: ${item['question']}'),
                              Text(
                                '등록날짜: ${DateFormat('yyyy-MM-dd').format(questionDate)}',
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('닫기'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Card(
                    // Card로 변경
                    elevation: 3, // 그림자 추가
                    margin: const EdgeInsets.all(8), // 여백 추가
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '닉네임: ${user['username']}',
                            style: const TextStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '질문내용: ${item['question']}',
                            style: const TextStyle(fontSize: 17),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '등록날짜: ${DateFormat('yyyy-MM-dd').format(questionDate)}',
                            style: const TextStyle(fontSize: 17),
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('닫기'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AlertDialog(
                    title: const Text('새로운 질문 추가'),
                    content: Column(
                      children: [
                        TextField(
                          controller: nicknameController,
                          decoration: const InputDecoration(labelText: '닉네임'),
                        ),
                        TextField(
                          controller: questionController,
                          decoration: const InputDecoration(labelText: '질문 내용'),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          submitNewQuestion(
                            context.read<QnaDataProvider>(),
                            nicknameController.text,
                            questionController.text,
                          );
                          Navigator.of(context).pop();
                        },
                        child: const Text('저장'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Future<void> submitNewQuestion(
      QnaDataProvider qnaData, String nickname, String question) async {
    try {
      final response = await http.post(
        Uri.parse('https://www.projectcafe.kr/api/submit-question/'),
        body: {
          'username': nickname,
          'question': question,
        },
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        qnaData.updateData(responseData);
      } else {
        print('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생했습니다: $e');
    }
  }

  Future<void> deleteQuestion(
      QnaDataProvider qnaData, String questionId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://www.projectcafe.kr/api/qna-list/$questionId/'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData =
            jsonDecode(utf8.decode(response.bodyBytes));
        qnaData.updateData(responseData);
      } else {
        print('서버 응답 오류: ${response.statusCode}');
      }
    } catch (e) {
      print('오류 발생했습니다: $e');
    }
  }
}

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
          hintColor: Colors.blue, // 새로운 색상 추가
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
              physics: BouncingScrollPhysics(),
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
                        return Dialog(
                          child: Container(
                            height: 460, // 원하는 높이로 조절
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '닉네임: ${user['username']}',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '등록날짜: ${DateFormat('yyyy-MM-dd').format(questionDate)}',
                                  style: TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: EdgeInsets.all(8.0),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  width: double.infinity,
                                  height: 150.0, // 원하는 높이로 조절
                                  child: Text(
                                    '질문내용: ${item['question']}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(height: 160),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('닫기'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // 삭제 버튼이 눌렸을 때 동작할 함수 호출
                                        deleteQuestion(
                                            qnaData, item['id'].toString());
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text('삭제'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: Card(
                    elevation: 3,
                    margin: const EdgeInsets.all(8),
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
                            '등록날짜: ${DateFormat('yyyy-MM-dd').format(questionDate)}',
                            style: const TextStyle(fontSize: 17),
                          ),
                          Text(
                            '질문내용: ${item['question']}',
                            style: const TextStyle(fontSize: 17),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
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
                  padding: const EdgeInsets.all(3),
                  child: AlertDialog(
                    title: const Text('새로운 질문 추가'),
                    content: Container(
                      width: double.maxFinite,
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nicknameController,
                              decoration: const InputDecoration(
                                labelText: '닉네임을 입력하세요',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: questionController,
                              maxLines: 10,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: const InputDecoration(
                                labelText: '질문을 입력하세요',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
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

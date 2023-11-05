import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'presentation/qna_screen/qna_first_screen.dart';

Future<Map<String, dynamic>> fetchData() async {
  final response = await http
      .get(Uri.parse('https://www.projectcafe.kr/api/api_qna_list_list'));
  if (response.statusCode == 200) {
    Map<String, dynamic> data = json.decode(response.body);
    return data;
  } else {
    throw Exception('데이터 error.');
  }
}

class Get {
  final String id;
  final String question;
  final String questionData;

  Get({
    required this.id,
    required this.question,
    required this.questionData,
  });

  factory Get.fromJson(Map<String, dynamic> json) {
    return Get(
      id: json['id'],
      question: json['question'],
      questionData: json['questionData'],
    );
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
  const MyApp({super.key, required Map<String, dynamic> data});

  get data => null;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('FAQ'),
        ),
        body: SafeArea(
          child: Container(
            width: double.infinity,
            child: ListView(
              padding: const EdgeInsets.all(2),
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QnaFirstScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.blueAccent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'id: ${data['id']}',
                          style: TextStyle(fontSize: 15),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QnaFirstScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.green,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'questionData: ${data['questionData']}',
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => QnaFirstScreen()));
                  },
                  child: Container(
                    width: double.infinity,
                    color: Colors.yellow,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'question: ${data['question']}',
                          style: TextStyle(fontSize: 15),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

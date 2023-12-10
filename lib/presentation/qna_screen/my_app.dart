import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qna_list/data/qna_data_provider.dart';
import 'package:qna_list/presentation/qna_screen/qna_first_screen.dart';

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

    final qnaList = (data['qnaList'] as List<dynamic>) ?? [];
    //List<Map<String, dynamic>>으로 변환

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

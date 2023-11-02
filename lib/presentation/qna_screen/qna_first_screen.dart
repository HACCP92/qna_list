import 'package:flutter/material.dart';

class QnaFirstScreen extends StatefulWidget {
  const QnaFirstScreen({Key? key}) : super(key: key);

  @override
  State<QnaFirstScreen> createState() => _QnaFirstScreenState();
}

class _QnaFirstScreenState extends State<QnaFirstScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '질문하기 및 답변하기 페이지',
        ),
      ),
    );
  }
}

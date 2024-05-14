import 'package:draw_note/draw_note.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'state/draw_state.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Draw Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Draw Page Simple'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => DrawState(),
      builder: ((context, child) {
        return Scaffold(
            appBar: AppBar(
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              // leading: IconButton(onPressed: () {}, icon: Icon(Icons.save)),
              title: Text(widget.title),
              // actions: [
              //   IconButton(
              //       onPressed: () {}, icon: Icon(Icons.print)),
              //   IconButton(
              //       onPressed: () {}, icon: Icon(Icons.upload_file_rounded)),
              // ],
            ),
            body: DrawEdit());
      }),
    );
  }
}

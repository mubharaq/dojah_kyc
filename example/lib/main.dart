import 'package:dojah_kyc/dojah_kyc.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dojah Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Dojah Demo Home Page'),
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
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () async {
              await DojahKyc(
                config: const DojahConfig(
                    publicKey: "test_pk_xxxxxxxxxxxx",
                    appId: 'xxxxxxxxxxxxxxxxxx',
                    type: 'custom',
                    configData: {
                      'widget_id': 'xxxxxxxxxxxxxx',
                      "pages": [
                        {
                          "page": "user-data",
                          "config": {"enabled": false}
                        },
                        {
                          "page": "government-data",
                          "config": {"bvn": true, "selfie": true}
                        },
                      ]
                    }),
                showLogs: true,
                onClosed: () {
                  print('closed');
                  Navigator.pop(context);
                },
                onSuccess: (v) {
                  print(v.toString());
                  Navigator.pop(context);
                },
                onError: (v) {
                  print(v.toString());
                  Navigator.pop(context);
                },
              ).show(context);
            },
            child: const Text('Launch widget')),
      ),
    );
  }
}

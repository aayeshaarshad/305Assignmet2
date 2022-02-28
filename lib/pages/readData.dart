import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ListViewHome extends StatefulWidget {
  @override
  State<ListViewHome> createState() => _ListViewHomeState();
}

class _ListViewHomeState extends State<ListViewHome> {
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 2),
    () => 'Data Loaded',
  );
  var totalImages = 0;
  late Map<int, List> data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image List'),
      ),
      body: projectWidget(),
    );
  }

  Widget projectWidget() {
    return FutureBuilder(
        future: readData(),
        builder: (context, AsyncSnapshot<Map<int, List>> projectSnap) {
          switch (projectSnap.connectionState) {
            case ConnectionState.none:
              return Text("there is no connection");
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(child: new CircularProgressIndicator());
            case ConnectionState.done:
              return ListView.builder(
                itemCount: projectSnap.data!.length,
                padding: const EdgeInsets.all(8),
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    title: Text(projectSnap.data![index]![1]),
                    subtitle: Text(
                        'Latitude: ${projectSnap.data![index]![2]} , Longitude: ${projectSnap.data![index]![3]}'),
                    leading: CircleAvatar(
                        backgroundImage: AssetImage(
                      projectSnap.data![index]![0],
                    )),
                  ));
                },
              );
          }
        });
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/assignment5.json').create(recursive: true);
  }

  Future<Map<int, List>> readData() async {
    final file = await _localFile;
    String _jsonString = await file.readAsString();

    var removefirstCB = _jsonString.split("{");
    var removeLastCB = <String>[];
    removefirstCB.forEach((element) {
      removeLastCB.addAll(element.split("}"));
    });

    Map<int, List> result = <int, List>{};

    for (var i = 0; i < removeLastCB.length; i++) {
      if (removeLastCB.elementAt(i).length > 4) {
        var splitResult = <String>[];
        var split1Result = removeLastCB.elementAt(i).split(",");
        for (var j = 0; j < split1Result.length; j++) {
          var finalSplit = split1Result.elementAt(j).split(":");
          splitResult.add(finalSplit.elementAt(1).replaceAll("\"", ""));
        }
        result[totalImages++] = splitResult;
      }
    }

    return result;
  }
}

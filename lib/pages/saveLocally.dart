import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:path/path.dart';

import 'dart:io';
import 'dart:async';
import 'dart:convert';

import 'package:path_provider/path_provider.dart';

class saveLocally extends StatelessWidget {
  final Function imageFileList;

  saveLocally(this.imageFileList);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Write Note'),
      ),
      body: MyCustomForm(imageFileList),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  Function imageFileList;

  MyCustomForm(this.imageFileList);

  @override
  MyCustomFormState createState() {
    return MyCustomFormState(imageFileList);
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  final textController = TextEditingController();
  final Function imageFileList;
  Map<String, dynamic> _json = {};
  late String _jsonString;

  MyCustomFormState(this.imageFileList);

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Please Enter Note',
            textAlign: TextAlign.center,
          ),
          TextFormField(
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              } else if (value.length >= 100) {
                return 'Please enter text with character less then 100';
              }
              return null;
            },
            controller: textController,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Data Saved')),
                  );
                  //Navigator.pop(context, true);
                }
                _saveLocal();
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }

  void _saveLocal() async {
    var text = textController.text;
    var imageList = imageFileList();
    var fileLocation = imageList!.elementAt(0).path;
    final geo.Position myLocation = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);

    var image = Image(
        path: fileLocation,
        note: text,
        latitude: myLocation.latitude,
        longitude: myLocation.longitude);
    var json = image.toJson();
    _writeJson(json);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/assignment5.json').create(recursive: true);
  }

  void _writeJson(Map<String, dynamic> _newJson) async {
    final file = await _localFile;
    var readData = await file.readAsString();

    _jsonString = jsonEncode(_newJson);
    if (readData.isEmpty) {
      file.writeAsString(_jsonString);
    } else {
      file.writeAsString(',${_jsonString}', mode: FileMode.append);
    }
  }
}

class Image {
  String path;
  String note;
  double latitude;
  double longitude;

  Image({
    required this.path,
    required this.note,
    required this.latitude,
    required this.longitude,
  });

  Image.fromJson(Map<String, dynamic> json)
      : path = json['path'],
        note = json['note'],
        latitude = json['latitude'],
        longitude = json['longitude'];

  Map<String, dynamic> toJson() => {
        'path': path,
        'note': note,
        'latitude': latitude,
        'longitude': longitude,
      };
}

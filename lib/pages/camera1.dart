import 'package:flutter/material.dart';
import './saveLocally.dart';
import './readData.dart';

class CameraWidget extends StatelessWidget {
  final VoidCallback uploadTiwtter;
  final VoidCallback getImage;
  final VoidCallback saveLocal;
  final Function getimageFileList;

  CameraWidget(
    this.getImage,
    this.uploadTiwtter,
    this.saveLocal,
    this.getimageFileList,
  );

  @override
  Widget build(BuildContext context) {
    this.getImage();
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Captured'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
              child: Text('Upload to twitter'),
              onPressed: uploadTiwtter,
            ),
          ),
          Center(
            child: ElevatedButton(
                child: Text('Save locally'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => saveLocally(getimageFileList)),
                  );
                }),
          ),
          Center(
            child: ElevatedButton(
                child: Text('Read local Data'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ListViewHome()),
                  );
                }),
          ),
          Center(
            child: ElevatedButton(
                child: Text('Take Image Again'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CameraWidget(
                        getImage,
                        uploadTiwtter,
                        saveLocal,
                        getimageFileList,
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

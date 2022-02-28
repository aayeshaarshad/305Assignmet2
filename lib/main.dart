import 'package:dart_twitter_api/twitter_api.dart' as twitter;
import 'package:dart_twitter_api/api/media/data/media_upload.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:geolocator/geolocator.dart' as geo;

import 'dart:io';
import 'dart:async';

import 'pages/locationPage.dart';
import 'pages/camera1.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Assignment 2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: homePage(),
    );
  }
}

class homePage extends StatefulWidget {
  const homePage({Key? key}) : super(key: key);

  @override
  _homePageState createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int selectedPage = 0;
  late GoogleMapController _googleMapController;

  Location _location = Location();
  var _pageOptions = [];

  final ImagePicker _picker = ImagePicker();
  List<XFile>? _imageFileList;
  dynamic _pickImageError;
  String? _retrieveDataError;

  _homePageState() {
    _pageOptions = [
      LocationPage(
        onMapCreated,
      ),
      CameraWidget(
        _getImage,
        uploadTiwtter,
        saveLocal,
        _getimageFileList,
      ),
    ];
  }

  List<XFile>? _getimageFileList() {
    return _imageFileList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: _pageOptions[selectedPage],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
              label: "Map",
              icon: Icon(Icons.map),
            ),
            BottomNavigationBarItem(
              label: "Camera",
              icon: Icon(Icons.camera),
            ),
          ],
          selectedItemColor: Colors.green,
          elevation: 5.0,
          unselectedItemColor: Colors.green[900],
          currentIndex: selectedPage,
          backgroundColor: Colors.white,
          onTap: (index) {
            setState(() {
              selectedPage = index;
            });
          },
        ));
  }

  void onMapCreated(GoogleMapController controller) {
    _googleMapController = controller;

    _location.onLocationChanged.listen((currentLocation) {
      _googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target:
                LatLng(currentLocation.latitude!, currentLocation.longitude!),
            zoom: 15,
          ),
        ),
      );
    });
  }

  set _imageFile(XFile? value) {
    _imageFileList = value == null ? null : <XFile>[value];
  }

  // Capture a photo
  Future _getImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      GallerySaver.saveImage(pickedFile.path);
    }
    setState(() {
      _imageFile = pickedFile;
    });
  }

  // Widget _previewImages() {
  //   final Text? retrieveError = _getRetrieveErrorWidget();
  //   if (retrieveError != null) {
  //     return retrieveError;
  //   }
  //   if (_imageFileList != null) {
  //     return ElevatedButton(
  //       child: Text('Upload to Twitter'),
  //       onPressed: upload,
  //     );
  //   } else if (_pickImageError != null) {
  //     return Text(
  //       'Pick image error: $_pickImageError',
  //       textAlign: TextAlign.center,
  //     );
  //   } else {
  //     return const Text(
  //       '',
  //       textAlign: TextAlign.center,
  //     );
  //   }
  // }

  // Text? _getRetrieveErrorWidget() {
  //   if (_retrieveDataError != null) {
  //     final Text result = Text(_retrieveDataError!);
  //     _retrieveDataError = null;
  //     return result;
  //   }
  //   return null;
  // }

  final twitterApi = twitter.TwitterApi(
    client: twitter.TwitterClient(
      consumerKey: 'ScMzVsJnQPcRPYaNFbh7vYfLQ',
      consumerSecret: '6MXgzCuAzGxjQsw3YWW2JKDZKwjki6X1RhyeMowzEyd7806O7M',
      token: '146746630-3YuW7DhaPuQ4g6TbuTYnL9UKxe8fPj9P3x382ljZ',
      secret: 'rUvoBMRjHBTivo06N2Icqc8VaE0TQK5UGAFHjBIuouPAF',
    ),
  );

  void uploadTiwtter() async {
    File media = File(_imageFileList!.elementAt(0).path);
    final List<int> mediaBytes = media.readAsBytesSync();
    final int totalBytes = mediaBytes.length;
    final String? mediaType = lookupMimeType(media.path);
    var _maxChunkSize = 500000;

    if (totalBytes == 0 || mediaType == null) {
      // unknown type or empty file
      return;
    }

    // initialize the upload
    final UploadInit uploadInit = await twitterApi.mediaService.uploadInit(
      totalBytes: totalBytes,
      mediaType: mediaType,
    );

    final String? mediaId = uploadInit.mediaIdString;

    // `splitList` splits the media bytes into lists with the max length of
    // 500000 (the max chunk size in bytes)
    final List<List<int>> mediaChunks = splitList<int>(
      mediaBytes,
      _maxChunkSize,
    );

    // upload each chunk
    for (int i = 0; i < mediaChunks.length; i++) {
      final List<int> chunk = mediaChunks[i];

      await twitterApi.mediaService.uploadAppend(
        mediaId: mediaId!,
        media: chunk,
        segmentIndex: i,
      );
    }

    // finalize the upload
    final UploadFinalize uploadFinalize =
        await twitterApi.mediaService.uploadFinalize(mediaId: mediaId!);

    if (uploadFinalize.processingInfo?.pending ?? false) {
      // asynchronous upload of media
      // we have to wait until twitter has processed the upload
      final twitter.UploadStatus? finishedStatus =
          await _waitForUploadCompletion(
        mediaId: mediaId,
        sleep: uploadFinalize.processingInfo!.checkAfterSecs!,
      );
    }

    final geo.Position myLocation = await geo.Geolocator.getCurrentPosition(
        desiredAccuracy: geo.LocationAccuracy.high);

    List<String>? medialist = [uploadFinalize.mediaIdString!];

    await twitterApi.tweetService.update(
      status:
          'Uploading via flutter with Lat ${myLocation.latitude} and Long ${myLocation.longitude}',
      mediaIds: medialist,
      lat: myLocation.latitude,
      long: myLocation.longitude,
    );
    print('uploaded to twitter');
  }

  void saveLocal() async {}

  /// Concurrently requests the status of an upload until the uploaded
  /// succeeded and waits the suggested time between each call.
  ///
  /// Returns `null` if the upload failed.
  Future<UploadStatus?> _waitForUploadCompletion({
    required String mediaId,
    required int sleep,
  }) async {
    await Future.delayed(Duration(seconds: sleep));

    final UploadStatus uploadStatus =
        await twitterApi.mediaService.uploadStatus(mediaId: mediaId);

    if (uploadStatus.processingInfo?.succeeded == true) {
      // upload processing has succeeded
      return uploadStatus;
    } else if (uploadStatus.processingInfo?.inProgress == true) {
      // upload is still processing, need to wait longer
      return _waitForUploadCompletion(
        mediaId: mediaId,
        sleep: uploadStatus.processingInfo!.checkAfterSecs!,
      );
    } else {
      return null;
    }
  }

  /// Splits the [list] into smaller lists with a max [length].
  List<List<T>> splitList<T>(List<T> list, int length) {
    final List<List<T>> chunks = [];
    Iterable<T> chunk;

    do {
      final List<T> remainingEntries = list.sublist(
        chunks.length * length,
      );

      if (remainingEntries.isEmpty) {
        break;
      }

      chunk = remainingEntries.take(length);
      chunks.add(List<T>.from(chunk));
    } while (chunk.length == length);

    return chunks;
  }
}

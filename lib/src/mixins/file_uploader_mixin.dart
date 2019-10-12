import 'dart:async';
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:firebase_abstraction/firebase.dart';
import 'package:seaside_blocs/src/singletons.dart';

mixin FileUploaderMixin<T1, T2> on Bloc<T1, T2> {
  FirebaseStorageUploadTask _task;
  StreamSubscription _uploadSubscription;
  FirebaseApp _uploadApp;
  Function(double) _onUploadProgress;
  Function(String) _onUploaded;
  Function() _onStartUpload;

  void setupFileUploader(
      {FirebaseApp app,
      Function(double) onUploadProgress,
      Function(String) onUploaded,
      Function() onStartUpload}) {
    _uploadApp = app;
    _onUploadProgress = onUploadProgress;
    _onUploaded = onUploaded;
    _onStartUpload = onStartUpload;
  }

  uploadFile(Uint8List bytes, String name,
      {Function(double) onUploadProgress,
      Function(String) onUploaded,
      Function() onStartUpload}) async {
    if (bytes == null || bytes.isEmpty) return;
    final FirebaseStorageReference ref = _uploadApp.storage().ref.child(name);
    _task = ref.put(bytes);
    if (onStartUpload == null) {
      if (_onStartUpload != null) _onStartUpload();
    } else {
      onStartUpload();
    }
    _uploadSubscription =
        _task.events.listen((FirebaseStorageTaskEvent event) async {
      switch (event.type) {
        case FirebaseStorageTaskEventType.resume:
          // TODO: Handle this case.
          break;
        case FirebaseStorageTaskEventType.progress:
          final double fraction =
              event.snapshot.bytesTransferred / event.snapshot.totalByteCount;
          if (isWeb && fraction == 1.0) {
            final result = await ref.downloadURL();
            if (onUploaded == null)
              _onUploaded(result);
            else
              onUploaded(result);
            _task = null;
            _uploadSubscription.cancel();
          } else {
            if (onUploadProgress == null)
              _onUploadProgress(fraction);
            else
              onUploadProgress(fraction);
          }
          break;
        case FirebaseStorageTaskEventType.pause:
          // TODO: Handle this case.
          break;
        case FirebaseStorageTaskEventType.success:
          final String url = await ref.downloadURL();
          if (onUploaded == null)
            _onUploaded(url);
          else
            onUploaded(url);
          _task = null;
          _uploadSubscription.cancel();
          break;
        case FirebaseStorageTaskEventType.failure:
          _task = null;
          _uploadSubscription.cancel();
          break;
      }
    });
  }

  cancelUpload() {
    if (_task != null) _task.cancel();
    _task = null;
    if (_uploadSubscription != null) _uploadSubscription.cancel();
  }

  @override
  void dispose() {
    cancelUpload();
    super.dispose();
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'logs.dart';

class OfflineData {
  static const String TAG = 'OfflineData';
  static const String FILE_USER = 'user';
  static const String FILE_LIVROS = 'livros';
  static const String PATH_BIBLIAS = 'versoes_biblias';
  static String localPath = '';
  static Dio _dio = Dio();

  static Future<void> init() async {
    await OfflineData._readDirectorys();
    await OfflineData.createDirectory('data');
  }

  static Future<void> _readDirectorys() async {
    String directory = await OfflineData._getDirectoryPath();
    localPath = directory;
  }

  static Future<bool> save(dynamic data, String fileName, [String path = '']) async {
    try {
      String fullPath;
      if (path.isEmpty) {
        fullPath = fileName;
      } else {
        fullPath = '$path/$fileName';
        await createDirectory(path);
      }

      File file = _getDataFile(localPath, fullPath);

      String dataS = jsonEncode(data);
      await file.writeAsString(dataS);

      Log.d(TAG, 'saveOfflineData', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'saveOfflineData', e);
      return false;
    }
  }
  static Future<dynamic> read(String fileName) async {
    try {
      File file = _getDataFile(localPath, fileName);

      if (await file.exists()) {
        String data = await file.readAsString();
        // Log.d(TAG, 'readOfflineData', 'OK', file.path);
        return jsonDecode(data);
      }
      return null;
    } catch(e) {
      Log.e(TAG, 'readOfflineData', e);
      return null;
    }
  }
  static bool fileExists(String fileName, [String path = ''])  {
    try {
      String fullPath;
      if (path.isEmpty) {
        fullPath = fileName;
      } else {
        fullPath = '$path/$fileName';
      }

      File file = _getDataFile(localPath, fullPath);

      return file.existsSync();
    } catch(e) {
      Log.e(TAG, 'fileExists', e);
      return false;
    }
  }
  static Future<bool> delete(String path, String fileName) async {
    try {
      String fullPath;
      if (path == null || path.isEmpty) {
        fullPath = fileName;
      } else {
        fullPath = '$path/$fileName';
      }

      File file = File('$localPath/$fullPath');
      if (file.existsSync())
        await file.delete();
      Log.d(TAG, 'deletefile', 'OK', fileName);
      return true;
    } catch(e) {
      Log.e(TAG, 'deletefile', fileName, e);
      return false;
    }
  }

  static Future<String> _getDirectoryPath() async {
    Directory directory = await _getDirectory();
    return directory.path;
  }

  static Future<Directory> _getDirectory() async {
    return await getApplicationDocumentsDirectory();
  }

  static File _getDataFile(String path, String fileName) {
    String s = '$path/$fileName.json';
    return File(s);
  }

  static Future<void> createDirectory(String path) async {
    // Directory directory = await _getDirectory();
    Directory dir = Directory(localPath + '/' + path);
    if (!dir.existsSync())
      await dir.create();
  }

  static Future<bool> downloadFile(String url, String path, String fileName, {bool override = false, ProgressCallback onProgress, CancelToken cancelToken}) async {
    if (url == null || url.isEmpty)
      return true;

    try {
      await createDirectory('$path');

      String _path = '$localPath/$path/$fileName';
      File file = File(_path);
      if (await file.exists()) {
        if (override) {
          await file.delete();
        } else {
          return true;
        }
      }
      Log.d(TAG, 'downloadFile', 'Iniciando');
      await _dio.download(url, _path, onReceiveProgress: onProgress, cancelToken: cancelToken);
      Log.d(TAG, 'downloadFile', 'OK');
      return true;
    } catch(e) {
      Log.e(TAG, 'downloadFile', e, url);
      return false;
    }
  }

}
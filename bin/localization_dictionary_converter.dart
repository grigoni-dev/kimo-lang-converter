import 'dart:io';

import 'assets/it.dart';

class LocalizationDictionaryConverter {
  final Map<String, dynamic> source;
  final String sourceFilename;
  final String lang;

  LocalizationDictionaryConverter({required this.source, required this.sourceFilename, required this.lang});

  void converter() {
    final tmp = "converted-to-flat";
    Map<String, String> result = {};
    _fromServerToClientMapping(source, result, "");
    _createNewFile(result, tmp, lang, "dart");
    addMissingKeysFromTemplate(kimoLocaleIT, result);
    _createNewFile(result, lang.toLowerCase(), lang.toUpperCase(), "json");
    _removeFile(tmp);
  }

  void _fromServerToClientMapping(Map<String, dynamic> source, Map<String, String> result, String parentKey) {
    source.forEach(
      (key, value) {
        if (value is String) {
          final fullKey = parentKey + key;
          result.putIfAbsent(fullKey, () => value.replaceAll("\n", "\\n"));
        } else {
          final nextParentKey = parentKey + key + ".";
          _fromServerToClientMapping(value, result, nextParentKey);
        }
      },
    );
  }

  void addMissingKeysFromTemplate(Map<String, String> templateMap, Map<String, String> importedMap) {
    for (final templateEntry in templateMap.entries) {
      importedMap.putIfAbsent(templateEntry.key, () => templateEntry.value.replaceAll("\n", "\\n"));
    }
  }

  void _createNewFile(Map<String, String> map, String filename, String lang, String extension) async {
    StringBuffer sb = StringBuffer();
    // sb.writeln("Map<String, String> kimoLocale$lang = {");
    sb.writeln("{");
    map.forEach((key, value) {
      sb.writeln("   \"$key\" : \"$value\",");
    });

    String finalValue = sb.toString();
    finalValue = finalValue.replaceRange(finalValue.length - 2, finalValue.length - 1, "\n}");
    final file = File('bin/assets/$filename.$extension');
    await file.writeAsString(finalValue);
  }

  void _removeFile(String filenameToRemove) {
    final file = File('bin/assets/$filenameToRemove.dart');
    file.delete();
  }
}

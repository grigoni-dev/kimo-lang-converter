import 'dart:collection';
import 'dart:io';

import 'assets/it.dart';

class LocalizationDictionaryConverter {
  static void converterCompareAndUpdate(Map<String, dynamic> source, String sourceFilename, String lang) {
    final result = SplayTreeMap<String, String>((a, b) => a.compareTo(b));
    final template = kimoLocaleIT;
    convertAndCreate(source, result, lang);
    compareAndUpdate(template, result, lang);
    // _removeFile(tmp);
  }

  static void convertAndCreate(Map<String, dynamic> source, Map<String, String> result, String lang) {
    _fromServerToClientMapping(source, result, "");
    _createNewFile(result, lang, "dart");
  }

  static void compareAndUpdate(Map<String, String> templateMap, Map<String, String> importedMap, String lang) {
    addMissingKeysFromTemplate(templateMap, importedMap);
    _createNewFile(importedMap, lang, "json");
  }

  static void _fromServerToClientMapping(Map<String, dynamic> source, Map<String, String> result, String parentKey) {
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

  static void addMissingKeysFromTemplate(Map<String, String> templateMap, Map<String, String> importedMap) {
    for (final templateEntry in templateMap.entries) {
      importedMap.putIfAbsent(templateEntry.key, () => templateEntry.value.replaceAll("\n", "\\n"));
    }
  }

  static void _createNewFile(Map<String, String> map, String filename, String extension) async {
    StringBuffer sb = StringBuffer();

    if (extension.contains('dart')) {
      sb.writeln("Map<String, String> kimoLocale${filename.toUpperCase()} = {");
    }

    sb.writeln("{");
    map.forEach((key, value) {
      sb.writeln("   \"$key\" : \"$value\",");
    });

    String finalValue = sb.toString();
    finalValue = finalValue.replaceRange(finalValue.length - 2, finalValue.length - 1, "\n}");

    if (extension.contains('dart')) {
      sb.writeln(";");
    }

    final file = File('bin/assets/${filename.toLowerCase()}.$extension');
    await file.writeAsString(finalValue);
  }

  void _removeFile(String filename) {
    final file = File('bin/assets/${filename.toLowerCase()}.dart');
    file.delete();
  }
}

import 'dart:collection';
import 'dart:io';

import 'assets/template/it.dart';
import 'assets/template/en.dart';
import 'assets/template/fr.dart';

class LocalizationDictionaryConverter {
  final Map<String, dynamic> source;
  final String sourceFilename;
  final String lang;

  LocalizationDictionaryConverter({required this.source, required this.sourceFilename, required this.lang});

  void converter() {
    Map<String, String> template = {};
    switch (lang) {
      case "it":
        template = kimoLocaleIT;
        break;
      case "en":
        template = kimoLocaleEN;
        break;
      case "fr":
        template = kimoLocaleFR;
        break;

      default:
    }

    final result = SplayTreeMap<String, String>((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    _fromServerToClientMapping(source, result, "");
    _createNewFile(result, "tmp_${lang.toLowerCase()}", "dart");
    _addMissingKeysFromTemplate(template, result);
    _createNewFile(result, lang, "dart");
    _createNewFile(result, lang, "json");
    _removeFile("tmp_${lang.toLowerCase()}", "dart");
  }

  void _fromServerToClientMapping(Map<String, dynamic> source, Map<String, String> result, String parentKey) {
    source.forEach(
      (key, value) {
        if (value is String) {
          final fullKey = parentKey + key;
          result.putIfAbsent(
              fullKey, () => value.replaceAll("\n", "\\n").replaceAll("\\'", "'").replaceAll("""\"""", ""));
        } else {
          final nextParentKey = parentKey + key + ".";
          _fromServerToClientMapping(value, result, nextParentKey);
        }
      },
    );
  }

  void _addMissingKeysFromTemplate(Map<String, String> templateMap, Map<String, String> importedMap) {
    for (final templateEntry in templateMap.entries) {
      importedMap.putIfAbsent(templateEntry.key,
          () => templateEntry.value.replaceAll("\n", "\\n").replaceAll("\\'", "'").replaceAll("""\"""", ""));
    }
  }

  void _createNewFile(Map<String, String> map, String lang, String extension) async {
    StringBuffer sb = StringBuffer();
    if (extension.contains("dart")) {
      sb.writeln("Map<String, String> kimoLocale${lang.toUpperCase()} = ");
    }
    sb.writeln("{");
    map.forEach((key, value) {
      sb.writeln("   \"$key\" : \"$value\",");
    });

    String finalValue = sb.toString();
    if (extension.contains("dart")) {
      finalValue = finalValue.replaceRange(finalValue.length - 2, finalValue.length - 1, "\n};");
    } else {
      finalValue = finalValue.replaceRange(finalValue.length - 2, finalValue.length - 1, "\n}");
    }

    final file = File('bin/assets/output/${lang.toLowerCase()}.$extension');
    await file.writeAsString(finalValue);
  }

  void _removeFile(String lang, String extension) {
    final file = File('bin/assets/output/${lang.toLowerCase()}.$extension');
    file.delete();
  }
}

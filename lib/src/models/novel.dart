import 'package:collection/collection.dart';

import './work_type.dart';

import './volume.dart';
import './metadata.dart';
import 'meta.dart';

class Novel {
  String title;
  String url;
  String? author;
  List<String> description;
  String? thumbnailUrl;
  String? status;
  String lang;
  List<Volume> volumes;
  List<MetaData> metadata;
  WorkType workType;
  ReadingDirection readingDirection;

  Novel({
    required this.title,
    required this.url,
    this.author,
    List<String>? description,
    this.thumbnailUrl,
    this.status,
    required this.lang,
    List<Volume>? volumes,
    List<MetaData>? metadata,
    this.workType = const UnknownWorkType(),
    this.readingDirection = ReadingDirection.ltr,
  })  : this.description = description ?? [],
        this.volumes = volumes ?? [],
        this.metadata = metadata ?? [];

  /// Add new metadata to the novel
  void addMeta(
    String name,
    String value, [
    Map<String, String> others = const {},
  ]) {
    metadata.add(MetaData(name, value, others));
  }

  /// Single default volume configuration
  /// to be used when novel has no defined
  /// volumes
  Volume singleVolume() {
    var volume;
    if (volumes.isEmpty) {
      volume = Volume.def();
      volumes.add(volume);
    } else {
      volume = volumes.first;
    }

    return volume;
  }

  int chapterCount() {
    return volumes.map((v) => v.chapters.length).sum;
  }
}

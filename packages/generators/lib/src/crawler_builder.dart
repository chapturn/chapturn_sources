import 'dart:async';

import 'package:annotations/annotations.dart';
import 'package:build/build.dart';
import 'package:generators/src/constants.dart';
import 'package:generators/src/model_visitor.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;
import 'package:source_gen/source_gen.dart';

class RegisteredCrawler {
  final String className;
  final Uri uri;
  RegisteredCrawler(this.className, this.uri);
}

class RegisteredFactory {
  final String className;
  final Uri uri;
  RegisteredFactory(this.className, this.uri);
}

class CrawlerCollectorBuilder extends Builder {
  static final _allFilesInLib = Glob('lib/**');

  static AssetId _allFileOutput(BuildStep buildStep) {
    return AssetId(
      buildStep.inputId.package,
      path.join('lib', 'generated/crawlers.g.dart'),
    );
  }

  @override
  Map<String, List<String>> get buildExtensions {
    return const {
      r'$lib$': ['generated/crawlers.g.dart'],
    };
  }

  @override
  FutureOr<void> build(BuildStep buildStep) async {
    final crawlers = <RegisteredCrawler>{};
    final factories = <RegisteredFactory>{};

    await for (final input in buildStep.findAssets(_allFilesInLib)) {
      final library = await buildStep.resolver.libraryFor(input);
      final reader = LibraryReader(library);

      crawlers.addAll(findCrawlers(reader));
      factories.addAll(findFactories(reader));
    }

    final factory = factories.single;
    final buffer = StringBuffer();

    buffer.writeln(generatedWarning);
    buffer.writeln('// ignore_for_file: directives_ordering');

    buffer.writeln();
    buffer.writeln('import "${factory.uri}";');
    for (var crawler in crawlers) {
      buffer.writeln('import "${crawler.uri}";');
    }

    buffer.writeln();
    buffer.writeln('const crawlers = [');

    for (var crawler in crawlers) {
      buffer.writeln(
        '${factory.className}(${crawler.className}.constMeta, ${crawler.className}.make, ${crawler.className}.makeWith),',
      );
    }

    buffer.writeln('];');

    return buildStep.writeAsString(
        _allFileOutput(buildStep), buffer.toString());
  }

  Set<RegisteredCrawler> findCrawlers(LibraryReader reader) {
    final annotatedElements =
        reader.annotatedWith(TypeChecker.fromRuntime(RegisterCrawler));

    return annotatedElements.map((annotated) {
      final visitor = ModelVisitor();
      annotated.element.visitChildren(visitor);

      return RegisteredCrawler(
          visitor.className, annotated.element.source!.uri);
    }).toSet();
  }

  Set<RegisteredFactory> findFactories(LibraryReader reader) {
    final annotatedElements =
        reader.annotatedWith(TypeChecker.fromRuntime(RegisterFactory));

    return annotatedElements.map((annotated) {
      final visitor = ModelVisitor();
      annotated.element.visitChildren(visitor);

      return RegisteredFactory(
          visitor.className, annotated.element.source!.uri);
    }).toSet();
  }
}

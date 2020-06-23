import 'package:project/project.dart';

Future main() async {
  final app = Application<ProjectChannel>()
    ..options.configurationFilePath = "config.yaml"
    ..options.port = 8888;

  final count = Platform.numberOfProcessors ~/ 2;
  //await app.start(numberOfInstances: count > 0 ? count : 1);
  await app.start();

  print("application started on port: ${app.options.port}.");
  print("Use Ctrl-C (SIGINT) to stop running the application.");
}

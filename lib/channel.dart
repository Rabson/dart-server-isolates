import 'dart:io';
import 'project.dart';
import 'dart:isolate';

/// This type initializes an application.
///
/// Override methods in this class to set up routes and initialize services like
/// database connections. See http://aqueduct.io/docs/http/channel/.
class ProjectChannel extends ApplicationChannel {
  /// Initialize services in this method.
  ///
  /// Implement this method to initialize services, read values from [options]
  /// and any other initialization required before constructing [entryPoint].
  ///
  /// This method is invoked prior to [entryPoint] being accessed.
  @override
  Future prepare() async {
    logger.onRecord.listen(
        (rec) => print("$rec ${rec.error ?? ""} ${rec.stackTrace ?? ""}"));
  }

  /*
   *Construct the request channel. 
   * Return an instance of some [Controller] that will be the initial receiver of all [Request]s.
   * This method is invoked after [prepare].
   * 
   */
  @override
  Controller get entryPoint {
    final router = Router();

    // Prefer to use `link` instead of `linkFunction`.
    // See: https://aqueduct.io/docs/http/request_controller/
    router.route("/example").linkFunction((request) async {
      return Response.ok({"key": "value"});
    });

    router.route("/").linkFunction((request) =>
        Response.ok("Hello world")..contentType = ContentType.html);

    router.route("/cpu-intensive/[:id]").linkFunction((request) async {
      //final reply = await startIsolate();

      final id = request.path.variables["id"];
      if (id == null) {
        return Response.serverError();
      }
      final count = int.parse(id);
      final receivePort = ReceivePort();
      await Isolate.spawn(calculate, receivePort.sendPort);
      // The 'calculate' isolate sends it's SendPort as the first message
      final SendPort sendPort = await receivePort.first as SendPort;

      var msg = await sendReceive(sendPort, count);
      return Response.ok({"key": msg});
    });

    router.route("/client").linkFunction((request) async {
      final client = await File('client.html').readAsStringSync();
      return Response.ok(client)..contentType = ContentType.html;
    });

    return router;
  }
}

// the entry point for the isolate
calculate(SendPort sendPort) async {
  // Open the ReceivePort for incoming messages.
  var port = new ReceivePort();
  // Notify any other isolates what port this isolate listens to.
  sendPort.send(port.sendPort);
  await for (var msg in port) {
    final data = msg[0] as int;
    final replyTo = msg[1] as SendPort;

    int count = 0;
    for (var i = 0; i < data; i++) {
      count++;
    }
    print(replyTo.toString().toLowerCase());
    replyTo.send(count);
    port.close();
  }
}

Future sendReceive(SendPort port, msg) {
  final ReceivePort response = ReceivePort();
  port.send([msg, response.sendPort]);
  return response.first;
}

tartIsolate() async {
  final receivePort = ReceivePort();
  await Isolate.spawn(calculate, receivePort.sendPort);
  final SendPort sendPort = await receivePort.first as SendPort;
  return await sendReceive(sendPort, 1000000000);
}

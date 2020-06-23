import 'package:project/project.dart';

class ReadsController extends Controller {
  @override
  Future<RequestOrResponse> handle(Request request) async {
    switch (request.method) {
      case 'GET':
        return Response.ok("Get all document");
        break;
      default:
    }
  }
}

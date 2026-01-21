import 'dart:io';
import 'package:tichu_server/tichu_server.dart';

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args[0]) ?? 8080 : 8080;

  final server = TichuServer(port: port);

  // Handle shutdown gracefully
  ProcessSignal.sigint.watch().listen((_) async {
    print('\n🛑 Shutting down server...');
    await server.stop();
    exit(0);
  });

  await server.start();
  print('📡 WebSocket endpoint: ws://localhost:$port');
  print('🏥 Health check: http://localhost:$port/health');
  print('🎮 Rooms list: http://localhost:$port/rooms');
  print('\nPress Ctrl+C to stop.');
}

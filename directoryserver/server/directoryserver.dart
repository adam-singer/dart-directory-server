#import('dart:io');
#import('dart:json');

var IP = '127.0.0.1';
var PORT = 8080;


Future<String> listDirectoryJson(path) {
  Completer c = new Completer();
  var files = [];
  var dirs = [];
  var d = new Directory(path);
  var cwd = d.path;
  
  DirectoryLister dl = d.list();
  
  dl.onDir = (dir) { 
    dirs.add(dir);
  };
  
  dl.onFile = (file) { 
    files.add(file);
  };
  
  dl.onDone = (done) {    
    var f = {"files": files, "dirs": dirs, "cwd": cwd};
    c.complete(JSON.stringify(f));
    
  };
  
  dl.onError = (e) { 
    print("error = ${e}"); 
  };
  
  return c.future;
}


void main() {
  HttpServer server = new HttpServer();
  WebSocketHandler wsHandler = new WebSocketHandler();
  server.addRequestHandler((req) => req.path == "/ws", wsHandler.onRequest);
  
  Map staticFiles = new Map();
  staticFiles["/"] = "../client/directoryClient/directoryClient.html";
  staticFiles["/directoryClient.html"] = "../client/directoryClient/directoryClient.html";
  staticFiles["/directoryClient.dart"] = "../client/directoryClient/directoryClient.dart";
  staticFiles["/directoryClient.dart.js"] = "../client/directoryClient/directoryClient.dart.js";
  staticFiles["/images/file-icon.svg"] = "../client/directoryClient/images/file-icon.svg";
  staticFiles["/images/folder-folder.svg"] = "../client/directoryClient/images/folder-folder.svg";
  staticFiles["/stylesheets/base.css"] = "../client/directoryClient/stylesheets/base.css";
  staticFiles["/stylesheets/layout.css"] = "../client/directoryClient/stylesheets/layout.css";
  staticFiles["/stylesheets/skeleton.css"] = "../client/directoryClient/stylesheets/skeleton.css";
  staticFiles["/stylesheets/golden-min.css"] = "../client/directoryClient/stylesheets/golden-min.css";
  
  staticFiles.forEach((k,v) {
    server.addRequestHandler((req) => req.path == k, (HttpRequest req, HttpResponse res) {
      File file = new File(v); 
      file.openInputStream().pipe(res.outputStream); 
    });
  });
  
  wsHandler.onOpen = (WebSocketConnection conn) {
    conn.onMessage = (message) {
      var jsonMessage = JSON.parse(message);
      var d = jsonMessage["displayFile"];
      listDirectoryJson(d).then((v) => conn.send(v));
    };
    
    conn.onClosed =  (int status, String reason) {
      print("conn.onClosed status=${status},reason=${reason}");
    };
    
    conn.onError = (e) {
      print("conn.onError e=${e}");
    };
  };
  
  print('listing on http://$IP:$PORT');
  server.listen(IP, PORT);
  
}
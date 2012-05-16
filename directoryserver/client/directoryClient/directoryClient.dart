#import('dart:html');
#import('dart:json');

var IP = '127.0.0.1';
var PORT = 8080;

class DirectoryModel {
  WebSocket _ws;
  get ws() => _ws;
  Function onMessage;
  
  void setupWebsocket() {
    _ws = new WebSocket("ws://127.0.0.1:8080/ws");
    _ws.on.open.add((a) {
      print("open $a");
    });
    
    _ws.on.close.add((c) {
      print("close $c");
    });
    
    _ws.on.message.add((message) {
      var jsonFiles = JSON.parse(message.data);
      if (onMessage is Function) {
        onMessage(jsonFiles);
      }
    });
  }
  
  // Send the server a message
  void sendMessage(String message) {
    if (!message.isEmpty()) {
      ws.send(JSON.stringify(message));
    }
  }
}

class DirectoryView {
  DivElement _filesDisplayElement; 
  DirectoryController _directoryController;
  InputElement _dirInput;
  
  DirectoryView() {
    _filesDisplayElement = document.query("#filesDisplay");
  }
  
  void addController(controller) {
    _directoryController = controller;
  }
  
  void setupUserInputEvents() {
    _dirInput = document.query('#dirInput');
    _dirInput.on.keyPress.add((key) {
      if (key.charCode == 13) {
        if (_directoryController != null) {
          _directoryController.displayFile(_dirInput.value);
        }
      }
    });
  }
  
  void displayFiles(Map jsonFiles) {
    _filesDisplayElement.elements.clear();
    _displayCwd(jsonFiles["cwd"]);
    jsonFiles["files"].forEach(_displayFile);
    jsonFiles["dirs"].forEach(_displayDir);    
  }
  
  void _displayCwd(cwd) {
    var c = new Element.html("<li>${cwd}</li>");
    _filesDisplayElement.elements.add(c);
    _dirInput.value = cwd;
  }
  
  void _displayFile(file) {
    var b = new Element.html("<Button>${file}</Button>");
    //<object data="circle1.svg" type="image/svg+xml"></object>
    var s = new Element.html('<object data="images/file-icon.svg" type="image/svg+xml"></object>');
    var f = new Element.html("<div class='g160'></div>");
    f.elements.add(s);
    f.elements.add(new Element.html("<br/>"));
    f.elements.add(b);
    f.elements.add(new Element.html("<br/>"));
    b.on.click.add((event) {
      _directoryController.displayFile(file);
      print(event);
    });
    
    _filesDisplayElement.elements.add(f);
  }
  
  void _displayDir(dir) {
    var b = new Element.html("<Button>${dir}</Button>");
    var s = new Element.html('<object data="images/folder-folder.svg" type="image/svg+xml"></object>');
    var f = new Element.html("<div class='g160'></div>");
    f.elements.add(s);
    f.elements.add(new Element.html("<br/>"));
    f.elements.add(b);
    f.elements.add(new Element.html("<br/>"));
    b.on.click.add((event) {
      _directoryController.displayFile(dir);
    });
    
    _filesDisplayElement.elements.add(f);
  }
}

class DirectoryController {
  DirectoryView _directoryView;
  DirectoryModel _directoryModel;
  
  DirectoryController(DirectoryModel model, DirectoryView view) {
    _directoryView = view;
    _directoryModel = model;
    
    _directoryView.addController(this);
    
    _directoryModel.onMessage = _directoryView.displayFiles;
    _directoryModel.setupWebsocket();
    _directoryView.setupUserInputEvents();
  }
    
  void displayFile(String fileName) {
    var f = {"displayFile": fileName};
    _directoryModel.sendMessage(f);
  }
}

void main() {
  DirectoryView _directoryView = new DirectoryView();
  DirectoryModel _directoryModel = new DirectoryModel();
  DirectoryController _directoryController = new DirectoryController(_directoryModel, _directoryView);

}


#import('dart:io');

main() {
  /*
  Create a bad symlink and run
  ln -s /usr/local/doesnotexist badlink
  */
  var files = [];
  var dirs = [];
  var d = new Directory("/tmp");
  var cwd = d.path;
  
  DirectoryLister dl = d.list();
  
  dl.onDir = (dir) { 
    dirs.add(dir);
  };
  
  dl.onFile = (file) { 
    files.add(file);
  };
  
  dl.onDone = (done) { 
    var f = {"files": files, "dirs": dirs};
    print(f);
  };
  
  dl.onError = (e) { 
    // After the first broken link found the 
    // DirectoryLister does not continue to run.
    print("error = ${e}"); 
  };
}


#!/usr/bin/env osascript -l JavaScript
function run(argv) {
  //debugger //trigger the debugger, requires Safari to be open
  ObjC.import('stdlib')
  ObjC.import('Foundation')
  var myFolder = $.getenv('alfred_workflow_data')
  var myLib = myFolder + "/" + "BookendsEvents.js"

  require(myLib)

  var ver = $.getenv('alfred_version')
  var query = argv[0];
  
  app.say('Hi ' + query + ', script running...');
    
  var env = $.NSProcessInfo.processInfo.environment // -[[NSProcessInfo processInfo] environment]
  env = ObjC.unwrap(env)
  for (var k in env) {
    onsole.log('"' + k + '": ' + ObjC.unwrap(env[k]))
  }

  var args = $.NSProcessInfo.processInfo.arguments

  // HOWTO: Build the normal argv/argc
  var argv = []
  var argc = args.count // -[NSArray count]
  for (var i = 0; i < argc; i++) {
    argv.push( ObjC.unwrap( args.objectAtIndex(i) ) ) // -[NSArray objectAtIndex:]
  }
  delete args
  //return query;
}

// this function both sets up StandardAdditions 
// and imports a JS library of functions
var require = function (path) {
  if (typeof app === 'undefined') {
    app = Application.currentApplication();
    app.includeStandardAdditions = true;
  }
  try
    var handle = app.openForAccess(path);
    var contents = app.read(handle);
    app.closeAccess(path);

    var module = {exports: {}};
    var exports = module.exports;
    eval(contents);

    return module.exports;
  end
};
/**
 * MyPlugin.js
 *
 * Phonegap MyPlugin Instance plugin
 * Copyright (c) Sabyasachi shadangi 2012
 *
 */
var MyPlugin = {
nativeFunction: function(types, success, fail) {
    return Cordova.exec(success, fail, "MyPlugin", "parse", types);
}
};
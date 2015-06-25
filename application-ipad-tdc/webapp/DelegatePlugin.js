/**
 * DelegatePlugin.js
 *
 * Phonegap MyPlugin Instance plugin
 * Copyright (c) Sabyasachi shadangi 2012
 *
 */

var DelegatePlugin = function()
{
};




//<Shayan's Saturday Code>

DelegatePlugin.prototype.LOGIN = function(jsonInput){
    // alert("Module 1 Alert:coming");
    //alert(jsonInput);
    return Cordova.exec(
                        function(result)
                        {
                        
                        console.log("Setting Result");
                        setMyResponse(result);
                        },               //Function called upon success
                        function(error)
                        {
                        alert(error);
                        //console.log(error);
                        }
                        ,               //Function called upon error
                        "DelegatePlugin",      //Tell PhoneGap to run "DelegatePlugin" Plugin
                        "execute",             //Tell the which action we want to perform, matches an "action" string
                        jsonInput);            //A list of args passed to the plugin
};


function setMyResponse(result){
    //console.log(result);
    lz.embed.setCanvasAttribute("response", result);
    console.log("Response has been set");
 
};
 

//</Shayan's Saturday Code>

/*

DelegatePlugin.addConstructor(function()
{
    DelegatePlugin.addPlugin("DelegatePlugin", new DelegatePlugin());
}); */

cordova.addConstructor(function() {
                       if (!window.Cordova) {
                       window.Cordova = cordova;
                       };
                       
                       if(!window.plugins) window.plugins = {};
                       
                       window.plugins.DelegatePlugin = new DelegatePlugin();
                       });

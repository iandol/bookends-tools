#!/usr/bin/env osascript -l JavaScript
// uses Javascript instead of Applescript

var se = Application('System Events');

//get name of current app
var pApp = se.processes.whose({frontmost: true})[0];
var pName = pApp.properties().name;

//copy selected text
se.keystroke('c', {using: ['command down']} );
delay(0.2)

//activate bookends
var be = Application('Bookends');
be.activate();

//open quick add paste from clipboard
delay(0.5);
se.keystroke('n', { using: ['control down', 'command down'] });
delay(0.5)
se.keystroke('v', {using: ['command down']} );
delay(0.1);
se.keyCode(36); // Press Enter
delay(0.2);

//reactivate previous app
Application(pName).activate();
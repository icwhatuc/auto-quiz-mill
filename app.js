var path = require('path');
var express = require('express');

// Server part
var app = express();
app.use('/', express.static(__dirname));

var server = app.listen(80);
console.log('Server listening on port 80');



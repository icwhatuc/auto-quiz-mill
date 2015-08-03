var path = require('path');
var express = require('express');

// Server part
var app = express();
app.use('/', express.static(__dirname));
app.use('/js', express.static(path.join(__dirname, 'js')));

var server = app.listen(2718);
console.log('Server listening on port 2718');



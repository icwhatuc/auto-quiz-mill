var es = require('elasticsearch');
var eshost = 'https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io';
var esindex = 'auto-quiz-mill';
var estype = 'entities';
var esclient = new es.Client({
    host: eshost
});
var sleep = require('sleep');
var async = require('async');
var fs = require('fs');
var sprintf = require('sprintf-js').sprintf;

var properties_phrases_mapping = {
    "P27" : [
        "citizen of %s",
    ],
    "P569" : [
        "born on %s",
    ],
    "P106" : [
        "%s",
    ],
    "P19" : [
        "born in %s"
    ],
    "P69" : [
        "studied in %s",
        "educated at %s"
    ]
};

var props_mapping;

async.waterfall([
    function(cb)
    {
        fs.readFile('properties-en.json', 'utf8', function(err, data) {
            if(err)
            {
                return console.log(err);
            }
            else
            {
                props_mapping = JSON.parse(data);
                props_mapping = props_mapping.properties;
            }
            cb(null);
        });
    },
    function(cb)
    {
        getPeople(cb);
    },
    function(people, cb)
    {
        for(var k = 0; k < people.length; k++)
        {
            var person = people[k];
            var hints = getHints(person);
            for(var h = 0; h < hints.length; h++)
            {
                console.log(hints[h]);
                sleep.sleep(3);
            }

            if(hints.length)
            {
                console.log("\n", person.name, "\n");
            }
        }

        cb(null);
    }
], function(err) {
    console.log('here');
});

function getPeople(cb)
{
    esclient.search({
        index : esindex,
        type : estype,
        body : {
            query : {
                term : {
                    "instance of" : "human"
                }
            },
            sort : [
                { views_last_month : { "order" : "desc", "missing" : "_last" } },
                { incoming_links_count : { "order" : "desc", "missing" : "_last" } },
            ],
            from : 0,
            size : 5
        }
    }, function(error, res) {
        if(error) {
            console.error("Unable to retrieve data from server.  Please try again later."); 
            cb(error);
        }
        else
        {
            var data = [];
            
            res.hits.hits.forEach(function(hit) {
                data.push(hit._source);
            });

            cb(null, data);
        }
    });
}

function getHints(entity)
{
    var hints = [];
    for(var prop in properties_phrases_mapping)
    {
        var prop_name = props_mapping[prop];
        console.log(prop, prop_name);

        var templates = properties_phrases_mapping[prop];
        for(var k = 0; k < templates.length; k++)
        {
            hints.push(sprintf(templates[k], entity[prop_name]));
        }
    }
    return hints;
}


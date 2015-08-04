var ComponentGallery = require('react-component-gallery');
var es = require('elasticsearch');
var eshost = 'https://mpetgxg8c4:8sl7z9gaui@quiz-9057819005.us-east-1.bonsai.io';
var esindex = 'auto-quiz-mill';
var estype = 'entities';
var esclient = new es.Client({
    host: eshost
});

var MillTopicsShow = React.createClass({
    getInitialState : function() {
        return { data : [] };
    },
    componentDidMount : function() {
        var self = this;
        esclient.search({
            index : esindex,
            type : estype,
            body : {
                _source : ["name", "description", "entity_url", "img_url", "views_last_month", "incoming_links_count"],
                query : {
                    filtered : {
                        filter : {
                            exists : {
                                field : "img_url"
                            }
                        }
                    }
                },
                sort : [
                    { views_last_month : { "order" : "desc", "missing" : "_last" } },
                    { incoming_links_count : { "order" : "desc", "missing" : "_last" } },
                ]
            }
        }, function(error, res) {
            if(error) {
                console.error("Unable to retrieve data from server.  Please try again later."); 
                return;
            }
            else
            {
                var data = [];
                res.hits.hits.forEach(function(hit) {
                    data.push({
                        name : hit._source.name,
                        url : hit._source.entity_url,
                        img_url : hit._source.img_url
                    });
                });
                self.setState({ data : data });
            }
        });
    },
    render : function() {
        var entityNodes = this.state.data.map(function(entity) {
            return (
                <a href={entity.url}>
                    <img src={entity.img_url}/>
                </a>
            );
        });
        
        if(!entityNodes.length)
        {
            return (
                <p>hello, world!</p>
            );
        }

        return (
            <ComponentGallery className="photos" margin="5" widthHeightRatio="5/3" targetWidth="300">
                {entityNodes}
            </ComponentGallery>  
        );
    }
});

React.render(
    <MillTopicsShow/>,
    document.getElementById('content')
);


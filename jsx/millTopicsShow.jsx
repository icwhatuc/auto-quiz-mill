var MillTopicsShow = React.createClass({
    getInitialState : function() {
        var self = this;

        var state = {
            topics : [
                {"name" : "Tomorrowland", "type" : "movie"},
                {"name" : "Barack Obama", "type" : "person"},
                {"name" : "Las Vegas", "type" : "place"},
                {"name" : "Fleet Week", "type" : "event"},
                {"name" : "Stephen Curry", "type" : "person"}
            ],
            currentTopic: {
                "name" : "Tomorrowland",
                "type" : "movie"
            },
        };

        google.load('search', '1', {
            callback: function() {
                self.imageSearch = new google.search.ImageSearch();
                self.imageSearch.setSearchCompleteCallback(self, self.setTopic, null);
                self.imageSearch.execute(state.currentTopic.name);
            }
        });
        
        return state;
    },

    getFreshTopicsFromServer : function() {
        
    },

    getRandomTopic : function(exclude) {
        var excludes_dict = {};
        var topics = this.state.topics;
        if(!exclude && this.state.currentTopic)
            exclude = this.state.currentTopic;
        
        if(exclude && exclude.contructor === Array)
        {
            for(var k = 0; k < exclude.length; k++)
                excludes_dict[exclude[k].name] = true;
        }
        else if(exclude)
            excludes_dict[exclude.name] = true;

        var randIdx;
        do {
            randIdx = Math.floor(Math.random()*topics.length);
        } while(excludes_dict[topics[randIdx].name]);
       
        if(this.imageSearch) {
            this.imageSearch.execute(topics[randIdx].name);
        }

        this.setState({
            nextTopic : topics[randIdx]
        });
    },

    setTopic : function() {
        if (this.imageSearch.results && this.imageSearch.results.length > 0) {
            var image = this.imageSearch.results[0];
            document.getElementById("background").style.backgroundImage = "url('" + image.url + "')";
        }

        if(this.state.nextTopic)
            this.setState({
                currentTopic : this.state.nextTopic
            });
    },

    /* expected stuff follows */
    componentDidMount : function() {
        this.getFreshTopicsFromServer();
        setInterval(this.getFreshTopicsFromServer, this.props.pollServerInterval);
        // this.getRandomTopic();
        setInterval(this.getRandomTopic, this.props.topicInterval);
    },

    render : function() {
        var currentTopicName = this.state.currentTopic.name;
        var currentTopicUrl = "http://www.google.com/search?q=" + currentTopicName;
        return (
            <div className="topicContainer">
                <a className="topic" target="_blank" href={currentTopicUrl}>
                    {currentTopicName}
                </a>
            </div>
        );
    }
});

React.render(
    // hit server every 20 seconds,
    // new topic displayed every 2 seconds
    <MillTopicsShow pollServerInterval={20000} topicInterval={2000} />,
    document.getElementById('content')
);


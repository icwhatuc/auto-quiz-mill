var MillTopicsShow = React.createClass({
    getInitialState : function() {
        return {
            topics : [
                {"name" : "Tomorrowland", "type" : "movie"},
                {"name" : "Barack Obama", "type" : "person"},
                {"name" : "Las Vegas", "type" : "place"},
                {"name" : "ICWHATUC", "type" : "organization"},
                {"name" : "Memorial Day", "type" : "event"},
            ],
            currentTopic: {
                "name" : "Tomorrowland",
                "type" : "movie"
            }
        };
    },

    getFreshTopicsFromServer : function() {
        
    },

    getRandomTopic : function(exclude) {
        var excludes_dict = {};
        var topics = this.state.topics;
        if(!exclude)
            exclude = this.state.currentTopic;
        
        if(exclude.contructor === Array)
        {
            for(var k = 0; k < exclude.length; k++)
                excludes_dict[exclude[k].name] = true;
        }
        else
            excludes_dict[exclude.name] = true;

        var randIdx;
        do {
            randIdx = Math.floor(Math.random()*topics.length);
        } while(excludes_dict[topics[randIdx].name]);
        
        this.setState({
            currentTopic : topics[randIdx]
        });
    },

    /* expected stuff follows */
    componentDidMount : function() {
        this.getFreshTopicsFromServer();
        setInterval(this.getFreshTopicsFromServer, this.props.pollServerInterval);
        this.getRandomTopic();
        setInterval(this.getRandomTopic, this.props.topicInterval);
    },

    render : function() {
        var currentTopicName = this.state.currentTopic.name;
        var currentTopicUrl = "http://www.google.com/search?q=" + currentTopicName;
        return (
            <div className="topic">
                <a target="_blank" href={currentTopicUrl}>
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


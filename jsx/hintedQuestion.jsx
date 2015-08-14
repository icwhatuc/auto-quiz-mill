var Hint = React.createClass({
    render: function()
    {
        var self = this;
        return (
            <p className="hint">
                {self.props.text}
            </p>
        );
    }
});

var HintedQuestion = React.createClass({
    getInitialState : function()
    {
        return {
            answer : null,
            solved : false,
            hints : [],
            currentHint : 0,
        };
    },
    componentDidMount : function()
    {
        var self = this;

        // TODO: get a question

        self.setState({
            answer : "Alan Turing",
            solved : false,
            hints : [
                "Born in England",
                "Mathematician",
                "Computer Scientist",
                "Creator of the Engima machine",
            ],
            currentHint : 0
        });

        setInterval(function() {
            var nextHint = (self.state.currentHint + 1)%self.state.hints.length;
            self.setState({currentHint : nextHint});
        }, self.props.hintInterval);
    },
    render : function()
    {
        var self = this;
        
        if(!self.state.hints.length)
        {
            // TODO: what happens here?
            return (
                <p></p>
            );
        }
        
        return (
            <Hint text={self.state.hints[self.state.currentHint]}/> 
        );
    }
});

React.render(
    <HintedQuestion hintInterval={3000}/>,
    document.getElementById('content')
);


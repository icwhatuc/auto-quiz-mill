(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
var Hint = React.createClass({displayName: "Hint",
    render: function()
    {
        var self = this;
        return (
            React.createElement("p", {className: "hint"}, 
                self.props.text
            )
        );
    }
});

var HintedQuestion = React.createClass({displayName: "HintedQuestion",
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
                React.createElement("p", null)
            );
        }
        
        return (
            React.createElement(Hint, {text: self.state.hints[self.state.currentHint]}) 
        );
    }
});

React.render(
    React.createElement(HintedQuestion, {hintInterval: 3000}),
    document.getElementById('content')
);

},{}]},{},[1]);

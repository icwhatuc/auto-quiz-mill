var ComponentGallery = require('react-component-gallery');

/*
var Canvas = require('canvas')
  , Image = Canvas.Image
  , canvas = new Canvas(300, 300)
  , ctx = canvas.getContext('2d');

ctx.font = '30px Impact';
ctx.rotate(.1);
ctx.fillText("Awesome!", 50, 100);

var te = ctx.measureText('Awesome!');
ctx.strokeStyle = 'rgba(0,0,0,0.5)';
ctx.beginPath();
ctx.lineTo(50, 102);
ctx.lineTo(50 + te.width, 102);
ctx.stroke();
*/

var MillTopicsShow = React.createClass({
    render : function() {
        return (
            <ComponentGallery className="photos" margin="5" widthHeightRatio="5/3" targetWidth="300">
                <a href="google.com">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/2/23/December_2009_partrial_lunar_eclipse-cropped.jpg/300px-December_2009_partrial_lunar_eclipse-cropped.jpg" />
                </a>
                <a href="google.com">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/0e/Googleplex-Patio-Aug-2014.JPG/300px-Googleplex-Patio-Aug-2014.JPG" />
                </a>
                <a href="google.com">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/38/Derek_Jeter_batting_stance_allison.jpg/333px-Derek_Jeter_batting_stance_allison.jpg" />
                </a>
                <a href="google.com">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Wetten_dass_20130323_6475.jpg/300px-Wetten_dass_20130323_6475.jpg" />
                </a>
                <a href="google.com">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/7/7a/Coldplay_Viva_La_Vida_Tour_in_Hannover_August_25th_2009.jpg/300px-Coldplay_Viva_La_Vida_Tour_in_Hannover_August_25th_2009.jpg" />
                </a>
                <a href="google.com">
                    <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/1/1b/Violin_VL100.png/221px-Violin_VL100.png" />
                </a>
            </ComponentGallery>  
        );
    }
});

React.render(
    <MillTopicsShow/>,
    document.getElementById('content')
);


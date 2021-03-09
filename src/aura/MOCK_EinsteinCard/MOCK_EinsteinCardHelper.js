({
    VERBOSE : true,
    setCanvas : function(component) {
        let canvas = component.find('scoreSpan').getElement();
        let loaded = component.get("v.canvasLoaded");
        
        if(canvas){
            let ctx = canvas.getContext('2d');
            let ctxHeight = canvas.height;
            let ctxWidth = canvas.width;
            console.log('EinsteinCard - Canvas Element', canvas, ctxHeight, ctxWidth);
            let fps = 60;
            let intervals = 1000/fps;
            let duration = 500; //In milliseconds
            let radialOffset = -0.5;
            let strokeColors = ['#556A8C', '#FDB665', '#51C983'];
            
            let score = component.get('v.score');
            
            function drawDial(score, percentComplete, callback){
                //console.log('animating', percentComplete);
                let fillGuageEnd = score == 0 ? -2.5 * Math.PI : ((2 * (Math.ceil(percentComplete * 100)/100)) * (score/100) + radialOffset ) * Math.PI;
                let strokeColor = Math.ceil(score * percentComplete) == 100 ? strokeColors[2] : strokeColors[Math.floor(score * percentComplete/33.3)] ;
                
                ctx.save();
                ctx.clearRect(0, 0, ctxWidth, ctxHeight);
                ctx.restore();
                
                ctx.strokeStyle = '#DDDBDA';
                ctx.beginPath();
                ctx.arc(25, 25, 22, fillGuageEnd, radialOffset * Math.PI);
                ctx.lineWidth = 6;
                ctx.stroke();
                ctx.strokeStyle = strokeColor;
                ctx.beginPath();
                ctx.arc(25, 25, 22, radialOffset * Math.PI, fillGuageEnd);
                ctx.lineWidth = 6;
                ctx.stroke();
                
                ctx.save();
                ctx.textAlign = "center";
                ctx.font='15px "Salesforce Sans"'; 
                ctx.fillText(Math.ceil(score * percentComplete), 25, 30);
                ctx.stroke();
                ctx.restore();
            }
            
            function animateCircle(duration, intervals){
                let time = 0;
                let interval = setInterval(function(){
                    if(time < duration){
                        let percentComplete = time/duration
                        time += intervals;
                        drawDial(score, percentComplete, null);
                    } else if( time > duration){
                        let percentComplete = Math.floor(time/duration);
                        time += intervals;
                        drawDial(score, percentComplete, null);
                        clearInterval(interval);
                    } else {
                        // console.log('animation complete');
                        clearInterval(interval);
                        component.set("v.canvasLoaded", true);
                    }
                }, intervals)
            }
            
            if(!loaded && score){
                animateCircle(duration, intervals);
            }
        }
    }
})
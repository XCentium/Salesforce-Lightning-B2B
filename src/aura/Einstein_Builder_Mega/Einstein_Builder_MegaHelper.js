({
    ctx:'',
    start:0,
    num:0,
    timeToFull:1000,
    
    stepCanvas:function(timestamp)
    {
        var ctx = this.ctx;
        var num = this.num;
        var timeToFull = this.timeToFull;
        
        ctx.clearRect(0,0,69,69);
        
        //ctx.fillStyle = 'rgb(230,230,230)';
        //ctx.fillRect(0,0,69,69);
        
        if (this.start==0) this.start = timestamp;
        var progress = timestamp - this.start;
        
        if (progress<timeToFull) {
            currentArcAngle = num*(progress/timeToFull);
        } else {
            currentArcAngle=num;
        }
        
        var x = 35; // x coordinate
        var y = 35; // y coordinate
        var radius = 30; // Arc radius
        var startAngle = (Math.PI*2)*75/100; // Starting point on circle
        var endAngle = (Math.PI*2)*((currentArcAngle+75)%100)/100; // End point on circle
        
        var anticlockwise = false; // clockwise or anticlockwise
        ctx.beginPath();
        ctx.arc(x, y, radius, startAngle, endAngle, anticlockwise);
        ctx.stroke();
        
        ctx.fillStyle = 'rgb(0,0,0)';
        ctx.font="24px Verdana";
        ctx.textBaseline = 'middle';
        ctx.textAlign = 'center';
        ctx.fillText(Math.floor(currentArcAngle), x, y);
        
        if (progress < timeToFull) {
            window.requestAnimationFrame(this.stepCanvas);
        }
    },

    drawCanvas:function(canvas,score) {
        if (canvas.getContext) {
            this.ctx = canvas.getContext('2d');
            this.num = score;
            
            this.ctx.lineWidth = 4;
            this.ctx.fillStyle = 'rgb(230,230,230)';
            this.ctx.strokeStyle = 'rgb(0,255,0)';
            
            window.requestAnimationFrame(this.stepCanvas);
        }
    }
})
({
    doInit : function(component, event, helper) {
        var scoreArr = [component.get('v.section11Score'), 
                        component.get('v.section12Score'),
                        component.get('v.section13Score'),
                        component.get('v.section14Score'),
                        component.get('v.section15Score'),
                        component.get('v.section21Score'),
                        component.get('v.section22Score'),
                        component.get('v.section23Score'),
                        component.get('v.section24Score'),
                        component.get('v.section25Score')];
        scoreArr.forEach(function(score, i){
            if(score != undefined){
                var cmpTarget = component.find('score'+(i+1));   
                score.includes('+') ? $A.util.addClass(cmpTarget, 'green') : $A.util.addClass(cmpTarget, 'red');
            }
        });
        
        var overallScore = parseFloat(component.get('v.scoreValue'));       
        var scoreTarget = component.find('overallScore');
        //$A.util.addClass(scoreTarget, ('p' + component.get('v.scoreValue')));
		var outcomeAttrs = component.get('v.outcomeColor').replace('/ ','/').split(',');
		
        
        if(overallScore <= parseFloat(outcomeAttrs[0].split('-')[1])){
            $A.util.addClass(scoreTarget, 'red');
        } else if (overallScore > parseFloat(outcomeAttrs[0].split('-')[1]) && overallScore < parseFloat(outcomeAttrs[1].split('-')[1])) {
            $A.util.addClass(scoreTarget, 'yellow');
        } else if (overallScore >= parseFloat(outcomeAttrs[1].split('-')[1])) {
            $A.util.addClass(scoreTarget, 'green');
        }        
    }    
})
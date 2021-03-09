({
    doInit : function(component, event) {
        //GET URL parm value
        var sPageURL = decodeURIComponent(window.location.search.substring(1)); 
        var sURLVariables = sPageURL.split('&'); 
        var sParameterName;
        var i;
        for (i = 0; i < sURLVariables.length; i++) {
            sParameterName = sURLVariables[i].split('='); 

            if (sParameterName[0] === 'firstName') { 
                sParameterName[1] === undefined ? 'Not found' : sParameterName[1];
            }
        }
        var value = sParameterName[1];
        //Set Parameter to variable
        component.set("v.vProductId", value);

        var actionClicked = event.getSource().getLocalId();
        // Fire that action
        var navigate = cmp.get('v.navigateFlow');
        navigate(actionClicked);

        //Pass values to Flow and start flow
        var inputVariables = [
         { name : "vProductId", type : "String", value: value }, 
        ];   
        var FlowName = component.get("v.Flow_Name");
        var flow = component.find("flowData");
        flow.startFlow(FlowName, inputVariables );
           
         
    }
})
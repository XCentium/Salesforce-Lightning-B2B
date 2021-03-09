({
    doInit : function(cmp,event, helper){
     	var gid = cmp.getGlobalId();
        cmp.set("v.uniqueFilterName", "number"+gid.replace(":", "").replace(";", ""));  
    },
    
    onFieldChange: function (cmp,event,helper){
       helper.prepareAndSendFilter(cmp,event); 
    },
    
	picklistSelect : function(cmp, event, helper) {
      helper.prepareAndSendFilter(cmp,event);
        
	}
})
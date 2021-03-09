({
    doInit : function(cmp,event, helper){
     	var gid = cmp.getGlobalId();
        cmp.set("v.uniqueFilterName", "boolean"+gid.replace(":", "").replace(";", ""));  
    },
    
    handleRadioClick: function (cmp,event,helper){
       cmp.set('v.selectedValue',event.getSource().get('v.value')); 
       helper.prepareAndSendFilter(cmp,event); 
    },
    
	picklistSelect : function(cmp, event, helper) {
      helper.prepareAndSendFilter(cmp,event);
        
	}
})
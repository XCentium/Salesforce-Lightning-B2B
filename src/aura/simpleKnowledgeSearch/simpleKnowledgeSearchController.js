({
	
    doInit: function(component, event, helper) { 
        helper.getArticles(component);
    },
    
    searchKeyChange: function(component, event, helper) {
        component.set ("v.searchKey", event.getParam("searchKey"));
		helper.getArticles(component);
	},
    
    doneRendering: function(component, event, helper){
        console.log("Inside done rendering");       
	}
  
    

})
({
	doInit : function(component, event, helper) {
		helper.loadAllArticles(component);
    },
    
    attach : function(component, event, helper) {
        var KnowledgeArticleVersionId = event.getSource().get("v.value");
        
		helper.attachArticle(component,helper, KnowledgeArticleVersionId);
    },
    
    detach : function(component, event, helper) {
        var KnowledgeArticleVersionId = event.getSource().get("v.value");
        
		helper.detachArticle(component, helper, KnowledgeArticleVersionId);
    },
    
    searchArticles : function (component, event, helper) {
        helper.searchArticles(component, helper);
    },
    
    clearSearch : function (component, event, helper) {       
        helper.clearSearch(component, helper);
    },
    
    handleBlur: function (component, event) {        
        var searchInput = component.find("search").get("v.value")
        var errorDiv = document.getElementById("ErrorMessage");
        
        if (searchInput != null && (searchInput.length == 1 || searchInput.length == 2)) {
            errorDiv.className = "slds-show";
        } else {
            errorDiv.className = "slds-hide";
        }
    },
    
    handleChange : function (component, event, helper) {
        var searchInput = component.find("search").get("v.value");
        if (!searchInput || searchInput.length === 0)
			helper.clearSearch(component, helper);
    },
    
    openArticle : function (component, event, helper) {
        var KnowledgeArticleVersionId = event.target.id;
    	var navEvt = $A.get("e.force:navigateToSObject");
	    navEvt.setParams({
    	  "recordId": KnowledgeArticleVersionId,
	      "slideDevName": "related"
    	});
	    navEvt.fire();
    }
})
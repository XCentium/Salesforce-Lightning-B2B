({
    loadAllArticles : function(component) {
        var action = component.get("c.getSuggestedArticles");
        
        action.setParams({
            "nbResult":component.get("v.nbResult"),
            "recordId":component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.knowledgeArticles", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    reloadAllArticles : function(component) {
        var action = component.get("c.getSuggestedArticles");
        
        action.setParams({
            "nbResult":component.get("v.nbResult"),
            "recordId":component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.knowledgeArticles", a.getReturnValue());
                $A.get('e.force:refreshView').fire();
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    attachArticle : function(component, helper, KnowledgeArticleVersionId) {
        var action = component.get("c.attachArticleToObject");
        
        action.setParams({
            "recordId":component.get("v.recordId"),
            "KnowledgeArticleVersionId":KnowledgeArticleVersionId
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                helper.reloadAllArticles(component);
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    detachArticle : function(component, helper, KnowledgeArticleVersionId) {
        var action = component.get("c.detachArticleToObject");
        
        action.setParams({
            "recordId":component.get("v.recordId"),
            "KnowledgeArticleVersionId":KnowledgeArticleVersionId
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                helper.reloadAllArticles(component);
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    },
    
    searchArticles : function(component, helper) {
        var action = component.get("c.searchknowledgeArticles");
        var searchInput = component.find("search").get("v.value")
        
        if (searchInput.length > 2) {
            action.setParams({
                "searchInput":searchInput,
                "nbResult":component.get("v.nbResult"),
                "recordId":component.get("v.recordId"),
                "language":component.get("v.searchLanguage")
            });
            action.setCallback(this, function(a) {
                if (a.getState() === "SUCCESS") {
                    component.set("v.knowledgeArticles", a.getReturnValue());
                } else if (a.getState() === "ERROR") {
                    $A.log("Errors", a.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },
    
    clearSearch : function(component, helper) {
        var action = component.get("c.getSuggestedArticles");
        var errorDiv = document.getElementById("ErrorMessage");
        
        errorDiv.className = "slds-hide";
        action.setParams({
            "nbResult":component.get("v.nbResult"),
            "recordId":component.get("v.recordId")
        });
        
        action.setCallback(this, function(a) {
            if (a.getState() === "SUCCESS") {
                component.set("v.knowledgeArticles", a.getReturnValue());
            } else if (a.getState() === "ERROR") {
                $A.log("Errors", a.getError());
            }
        });
        $A.enqueueAction(action);
    }
})
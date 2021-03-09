({
    doInit : function(component, event, helper) {
        helper.GetZone(component, event, helper);
        helper.GetGuestUser(component, event, helper);
    },
    promoteAnIdea : function(component, event, helper){
        var IdeaId = event.target.getAttribute('data-idValue');
        var action = component.get("c.promoteIdea");
        action.setParams({"IdeaId" : IdeaId});
        action.setCallback(this, function(a) {
            console.log('Promote: '+a.getReturnValue());
            helper.IdeasList(component, event);
        });
        $A.enqueueAction(action);
    },
    demoteAnIdea : function(component, event, helper){
        var IdeaId = event.target.getAttribute('data-idValue');
        var action = component.get("c.demoteIdea");
        action.setParams({"IdeaId" : IdeaId});
        action.setCallback(this, function(a) {
            console.log('Demote: '+a.getReturnValue());
            helper.IdeasList(component, event);
        });
        $A.enqueueAction(action);
    },
    onSelectChange : function(component, event, helper){
        component.set("v.viewName", component.find("filters").get("v.value"));
        component.set("v.nextPage", 0);
        helper.IdeasList(component, event);
        helper.TotalIdeas(component, event);
    },
    firstPage : function(component, event, helper){
        component.set("v.nextPage", 0);
        helper.IdeasList(component, event);
    },
    previousPage : function(component, event, helper){
        var nextPage = component.get("v.nextPage");
        if(component.get("v.ideasPageUpdated")){
            nextPage = nextPage-1;
        }
        component.set("v.nextPage", nextPage);
        helper.IdeasList(component, event);
    },
    nextPage : function(component, event, helper){
        var nextPage = component.get("v.nextPage");
        if(component.get("v.ideasPageUpdated")){
            nextPage = nextPage+1;
        }
        component.set("v.nextPage", nextPage);
        helper.IdeasList(component, event);
    },
    lastPage : function(component, event, helper){
        var ideasPerPage = component.get("v.ideasPerPage");
        component.set("v.nextPage", Math.floor(component.get("v.TotalIdeas")/ideasPerPage));
        helper.IdeasList(component, event);
    },
    onZoneChange : function(component, event, helper){
        component.set("v.selectedZoneId", component.find("zone").get("v.value"));
        component.set("v.viewName", component.find("filters").get("v.value"));
        component.set("v.nextPage", 0);
        helper.IdeasList(component, event);
        helper.TotalIdeas(component, event);
    }
})
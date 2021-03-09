({
    GetGuestUser : function(component, event) {
        var isGuestUserMethod = component.get("c.isGuestUser");
        isGuestUserMethod.setCallback(this, function(a) {
            console.log(a.getReturnValue());
            component.set("v.isGuest", a.getReturnValue());
        });
        $A.enqueueAction(isGuestUserMethod);
    },
	IdeasList : function(component, event) {
        var newAction = component.get("c.getIdeasList");
        newAction.setParams({
            ideasPerPage : component.get("v.ideasPerPage"),
            selectedFilter : component.find("filters").get("v.value"),
            selPageNo : component.get("v.nextPage"),
            selectedZone : component.get("v.selectedZoneId")
        });
        newAction.setCallback(this, function(a) {
            if(a.getReturnValue().length != 0){
                component.set("v.IdeasList", a.getReturnValue());
                component.set("v.ideasPageUpdated", true);
            }else{
                component.set("v.ideasPageUpdated", false);
                component.set("v.nextPage", component.get("v.nextPage")-1);
            }
            console.log(a.getReturnValue());
        });
        $A.enqueueAction(newAction);
	},
    TotalIdeas : function(component, event){
        var totalIdeasAction = component.get("c.getTotalIdeas");
        totalIdeasAction.setParams({
            ideasPerPage : component.get("v.ideasPerPage"),
            selectedFilter : component.find("filters").get("v.value"),
            selPageNo : component.get("v.nextPage"),
            selectedZone : component.get("v.selectedZoneId")
        });
        totalIdeasAction.setCallback(this, function(a) {
            var ideasPerPage = component.get("v.ideasPerPage");
            var totalIdeas = a.getReturnValue();
            var totalIdeaPages = Math.ceil(totalIdeas/ideasPerPage);
            component.set("v.TotalIdeas", a.getReturnValue());
            component.set("v.totalIdeaPages", totalIdeaPages);
            console.log('TotalIdeas: '+a.getReturnValue());
            console.log('totalIdeaPages: '+totalIdeaPages);
        });
        $A.enqueueAction(totalIdeasAction);
        
    },
    GetZone : function(component, event, helper){
        var getZones = component.get("c.getCurrentCommunityZones");
        getZones.setCallback(this, function(a){
            console.log('got zones');
            component.set("v.zoneIdNames", a.getReturnValue());
            component.set("v.selectedZoneId", a.getReturnValue()[0].Id);
            console.log(a.getReturnValue()[0].Name);
            helper.IdeasList(component, event);
            helper.TotalIdeas(component, event);
        });
        $A.enqueueAction(getZones);
    }
})
({
    // Handle component initialization
    doInit : function(component, event, helper) {
        var type = component.get("v.type");
        var types = component.get("v.types");
        var opts = new Array();

        // Set the feed types on the lightning:select component
        for (var i = 0; i < types.length; i++) {
            opts.push({label: types[i], value: types[i], selected: types[i] === type});
        }
        component.set("v.options", opts);
        
        component.set("v.type", "UserProfile");

        // Dynamically create the feed with the specified type
        $A.createComponent("forceChatter:feed", {"type": type}, function(feed) {
            var feedContainer = component.find("feedContainer");
            feedContainer.set("v.body", feed);
        });
    },

  onChangeType : function(component, event, helper) {
        var typeSelect = component.find("typeSelect");
        var type = typeSelect.get("v.value");
        component.set("v.type", type);

        // Dynamically create the feed with the specified type
        $A.createComponent("forceChatter:feed", {"type": type}, function(feed) {
            var feedContainer = component.find("feedContainer");
            feedContainer.set("v.body", feed);
        });
    }
})
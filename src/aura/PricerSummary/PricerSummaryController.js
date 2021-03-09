({
	refresh : function(component, event, helper) {
       // console.log("Refreshing View");
        var sections=component.get("v.sections");
        var displaySections=[];
        for (var i=0;i<sections.length;i++){
            var displaySection = {};
            displaySection.name=sections[i].oSection.Name;
            displaySection.total=sections[i].total;
            displaySections.push(displaySection);
        }
        component.set("v.displaySections",component.get("v.sections"));
	}
})
({
	addpicklistvalue:function(component,event,elementId)
    {   
       component.find(elementId).set("v.options", opts);
       var selectedValue= event.getSource().get("v.value");
       component.set("v.InventorySelected",selectedValue);
       console.log(component.set("v.InventorySelected"));
    }
})
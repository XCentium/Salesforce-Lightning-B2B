({
	doInit : function(component, event, helper) {
		var Icon1 = '/'+component.get("v.Text1").replace(/\s+/g, '')+'.png';
        var Icon2 = '/'+component.get("v.Text2").replace(/\s+/g, '')+'.png';
        var Icon3 = '/'+component.get("v.Text3").replace(/\s+/g, '')+'.png';
        var Icon4 = '/'+component.get("v.Text4").replace(/\s+/g, '')+'.png';
        var Icon5 = '/'+component.get("v.Text5").replace(/\s+/g, '')+'.png';
        component.set("v.Icon1",Icon1);
        component.set("v.Icon2",Icon2);
        component.set("v.Icon3",Icon3);
        component.set("v.Icon4",Icon4);
        component.set("v.Icon5",Icon5);
      // console.log(Icon1);
	}
})
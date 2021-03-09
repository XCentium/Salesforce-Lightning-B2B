({
	doInit : function(component, event, helper) {
        var key = component.get("v.atKey");
        var map = component.get("v.Imgmap");
          
        
        var images=new Array();
        for(var i=0; i<map.length;i++){
            if(map[i].LinkedEntityId === key)
            images.push(map[i]);    
            
        }
        component.set("v.inStoreImgs", images);
        
	},
})
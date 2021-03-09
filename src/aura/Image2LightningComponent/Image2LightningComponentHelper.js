({

    
    parseAttribute : function(component, attrName) {
        var image = component.get("v."+attrName);
        if(image)
        {
            image = image.split("|");
           // console.log(image);
            component.set("v.resourceName",image[0]);
            component.set("v.fileLoc",image[1]);
            component.set("v.pos",image[2]);
           // component.set("v.top",image[3]);
            component.set("v.currentScreen",component.get("v.currentScreen")+1);
            
          //  console.log('image Name: '+attrName);
          //  console.log('current Screen:'+component.get("v.currentScreen"));
            
            
        }
            

            

            
    },
    
    addAppIcon:function(component){
        var appIcon = component.get("v.appIcon");
        var head = document.querySelector('head');
        var link = document.createElement("link");
        link.setAttribute("rel", "apple-touch-icon");
        link.setAttribute("href", appIcon);
        
        document.getElementsByTagName('head')[0].appendChild(link);
    }
})
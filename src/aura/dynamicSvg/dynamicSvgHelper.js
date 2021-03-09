({
	renderChildren : function(component, dynamicSvg) {
		var childItems = component.get("v.childItems");
        
        // Iterate over the list of objects
        for(var key in childItems){            
            var header = childItems[key];

            for(var element in header){

                // Create the parent element
                var parentGen = document.createElementNS("http://www.w3.org/2000/svg", element);
                var childElements = header[element];
                
                // Set the attributes on the parent element
                for(var attribute in childElements){
                    parentGen.setAttribute(attribute, childElements[attribute]);
                }
                
                // Add it to the root SVG
				dynamicSvg.appendChild(parentGen);
            }
        }
	}
})
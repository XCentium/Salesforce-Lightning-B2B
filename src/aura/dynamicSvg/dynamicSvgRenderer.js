({
    render: function(component, helper) {
        
        // Create the svg, viewbox and circle elements
        var svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
        if(component.get("v.viewbox") != ''){
            svg.setAttribute("viewBox", component.get("v.viewbox"));
        }
        
        if(component.get("v.class") != ''){
            svg.setAttribute("class", component.get("v.class"));
        }
        
		svg.setAttribute("aria-hidden", "true");
        
		helper.renderChildren(component, svg);
        
        return svg;
    }       
})
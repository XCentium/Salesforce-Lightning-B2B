({
	doInit: function(component, event, helper) { 
        var getList = component.get('v.items'); 
        if(getList != '' && getList != null){
            getList = getList.toLowerCase();
        }
        	
        
        var getList2 = component.get('v.items2'); 
		var getList3 = component.get('v.items3');
        
        var getElement = component.get('v.element');
        if(getElement != '' && getElement != null){
        	getElement = getElement.toLowerCase();
        }
        
        var getElementIndex = -1;
        var getElementIndex2 = -1;
        var getElementIndex3 = -1;
        
        
        
        if(getElement != '' && getElement != null){
        	getElementIndex = getList.indexOf(getElement);
        }
         
        if(getList2 != null && getList2 != ''){
            getList2 = getList2.toLowerCase();
			getElementIndex2 = getList2.indexOf(getElement);
        }

        if(getList3 != null && getList3 != ''){
            getList3 = getList3.toLowerCase();
        	getElementIndex3 = getList3.indexOf(getElement);
        }
        
       // if getElementIndex is not equal to -1 it's means list contains this element. 
        if(getElementIndex != -1 ){ 
              component.set('v.condition',true);
        }else if(getElementIndex2 != -1){ 
            if(getList2 != null){
              component.set('v.condition',true);
            }
        }else if(getElementIndex3 != -1 ){ 
            if(getList3 != null){
            	component.set('v.condition',true);
            }
        }else{
              component.set('v.condition',false);
        } 
    }
})
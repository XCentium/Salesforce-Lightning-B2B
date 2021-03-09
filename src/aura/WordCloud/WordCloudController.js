({
	onInit: function(component, event, helper) {
       
         var objectName = component.get("v.objectName");
         var fieldName = component.get("v.fieldName");
        
          console.log("Init " + objectName + ' - ' + fieldName);
        
        if(objectName == null || objectName.length == 0 || fieldName == null || fieldName.length == 0 ) { return;}
            
            
        var action = component.get("c.getWordCloudData");      
         action.setParams({     
            objectName: objectName,
             fieldName: fieldName
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS') {
                var returnValue = response.getReturnValue(); 
               console.log("SUCCESS");
               // var values = JSON.stringify(response.getReturnValue());
                var values = response.getReturnValue();
                var words = [ ];
                for(var itemName in values) { 
                    var wordItem = new Object();
                    wordItem.text = itemName;
                    wordItem.weight = values[itemName];
           			
                    words.push(wordItem);
                  
                }
              var rendered = component.get("v.rendered");
                if(!rendered) {
                    $('#demo').jQCloud(words);
                    component.set("v.rendered", true);
                    
                } else {
                    $('#demo').jQCloud('update', words);
                }
                
		
             
            } else if(state === 'ERROR') {
                 var errors = action.getError();
             //   alert(errors[0].message);
               $A.log("Errors", errors);
                helper.handleErrors(errors);
            }
        });
        $A.enqueueAction(action);
    }
 
})
({
	saveSignature : function(cmp,e) {
        var canvas = document.getElementById('signature-pad');
        var context = canvas.getContext('2d');
		
        var w = canvas.width;
        var h = canvas.height;
        var data = context.getImageData(0,0,w,h);
        var compositeOperation = context.globalCompositeOperation;
        context.globalCompositeOperation = "destination-over";
        context.fillStyle = '#FFF';
        context.fillRect(0,0,w,h);
        
        var d = canvas.toDataURL();
        console.log(d);
        var split = d.split('base64,',2);
        console.log(split[1]);
        var test = split[1].toString();
        
        var action = cmp.get("c.uploadSignature");
        action.setParams({
            "parentId": cmp.get("v.recordId"),
            "content": test
        });
        action.setCallback(this, function(a) {
            var state = a.getState();
            if (state === 'SUCCESS'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "success",
                    "message": "Signature added successfully."
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "message": "Failed to add signature."
                });
                toastEvent.fire();
            }
            /*$A.get("e.force:closeQuickAction").fire();*/
            var navigate = cmp.get("v.navigateFlow");
            navigate("NEXT");
        });
        $A.enqueueAction(action);
	}
})
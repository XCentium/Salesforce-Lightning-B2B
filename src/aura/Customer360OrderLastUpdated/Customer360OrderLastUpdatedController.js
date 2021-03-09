({
    init : function(component, event, helper) {
        helper.getOrderDetails(component, component.get('v.recordId'))
        .then(function(res){
            console.log(res);
            if(res != null && !res.total){
                component.set('v.order', res)
            } else {
            }
        })
        
    }
})
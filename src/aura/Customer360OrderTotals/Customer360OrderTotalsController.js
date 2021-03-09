({
    init : function(component, event, helper) {
        if(!helper.isTest){
            helper.getOrderDetails(component, component.get('v.recordId'))
            .then(function(res){
                console.log(res);
                if(res != null && !res.total){
                    component.set('v.order', res)
                } else {
                }
            })
            
        } else {
            component.set('v.order', {
                'subtotal': 162.00,
                'adjustments': 0.00,
                'shipping': 7.99,
                'tax__c': 8.50,
                'total':178.49
            })
        }
    }
})
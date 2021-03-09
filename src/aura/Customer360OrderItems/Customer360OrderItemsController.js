({
    init : function(component, event, helper) {
        Promise.all([helper.getOrderDetails(component, component.get('v.recordId')), helper.getOrderLineItems(component, component.get('v.recordId'))])
        .then(function(res){
            console.log(res)
            let order = res[0]
            let orderItems = res[1]
            if(order != null && !order.total) component.set('v.order', order)
            if(orderItems != null) component.set('v.orderItems', orderItems)
        })
    }
})
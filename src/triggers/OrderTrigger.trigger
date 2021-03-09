trigger OrderTrigger on Order (after insert, after update){
    for (Order order : Trigger.New) {
        if(order.Status == 'Activated') {
            Map<String, Object> params = new Map<String, Object>();
            params.put('OrderId', order.Id);
            Flow.Interview.Create_Transaction_Journals_From_Order_and_Process myFlow = new Flow.Interview.Create_Transaction_Journals_From_Order_and_Process(params);
            myFlow.start();
        }
    }
}
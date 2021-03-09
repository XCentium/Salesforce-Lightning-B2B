public class Q2COrderNow {

    public Id OrderId { get; set; }
    private ApexPages.StandardController Controller;

// This is an Extension Controller. Thus, we must invoke the standard controller.
    public Q2COrderNow(ApexPages.StandardController controller) {
        this.OrderId = controller.getId();
        this.Controller = controller;
    }

// Method for creating Quote 
    public PageReference orderNow() {
        Id a = this.OrderId;
        SBQQ__Quote__c thisOrder = [SELECT SBQQ__Ordered__c FROM SBQQ__Quote__c WHERE Id = :a];
        thisOrder.SBQQ__Ordered__c = true;
        update thisOrder;
        return this.Controller.view();
    }
}
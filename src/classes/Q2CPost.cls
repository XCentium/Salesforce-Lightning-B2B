public class Q2CPost {

    public Id OrderId { get; set; }
    private ApexPages.StandardController Controller;

// This is an Extension Controller. Thus, we must invoke the standard controller.
    public Q2CPost(ApexPages.StandardController controller) {
        this.OrderId = controller.getId();
        this.Controller = controller;
    }

// Method for creating Quote 
    public PageReference post() {
        Id a = this.OrderId;
        blng__Invoice__c thisOrder = [SELECT blng__InvoiceStatus__c FROM blng__Invoice__c WHERE Id = :a];//blng__Invoice__c thisOrder = [SELECT Status__c, blng__InvoiceStatus__c FROM blng__Invoice__c WHERE Id = :a];
        thisOrder.blng__InvoiceStatus__c = 'Posted';
        //thisOrder.Status__c = 'Posted';
        update thisOrder;
        return this.Controller.view();
    }
    public PageReference postCredit() {
        Id a = this.OrderId;
        blng__CreditNote__c thisOrder = [SELECT blng__Status__c FROM blng__CreditNote__c WHERE Id = :a];
        thisOrder.blng__Status__c = 'Posted';
        update thisOrder;
        return this.Controller.view();
    }
    public PageReference postDebit() {
        Id a = this.OrderId;
        blng__DebitNote__c thisOrder = [SELECT blng__Status__c FROM blng__DebitNote__c WHERE Id = :a];
        thisOrder.blng__Status__c = 'Posted';
        update thisOrder;
        return this.Controller.view();
    }
}
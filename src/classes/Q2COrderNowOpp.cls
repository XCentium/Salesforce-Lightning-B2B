public class Q2COrderNowOpp {

    public Id recId { get; set; }
    private ApexPages.StandardController Controller;

// This is an Extension Controller. Thus, we must invoke the standard controller.
    public Q2COrderNowOpp(ApexPages.StandardController controller) {
        this.recId = controller.getId();
        this.Controller = controller;
    }

// Method for creating Quote 
    public PageReference orderNow() {
        Id a = this.recId;
        Opportunity thisOpp = [SELECT SBQQ__Ordered__c FROM Opportunity WHERE Id = :a];
        thisOpp.SBQQ__Ordered__c = true;
        update thisOpp;
        return this.Controller.view();
    }
}
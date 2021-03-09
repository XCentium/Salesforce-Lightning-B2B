global class SCCUpdateCCCustomerQueueable implements Queueable, Database.AllowsCallouts {

    private Id recordId;
    private String customerNo;
    private String customerListId;
    private String accessToken;

    public SCCUpdateCCCustomerQueueable(Id recordId, String customerListId, String customerNo, String accessToken){
        this.recordId = recordId;
        this.customerNo = customerNo;
        this.customerListId = customerListId;
        this.accessToken = accessToken;
        System.debug('SCCUpdateCCCustomerQueueable' + 'inputs: '+this.recordId+' : ' + this.customerNo);
    }

    global void execute(QueueableContext context){
        System.debug('SCCUpdateCCCustomerQueueable.execute');
        updateCCCustomerProfile(recordId, customerListId, customerNo, accessToken);
    }

    @Future(Callout=true)
    private static void updateCCCustomerProfile(Id recordId, String customerListId, String customerNo, String accessToken){

        // Initialize the ccConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();
        ccConnect.setCustomerListId(customerListId);

        // Initialize the requestJSON object definition
        String requestJSON = '{"c_sscid":"' + recordId + '"}';

        System.debug('SCCUpdateCCCustomerQueueable:updateCCCustomerProfile' + ' recordId: ' + recordId + ' customerNo: ' + customerNo);
        HttpResponse resp = ccConnect.updateCCCustomerProfile(requestJSON, customerNo, accessToken);
    }
}
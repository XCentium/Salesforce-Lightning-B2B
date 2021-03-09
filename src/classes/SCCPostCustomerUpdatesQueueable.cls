/**
* Class implementing queueable to call the SFCC OCAPI to get the order details in order to update it the PA in SC.
*
* @author  Praveen Gaur
* @version 1.0
* @since   2020-03-02
*/

public class SCCPostCustomerUpdatesQueueable implements Queueable,Database.AllowsCallouts {

    // related properties
    private Id recordId                 {get; set;}
    private Id personContactId          {get; set;}
    private String customerListId       {get; set;}
    private String SiteId               {get; set;}
    private String customerNo           {get; set;}

    /**
     * Constructor to set the values at the time of instantiation.
     */
    public SCCPostCustomerUpdatesQueueable(Id recordId, Id personContactId, String customerListId, String SiteId, String customerNo){
        this.recordId = recordId;
        this.personContactId = personContactId;
        this.customerListId = customerListId;
        this.SiteId = SiteId;
        this.customerNo = customerNo;
    }


    public void execute(QueueableContext context) {

        // Initialize the logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        try {

            // Create a new instance of the SCCCommerceCloudConnect class
            SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

            // Scope the request by siteId / customerListId
            ccConnect.setSiteId(SiteId);
            ccConnect.setCustomerListId(customerListId);

            // Create the updateJSON used to attach the accountId and contactId back to the customer profile
            String updateJSON = '{"c_sscid": "' + recordId + '", "c_ssccid": "' + personContactId + '"}';

            // Update the customer record to include the account / contact identifiers from Service Cloud
            HttpResponse resp = ccConnect.updateCCCustomerProfile(updateJSON, customerNo, ccConnect.connectToCommerceCloud2ProfileOperations());


        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCPostCustomerUpdatesQueueable.execute', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        } finally {
            logger.flush();

        }

    }
}
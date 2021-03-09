/**
* Class implementing queueable to call the SFCC OCAPI to get the order details in order to update it the PA in SC.
*  
* @author  Praveen Gaur 
* @version 1.0
* @since   2020-03-02
*/

public class SCCOrderQueueable implements Queueable,Database.AllowsCallouts {

    // related account record
    private Id orderId                 {get; set;}
    private List<Id> objectIds           {get; set;}

    public SCCOrderQueueable(Id id, List<Id> objectIds) {
        this.orderId = id;
        this.objectIds = objectIds;
    }

    /**
    * This method is used by order sync lightning component
    * @param orderId: String
    * @return none
    */
    public void execute(QueueableContext context) {

        // Initialize the logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        try {

            // First, validate that either orderId or objectIds is provided
            if (String.isEmpty(orderId) && (objectIds == null || objectIds.isEmpty())) {
                throw new SObjectException('orderId is empty: ' + orderId);
            }
            
            //Initiate the call to SFCC for order details
            SCCOrderHelper orderHelper = new SCCOrderHelper();
            if(objectIds != null && !objectIds.isEmpty()){
                for (Id objectId : objectIds){
                    logger.debug('SCCOrderQueueable', 'starting the batch process');
                    orderHelper.continueWithObject(objectId);
                }
            }else{
                logger.debug('SCCOrderQueueable', 'processing the individual record, ID: ' + orderId);
                orderHelper.continueWithObject(orderId);
            }
        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCOrderHelper.syncOrder', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            
        } finally {

            logger.flush();

        }

    }
}
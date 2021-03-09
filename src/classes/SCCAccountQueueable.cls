/**
* Class implementing queueable to call the SFCC OCAPI to get the customer details in order to update it the PA in SC.
*
* @author Praveen Gaur
* @version 1.0
* @since 2020-03-02
*/

public class SCCAccountQueueable implements Queueable,Database.AllowsCallouts {

    // related account record
    private Id accountId                 {get; set;}
    private List<Id> objectIds           {get; set;}

    public SCCAccountQueueable(Id id, List<Id> objectIds) {
        this.accountId = id;
        this.objectIds = objectIds;
    }

    public void execute(QueueableContext context) {

        //Initializing an instance of AccountHelper class
        SCCAccountHelper accountHelper = new SCCAccountHelper();

        // Initialize an instance of the current logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        //if objectIds are available -- batch processing
        if(objectIds != null && !objectIds.isEmpty()){
            for (Id objectId : objectIds){
                logger.debug('SCCAccountQueueable', 'starting the batch process');
                accountHelper.continueWithObject(objectId);
            }
        }else{// else -- Request for individual Account synch
            logger.debug('SCCAccountQueueable', 'processing the individual record, ID: ' + accountId);
            accountHelper.continueWithObject(accountId);
        }
    }
}
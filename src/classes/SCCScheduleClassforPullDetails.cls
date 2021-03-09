/**
* Schedule clas to pull informations for both contact and order after defined minutes when commerce cloud part push something to service cloud
* 
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-20 
*/
global class SCCScheduleClassforPullDetails implements Schedulable {
    
    //related record's id
    public Id recordId                  {get; set;}

    /**
    * This is constructor of schedule class.
    * @param recordId: Id
    * @return None.
    */
    public SCCScheduleClassforPullDetails(Id recordId) {
        this.recordId           = recordId;
    }
    
    /**
     * @description Executes the scheduled Apex job. 
     * @param sc SchedulableContext
     */ 
    global void execute(SchedulableContext sc) {
        //SCCCommerceCloudConnect.synchroniseObjectFuture(recordId);
        Id jobId = sc.getTriggerId();
        System.abortJob(jobId);
    }

}
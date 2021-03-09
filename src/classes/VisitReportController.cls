public class VisitReportController {
    @AuraEnabled
    public static List<RetailLocationGroup> getRetailGroups(){
        List<RetailLocationGroup> rg = [SELECT Id,Name FROM RetailLocationGroup Limit 50000];
        return rg;
    }
    
    @AuraEnabled
    public static List<RetailStore> getRetailStores(Id rsgId){
        List<RetailStore> rs = [SELECT Id,Name,RetailLocationGroupId FROM RetailStore WHERE RetailLocationGroupId = :rsgId Limit 50000];
        return rs;         
    }
    
    //Main method to return Task List and its images.
    @AuraEnabled
    public static VisitReportWrapper getTaskData(Id rGroupId, String rStoreId, Date startDate, Date endDate, Boolean reportTab){
        
        system.debug('***enter getTaskData***' + rGroupId +'-- ' + rStoreId +'-- ' +startDate +'-- ' + endDate +'-- ' + reportTab);
        //Get all AssessmentTasks
        List <AssessmentTask> aTasks = new List<AssessmentTask>();
           aTasks = getAssessmentList(rGroupId,rStoreId,startDate,endDate,reportTab);
        
        system.debug('after aTasks-- '+aTasks);
        if(aTasks == null) return null;
        if (aTasks.isEmpty()){
            system.debug('its empty aTasks-- '+aTasks);
            return null;
        } 
        
        //Get CDLs for AssessmentTasks
        List<ContentDocumentLink> cdlMap = getCDLMap(aTasks);
        
        //Get Parent Info for AssessmentTasks
        Map<Id,String> rsgInfo = getTaskParentInfo(aTasks);
        
        //Initialize the wrapperclass
        VisitReportWrapper returnwrapperClass = new  VisitReportWrapper();	
        returnwrapperClass.assessmentList = aTasks;
        returnwrapperClass.atCount = returnwrapperClass.assessmentList.Size();
        returnwrapperClass.atImageMap=cdlMap;
        returnwrapperClass.rsgMap = rsgInfo;
        return returnwrapperClass;    
    }
    
    //Method to Fetch all related Assessment Tasks
    public static List<AssessmentTask> getAssessmentList(Id rGroupId, String rStoreId, Date startDate, Date endDate, Boolean reportTab){
        system.debug('***enter getAssessmentList***');
        List <AssessmentTask> aTasks;
        
        DateTime startDateTime = startDate;
        DateTime endDateTime = endDate;
        
        /** TESTING DATA 
         rGroupId = '0Y26g000000PBoBCAW';
         rStoreId = '0YQ6g000000PBoHGAW';
         //Visit = '0Z56g000000k9c1CAA';
         startDateTime = Datetime.newInstanceGmt(2020, 04, 02, 10, 00, 00);
         endDateTime = Datetime.newInstanceGmt(2020, 04, 02, 20, 00, 00);
		**/
        
        /* Check if Record Detail */
        if(reportTab == false){            
            aTasks =  [SELECT Id,Name,TaskType,Parent.Name,Parent.Place.Name,Parent.PlaceId,Parent.ActualVisitStartTime FROM AssessmentTask 
                       WHERE Parent.PlaceId = :rStoreId
                       and Parent.ActualVisitStartTime >= :startDateTime and Parent.ActualVisitStartTime <= :endDateTime
                       and TaskType = 'PromotionCheck' order by Parent.ActualVisitStartTime limit 50000];
            return aTasks;
        }
        
        
        if(String.isBlank(rStoreId)){
            //system.debug('***store blank getAssessmentList***');
            List<Visit> visits = [Select Id from Visit where 
                                  placeId in (select Id from retailstore where RetailLocationGroupId= :rGroupId)
                                  and Id in (select parentId from AssessmentTask where TaskType= 'PromotionCheck')
                                  and ActualVisitStartTime >= :startDateTime and ActualVisitStartTime <= :endDateTime
                                 ];            
            if (visits.size() < 1) return null; 
            
            // Make a List of Visit IDs
            List <Id> visitList = new List <Id> ();
            for (Visit nextVisit : visits) {
                visitList.add(nextVisit.Id); 
            }
            
            // Make a List of AssessmentTask IDs   
            aTasks = [SELECT Id,Name,TaskType,Parent.Name,Parent.Place.Name,Parent.PlaceId,Parent.ActualVisitStartTime FROM AssessmentTask 
                      WHERE ParentId in :visitList and TaskType= 'PromotionCheck' order by Parent.ActualVisitStartTime limit 50000]; 
        } else {
            //system.debug('***In ELSE getAssessmentList***');
            aTasks =  [SELECT Id,Name,TaskType,Parent.Name,Parent.Place.Name,Parent.PlaceId,Parent.ActualVisitStartTime FROM AssessmentTask 
                       WHERE Parent.PlaceId = :rStoreId
                       and Parent.ActualVisitStartTime >= :startDateTime and Parent.ActualVisitStartTime <= :endDateTime
                       and TaskType = 'PromotionCheck' order by Parent.ActualVisitStartTime limit 50000];
        }        
        return aTasks;
    }
    
    //Method to get Parent Object data - Visit,RetailStore, RetailLocationGroup
    public Static Map<Id,String> getTaskParentInfo(List<AssessmentTask> aTasks){
        
        //system.debug('***enter getTaskParentInfo***');
        
        List <Id> recId = new List <Id> ();
        
        Map<Id,Id> tempMap = new Map<Id,Id>();
        
        for (AssessmentTask at : aTasks) {
            recId.add(at.Parent.PlaceId);
            tempMap.put(at.Id, at.Parent.PlaceId);
            //system.debug('***enter getTaskParentInfo***' + at.Id + '***'+at.Parent.PlaceId);
        }        
        Map<Id,String> rsgMap = new Map<Id,String>();
        
        List<RetailStore> rs = [select Id,Name,RetailLocationgroup.Name from RetailStore where Id = :recId];
        
        for(AssessmentTask at1 : aTasks){
            Id tempRG = tempMap.get(at1.Id);
            //system.debug('inside first for-- '+tempRG);
            for(RetailStore tempRS : rs){
                if(tempRG == tempRS.Id){
                    rsgMap.put(at1.Id,tempRS.RetailLocationGroup.Name);
                }
            }
        }
        return rsgMap;
        
    }
    
    //Method to get CDLs
    public static List<ContentDocumentLink> getCDLMap(List<AssessmentTask> aTasks){
        //system.debug('***enter getCDLMap***');
        //Make a List of AssessmentTask IDs
        List <Id> AssessTaskList = new List <Id> ();
        for (AssessmentTask at : aTasks) {
            AssessTaskList.add(at.Id); 
        }
        //Map<Id,ContentDocumentLink> cdlMap = new Map<Id,ContentDocumentLink>();
        List<ContentDocumentLink> cdList = [SELECT Id, ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, 
                                            LinkedEntityId, LinkedEntity.Name, LinkedEntity.Type, ShareType, Visibility 
                                            FROM ContentDocumentLink WHERE LinkedEntityId = :AssessTaskList];
        
        
        return cdList;
    }
}
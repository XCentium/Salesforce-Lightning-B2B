public class PartnerPortalWelcomeController {
    public List<Lead> LeadInbox {get; set;}
    public List<Solution> TopSolutions {get; set;}
    public List<ApprovalRequests> ApprovalRequests {get; set;}

    public String sortField1 {get; set;}
    public String previousSortField1 {get; set;}
       
    public User getPartnerUser() {
         User PartnerUser= [select u.Contact.AccountId,u.Contact.Account.Owner.Name,u.Contact.Account.Owner.Email from User u where u.id= :UserInfo.getUserId() limit 1];
         if (PartnerUser == null) {return null;}
         return PartnerUser;
    }

    public PartnerPortalWelcomeController() {
        LeadInbox = [select Id, Name, Title, City, Company, toLabel(Industry),
                                       CreatedDate, IsConverted, IsUnreadByOwner, OwnerId, Owner.Type, 
                                       LeadSource, ConvertedOpportunityId, ConvertedOpportunity.Name 
                                from Lead 
                                where IsConverted = false and Owner.Type='Queue' order by CreatedDate desc limit 5];
        
        TopSolutions = [select id,SolutionName,TimesUsed,LastModifiedDate from Solution order by TimesUsed desc limit 3];
        
        ApprovalRequests = new List<ApprovalRequests>();
        List<ProcessInstanceStep>Requests = [select Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type,
                                                  ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId
                                             from ProcessInstanceStep 
                                             where StepStatus = 'Started' AND ActorId=:UserInfo.getUserId() AND ProcessInstance.TargetObject.Name != ''
                                             order by CreatedDate DESC LIMIT 5];
        for(ProcessInstanceStep Request : Requests){
            ApprovalRequests ar = new ApprovalRequests(Request);
            ApprovalRequests.add(ar);   
        }
    }

    public Integer getExpiringDealRegs() {
    	RecordType PartnerOpportunityRecordType = [Select Id From RecordType where Name like 'Indirect (Partner)'];
        return [select count()from Opportunity where LeadSource='Deal Registration' AND RecordTypeId=:PartnerOpportunityRecordType.Id AND ownerid=:UserInfo.getUserId() AND IsClosed = False];
    }
    
    public Integer getActiveLeads() {	
        return [select count()from Lead where IsConverted=FALSE AND ownerid=:UserInfo.getUserId()];
    }
    
    public PageReference AcceptLead() {
        
        String leadId = System.currentPageReference().getParameters().get('LeadId');      
        Lead theLead = [Select id from Lead where id = :leadId];
        
        theLead.OwnerId = UserInfo.getUserId();
        update theLead; 
        
        PageReference page = new PageReference('/apex/PartnerPortalWelcome');
        page.getParameters().put('lead_id',theLead.Id);
        
        page.setRedirect(true);
        return page;
    }

    
    public class ApprovalRequests {
        
        public ProcessInstanceStep pi {get; set;}
        
        public String TargetObjectName {get; set;}
        
        public String TargetObjectType {
            get { return TargetObjectType; }
            set { TargetObjectType = value; }
        }
        
        public String SubmittedDate {
            get { return SubmittedDate; }
            set { SubmittedDate = value; }
        }
        
        public ApprovalRequests(ProcessInstanceStep p){
            pi = p;
            TargetObjectName = pi.ProcessInstance.TargetObject.Name;
            TargetObjectType = pi.ProcessInstance.TargetObject.Type;
            Datetime Temp = Datetime.newInstance(pi.CreatedDate.year(), pi.CreatedDate.month(), pi.CreatedDate.day());
            SubmittedDate = Temp.format('MMMM dd, yyyy');           
            
        }
    }
    
    public void SortLeads(){
        String order = 'asc';
        if(previousSortField1 == sortField1){
            order = 'desc';
            previousSortField1 = null;
        }else{
            previousSortField1 = sortField1;
        }
        superSort.sortList(LeadInbox,sortField1,order);
    }
    
    /*
    public List<ApprovalRequests> getApprovalRequests() {
        List<ApprovalRequests> ApprovalRequests = new List<ApprovalRequests>();
        List<ProcessInstanceStep>Requests = [select Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type,
                                                  ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId
                                             from ProcessInstanceStep 
                                             where StepStatus = 'Started' AND ActorId=:UserInfo.getUserId() AND ProcessInstance.TargetObject.Name != ''
                                             order by CreatedDate DESC LIMIT 5];
        for(ProcessInstanceStep Request : Requests){
            ApprovalRequests ar = new ApprovalRequests(Request);
            ApprovalRequests.add(ar);   
        }
        if (ApprovalRequests.isEmpty()) {return null;}
        return ApprovalRequests;
    }
*/
    

}
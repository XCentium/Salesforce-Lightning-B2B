public class SSEPortalHome {
   
   User loggedInUser = [Select id,contactId,Contact.AccountId,Branding_Template__c from User where id = :UserInfo.getUserId()];
   
   public Org_Template__c userTemplate {get;set;}
   public List<Asset> MyRegisteredProducts {get; set;}
   public List<Case> MyRecentCases {get; set;}
   public List<Solution> TopSolutions {get; set;}
   public List<Idea> PopularIdeas {get; set;}
   public List<Entitlement> MyEntitlements {get; set;}
   public List<Lead> LeadInbox {get; set;}
   public List<ApprovalRequests> ApprovalRequests {get; set;}
   public List<Case> AllCases {get;set;}
   public List<Entitlement> AllEntitlements {get; set;}

   //Populate lists
   public SSEPortalHome() {
        MyRegisteredProducts = [select id,Name,SerialNumber,InstallDate,UsageEndDate,Status, Image__c from Asset where ContactId = :loggedInUser.ContactId order by SerialNumber desc limit 5];
        MyRecentCases = [select id,CaseNumber,Subject,Status,LastModifiedDate from Case where ContactId = :loggedInUser.ContactId order by LastModifiedDate desc limit 3];
        AllCases = [select id,CaseNumber,Subject,Status,LastModifiedDate from Case where ContactId = :loggedInUser.ContactId order by LastModifiedDate]; 
        TopSolutions = [select id,SolutionName,TimesUsed,LastModifiedDate from Solution order by TimesUsed desc limit 3];            
        PopularIdeas = [select id,Title,VoteTotal from Idea order by VoteTotal desc limit 3];
        MyEntitlements = [select id, name, type, accountid, asset.name, assetid, status from Entitlement where Accountid = :loggedInUser.Contact.Accountid order by name desc limit 3];   
        AllEntitlements = [select id, name, type, accountid, asset.name, assetid, status from Entitlement where Accountid = :loggedInUser.Contact.Accountid order by name desc];   
        LeadInbox = [select Id, Name, Title, City, Company, toLabel(Industry),CreatedDate, IsConverted, IsUnreadByOwner, OwnerId, Owner.Type, LeadSource, ConvertedOpportunityId, ConvertedOpportunity.Name from Lead where IsConverted = false and Owner.Type='Queue' order by CreatedDate desc limit 5];
        ApprovalRequests = new List<ApprovalRequests>();
        List<ProcessInstanceStep> Requests = [select Id, ProcessInstance.TargetObject.Name, ProcessInstance.TargetObject.Type,ProcessInstance.Status, CreatedDate, ProcessInstance.Id, ProcessInstance.TargetObjectId from ProcessInstanceStep where StepStatus = 'Started' AND ActorId=:UserInfo.getUserId() AND ProcessInstance.TargetObject.Name != '' order by CreatedDate DESC LIMIT 5];
        for(ProcessInstanceStep Request : Requests){
            ApprovalRequests ar = new ApprovalRequests(Request);
            ApprovalRequests.add(ar);   
        }
        List<Org_Template__c> templateList = [SELECT Back_Google_Chart_1__c, Back_Google_Chart_2__c, Back_Google_Chart_3__c, Back_Google_Chart_4__c, Back_Background_G_B__c,Back_Background_G_T__c,Back_Body_G_B__c,Back_Body_G_T__c,Back_Button_G_B__c,Back_Button_G_T__c,Back_Button_H_G_B__c,Back_Button_H_G_T__c,Back_Footer_G_B__c,Back_Footer_G_T__c,Back_Header_B_G_B__c,Back_Header_B_G_T__c,Back_Header_Mid_G_B__c,Back_Header_Mid_G_T__c,Back_Header_T_G_B__c,Back_Header_T_G_T__c,Back_Navigation_Menu_H__c,Back_Navigation_Menu__c,Back_Page_Block_G_B__c,Back_Page_Block_G_T__c,Back_Page_Block_Header_G_B__c,Back_Page_Block_Header_G_T__c,Back_Page_Block_Table_Even__c,Back_Page_Block_Table_Odd__c,Back_Side_Button_G_B__c,Back_Side_Button_G_T__c,Back_Side_Button_H_G_B__c,Back_Side_Button_H_G_T__c,Back_Side_G_B__c,Back_Side_G_T__c,Back_Side_Module_G_B__c,Back_Side_Module_G_T__c,Back_Side_Module_Header_G_B__c,Back_Side_Module_Header_G_T__c,Back_Side__c,Back_Tab_A_G_B__c,Back_Tab_A_G_T__c,Back_Tab_G_B__c,Back_Tab_G_T__c,Back_Tab_H_G_B__c,Back_Tab_H_G_T__c,Component_Approvals__c,Component_Articles__c,Component_Cases__c,Component_Charts__c,Component_Entitlements__c,Component_Ideas__c,Component_Image__c,Component_Leads__c,Component_Products__c,Component_Solutions__c,ConnectionReceivedId,ConnectionSentId,CreatedById,CreatedDate,Font_Colour_Button_H__c,Font_Colour_Button__c,Font_Colour_Main__c,Font_Colour_Navigation_Menu_H__c,Font_Colour_Navigation_Menu__c,Font_Colour_Page_Title__c,Font_Colour_Secondary_Title__c,Font_Colour_Side_Button_H__c,Font_Colour_Side_Button__c,Font_Colour_Side_Header__c,Font_Colour_Small_Information__c,Font_Colour_Tab_A__c,Font_Colour_Tab_H__c,Font_Colour_Tab__c,Font_Decoration_Button_H__c,Font_Decoration_Button__c,Font_Decoration_Main__c,Font_Decoration_Navigation_Menu_H__c,Font_Decoration_Navigation_Menu__c,Font_Decoration_Page_Title__c,Font_Decoration_Secondary_Title__c,Font_Decoration_Side_Button_H__c,Font_Decoration_Side_Button__c,Font_Decoration_Side_Header__c,Font_Decoration_Small_Information__c,Font_Decoration_Tab_A__c,Font_Decoration_Tab_H__c,Font_Decoration_Tab__c,Font_Size_Button_H__c,Font_Size_Button__c,Font_Size_Main__c,Font_Size_Navigation_Menu_H__c,Font_Size_Navigation_Menu__c,Font_Size_Page_Title__c,Font_Size_Secondary_Title__c,Font_Size_Side_Button_H__c,Font_Size_Side_Button__c,Font_Size_Side_Header__c,Font_Size_Small_Information__c,Font_Size_Tab_A__c,Font_Size_Tab_H__c,Font_Size_Tab__c,Font_Transform_Button_H__c,Font_Transform_Button__c,Font_Transform_Main__c,Font_Transform_Navigation_Menu_H__c,Font_Transform_Navigation_Menu__c,Font_Transform_Page_Title__c,Font_Transform_Secondary_Title__c,Font_Transform_Side_Button_H__c,Font_Transform_Side_Button__c,Font_Transform_Side_Header__c,Font_Transform_Small_Information__c,Font_Transform_Tab_A__c,Font_Transform_Tab_H__c,Font_Transform_Tab__c,Font_Weight_Button_H__c,Font_Weight_Button__c,Font_Weight_Main__c,Font_Weight_Navigation_Menu_H__c,Font_Weight_Navigation_Menu__c,Font_Weight_Page_Title__c,Font_Weight_Secondary_Title__c,Font_Weight_Side_Button_H__c,Font_Weight_Side_Button__c,Font_Weight_Side_Header__c,Font_Weight_Small_Information__c,Font_Weight_Tab_A__c,Font_Weight_Tab_H__c,Font_Weight_Tab__c,Id,Image_Background__c,Image_Body__c,Image_Button_H__c,Image_Button__c,Image_Footer__c,Image_Logo__c,Image_Page_Block_Header__c,Image_Slide1__c,Image_Slide2__c,Image_Slide3__c,IsDeleted,LastModifiedById,LastModifiedDate,Name,OwnerId,Position_Page__c,Position_Sidebar__c,Position_Slider__c,Position_Tabs__c,Radius_Button__c,Radius_Page_Block__c,Radius_Side_Button__c,Radius_Side_Module__c,Radius_Side__c,Radius_Tab__c,Shadow_Body__c,Shadow_Header__c,Shadow_Page_Block__c,Shadow_Side_Module__c,Shadow_Side__c FROM Org_Template__c WHERE name = :loggedInUser.Branding_Template__c];
        if(templateList.size() > 0)
            userTemplate = templateList[0];
        else
            userTemplate = null;
   }
   
   //Accept lead
   public PageReference AcceptLead(){
        String leadId = System.currentPageReference().getParameters().get('LeadId');      
        Lead theLead = [Select id from Lead where id = :leadId];
        theLead.OwnerId = UserInfo.getUserId();
        update theLead; 
        PageReference page = new PageReference('/apex/SSEPortalHome');
        page.getParameters().put('lead_id',theLead.Id);
        page.setRedirect(true);
        return page;
   }
   
   //Approval requests wrapper
   public class ApprovalRequests{
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
        //Used for test classes because I'm lazy
        public ApprovalRequests(){
            pi = new ProcessInstanceStep();
            TargetObjectName = '';
            TargetObjectType = '';
            Datetime Temp = System.Today();
            SubmittedDate = Temp.format('MMMM dd, yyyy');  
        }
    }
    
    //Test method
    public static testmethod void testSSEPortalHome() {
        PageReference pageRef = Page.SSEPortalHome;
        Test.setCurrentPage(pageRef);
        Lead l = new Lead(LastName = 'Test', Title ='Test', City = 'Test', Company ='Test');
        insert l;
        ApexPages.currentPage().getParameters().put('LeadId', l.id);
        SSEPortalHome controller = new SSEPortalHome();
        controller.AcceptLead();
        ApprovalRequests ap = new ApprovalRequests();
    }
}
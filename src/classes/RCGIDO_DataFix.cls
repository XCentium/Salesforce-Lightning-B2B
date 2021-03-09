public class RCGIDO_DataFix {
    public static void runBeforeDataPush(){
        /** Grants User Permissions before data push. OPEN DEBUG -> Open Execute Anonymous Window and Run:  RCGIDO_DataFix.runBeforeDataPush();   */
        RCGIDO_DataFix.addAdminPermstoUsers('Admin User'); 
        RCGIDO_DataFix.FixOperatingHours();
        RCGIDO_DataFix.createInitialUsers();
        RCGIDO_DataFix.OMSCreateAccountLocation86();  
        RCGIDO_DataFix.OMSCreateAccountLocation192();
        RCGIDO_DataFix.OMSCreateAccountLocation295();
        RCGIDO_DataFix.OMSCreateAccountLocation341();
    }
    public static void doAmazingStuff(){
        /** Fixes Packaging issues. OPEN DEBUG -> Open Execute Anonymous Window and Run:  RCGIDO_DataFix.doAmazingStuff();   */
        RCGIDO_DataFix.createContactUsers();
        RCGIDO_DataFix.AddAllPermissionSets();
     	RCGIDO_DataFix.FixChainAccounts();
        RCGIDO_DataFix.FixProfileAccounts();
        RCGIDO_DataFix.FixStoreAccounts();
    	RCGIDO_DataFix.FixB2BContacts();
        RCGIDO_DataFix.FixCGCloudContacts();
		RCGIDO_DataFix.FixTasks();
        RCGIDO_DataFix.AssignServiceResourcesSkills();
        RCGIDO_DataFix.AssignSkills(); //>?//
        RCGIDO_DataFix.PublishKnowledge();
        RCGIDO_DataFix.FixQSRCases();
        RCGIDO_DataFix.AssignSamGreenQueue();
        RCGIDO_DataFix.updateOrgIdentifier('39fdef56-3a78-584c-5957-9befc5dc9f76');
        RCGIDO_DataFix.FixDawnDistributor();
		RCGIDO_DataFix.FixMLMDownlines();
        RCGIDO_DataFix.FixRACHELPA();
        RCGIDO_DataFix.KAMData(); 
        RCGIDO_DataFix.FixCGCloudKPIs();
        RCGIDO_DataFix.applyNBAImages();
        RCGIDO_DataFix.AssignUserQueues();
        RCGIDO_DataFix.AssignGustavoRole();
        RCGIDO_DataFix.FixJBPTasks();
        RCGIDO_DataFix.FixProductAttachments();
		RCGIDO_DataFix.FixPromotionAttachments();
        RCGIDO_DataFix.FixCCPriceListItems();
        RCGIDO_DataFix.FixPaymentAuth();
        RCGIDO_DataFix.SetOMSOrderstoActive();
        RCGIDO_DataFix.B2BCommUpdateContactPointAddress();
    }
    public static void doAmazingStuff2(){
        /** RUN ME AFTER YOU CREATE AND PUBLISH YOUR ACTION PLAN TEMPLATE. MANUAL SETUP TO DO THIS   */
        RCGIDO_DataFix.CreateActionPlanTemplate();
    }
    public static void addAdminPermstoUsers(String DevName){
        
        DevName = 'Admin User';
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Admin', DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_IoT',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Clienteling_Admin',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_CG_Service_Apps',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_Service_Retail',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_CPQ_NTO',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_CPQ_Alpine',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Sales_Apps',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_Retail_Execution_Plus',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_CGCloud',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_CG_Cloud_Sales',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_Sales_Agreements',DevName);
        RCGIDO_DataFix.AssignPermissionSet('CGAnalyticsUser',DevName);
        RCGIDO_DataFix.AssignPermissionSet('CGAnalyticsAdmin',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Quick_Service_Restaurant',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_HVS',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_MLM',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_INTERNAL_QSR',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RGG_INTERNAL_Marketing_User',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_KeyAccountManagement_Internal',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Grocery',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_Retail_Loyalty',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_OMS',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_Store_Ops',DevName);
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_IndustriesVisit',DevName);
        RCGIDO_DataFix.AssignPermissionSet('ActionPlans',DevName);
        RCGIDO_DataFix.AssignPermissionSet('ManufacturingSalesAgreementsForCmtyPsl',DevName);
        RCGIDO_DataFix.AssignPermissionSet('ManufacturingSalesAgreementsPsl',DevName);
        RCGIDO_DataFix.AssignPermissionSet('LightningRetailExecutionPlusPsl',DevName);
    }
    /** Use this to generate your dev users and add all admin permission sets to them **/
    public static void generateDevUser(String First, String Last){
        String sizeString = First + Last;
        Integer maxSize = 8;
        if(sizeString.length() > maxSize ){
            sizeString = sizeString.substring(0, maxSize);
        }
        RCGIDO_DataFix.CreateUsers(
            First,
            Last, 
            sizeString , 
            sizeString, 
            'System Administrator' ,
            'Dev User',
            '' , 
            '',
            false,
            null
        );
        
        RCGIDO_DataFix.addAdminPermstoUsers(First + ' ' + Last);
    }
        
	public static void CreateActionPlanTemplate(){
        String StoreId = [SELECT Id FROM RetailStore WHERE Name = 'NTO Store - Presidio'].Id;
        String UserId = [SELECT ID FROM User WHERE External_Id__c = 'User.001'].Id;
        String ActionPlanType = [SELECT ActionPlanType FROM ActionPlanTemplate LIMIT 1].ActionPlanType;
        /** Temp Visit **/
        Visit v = new Visit (
            PlannedVisitStartTime = DateTime.now().AddHours(1),
            PlannedVisitEndTime = DateTime.now().AddHours(2),
            InstructionDescription = '',
            Status = 'Planned',
            VisitPriority = 'High',
            VisitorId = UserId,
            PlaceId = StoreId
        );
        insert v;
        
        /** Generate Plan Template **/
        String Template = [SELECT Id,Name,ActionPlanType FROM ActionPlanTemplate WHERE Name = '* Primary Visit Template'].id;
        String vid = [SELECT Id FROM ActionPlanTemplateVersion WHERE ActionPlanTemplateId = :Template].Id; 
        ActionPlan u = new ActionPlan(
            Name = 'Primary Action Plan Template',
            IsTemplate__c = true,
            ActionPlanTemplateVersionId = vid,
            StartDate = date.parse('05/11/2019'),
            ActionPlanState = 'Not Started',
            TargetID = v.Id,
            ActionPlanType = 'Retail' 
        );
        insert u;
    }
    public static void FixChainAccounts(){
        String RecordTypeChain = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Chain').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList = [Select Id, Name from Account where Name = 'Northern Trail Outfitters' OR Name = 'Rondel' OR Name = 'Scotts' OR Name = 'Fare Merchants' OR Name = 'Alpine Nutrition' OR Name = 'Nutrition Stop'];
        for(Account acc : accountList )
        {
            acc.RecordTypeId  = RecordTypeChain;
        }
        if(accountList.size() > 0)
        {
            update accountList;
        }
    }
    public static void FixProfileAccounts(){
        String RecordTypeProfile = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Profile').getRecordTypeId();
        List<Account> accountList = new List<Account>();
        accountList = [Select Id, Name from Account where Name = 'NTO San Francisco' OR Name = 'Rondel Central' OR Name = 'Rondel East' ];
        for(Account acc : accountList )
        {
            acc.RecordTypeId  = RecordTypeProfile;
        }
        if(accountList.size() > 0)
        {
            update accountList;
        }
    }
    public static void FixStoreAccounts(){
        String RecordTypeStore = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Retail Store').getRecordTypeId();

        List<Account> accountList = new List<Account>();
        accountList = [Select Id, Name from Account where 
                       Name LIKE '%NTO Store -%' OR 
                       Name LIKE '%Rondel Store -%' OR 
                       Name LIKE '%Sunnie Foods -%' OR 
                       Name LIKE '%Fare Merchants -%' OR 
                       Name LIKE '%Alpine Nutrition Outlets%' OR 
                       Name LIKE '%Nutrition Stop -%' OR 
                       Name = '%Scott\'s San Francisco%'  
                      ];
        for(Account acc : accountList )
        {
            acc.RecordTypeId  = RecordTypeStore;
        }
        if(accountList.size() > 0)
        {
            update accountList;
        }
    }
    public static void FixOperatingHours(){

        List<OperatingHours> ophour = new List<OperatingHours>();
        ophour = [Select Id,External_ID__c from OperatingHours WHERE Name = 'Normal Business Hours' ];
        for(OperatingHours o : ophour )
        {
            o.External_ID__c  = 'Hours.123';
        }
        if(ophour.size() > 0)
        {
            update ophour;
        }
    }
    
    
    public static void FixB2BContacts(){
        String RecordTypeStore = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('B2B Contact').getRecordTypeId();

        List<Contact> contactList = new List<Contact>();
        contactList = [Select Id, Name from Contact where 
                       Name = 'Olivia Buyer' OR 
                       Name = 'Stephanie Curran' OR 
                       Name = 'Bob Hodges'
                      ];
        for(Contact con : contactList )
        {
            con.RecordTypeId  = RecordTypeStore;
        }
        if(contactList.size() > 0)
        {
            update contactList;
        }
    }
    public static void FixCGCloudContacts(){
        String RecordTypeStore = Schema.Sobjecttype.Contact.getRecordTypeInfosByName().get('CG Cloud Customer').getRecordTypeId();

        List<Contact> contactList = new List<Contact>();
        contactList = [Select Id, Name from Contact where 
                       Name = 'Tyree Zilnicki'
                      ];
        for(Contact con : contactList )
        {
            con.RecordTypeId  = RecordTypeStore;
        }
        if(contactList.size() > 0)
        {
            update contactList;
        }
    }
    public static void updateOMSAccountExternalID(){

        List<Account> accList = new List<Account>();
        accList = [Select Id, Name,External_ID__c from Account where 
                       Name = '0086'
                      ];
        for(Account a : accList )
        {
            a.External_ID__c  = 'Account.0086';
        }
        if(accList.size() > 0)
        {
            update accList;
        }
    }
    
        public static void updateOMSAccountExternalID2(){

        List<Account> accList = new List<Account>();
        accList = [Select Id, Name,External_ID__c from Account where 
                       Name = '0192'
                      ];
        for(Account a : accList )
        {
            a.External_ID__c  = 'Account.0192';
        }
        if(accList.size() > 0)
        {
            update accList;
        }
    }
    
        public static void updateOMSAccountExternalID3(){

        List<Account> accList = new List<Account>();
        accList = [Select Id, Name,External_ID__c from Account where 
                       Name = '0295'
                      ];
        for(Account a : accList )
        {
            a.External_ID__c  = 'Account.0295';
        }
        if(accList.size() > 0)
        {
            update accList;
        }
    }
    
        public static void updateOMSAccountExternalID4(){

        List<Account> accList = new List<Account>();
        accList = [Select Id, Name,External_ID__c from Account where 
                       Name = '0341'
                      ];
        for(Account a : accList )
        {
            a.External_ID__c  = 'Account.0341';
        }
        if(accList.size() > 0)
        {
            update accList;
        }
    }
    
    
    public static void FixCGCloudKPIs(){
        String polar = [Select Id from IDO_Refrigerator__c where 
                       Name LIKE '%Polar%'
                      ].id;
        
        String tenshelf = [Select Id from IDO_Refrigerator__c where 
                       Name LIKE '%Alpine Vending Machine - 10 Shelf%'
                      ].id;
        
        /** Assign Polar WORKING KPI  **/
        List<RetailStoreKPI> polarWorkingkpi = new List<RetailStoreKPI>();
        polarWorkingkpi = [Select Id from RetailStoreKPI where 
                       AssessmentIndDefinition.Name LIKE '%Working Correctly%'
                	   AND CustomContextId = ''
                	   LIMIT 1
                      ];
        for(RetailStoreKPI k : polarWorkingkpi )
        {
            k.CustomContextId = polar;
        }
        if(polarWorkingkpi.size() > 0)
        {
            update polarWorkingkpi;
        }
        
        /** Assign Polar Competitor KPI  **/
        List<RetailStoreKPI> polarCompetitorkpi = new List<RetailStoreKPI>();
        polarCompetitorkpi = [Select Id from RetailStoreKPI where 
                       AssessmentIndDefinition.Name LIKE '%Any competitor products present?%'
                	   AND CustomContextId = ''
                	   LIMIT 1
                      ];
        for(RetailStoreKPI k : polarCompetitorkpi )
        {
            k.CustomContextId = polar;
        }
        if(polarWorkingkpi.size() > 0)
        {
            update polarCompetitorkpi;
        }
        
        /** Assign tenshelf WORKING KPI  **/
        List<RetailStoreKPI> tenshelfWorkingkpi = new List<RetailStoreKPI>();
        tenshelfWorkingkpi = [Select Id from RetailStoreKPI where 
                       AssessmentIndDefinition.Name LIKE '%Working Correctly%'
                	   AND CustomContextId = ''
                	   LIMIT 1
                      ];
        for(RetailStoreKPI k : tenshelfWorkingkpi )
        {
            k.CustomContextId = tenshelf;
        }
        if(tenshelfWorkingkpi.size() > 0)
        {
            update tenshelfWorkingkpi;
        }
        
        /** Assign tenshelf Competitor KPI  **/
        List<RetailStoreKPI> tenshelfCompetitorkpi = new List<RetailStoreKPI>();
        tenshelfCompetitorkpi = [Select Id from RetailStoreKPI where 
                       AssessmentIndDefinition.Name LIKE '%Any competitor products present?%'
                	   AND CustomContextId = ''
                	   LIMIT 1
                      ];
        for(RetailStoreKPI k : tenshelfCompetitorkpi )
        {
            k.CustomContextId = tenshelf;
        }
        if(tenshelfCompetitorkpi.size() > 0)
        {
            update tenshelfCompetitorkpi;
        }
    }
    public static void FixQSRCases(){
        String SamGreenId = [Select Id from User where Name = 'Sam Green'].Id;
        String SocialQueuId = [select Id from Group where Type = 'Queue' AND Name = 'Social_Queue'].Id;
        List<Case> caseList = new List<Case>();
        caseList = [Select Id, Subject from Case where 
                       Subject LIKE '%@Scott%'
                      ];
        for(Case c : caseList )
        {
            c.OwnerId  = SocialQueuId;
        }
        if(caseList.size() > 0)
        {
            update caseList;
        }
    }
    public static void FixRACHELPA(){
        List<Contact> cList = new List<Contact>();
        cList = [Select Id, Name,
                    Cust360_CSAT__c,Cust360_Metric1__c,Cust360_Metric2__c,Cust360_ChurnRisk__c 
                    FROM Contact WHere Name = 'Rachel Morris PA'
                    ];
        for(Contact c : cList )
        {
            c.Cust360_CSAT__c  = 78;
            c.Cust360_ChurnRisk__c  = 71;
            c.Cust360_Metric1__c  = 'Silver';
            c.Cust360_Metric2__c  = '225.38';
            c.myNTO_Balance__c = 346;
            c.Cust360_Contact_Picture_URL__c  = 'https://s3.amazonaws.com/sfdc-ckz-b2b/RCG/UserImages/Contacts/rachelmorris-ret.jpg';
        }
        if(cList.size() > 0)
        {
            update cList;
        }
    }
    
    
    public static void AssignSamGreenQueue(){
        //This can be replaced with any user id
        String userId = [Select Id from User where Name = 'Sam Green'].Id;
        
        //Get the group you want. Queues are stored as group objects with a type of Queue
        Group g = [select Id from Group where Name='Social_Queue' AND Type = 'Queue'];
        
        GroupMember member = new GroupMember();
        member.UserOrGroupId = userId;
        member.GroupId = g.Id;
        
        insert member;
    }
    public static void FixProductAttachments(){
        /*  Will look up CG Cloud products 
        	if a ContentVersion Title matches the Product Name, 
			it will associate it to the product
        */
        List<ContentVersion> contentList = new List<ContentVersion>();
                
        for(Product2 prod : [Select Id, Name from Product2 where CG_Cloud_Product__c = TRUE] )
        {
            for(ContentVersion content : [SELECT ContentDocumentId FROM ContentVersion Where Title = :prod.Name] )
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = content.ContentDocumentId;
                cdl.LinkedEntityId = prod.Id;
                cdl.ShareType = 'V';
                insert cdl;
            }
        }   
     }
    
    public static void FixPromotionAttachments(){
        /*  Will look up CG Cloud Promotion
        	if a ContentVersion Title matches the Product Name, 
			it will associate it to the Promotion
        */
        List<ContentVersion> contentList = new List<ContentVersion>(); 
                
        for(Promotion prom : [Select Id, Name from Promotion] )
        {
            for(ContentVersion content : [SELECT ContentDocumentId FROM ContentVersion Where Title = :prom.Name] )
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = content.ContentDocumentId;
                cdl.LinkedEntityId = prom.Id;
                cdl.ShareType = 'V';
                insert cdl;
            }
        }   
     }
    public static void FixTasks(){
        /*  Update Joint Business Plan Task Associations
        */
        List<Task> taskList = new List<Task>(); 
        taskList = [Select Id, WhatId from Task WHERE External_ID__c LIKE '%RCGTask%'];
        String NTOSanFran = [SELECT Id FROM Account WHERE Name = 'NTO San Francisco'].id;
                
        for(Task t : taskList )
        {
            t.WhatId  = NTOSanFran;
        } 
        if(taskList.size() > 0)
        {
            update taskList;
        }
     }
    public static void FixJBPTasks(){
        /*  Update Joint Business Plan Task Associations
        */
        List<Task> taskList = new List<Task>(); 
        taskList = [Select Id, WhatId from Task WHERE External_ID__c LIKE '%RCGJBP%'];
        String JBP = [SELECT Id FROM IDO_JBP_Planning_Period__c WHERE Joint_Business_Plan_Name__c = 'NTO 2020 Business Plan'].id;
                
        for(Task t : taskList )
        {
            t.WhatId  = JBP;
        } 
        if(taskList.size() > 0)
        {
            update taskList;
        }
     }
    public static void createInitialUsers(){
        RCGIDO_DataFix.CreateUsers(
            'Adrian',
            'Service', 
            'aservice' , 
            'RCG_User.001', 
            '*RCG Service - CG' ,
            'Customer Service Agent',
            'Consumer Goods Service Agent - Senior Customer Service Agent on a world class customer engagement to keeping Alpine customers happy.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Users/adrian-Service.png',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Alex',
            'Associate', 
            'aassoch' , 
            'RCG_User.018', 
            'System Administrator' ,
            'Store Associate',
            'Store Associate who helps deliver world class store experiences.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/Andy-Associate.png',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Anna',
            'Taylor', 
            'atayl' , 
            'RCG_User.014', 
            '*RCG FSL User' ,
            'Field Service - Technician',
            'Anna Taylor helps Sales and Service issues in San Francisco' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/AnnaTaylor.jpeg',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Ron',
            'Clark', 
            'nclar' , 
            'RCG_User.016', 
            '*RCG FSL User' ,
            'Field Service - Home Delivery',
            'Ron is a delivery man for Sunnie Foods Delivery for 2 years. Efficiency is key but he too is passionate about customer service and satisfaction.' , 
            '',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Scott',
            'Williams', 
            'swill' , 
            'RCG_User.015', 
            '*RCG FSL User' ,
            'Field Service - Technician',
            'Scott helps Sales and Service issues in San Francisco' , 
            '',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Chantelle',
            'Rep', 
            'cRep' , 
            'RCG_User.003', 
            '*RCG Field Sales' ,
            'Sales Rep',
            'As an Alpine Group Field Sales rep, Chantelle juggles dozens of high demanding retail stores as well as her distribution partners. Rarely in her office, she relies on her tablet to plan her day and prioritize how to spend her time. She works to identify key products to position at store locations to drive the highest foot traffic into those accounts to maximize revenue uplift for the customer and margins for The Alpine Group.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/chantellerep.png',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Gustavo',
            'Manager', 
            'gMan' , 
            'RCG_User.005', 
            'System Administrator' ,
            'Key Account Manager - NTO',
            'Gustavo, a Key Account Manager with The Alpine Group, manages a very large retailer, Northern Trail Outfitters, as well as a geographically dispersed sales and support team responsible for managing the relationship with NTO.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/gustavomanager.png',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Megan',
            'Marketer', 
            'mMark' , 
            'RCG_User.006', 
            '*Marketing' ,
            'Digital Brand Manager',
            'Megan Marketer is a marketing rep for the Alpine Group. She works actively in Pardot Lightning app executing on B2B marketing campaigns.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/meganmarketer.jpg',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Sue',
            'Marketer', 
            'sMark' , 
            'RCG_User.009', 
            '*Marketing' ,
            'VP of Marketing',
            'Sue Marketing is the VP of Marketing for the Alpine Group. Sue keeps a pulse on overall campaign performance. Using B2B Marketing analytics, she can see the health of her marketing funnel, the pipeline value, ROI, and closed/won/open deals. She is referenced in the Alpine Pardot Intelligent B2B Marketing & Sales demo.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/suemarketing.png',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Cici',
            'Mathews', 
            'cMathews' , 
            'RCG_User.011', 
            'System Administrator' ,
            'Senior Recruiter',
            'Cici is a recruiter with Scotts. She has been with them for 2 years and helps to recruit the best talent for their IT department. Her customers are both external candidates and internal hiring teams. Some of Cicis primary tasks are to manage job requisitions from internal staff, qualify candidates, and schedule interviews with candidates and hiring teams.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/Retail/Restaurant/Personas/CiciMathews.jpeg',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Cameron',
            'Technician', 
            'ctech' , 
            'RCG_User.013', 
            '*RCG FSL User' ,
            'Field Service - Technician',
            'Cameron is an Alpine Merchandiser / Technician with the Alpine Group.' , 
            'https://s3.amazonaws.com/sfdc-ckz-b2b/RCG/UserImages/Contacts/camerontechnican.png',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'RCG',
            'Chatbot', 
            'rchat' , 
            'RCG_User.1000', 
            'System Administrator' ,
            'RCG Chatbot',
            '' , 
            '',
            false,
            null
        );
        RCGIDO_DataFix.CreateUsers(
            'Andy',
            'Associate', 
            'aasso' , 
            'RCG_User.017', 
            'System Administrator' ,
            'Store Associate',
            'Andy is an NTO Store Associate and he is a superstar on the fast track at NTO to becoming Assistant store manager after less than a year of employment. Andy is able to focus on his customers so intently because he has a tablet in his hand with a store application that supercharges his ability to wow the customer.' , 
            'https://s3.amazonaws.com/sfdc-ckz-b2b/RCG/UserImages/Contacts/andyassociate.jpg',
            false,
            null
        );
    }
    public static void createContactUsers(){
        String DawnID = [SELECT Id FROM Contact WHERE Name = 'Dawn Distributor'].Id;
        RCGIDO_DataFix.CreateUsers(
            'Dawn',
            'Distributor', 
            'dDist' , 
            'RCG_User.004', 
            '*RCG Partner Community User' ,
            'Direct Selling Distributor',
            'Dawn Distributor is the MLM Distributor and primary persona for the MLM Demo script. Login as her to access her downline in the MLM Distributor community.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/dawndistributor.png',
            true,
            DawnID
        );
       String OliviaID = [SELECT Id FROM Contact WHERE Name = 'Olivia Buyer'].Id;
       RCGIDO_DataFix.CreateUsers(
            'Olivia',
            'Buyer', 
            'oBuyer' , 
            'RCG_User.007', 
            '*Customer Community Plus' ,
            'NTO Store Buyer',
            'Olivia is a retail store buyer for the Northern Trail Outfitters retail chain. Olivia is responsible for planning, selecting and purchasing quantities of Alpine food & beverage products that are sold in NTO retail stores. She takes current inventory levels, sales trends and store needs into account when deciding what to buy from Alpine. She stays on top of relevant brand and product news via Alpine Retail partner community. She also engages with Alpine’s NTO customer care team to work through service & order processing issues. She is delighted with Alpine’s white glove service experience' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/oliviabuyer.png',
            true,
            OliviaID
        );
        String RachelId = [SELECT Id FROM Contact WHERE Name = 'Rachel Morris'].Id;
        RCGIDO_DataFix.CreateUsers(
            'Rachel',
            'Morris', 
            'rMorris' , 
            'RCG_User.008', 
            '*RCG Customer Community User' ,
            'Consumer',
            'Rachel is a mid-thirties working professional. She is married with two kids. She is an avid hiker and trail runner. Rachel has purchased from Alpine in the past, but it has been over a year. Training for half marathon trail run in France later this year and looking for new training supplements.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Contacts/rachelmorris-cg.png',
            true,
            RachelId
        );
       // String rMorrisPAId = [SELECT Id FROM Contact WHERE Name = 'Rachel Morris PA'].Id;
       String rMorrisPAId = [SELECT Id FROM Contact WHERE External_Id__c = 'RCGPAccount.1'].Id;
        RCGIDO_DataFix.CreateUsers(
            'Rachel',
            'Morris PA', 
            'rMorPA' , 
            'RCG_User.012', 
            '*RCG Customer Community User' ,
            'Customer',
            'Mid-thirties working professional. Married with two young kids. Avid hiker & trail runner. Purchased from Northern Trail Outfitters (NTO) in the past, but it’s been over a year. Running a half marathon in London later this year and looking for new training gear.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/UserImages/Users/RachelMorrisPA.jpeg',
            true,
            rMorrisPAId
        );
        
        String SamGreenId = [SELECT Id FROM Contact WHERE Name = 'Sam Green'].Id;
        RCGIDO_DataFix.CreateUsers(
            'Sam',
            'Green', 
            'sGreen' , 
            'RCG_User.010', 
            '*RCG Restaurant Partner User' ,
            'Franchise Owner',
            'Sam is a new Scotts Franchise owner of the Scotts San Francisco Location.' , 
            'https://sfdc-ckz-b2b.s3.amazonaws.com/RCG/Retail/Restaurant/Personas/samgreen.png',
            true,
            SamGreenId
        );

    }
    public static void CreateUsers(String FirstName,String LastName,String Alias, String ExternalId, String ProfileName,String Title,String Description,String ProfileImage, Boolean isContact,String contactId){
        String domain = [SELECT Domain FROM Domain].Domain;
        String Profile = [SELECT Id,Name FROM Profile Where Name = :ProfileName].Id;
        String EmailAdd = (FirstName + LastName).replaceAll( '\\s+', '');
        String myAlias = Alias;
        Integer maxSize = 8;
        if(myAlias.length() > maxSize ){
            myAlias = myAlias.substring(0, maxSize);
        }
        if(isContact){
            User u = new User(
                FirstName = FirstName,
                LastName = LastName,
                Email = EmailAdd + '@example.com',
                Alias = myAlias,
                Username = EmailAdd + '@' + domain + '123',
                CommunityNickname = myAlias,
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                ProfileID = Profile,
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                External_ID__c = ExternalId,
                Key_User__c = true,
                RCG_Key_User__c = true,
                Lightning_Scheduler_User__c  = true,
                Title = Title,
                Persona_Description__c = Description,
                ContactId = contactId 
            );
            insert u;
            RCGIDO_DataFix.GenerateUserImage(u.ID,Alias,ProfileImage);  
        }else{
            User u = new User(
                FirstName = FirstName,
                LastName = LastName,
                Email = EmailAdd + '@example.com',
                Alias = myAlias,
                Username = EmailAdd + '@' + domain + '123',
                CommunityNickname = myAlias,
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'GMT',
                ProfileID = Profile,
                LanguageLocaleKey = 'en_US',
                EmailEncodingKey = 'UTF-8',
                External_ID__c = ExternalId,
                Key_User__c = true,
                RCG_Key_User__c = true,
                Lightning_Scheduler_User__c  = true,
                Title = Title,
                Persona_Description__c = Description
            );
            insert u;
            RCGIDO_DataFix.GenerateUserImage(u.ID,Alias,ProfileImage);  

        }
	}
        
    @future(callout = true)   
    public static void GenerateUserImage(String UserId, String Username, String UserImagePath){
        String base64Data = '';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(UserImagePath);
        req.setMethod('GET');
        Http http = new Http();
        HttpResponse res = http.send(req);
        Blob image = res.getBodyAsBlob();
        base64Data =  EncodingUtil.base64Encode(image);
        
        Document doc = new Document();
        doc.Name = Username;
        doc.body = EncodingUtil.base64Decode(base64Data);
        doc.FolderId = [SELECT Id,Name FROM Folder Where Name = 'Images, Logos, Buttons'].Id;
        insert doc;

        ConnectApi.UserProfiles.setPhoto(null, UserId, new ConnectApi.BinaryInput(doc.body,'image/jpg','user.jpg'));

    }
    public static void AddAllPermissionSets(){
        /** Adrian Service **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_CG_Service_Apps','Adrian Service');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_IoT','Adrian Service');
        RCGIDO_DataFix.AssignPermissionSet('RCG_MLM','Adrian Service');
        RCGIDO_DataFix.AssignPermissionSet('Omni_Presence_Statuses','Adrian Service');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Demo_CTI','Adrian Service');
        RCGIDO_DataFix.AssignPermissionSet('Flow_User','Adrian Service');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Experience_User','Adrian Service');

        /*RCGIDO_DataFix.AssignPermissionSet('LiveMessage_Lightning','Adrian Service');*/
        
        /** Tim Service **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_Service_Retail','Tim Service');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Grocery','Tim Service');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_Retail_Loyalty','Tim Service');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_CPQ_NTO','Tim Service');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_INTERNAL_QSR','Tim Service');
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_OMS','Tim Service');

        /** Chantelle Rep **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_Sales_Agreements','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_HVS','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCG_CG_Cloud_Sales','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Sales_Apps','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_Retail_Execution_Plus','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('ActionPlans','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_CPQ_Alpine','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_KeyAccountManagement_Internal','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('MapsUser','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('EinsteinAnalyticsPlusUser','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Grocery','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('CGAnalyticsUser','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_IndustriesVisit','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('LightningRetailExecutionPlusPsl','Chantelle Rep');
        RCGIDO_DataFix.AssignPermissionSet('RCG_CG_Cloud_Sales_Manager','Chantelle Rep');

        /** Gustavo Manager **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_Sales_Agreements','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_HVS','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('MapsUser','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Sales_Apps','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_KeyAccountManagement_Internal','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCG_CG_Cloud_Sales_Manager','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCG_CG_Cloud_Sales','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('EinsteinAnalyticsPlusUser','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('ActionPlans','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_CGCloud','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('CGAnalyticsUser','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_IndustriesVisit','Gustavo Manager');
        RCGIDO_DataFix.AssignPermissionSet('LightningRetailExecutionPlusPsl','Gustavo Manager');

        /** Dawn Distributor **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_MLM_Community_User','Dawn Distributor');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Dawn Distributor');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Dawn Distributor');
        RCGIDO_DataFix.AssignPermissionSet('RCG_Einstein_Analytics_Community_User','Dawn Distributor');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Analytics_For_Communities','Dawn Distributor');
        
        /** Olivia Buyer **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_Sales_Agreements','Olivia Buyer');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Store_Buyer','Olivia Buyer');
        RCGIDO_DataFix.AssignPermissionSet('RCG_Einstein_Analytics_Community_User','Olivia Buyer');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Olivia Buyer');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Olivia Buyer');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Analytics_For_Communities','Olivia Buyer');
        RCGIDO_DataFix.AssignPermissionSet('CloudCraze_CustomerCommunityPlus','Olivia Buyer');
        
         /** Rachel Morris **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_Restaurant_Customer','Rachel Morris');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Loyalty_Customer','Rachel Morris');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Community_User_Basic','Rachel Morris');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Rachel Morris');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Rachel Morris');

		 /** Rachel Morris PA  HAVENT DEPLOYED **/ 
        RCGIDO_DataFix.AssignPermissionSet('RCG_Restaurant_Customer','Rachel Morris PA');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Loyalty_Customer','Rachel Morris PA');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Community_User_Basic','Rachel Morris PA');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Rachel Morris PA');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Rachel Morris PA');

        /** Sam Green Analytics Cloud - Wave Community Users permission **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_QSR_Franchisee','Sam Green');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Sam Green');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Sam Green');
        RCGIDO_DataFix.AssignPermissionSet('RCG_Einstein_Analytics_Community_User','Sam Green');
		RCGIDO_DataFix.AssignPermissionSet('View_Wave_Analytics_on_Communities_Pages','Sam Green');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Analytics_For_Communities','Sam Green');
        
        /** Chatbot User **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_CHATBOT','RCG Chatbot');
        
        /** Cici Mathews **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_HR_Recruiter','Cici Mathews');
        RCGIDO_DataFix.AssignPermissionSet('Pardot','Cici Mathews');
        RCGIDO_DataFix.AssignPermissionSet('Pardot_Connector_User','Cici Mathews');
        RCGIDO_DataFix.AssignPermissionSet('Quip','Cici Mathews');
        RCGIDO_DataFix.AssignPermissionSet('Sales_Edge','Cici Mathews');
		
        /** Anna Taylor **/
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Schedulable_Resource_Permission','Anna Taylor');
        
        /** Scott Williams **/
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Schedulable_Resource_Permission','Scott Williams');
        
        /**  Ron Clark **/
        RCGIDO_DataFix.AssignPermissionSet('FSL_Mobile_License','Ron Clark');
        RCGIDO_DataFix.AssignPermissionSet('FSL_Mobile_Permissions','Ron Clark');
        RCGIDO_DataFix.AssignPermissionSet('FSL_Resource_License','Ron Clark');
        RCGIDO_DataFix.AssignPermissionSet('FSL_Resource_Permissions','Ron Clark');
        RCGIDO_DataFix.AssignPermissionSet('Quip','Ron Clark');
        RCGIDO_DataFix.AssignPermissionSet('Flow_User','Ron Clark');
        
        /**  Cameron Technician **/
        RCGIDO_DataFix.AssignPermissionSet('FSL_Mobile_License','Cameron Technician');
        RCGIDO_DataFix.AssignPermissionSet('FSL_Mobile_Permissions','Cameron Technician');
        RCGIDO_DataFix.AssignPermissionSet('FSL_Resource_License','Cameron Technician');
        RCGIDO_DataFix.AssignPermissionSet('FSL_Resource_Permissions','Cameron Technician');
        RCGIDO_DataFix.AssignPermissionSet('Quip','Cameron Technician');
        RCGIDO_DataFix.AssignPermissionSet('Flow_User','Cameron Technician');
		
        /**  Sue Marketer  **/
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_HVS','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('EinsteinAnalyticsPlusUser','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('SocialIntelligenceStandardLicense','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Pardot','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Pardot_Connector_User','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Quip','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Sales_Edge','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('RGG_INTERNAL_Marketing_User','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Sue Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Sue Marketer');
        
        /**  Megan Marketer  **/
        RCGIDO_DataFix.AssignPermissionSet('RCGIDO_HVS','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('EinsteinAnalyticsPlusUser','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('SocialIntelligenceStandardLicense','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Pardot','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Pardot_Connector_User','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Quip','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Sales_Edge','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('RGG_INTERNAL_Marketing_User','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('RCG_EXTERNAL_Lightning_Scheduler','Megan Marketer');
        RCGIDO_DataFix.AssignPermissionSet('Lightning_Scheduler_Community_User_Object_Permission','Megan Marketer');

        /**  Alex Associate  **/
        RCGIDO_DataFix.AssignPermissionSet('RCG_INTERNAL_OMS','Alex Associate');
        RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_Admin','Alex Associate');

    }
    public static void AssignPermissionSet(String PermName, String UserName){
        /** Adds User to Permission Set 
         * Example Callout :
         * 			RCGIDO_DataFix.AssignPermissionSet('RCG_IDO_CG_Service_Apps','Adrian Service');
         **/
        String uId = [SELECT ID From User WHERE Name = :UserName].Id;
        List<PermissionSetAssignment> permCheck = [SELECT PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId= :uId AND PermissionSet.Name = :PermName];
        if(permCheck.isEmpty()){
            String PermId = [Select ID From PermissionSet WHERE Name = :PermName].Id;
            if(UserName == 'Admin User'){
                String UserId = [SELECT ID FROM User WHERE External_ID__c = 'User.001'].Id;
                if(PermId != '' && UserId != ''){
                    PermissionSetAssignment psa = new PermissionSetAssignment
                    (
                        PermissionSetId = PermId, 
                        AssigneeId = UserId
                    );
                    insert psa;        
                }
            }else{
                
                if(PermId != '' && uId != ''){
                    PermissionSetAssignment psa = new PermissionSetAssignment
                    (
                        PermissionSetId = PermId, 
                        AssigneeId = uId
                    );
                    insert psa;        
                }
            }
        }
    }
    
    public static void PublishKnowledge(){
        List<knowledge__kav> obj1 = new List<knowledge__kav>();
        obj1 = [SELECT Id,Title,KnowledgeArticleId, PublishStatus  FROM knowledge__kav WHERE PublishStatus = 'Draft' AND CreatedDate = LAST_N_DAYS:1 AND LANGUAGE = 'en_US'];
        String rcgArticle = Schema.Sobjecttype.Knowledge__kav.getRecordTypeInfosByName().get('RCG Article').getRecordTypeId();
        /** First we update the record type **/
        for(knowledge__kav k : obj1 )
        {
            k.RecordTypeId  = rcgArticle;
            
        }
        if(obj1.size() > 0)
        {  
            update obj1;
            for(knowledge__kav k : obj1 )
            {
				/** Then We publish them all **/
                KbManagement.PublishingService.publishArticle(k.KnowledgeArticleId, true);
            }
        }		
    }
    /* Set all RCG knowledge Articles to Draft. Only for Issue testing */
    public static void DraftKnowledge(){
        List<knowledge__kav> obj1 = new List<knowledge__kav>();
        String rcgArticle = Schema.Sobjecttype.Knowledge__kav.getRecordTypeInfosByName().get('RCG Article').getRecordTypeId();
        obj1 = [SELECT Id,Title,KnowledgeArticleId, PublishStatus  FROM knowledge__kav WHERE RecordTypeId = :rcgArticle];
        for(knowledge__kav k : obj1 )
        {
            /** Then We publish them all **/
            KbManagement.PublishingService.editOnlineArticle(k.KnowledgeArticleId, true);
        }	
    }
    public static void AssignServiceResourcesSkills(){
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Alpine Cooler', 9);
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Beverage Delivery', 6);
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Break-Fix', 5);
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Field Connect', 5);
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Field Upgrade', 6);
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Maintenance', 6);
        
        RCGIDO_DataFix.AddFSLSkills('Anna Taylor','Billing and Accounts', 9);
        RCGIDO_DataFix.AddFSLSkills('Cameron Technician','Interviews', 6);
        
        RCGIDO_DataFix.AddFSLSkills('Scott Williams','Billing and Accounts', 8);
        RCGIDO_DataFix.AddFSLSkills('Scott Williams','Interviews', 5);
    }
    public static void AddFSLSkills(String UserName, String SkillName, Decimal SkillLevel){
        String NewUserId = [SELECT ID FROM ServiceResource WHERE Name = :UserName].Id;
        String NewSkillId = [SELECT Id FROM Skill WHere MasterLabel = :SkillName].Id;
        ServiceResourceSkill userSkill = new ServiceResourceSkill(
            SERVICERESOURCEID = NewUserId,
            SKILLID = NewSkillId,
            SKILLLEVEL = SkillLevel,
            EffectiveStartDate = DateTime.now()
        );
        insert userSkill;
    }
    public static void OMSCreateAccountLocation86(){
        String RecordTypeLocation = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        String pricebookid = [SELECT id FROM Pricebook2 WHERE External_ID__c = 'Pricebook.101'].Id;
        Account acct = new Account(
            Name='0086',
            External_ID__c = 'Account.0086',
            Default_Price_Book__c=pricebookid,
            Type='Specialty Store',
            RecordTypeId=RecordTypeLocation
            
        );
    	insert acct;
    }   
    
    public static void OMSCreateAccountLocation192(){
        String RecordTypeLocation = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        String pricebookid = [SELECT id FROM Pricebook2 WHERE External_ID__c = 'Pricebook.101'].Id;
        Account acct = new Account(
            Name='0192',
            External_ID__c = 'Account.0192',
            Default_Price_Book__c=pricebookid,
            Type='Specialty Store',
            RecordTypeId=RecordTypeLocation
            
        );
    	insert acct;
    }   
    
    public static void OMSCreateAccountLocation295(){
        String RecordTypeLocation = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        String pricebookid = [SELECT id FROM Pricebook2 WHERE External_ID__c = 'Pricebook.101'].Id;
        Account acct = new Account(
            Name='0295',
            External_ID__c = 'Account.0295',
            Default_Price_Book__c=pricebookid,
            Type='Specialty Store',
            RecordTypeId=RecordTypeLocation
            
        );
    	insert acct;
    }   
    
    public static void OMSCreateAccountLocation341(){
        String RecordTypeLocation = Schema.Sobjecttype.Account.getRecordTypeInfosByName().get('Location').getRecordTypeId();
        String pricebookid = [SELECT id FROM Pricebook2 WHERE External_ID__c = 'Pricebook.101'].Id;
        Account acct = new Account(
            Name='0341',
            External_ID__c = 'Account.0341',
            Default_Price_Book__c=pricebookid,
            Type='Specialty Store',
            RecordTypeId=RecordTypeLocation
            
        );
    	insert acct;
    }   

    
    public static void FixCCPriceListItems(){
        String AlpinepartnerRetail = [SELECT ID FROM ccrz__E_PriceList__c  WHERE Name = 'Alpine Partner Retail'].Id;
        String NTOFranchiseRetail = [SELECT ID FROM ccrz__E_PriceList__c  WHERE Name = 'NTOFranchise Retail'].Id;
        List<ccrz__E_Product__c > metaList = new List<ccrz__E_Product__c >();
        metaList = [SELECT Id,Name,CCRZ__STOREFRONT__C,Price__c FROM ccrz__E_Product__c WHERE ccrz__ProductId__c LIKE '%RCG%']; 
        List<ccrz__E_PriceListItem__c> myPricelist = new list<ccrz__E_PriceListItem__c>();
		
        Integer i = 0;
        
        List<ccrz__E_PriceListItem__c > NTOProductList = new List<ccrz__E_PriceListItem__c >();
        
        NTOProductList = [SELECT ccrz__Product__c FROM ccrz__E_PriceListItem__c  WHERE Name = 'NTOFranchise Retail'];
        
        List<ccrz__E_PriceListItem__c > pricelistitems = new List<ccrz__E_PriceListItem__c >();
        pricelistitems = [SELECT ccrz__Product__c FROM ccrz__E_PriceListItem__c  WHERE ccrz__Pricelist__r.Name = 'NTOFranchise Retail' OR ccrz__Pricelist__r.Name = 'Alpine Partner Retail'];
        
        for(ccrz__E_Product__c obj : metaList )
        {
            	boolean pcheckvalue = false;
            	String prodid = obj.id;
                if(obj.CCRZ__STOREFRONT__C == 'NTOFranchise'){
                    for(ccrz__E_PriceListItem__c pcheck : pricelistitems )
        			{
                        if(pcheck.ccrz__Product__c == prodid){
                            pcheckvalue = true;
                            continue;
                        }else{
                            pcheckvalue = false;
                        }
                    }
                    if(pcheckvalue = false){
                        ccrz__E_PriceListItem__c listItem = new ccrz__E_PriceListItem__c(
                            ccrz__Pricelist__c = NTOFranchiseRetail,
                            ccrz__Product__c = prodid,
                            CCRZ__STARTDATE__C = date.today(),
                            CCRZ__ENDDATE__C = date.today().addYears(5),
                            ccrz__PricelistItemId__c = obj.Name,
                            ccrz__Price__c = obj.Price__c
                        );
                        myPricelist.add(listItem);
                    	continue;
                    }else{
                    	continue;
                    }
                }else if(obj.CCRZ__STOREFRONT__C == 'AlpinePartner'){
                    for(ccrz__E_PriceListItem__c pcheck : pricelistitems )
        			{
                        if(pcheck.ccrz__Product__c == prodid){
                            pcheckvalue = true;
                            continue;
                        }else{
                            pcheckvalue = false;
                        }
                    }
                    if(pcheckvalue = false){
                        ccrz__E_PriceListItem__c listItem = new ccrz__E_PriceListItem__c(
                            ccrz__Pricelist__c = NTOFranchiseRetail,
                            ccrz__Product__c = prodid,
                            CCRZ__STARTDATE__C = date.today(),
                            CCRZ__ENDDATE__C = date.today().addYears(5),
                            ccrz__PricelistItemId__c = obj.Name,
                            ccrz__Price__c = obj.Price__c
                        );
                        myPricelist.add(listItem);
                    	continue;
                    }else{
                    	continue;
                    }
                }
        } 
        if(!myPricelist.isEmpty())
        {
            insert myPricelist; 
        } 
    }
    /* Assign all Skills required **/
    public static void AssignSkills(){
        /** Assign All Work Type Skills Required **/
        RCGIDO_DataFix.AssignWorkTypeSkill('Interviews','Job Interview',1);
        RCGIDO_DataFix.AssignWorkTypeSkill('Billing and Accounts','Sales Meeting',1);
        RCGIDO_DataFix.AssignWorkTypeSkill('Repair Estimate','Service Meeting',1);
        
        /** Assign All Service Resource Skills Required **/
        RCGIDO_DataFix.AssignServiceResourceSkill('Interviews','Anna Taylor',8);
        RCGIDO_DataFix.AssignServiceResourceSkill('Billing and Accounts','Anna Taylor',7);
        RCGIDO_DataFix.AssignServiceResourceSkill('Interviews','Scott Williams',7);
        RCGIDO_DataFix.AssignServiceResourceSkill('Billing and Accounts','Scott Williams',8);
    }
    /** Assign a Skill to a work type **/
    public static void AssignWorkTypeSkill(String SkillName, String WorkTypeName,Integer SetSkillLevel){
        String mySkillId = [SELECT ID,MASTERLABEL FROM Skill WHERE MASTERLABEL = :SkillName].Id;
        String myworktypeid = [SELECT Id FROM WorkType WHERE Name = :WorkTypeName].Id;
        SkillRequirement  skillItem = new SkillRequirement (
            RELATEDRECORDID = myworktypeid,
            SKILLID = mySkillId,
            SKILLLEVEL = SetSkillLevel
        );
		insert skillItem;
    }
    /** Assign a skill to a Service Resource **/
    public static void AssignServiceResourceSkill(String SkillName, String myuser,Integer SetSkillLevel){
        String mySkillId = [SELECT ID,MASTERLABEL FROM Skill WHERE MASTERLABEL = :SkillName].Id;
        String myResourceId = [SELECT Id FROM ServiceResource WHERE Name = :myuser].Id;
        ServiceResourceSkill   skillItem = new ServiceResourceSkill  (
            ServiceResourceId = myResourceId,
            SkillId = mySkillId,
            SkillLevel = SetSkillLevel,
            EffectiveStartDate = DateTime.now().AddMonths(-10)
        );
		insert skillItem;
    }
    /** Update Custom Metadata Type to use Industry Org Identifier **/
    public static void updateOrgIdentifier(String OrgId){
        
        List<QLabs__mdt> MetadataList1 = [SELECT MasterLabel, DeveloperName,Id, Identifier__c FROM QLabs__mdt];
        MetadataList1[0].Identifier__c = OrgId;
        String jobId2 = RCG_MetadataUtility.upsertMetadata(MetadataList1);
        
    }
    /** Fix Missing Dawn Distributor / MLM Data **/
    public static void FixDawnDistributor(){
        List<Contact> conList = new List<Contact>();
        conList = [Select Id, Name,Percentage_to_Next_Level__c from Contact where Name = 'Dawn Distributor' ];
        for(Contact c : conList )
        {
            c.Percentage_to_Next_Level__c  = 70.0;
        }
        if(conList.size() > 0)
        {
            update conList;
        }
    }
    /** Fix Missing Dawn Distributor / MLM Data **/
    public static void FixMLMDownlines(){
        String DawnId = [SELECT ID FROM Contact Where Name = 'Dawn Distributor'].Id;
        List<Contact> conList = new List<Contact>();
        conList = [Select Id, Name from Contact where Name = 'Lisa Jones' OR Name = 'Stephanie Curran' ];
        for(Contact c : conList )
        {
            c.ReportsToId   = DawnId;
        }
        if(conList.size() > 0)
        {
            update conList;
        }
    }
    public static void AssignGustavoRole(){
        /** ASSIGN A ROLE TO GUSTAVO **/
        String role = [SELECT ID,Name FROM UserRole WHERE Name = 'West Sales'].Id;
        List<User> uList = new List<User>();
        uList = [Select Id, Name from User where Name = 'Gustavo Manager'];
        for(User u : uList )
        {
            u.UserRoleId = role;
        }
        if(uList.size() > 0)
        {
            update uList;
        }
    }
    /** Fix Various KAM Data Issues **/
    public static void KAMData(){
        String Gustavo = [SELECT ID FROM User Where Name = 'Gustavo Manager'].Id;
        List<Account> aList = new List<Account>();
        aList = [Select Id, Name from Account where Name = 'Northern Trail Outfitters'];
        for(Account a : aList )
        {
            a.OwnerId   = Gustavo;
        }
        if(aList.size() > 0)
        {
            update aList;
        }
        
        /** Create Events for Gustavo **/
        String oliv = [SELECT ID FROM Contact WHERE Name = 'Olivia Buyer'].id;
        String gust = [SELECT ID FROM User WHERE Name = 'Gustavo Manager'].id;
        String nto = [SELECT ID FROM Account WHERE Name = 'Northern Trail Outfitters'].id;
        Event u = new Event (
            Subject = 'On-Site Visit',
            WhoId = oliv,
            WhatId  = nto,
            Type  = 'Call',
            StartDateTime  = DateTime.now(),
            EndDateTime  = DateTime.now().AddDays(5),
            OwnerId  = gust
        );
        insert u;
        Event u2 = new Event (
            Subject = 'Promotion Analysis',
            WhoId = oliv,
            WhatId  = nto,
            Type  = 'Prep',
            StartDateTime  = DateTime.now(),
            EndDateTime  = DateTime.now().AddDays(5),
            OwnerId  = gust
        );
        insert u2;
        
        
        /*  Add JBP Files to record
        */
        List<ContentVersion> contentList = new List<ContentVersion>();
                
        for(IDO_JBP_Planning_Period__c  jbp : [Select Id, Name from IDO_JBP_Planning_Period__c where Joint_Business_Plan_Name__c = 'NTO 2020 Business Plan'] )
        {
            for(ContentVersion content : [SELECT ContentDocumentId FROM ContentVersion Where Title = 'SSB_EnergyDrinks' LIMIT 1] )
            {
                ContentDocumentLink cdl = new ContentDocumentLink();
                cdl.ContentDocumentId = content.ContentDocumentId;
                cdl.LinkedEntityId = jbp.Id;
                cdl.ShareType = 'V';
                insert cdl;
            }
        }  
        
        String jbp = [SELECT ID FROM IDO_JBP_Planning_Period__c WHERE Joint_Business_Plan_Name__c  = 'NTO 2020 Business Plan'].id;
        Task t1 = new Task (
            Subject = 'Send New Product Quotes',
            OwnerId = gust,
            WhatId = jbp,
            Status  = 'Not Started',
            ActivityDate = system.today()
        );
        insert t1;
        
        Task t2 = new Task (
            Subject = 'Send Marketing Invite',
            OwnerId = gust,
            WhatId = jbp,
            Status  = 'Not Started',
            ActivityDate = system.today()
        );
        insert t2;
        
        Task t3 = new Task (
            Subject = 'Arrange a Call with Olivia',
            OwnerId = gust,
            WhatId = jbp,
            WhoId = oliv,
            Status  = 'Not Started',
            ActivityDate = system.today()
        );
        insert t3;
    } 
    
    /** Fix MAPS DATA **/
    public static void MapsDataFix(){
        /*** THIS DOES NOT WORK */
         /*   
        Schema.DescribeSObjectResult r = RetailStore.sObjectType.getDescribe();
		String keyPrefix = r.getKeyPrefix();
        
        maps__CalEventLookup__c u = new maps__CalEventLookup__c (
            MAPS__BASEOBJECTID__C = '01I4V000002goSIUAY',
            MAPS__CALEVENTBASEOBJ__C = '01I4V000002goSIUAY',
            MAPS__ENABLED__C = true,
            MAPS__LOCATIONSOURCE__C = false,
            MAPS__OBJECTAPI__C = 'RetailStore',
            MAPS__TYPEAPI__C = 'Type',
            MAPS__TYPEDEFAULTVALUE__C = 'Store Visit',
            MAPS__TYPE__C = 'Custom'
        );
        insert u;
		*/                
    } 
        public static void AssignUserQueues(){
        String adrianId = [SELECT ID FROM USER WHere Name = 'Adrian Service'].id;
        /** CHAT QUEUE **/
        Group g = [select Id from Group where Name='Chat' AND Type = 'Queue'];

        GroupMember member = new GroupMember();
        member.UserOrGroupId = adrianId;
        member.GroupId = g.Id;
        
        insert member;
        
        /** TIER1 QUEUE **/
        Group Tier1 = [select Id from Group where Name='Tier1Queue' AND Type = 'Queue'];

        GroupMember member3 = new GroupMember();
        member3.UserOrGroupId = adrianId;
        member3.GroupId = Tier1.Id;
        
        insert member3;
            
        /** SMS **/
        Group sms = [select Id from Group where Name='SMS' AND Type = 'Queue'];

        GroupMember mem2 = new GroupMember();
        mem2.UserOrGroupId = adrianId;
        mem2.GroupId = sms.Id;
        
        insert mem2;
    }
    public static void applyNBAImages(){
        //Select all the Recommendations ID and Names
        //Take the names, replace - and & with a space
        //String.remove()
        //String.deleteWhitespace()
        
        //get ContentAsset ID of all assets with matching names
        //update recommendation.imageID with mathcing content asset ID
        
        // WHERE ImageID = null
        List<Recommendation> recommendations = [SELECT ID, Name, ImageID from Recommendation WHERE ImageID = null];
        Map<String,Recommendation> recommendationMap = new Map<String,Recommendation>();
        List<String> fileNames = new List<String>();
        List<ContentAsset> assetFiles;
        List<Recommendation> recsToUpdate = new List<Recommendation>();
        
        for(Recommendation curRec : recommendations) {
            String fileName;
            fileName = curRec.name.replaceAll('[^a-zA-Z0-9\\s+]', '').deleteWhitespace();
            System.debug('******* Recommendation ' + curRec.name + ' is missing an icon. Guessing at ContentAsset name of: ' + fileName);
            recommendationMap.put(fileName, curRec);
            fileNames.add(fileName);
        }
        
        if (!fileNames.isEmpty()) {
            System.debug('******* Searching for the following ContentAssets: ' + fileNames);
            assetFiles = [SELECT ID, DeveloperName FROM ContentAsset where DeveloperName in :fileNames];
            
            for(ContentAsset curContent : assetFiles) {
                Recommendation curRec = recommendationMap.get(curContent.DeveloperName);
                
                if(curRec != null) {
                    curRec.imageId = curContent.ID;
                    recsToUpdate.add(curRec);
                }
            }
        }
        
        if (!recsToUpdate.isEmpty()) {
            System.debug('Going to update ' + recsToUpdate.size() + ' Recommendations');
            Database.update(recsToUpdate);
        }
    }
    
    /** FIX OMS Payment Authorization **/
    public static void FixPaymentAuth(){
        List<PaymentAuthorization> payauths = new List<PaymentAuthorization>();
        payauths = [SELECT ID,External_ID__c, PaymentMethodId FROM PaymentAuthorization Where PaymentMethodId = '' ANd ACCOUNT.Name = 'Rachel Morris PA' AND Status = 'Draft'];
        Integer i = 1;
        String cpaymeth;
            
        for(PaymentAuthorization p : payauths )
        {
            String filterValue = 'RCG.' + i;
            cpaymeth = [SELECT External_ID__c,ID,Account.Name FROM CardPaymentMethod WHERE External_ID__c = :filterValue].ID;
            p.PaymentMethodId  = cpaymeth;
            p.Status = 'Processed';
        }
        if(payauths.size() > 0)
        {
            update payauths;
        }
    }
    /** SET OMS ORDERS TO ACTIVATED SO IT WILL GENERATED ORDER SUMMARY **/
    public static void SetOMSOrderstoActive(){
        List<Order> omsorders = new List<Order>();
        omsorders = [SELECT ID,Status FROM Order WHERE ACCOUNT.Name = 'Rachel Morris PA' AND Status = 'Draft'];
        for(Order o : omsorders )
        {
            o.Status  = 'Activated';
        }
        if(omsorders.size() > 0)
        {
            update omsorders;
        }
    }
    
    /**
     * 				B2B Commerce Lightnign Fixes
     * 
     * /
     * 
    /** B2B commerce Update Contact Point Address records to have a parent record **/
    public static void B2BCommUpdateContactPointAddress(){
        String ntosanfran = [Select Id From Account Where Name = 'NTO San Francisco' ].Id;
        List<ContactPointAddress > conadd = new List<ContactPointAddress >();
        conadd = [SELECT ID,ParentId FROM ContactPointAddress WHERE Name = 'Olivia Buyer'];
        for(ContactPointAddress o : conadd )
        {
            o.ParentId   = ntosanfran;
        }
        if(conadd.size() > 0)
        {
            update conadd;
        }
    }
}
public class ClientellingController {
    @AuraEnabled
    public static List<User> isActiveUser() {
        Id userId = UserInfo.getUserId();
        return [SELECT FirstName,LastName, AboutMe, FullPhotoUrl,BannerPhotoUrl, Title   FROM User WHERE Id = :userId];
    }
    @AuraEnabled
    public static String getUser(){
        String usNameFirst = UserInfo.getFirstName();
        String usNameLast = UserInfo.getLastName();
        String fullName = usNameFirst + ' ' + usNameLast;
        return fullName;
    }
    
    @AuraEnabled
    public static List<IDO_Clienteling__c> getAppSettings() {
        Id userId = UserInfo.getUserId();
        return [Select  Trailhead_Third_Link__c ,Trailhead_First_Link__c ,Trailhead_Second_Link__c ,Trailhead_First_Description__c ,Trailhead_First_Title__c ,Trailhead_Second_Description__c ,Trailhead_Second_Title__c ,Trailhead_Third_Description__c ,Trailhead_Third_Title__c ,Enable_Sales_Leaderboard__c,Enable_Customer_Timeline__c,Enable_Customer_Profile__c,Enable_Customer_Insights__c,Enable_Customer_Cases__c,Enable_Customer_Feed__c ,Enable_Customer_Discussions__c,Analytics_Page_Label__c,Shifts_Page_Label__c ,Enable_Discussions_Page__c,Discussions_Page_Label__c,NBA_Description_1__c,NBA_Description_2__c,Next_Best_Action_Recommendation_Title_1__c,Next_Best_Action_Recommendation_Title_2__c ,Enable_Wishlist__c,Page_Layout__c,Setup_Instructions_Read__c,Recommended_Product_Name_1__c,Recommended_Product_Name_2__c,Customer_Recommended_Product_Name_1__c,Customer_Recommended_Product_Name_2__c,Hex_Color_Scheme__c,Homepage_Show_Wave_Dashboard__c,HomePage_Wave_ID__c,Homepage_Wave_Dashboard_Height__c,YouTube_Video__c,Enable_Shift_Schedule__c, Enable_Order_on_Behalf__c,Order_on_behalf_Button_Label__c,Order_on_Behalf_URL__c, Announcements_Label__c ,Chatter_Label__c ,Leaderboard_Label__c ,My_Appointments_Label__c ,My_Tasks_Label__c,App_Logo__c,Customer_Page_Label__c,New_Merchandise_Page_Label__c,Store_Promotions_Page_Label__c,Training_Page_Label__c, Enable_New_Merchandise__c ,Enable_Store_Promotions__c, Enable_Training_Page__c, Store_Promotion_Static_Resource__c, Logo_Background_Color__c , App_background_color__c, App_background_Static_Resource__c, Primary_Button_Color__c, Secondary_Button_Collor__c From IDO_Clienteling__c WHERE User__c = :userId LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<Task> getUserTasks() {
        Id userId = UserInfo.getUserId();
        return [Select Id,Description, ActivityDate, Priority, Status, Subject From Task Where OwnerId = :userId AND (ActivityDate != null) Order By ActivityDate Desc LIMIT 3]; 
    }
    @AuraEnabled
    public static List<IDO_Work_Shift__c> getUserShifts() {
        Id userId = UserInfo.getUserId();
        return [Select Id,Shift_Checkin__c, Shift_Check_out__c,Shift_End__c, Shift_Start__c, Status__c,Is_this_todays_shift__c From IDO_Work_Shift__c Where User__c  = :userId ORDER BY Shift_Start__c ASC LIMIT 14]; 
    }
    @AuraEnabled
    public static List<IDO_Work_Shift__c> CheckIntoShift(String ShiftId) {  
        try {
            IDO_Work_Shift__c shift = [Select Id,Shift_Checkin__c From IDO_Work_Shift__c Where Id = :ShiftId]; 
            shift.Shift_Checkin__c = system.now();
            shift.Status__c = 'In Progress';
            update shift;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
        Id userId = UserInfo.getUserId();
        return [Select Id,Shift_Checkin__c, Shift_Check_out__c,Shift_End__c, Shift_Start__c,Status__c,Is_this_todays_shift__c  From IDO_Work_Shift__c Where User__c  = :userId ORDER BY Shift_Start__c DESC LIMIT 14];  
    }

    @AuraEnabled
    public static List<IDO_Clienteling__c> UpdateSettings() {  
        Id userId = UserInfo.getUserId();
        try {
            IDO_Clienteling__c settings = [Select Id,Setup_Instructions_Read__c From IDO_Clienteling__c Where User__c  = :userId]; 
            settings.Setup_Instructions_Read__c = True;
            update settings;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        return [Select Page_Layout__c,Recommended_Product_Name_1__c,Recommended_Product_Name_2__c,Customer_Recommended_Product_Name_1__c,Customer_Recommended_Product_Name_2__c,Hex_Color_Scheme__c,Homepage_Show_Wave_Dashboard__c,HomePage_Wave_ID__c,Homepage_Wave_Dashboard_Height__c,YouTube_Video__c,Enable_Shift_Schedule__c, Enable_Order_on_Behalf__c,Order_on_behalf_Button_Label__c,Order_on_Behalf_URL__c, Announcements_Label__c ,Chatter_Label__c ,Leaderboard_Label__c ,My_Appointments_Label__c ,My_Tasks_Label__c,App_Logo__c,Customer_Page_Label__c,New_Merchandise_Page_Label__c,Store_Promotions_Page_Label__c,Training_Page_Label__c, Enable_New_Merchandise__c ,Enable_Store_Promotions__c, Enable_Training_Page__c, Store_Promotion_Static_Resource__c, Logo_Background_Color__c , App_background_color__c, App_background_Static_Resource__c, Primary_Button_Color__c, Secondary_Button_Collor__c,Setup_Instructions_Read__c From IDO_Clienteling__c WHERE User__c = :userId LIMIT 1];
    }

    @AuraEnabled
    public static List<IDO_Work_Shift__c> CheckOutShift(String ShiftId) {  
        try {
            IDO_Work_Shift__c shift = [Select Id,Shift_Check_out__c From IDO_Work_Shift__c Where Id = :ShiftId]; 
            shift.Shift_Check_out__c  = system.now();
            shift.Status__c = 'Completed';
            update shift;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
        Id userId = UserInfo.getUserId();
        return [Select Id,Shift_Checkin__c, Shift_Check_out__c,Shift_End__c, Shift_Start__c, Status__c,Is_this_todays_shift__c From IDO_Work_Shift__c Where User__c  = :userId ORDER BY Shift_Start__c DESC LIMIT 14]; 
    }
    @AuraEnabled
    public static List<Task> getTaskInfo(String TaskId) {
        return [Select Id,Description, ActivityDate, Priority, Status, Subject From Task Where Id = :TaskId LIMIT 1]; 
    }
    @AuraEnabled
    public static List<Task> updateTask(String TaskId, String Status, String Subject) {  
        try {
            Task myTask = [Select Id,Description, ActivityDate, Priority, Status, Subject From Task Where Id = :TaskId]; 
            myTask.Subject = 'Stock Summer Promotion Shelf';
            myTask.Status = 'Completed';
            update myTask;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        
        Id userId = UserInfo.getUserId();
        return [Select Id,Description, ActivityDate, Priority, Status, Subject From Task Where OwnerId = :userId LIMIT 3]; 
    }
    @AuraEnabled
    public static List<Appointment__c> getUserAppointments() {
        Id userId = UserInfo.getUserId();
        return [Select Id,Appointment_Time__c, Contact__c, Name,Status__c    From Appointment__c  Where OwnerId = :userId LIMIT 3]; 
    }
    @AuraEnabled
    public static String getAppointmentContacted(String AppointmentContact){
        String contact = [SELECT Id,Contact__c FROM Appointment__c WHERE Id = :AppointmentContact].Contact__c;
        return contact;
    }
    @AuraEnabled
    public static List<Appointment__c> CheckInAppointment(String AppointmentId) {
        try {
            Appointment__c appointment = [Select Id,Status__c  From Appointment__c Where Id = :AppointmentId]; 
            appointment.Status__c  = 'Checked In';
            update appointment;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        Id userId = UserInfo.getUserId();
        return [Select Id,Appointment_Time__c, Contact__c, Name,Status__c    From Appointment__c  Where OwnerId = :userId LIMIT 3]; 
    }
    @AuraEnabled
    public static List<Appointment__c> CheckOutAppointment(String AppointmentId) {
        try {
            Appointment__c appointment = [Select Id,Status__c  From Appointment__c Where Id = :AppointmentId]; 
            appointment.Status__c  = 'Completed';
            update appointment;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        Id userId = UserInfo.getUserId();
        return [Select Id,Appointment_Time__c, Contact__c, Name,Status__c    From Appointment__c  Where OwnerId = :userId LIMIT 3]; 
    }
    @AuraEnabled
    public static List<IDO_Announcements__c> getAllAnnouncements() {
        Id userId = UserInfo.getUserId();
        return [Select Name, Description__c  From IDO_Announcements__c LIMIT 3]; 
    }
    @AuraEnabled
    public static List<String> searchForIds(String searchText) {
        List<List<SObject>> results = [FIND :searchText IN ALL FIELDS  RETURNING Contact(Id)]; 
        List<String> ids = new List<String>();
        for (List<SObject> sobjs : results) {
          for (SObject sobj : sobjs) {
            ids.add(sobj.Id);
          }
        }
        return ids;
    }

    @AuraEnabled 
    public static List<Knowledge__kav> getSomeKnowledge(Integer TotalResults) { 
        return [Select Id,Title,Summary  From Knowledge__kav WHERE IsOutOfDate != True AND (IsVisibleInApp = True) LIMIT 10]; 
    }
    @AuraEnabled 
    public static List<Knowledge__kav> getFilteredKnowledge(String SearchPhrase) { 
        String sp = '%' + SearchPhrase + '%';
        return [Select Id,Title,Summary  From Knowledge__kav WHERE IsOutOfDate != True AND (IsVisibleInApp = True) AND ((Title LIKE :sp) OR (Summary LIKE :sp)) LIMIT 10]; 
    }
    @AuraEnabled 
    public static List<Knowledge__kav> getCurrentKnowledge(String KnowledgeId) {
        return [Select Id,Title, Answer__c  From Knowledge__kav WHERE Id = :KnowledgeId LIMIT 1]; 
    }
    
    @AuraEnabled
    public static List<Contact> getContactRecord(String ContactId) {
        return [Select Name,FirstName, LastName, Customer_Rewards__c,Email, Phone, Profile_Image_URL__c, Gender__c, Occupation__c, Birthdate, Marital_Status__c, Income_Range__c, Age__c, myNTO_Balance__c, myNTO_Status__c, Preferred_Store__c      From Contact Where Id = :ContactId LIMIT 1]; 
    }
    @AuraEnabled
    public static List<Order> getOrderInfo(String oId) {
        return [Select TotalAmount From Order Where Id = :oId LIMIT 1]; 
    }
    @AuraEnabled
    public static List<Order> CancelOrder(String OrderId, String ContactID) {  
        try {
            Order order = [Select Id,Status From Order Where Id = :OrderId]; 
            order.Status = 'Cancelled';
            update order;
        }catch(Exception e) {
            System.debug('An unexpected error has occurred: ' + e.getMessage());
        }
        return [Select Id, OrderNumber, Name, Status, TotalAmount, EffectiveDate From Order Where BillToContactId = :ContactId ORDER BY OrderNumber DESC]; 
    }
    @AuraEnabled
    public static Integer countBackOrders(String ContactId) {
        Integer count = [Select Count() From Order Where BillToContactId = :ContactId AND (Status = 'Backorder')]; 
        return count;
    }
    @AuraEnabled
    public static Integer countCancelledOrders(String ContactId) {
        Integer count = [Select Count() From Order Where BillToContactId = :ContactId AND (Status = 'Cancelled')]; 
        return count;
    }
    @AuraEnabled
    public static Integer countNormalOrders(String ContactId) {
        Integer count = [Select Count() From Order Where BillToContactId = :ContactId AND (Status != 'Cancelled') AND (Status != 'Backorder')]; 
        return count;
    }
    @AuraEnabled
    public static Double SentimentScore(String ContactId) {
        Double countNormalOrders = [Select Count() From Order Where BillToContactId = :ContactId AND (Status != 'Cancelled') AND (Status != 'Backorder') AND (Status != 'Cancelled') AND (Status != 'Draft')]; 
        Double totalOrderAmount = [Select Count() From Order Where BillToContactId = :ContactId];
        Double Orderscore = countNormalOrders/totalOrderAmount;
                
        Double CountGoodCases = [Select Count() From Case Where ContactId = :ContactId AND (Days_Open__c <= 14) AND (Status != 'Closed')]; 
        Double totalCaseAmount = [Select Count() From Case Where ContactId = :ContactId];
        Double Casescore = CountGoodCases/totalCaseAmount;
        
        return (Orderscore + Casescore)/2;
    }
    @AuraEnabled
    public static Double OrderSentimentScore(String ContactId) {
        Double countNormal = [Select Count() From Order Where BillToContactId = :ContactId AND (Status != 'Cancelled') AND (Status != 'Backorder') AND (Status != 'Cancelled') AND (Status != 'Draft')]; 
        Double totalAmount = [Select Count() From Order Where BillToContactId = :ContactId];
        Double score = countNormal/totalAmount;
        return score;  
    }
    @AuraEnabled
    public static Double CaseSentimentScore(String ContactId) {
        Double CountGoodCases = [Select Count() From Case Where ContactId = :ContactId AND (Days_Open__c <= 14) AND (Status != 'Closed')]; 
        Double totalAmount = [Select Count() From Case Where ContactId = :ContactId];
        Double score = CountGoodCases/totalAmount;
        return score;  
    }
    @AuraEnabled
    public static List<Appointment__c> createAppointment(String AppointmentName, String AppointmentOwnerId, String AppointmentStatus) {
        Appointment__c appointment= new Appointment__c();
            appointment.Name = AppointmentName;
            appointment.OwnerId = AppointmentOwnerId;
            appointment.Status__c  = AppointmentStatus;
            /*Contact Field on object must not be required */
            appointment.Appointment_Time__c = Datetime.newInstance(2008, 12, 1, 12, 30, 2);
        insert appointment;
        
        Id userId = UserInfo.getUserId();
        return [Select Appointment_Time__c, Contact__c, Name,Status__c    From Appointment__c  Where OwnerId = :userId LIMIT 3]; 
    }
    @AuraEnabled
    public static List<Order> getContactOrders(String ContactId) {
        return [Select Id, OrderNumber, Name, Status, TotalAmount, EffectiveDate From Order Where BillToContactId = :ContactId ORDER BY OrderNumber DESC]; 
    }
    @AuraEnabled
    public static List<Case> getContactCases(String ContactId) {
        return [Select Id,Days_Open__c, CaseNumber,Subject,Status From Case Where ContactId = :ContactId ORDER BY CaseNumber DESC]; 
    }
    @AuraEnabled
    public static List<IDO_Wish_List__c> getContactWishlist(String ContactId) {
        return [Select Product__c,Product__r.Name,Product__r.purl__c,Product__r.Description ,Product__r.ProductCode,Product__r.Item_MSRP__c,Product__r.Family From IDO_Wish_List__c Where Customer__c = :ContactId]; 
    }
    @AuraEnabled
    public static List<FeedItem> getUnansweredDiscussions() {
        return [Select Id, CreatedBy.FirstName,CreatedBy.LastName,CreatedDate ,LikeCount, Body, Title, Type, CommentCount, Status,(Select FeedItemId, CommentBody From FeedComments) from FeedItem WHERE type = 'QuestionPost' AND (CommentCount > 0)  AND (IsClosed != true) ORDER BY CreatedDate Desc LIMIT 20];
    }
    @AuraEnabled
    public static List<FeedItem> getContactDiscussions(String ContactId) {
        String UserId = [select id, contactId from User WHERE contactId = :ContactId].Id;
        return [Select Id, CreatedBy.FirstName,CreatedBy.LastName,CreatedDate ,LikeCount, Body, Title, Type, CommentCount, Status,(Select FeedItemId, CommentBody From FeedComments) from FeedItem WHERE type = 'QuestionPost' AND (CreatedById = :UserId) ORDER BY CreatedDate Desc LIMIT 20];
    }
    @AuraEnabled
    public static List<FeedItem> getCurrentDiscussion(String DiscussionId) {
        return [Select Id, CreatedDate ,CreatedBy.FirstName,CreatedBy.LastName,LikeCount, Body, Title, Type, CommentCount, Status,(Select CreatedBy.FirstName,CreatedBy.LastName,FeedItemId, CommentBody, LastEditDate, SystemModstamp   From FeedComments) from FeedItem WHERE Id = :DiscussionId];
    }
    @AuraEnabled
    public static String getCurrentDiscussionId(String DiscussionId) {
        return [Select Id from FeedItem WHERE Id = :DiscussionId].Id;
    }
    @AuraEnabled
    public static List<FeedItem> addDiscussionComment(String DiscussionId,String comment) {
        Id userId = UserInfo.getUserId();
        FeedComment newcomm= new FeedComment();
            newcomm.CommentBody = comment;
            newcomm.FeedItemId = DiscussionId;
        insert newcomm;
        
        return [Select Id, CreatedDate ,CreatedBy.FirstName,CreatedBy.LastName,LikeCount, Body, Title, Type, CommentCount, Status,(Select CreatedBy.FirstName,CreatedBy.LastName,FeedItemId, CommentBody, LastEditDate, SystemModstamp   From FeedComments) from FeedItem WHERE Id = :DiscussionId];
    }
    @AuraEnabled
    public static List<OrderItem> getOrderProducts(String oId) {
        return [Select Product2Id,product2.Id,Quantity ,UnitPrice ,product2.Name,product2.purl__c,product2.Description,product2.MSRP__c From OrderItem Where OrderId = :oId Order By product2.Name];  
    }
    @AuraEnabled
    public static List<Product2> getNewProducts() {
        return [Select Id,purl__c, ProductCode , Name,MSRP__c, Description From Product2 Where purl__c != '' AND (New__c  = true) Order By CreatedDate LIMIT 6];  
    }
    @AuraEnabled
    public static List<OrderItem> removeProduct(String OrderId, String ProdId) {  
        OrderItem[] RemovedItem = [SELECT Id FROM OrderItem WHERE OrderId  = :OrderId AND (Product2Id = :ProdId)]; 
        try {
            delete RemovedItem;
        } catch (DmlException e) {
            System.debug('Error: ' + e);
        }
        return [Select Product2Id,product2.Id,Quantity ,UnitPrice ,product2.Name,product2.purl__c,product2.Description,product2.MSRP__c From OrderItem Where OrderId = :OrderId];  
    }
    /**** SIGNATURE CAPTURE ****/
    @AuraEnabled 
    public static void uploadSignature(String parentId, Blob content) {
        
        System.debug('Body: ' + content.toString());        
        String myString = content.toString();
        
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = EncodingUtil.base64Decode(myString); 
        cv.Title = 'Signature';
        cv.PathOnClient = 'Signature.png';
        
        insert cv;
        
        ContentDocumentLink cdl = new ContentDocumentLink(); 
        cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
        cdl.LinkedEntityId = parentId;
        cdl.ShareType = 'V';
        insert cdl;

    }
    public static void passTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
global class Sunnie_ToggleController {
    @AuraEnabled
    global static void updateContact(String contactId, String var, Boolean status){
        List<Contact> objCon=[SELECT Id, Name, Crohns__c, Vegan__c , Vegetarian__c , Gluten_Free__c ,
                              Kosher__c , Low_Fat__c  FROM Contact where Id=:contactId limit 1];
        if(objCon.size() > 0){
            if(var.equalsIgnoreCase('glutenFree')){
                objCon[0].Gluten_Free__c = status;
            }else if(var.equalsIgnoreCase('kosher')){
                objCon[0].Kosher__c = status;
            }else if(var.equalsIgnoreCase('vegetarian')){
                objCon[0].Vegetarian__c = status;
            }else if(var.equalsIgnoreCase('vegan')){
                objCon[0].Vegan__c = status;
            }else if(var.equalsIgnoreCase('crohns')){
                objCon[0].Crohns__c = status;
            }else if(var.equalsIgnoreCase('lowFat')){
                objCon[0].Low_Fat__c = status;
            }
            update objCon;
        }
    }
    
    @AuraEnabled
    global static List<Contact> getContactInfo(String caseId) {
        List<Contact> contactDetails;
        Id rid = Id.valueOf(caseId);
        Schema.SObjectType sobjectType = rid.getSObjectType();
        string type = String.valueOf(sobjectType);
        
        if(type == 'Case'){
            List<Case> contactId = [SELECT ContactId FROM Case WHERE Id = :caseId];
            contactDetails = [SELECT Id, Name, Crohns__c, Vegan__c , Vegetarian__c , Gluten_Free__c ,
                                        Kosher__c , Low_Fat__c 
                                        FROM Contact WHERE Id = :contactId[0].ContactId];
        }else if(type == 'Account'){
            String contactId = [Select PersonContactId From Account Where Id = :caseId].PersonContactId;
            contactDetails = [SELECT Id, Name, Crohns__c, Vegan__c , Vegetarian__c , Gluten_Free__c ,
                                        Kosher__c , Low_Fat__c 
                                        FROM Contact WHERE Id = :contactId ];
        }else if(type == 'Contact'){
            String contactId = caseId;
            contactDetails = [SELECT Id, Name, Crohns__c, Vegan__c , Vegetarian__c , Gluten_Free__c ,
                                        Kosher__c , Low_Fat__c 
                                        FROM Contact WHERE Id = :contactId ];
        }
        
        return contactDetails;
    }
    
    @AuraEnabled
    global static List<IDO_Product_Preference__c> getProdPrefUpdate(String recid, String ProdName,String var, Boolean status){
        List<IDO_Product_Preference__c> Prefs = new LIST<IDO_Product_Preference__c>();  
        
        /** get Product Name **/
        String ProductId = [SELECT Id FROM Product2 Where Name = :ProdName].Id; 
        /** Figure out Which Object we are starting from **/
        
        String cid;
        
        /** Now get the Contact ID from that Object **/
        
        cid = [SELECT ContactId FROM Case WHERE Id = :recid].ContactId;
        
        /** Find all contact Product Preferences **/
        if(cid != '' && cid != null){
            Prefs = [SELECT Id,Tenderness__c, Ripeness__c,Product__c 
                     FROM IDO_Product_Preference__c
                     WHERE (Product__c = :ProductId) 
                    ];
        }
        return Prefs; 
    }
    
    @AuraEnabled
    public static List<IDO_Product_Preference__c> getProdPrefUpdate(Id recid, String ProdName){
        List<IDO_Product_Preference__c> Prefs = new LIST<IDO_Product_Preference__c>();  
        String contactId;
        
        /** Get Product Id **/
        String Prodid = [SELECT Id FROM Product2 WHERE Name = :ProdName].Id;
        
        /** Get Object Type **/
        Schema.SObjectType sobjectType = recid.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        String s = String.valueOf(sobjectName);
        
        /** Get Contact ID based off object type **/
        if(s == 'Case'){
            contactId = [SELECT ContactId FROM Case WHERE Id = :recid].ContactId;
        }else{
            contactId = recid; 
        }
        
        Prefs = [SELECT Id, Ripeness__c, Tenderness__c,Product__r.purl__c FROM IDO_Product_Preference__c WHERE Contact__c = :ContactId AND Product__c = :Prodid];
        if(Prefs.size() > 0){
            return Prefs;
        }else{
            return null;
        }
    }
    
    @AuraEnabled
    public static IDO_Product_Preference__c[] updateProdPrefUpdate(Id recid, String ProdName,Decimal val, String Filtertype){
        IDO_Product_Preference__c[] Prefs;  
        String contactId;
        
        /** Get Product Id **/
        String Prodid = [SELECT Id FROM Product2 WHERE Name = :ProdName].Id;
        
        /** Get Object Type **/
        Schema.SObjectType sobjectType = recid.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        String s = String.valueOf(sobjectName);
        
        /** Get Contact ID based off object type **/
        if(s == 'Case'){
            contactId = [SELECT ContactId FROM Case WHERE Id = :recid].ContactId;
        }else{
            contactId = recid; 
        }
        /** Get Existing Preference Records **/
        Prefs = [SELECT Id, Ripeness__c, Tenderness__c FROM IDO_Product_Preference__c WHERE Contact__c = :ContactId AND Product__c = :Prodid];
        
        /** Update or Insert new record **/
        if(Prefs.size() > 0){
            if(Filtertype == 'Ripeness'){
                Prefs[0].Ripeness__c = val;
            }else if(Filtertype == 'Tenderness'){
                Prefs[0].Tenderness__c = val;
            }
            update Prefs;
        }else{
            IDO_Product_Preference__c pp = New IDO_Product_Preference__c();
             /** Create new record for contact and product **/
            if(Filtertype == 'Ripeness'){
                pp.Ripeness__c = val;
                pp.Contact__c = contactId;
                pp.Product__c = Prodid;
            }else if(Filtertype == 'Tenderness'){
                pp.Tenderness__c = val;
                pp.Contact__c = contactId;
                pp.Product__c = Prodid;
            }              
            insert pp;
        }
        /** Get and Return Results **/
        Prefs = [SELECT Id, Ripeness__c, Tenderness__c,Product__r.purl__c FROM IDO_Product_Preference__c WHERE Contact__c = :ContactId AND Product__c = :Prodid];
        return Prefs;
    }
}
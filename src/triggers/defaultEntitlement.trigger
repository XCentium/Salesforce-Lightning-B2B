trigger defaultEntitlement on Case (Before Insert, Before Update) {
    /*
If the Entitlement Name is not set then, check to see if the Contact on the Case has an active Entitlement
and select the first one.  If not then check to see if the Account on the Case has an active Entitlement.
If no Entitlement set then default to the "Premium Service" associated with "*Ohana, Inc" Account.
*/
    
    List<Id> contactIds = new List<Id>();
    List<Id> acctIds = new List<Id>();
    
    for (Case newCase : Trigger.new){
        if (newCase.EntitlementId == null && newCase.ContactId != null && newCase.AccountId != null){
            contactIds.add(newCase.ContactId);
            acctIds.add(newCase.AccountId);
        }
        else if(newCase.EntitlementId == null && newCase.AccountId == null && newCase.ContactId == null){
            
            Account ohana = [SELECT Id, Name FROM Account WHERE External_Id__c = 'Account.001' LIMIT 1];
            Entitlement entitlement = [SELECT AccountId,Id, Name FROM Entitlement WHERE AccountId = :ohana.Id AND Name LIKE '%Premium Service%' LIMIT 1];
            
            newCase.EntitlementId = entitlement.Id;
        }
    }
    
    /* Logic if accounts and contacts is defined */
    if(contactIds.isEmpty() == false || acctIds.isEmpty() == false){
        List <EntitlementContact> entitlementContacts = [Select EntitlementId, ContactId, Entitlement.AssetId From EntitlementContact
                                                         Where ContactId in :contactIds
                                                         And Entitlement.EndDate >= Today And Entitlement.StartDate <= Today And Entitlement.Name LIKE '%Premium Service%'];
        
        Map<String,EntitlementContact> entitlementContactsMap = new Map<String,EntitlementContact>();
        for(EntitlementContact entitlementContact: entitlementContacts){
            entitlementContactsMap.put(entitlementContact.ContactId, entitlementContact);
        }
        
        //If SLA Contact exists Lauren Bailey
        if(!entitlementContacts.isEmpty()){
            for(Case newCase : Trigger.new){
                if(newCase.EntitlementId == null && newCase.ContactId != null){
                    if(entitlementContactsMap.containsKey(newCase.ContactId)){
                        EntitlementContact entitlementContact = entitlementContactsMap.get(newCase.ContactId);
                        newCase.EntitlementId = entitlementContact.EntitlementId;
                        
                        if(newCase.AssetId == null && entitlementContact.Entitlement.AssetId != null){
                            newCase.AssetId = entitlementContact.Entitlement.AssetId;
                        }
                    }
                }
            }
        }
        else if(entitlementContacts.isEmpty()) {
            List <Entitlement> entitlements = [Select StartDate, Id, EndDate, AccountId, AssetId
                                        From Entitlement
                                        Where AccountId in :acctIds And EndDate >= Today And StartDate <= Today];
            
            Map<String,Entitlement> entitlementsMap = new Map<String,Entitlement>();
            
            for(Entitlement entitlement: entitlements){
                entitlementsMap.put(entitlement.AccountId, entitlement);
            }
            
            if(!entitlements.isEmpty()){
                for(Case newCase : Trigger.new){
                    if(newCase.EntitlementId == null && newCase.AccountId != null){
                        if(entitlementsMap.containsKey(newCase.AccountId)){
                            Entitlement entitlement = entitlementsMap.get(newCase.AccountId);
                            
                            if(entitlement.AccountId == newCase.AccountId){
                                newCase.EntitlementId = entitlement.Id;
                                if(newCase.AssetId == null && entitlement.AssetId != null)
                                    newCase.AssetId = entitlement.AssetId;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
}
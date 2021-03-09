public with sharing class SDO_CatalogCheckout2 {
    public Order o {get;set;}
    public Account a {get;set;}
    public Contract c {get;set;}

    public boolean canEditOrder {get;set;}

    //account search
    public String accountName {Get;set;}
    public String accountEmail {Get;set;}
    public String accountNumber {Get;set;}
    public String isPersonAccount {get;set;}

    //contact search
    public String contactName {Get;set;}
    public String contactEmail {Get;set;}


    //results
    public List<Contact> contactList {Get;set;}
    public List<Account> accountList {Get;set;}

    public String updateAccountId {get;set;}
    public String updateContactId {get;set;}

    public String orderAccountName {Get;set;}
    public String orderContactName {get;set;}

    public Account newAccount {Get;set;}

    public RecordType personAccountRecordType {get;set;} 
    public RecordType businessOrderType {get;set;}  
    public RecordType personalOrderType {get;set;}  

    public String resultsMessage {get;set;}

    public SDO_CatalogCheckout2(ApexPages.StandardController std) {
        try{
            resultsMessage = '';
            personAccountRecordType =  [SELECT BusinessProcessId,CreatedById,CreatedDate,Description,DeveloperName,Id,IsActive,IsPersonType,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SobjectType,SystemModstamp FROM RecordType WHERE Name = 'Person Accounts' and SObjectType = 'Account' limit 1];
            businessOrderType = [SELECT BusinessProcessId,CreatedById,CreatedDate,Description,DeveloperName,Id,IsActive,IsPersonType,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SobjectType,SystemModstamp FROM RecordType WHERE Name = 'Order - Business' AND SobjectType = 'Order' limit 1];
            personalOrderType = [SELECT BusinessProcessId,CreatedById,CreatedDate,Description,DeveloperName,Id,IsActive,IsPersonType,LastModifiedById,LastModifiedDate,Name,NamespacePrefix,SobjectType,SystemModstamp FROM RecordType WHERE Name = 'Order - Consumer' AND SobjectType = 'Order' limit 1];
            newAccount = new Account();
            canEditOrder = true;
            o = [SELECT Account.isPersonAccount,Contract.Account.Name,Account.name,AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,BillingLongitude,
                    BillingPostalCode,BillingState,BillingStreet,CompanyAuthorizedById,ContractId,CreatedById,CreatedDate,CustomerAuthorizedById,
                    CustomerAuthorizedBy.name,CustomerAuthorizedBy.email,CustomerAuthorizedBy.mailingstreet,CustomerAuthorizedBy.mailingcity,
                    CustomerAuthorizedBy.mailingstate,CustomerAuthorizedBy.mailingpostalcode,
                    Description,EffectiveDate,EndDate,Id,Indicator__c,IsDeleted,IsReductionOrder,LastModifiedById,LastModifiedDate,
                    OpportunityId,OrderNumber,OriginalOrderId,Pricebook2Id,QuoteId,RecordType.Name,RecordTypeId,ShippingCity,
                    ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Status,StatusCode,SystemModstamp,
                    TotalAmount,Type,URLsrc__c,Credit_Card_Expiration_Date__c,Credit_Card_Name__c,Credit_Card_Number__c FROM Order where id=:std.getId()];
            orderAccountName = o.account.name;
            if(o.Account.isPersonAccount){
                renderContactSearch = false;
            }else {
                renderContactSearch = true;
            }

            if(o.contractid != null) {
                c = [SELECT AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,
                    BillingLongitude,BillingPostalCode,BillingState,BillingStreet,CompanySignedDate,CompanySignedId,
                    ContractNumber,ContractTerm,CreatedById,CreatedDate,CustomerSignedDate,CustomerSignedId,
                    CustomerSignedTitle,Description,EndDate,External_ID__c,Id,IsDeleted,LastActivityDate,
                    LastApprovedDate,LastModifiedById,LastModifiedDate,
                    OwnerExpirationNotice,OwnerId,ShippingCity,ShippingCountry,ShippingLatitude,
                    ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,SpecialTerms,StartDate,Status,
                    StatusCode,SystemModstamp FROM Contract where id =:o.contractId];
                if(c.status == 'Activated') canEditOrder = false;
                a = [SELECT id,name,isPersonAccount,firstname,lastname,accountNumber,personemail,BillingStreet,BillingState,BillingCity,BillingPostalCode FROM Account where id =:c.AccountId];
            }   
            if(o.CustomerAuthorizedById != null) {
                Contact tempContact = [select id,name from contact where id=:o.CustomerAuthorizedById];
                orderContactName = tempContact.name;
            }
        }catch(Exception e) {
            system.assert(false,e.getMessage() + e.getLineNumber() + e.getCause() + e.getTypeName() + e.getStackTraceString());

        }
    }

    public void search() {
        resultsMessage = '';
        if(accountName == null || accountName == '') accountName = ApexPages.CurrentPage().getParameters().get('accountName');
        if(accountNumber == null || accountNumber == '') accountNumber = ApexPages.CurrentPage().getParameters().get('accountNumber');
        if(accountEmail == null || accountEmail == '') accountEmail = ApexPages.CurrentPage().getParameters().get('accountEmail');
        if(isPersonAccount == null || isPersonAccount == '') isPersonAccount = ApexPages.CurrentPage().getParameters().get('isPersonAccount'); 
        String q = 'SELECT AccountNumber,personemail,BillingCity,BillingPostalCode,BillingState,BillingStreet,IsPersonAccount,Name,PersonMailingAddress,PersonMailingCity,PersonMailingCountry,PersonMailingState,PersonMailingStreet,PersonOtherCity FROM Account where name != \'\' ';
        if(accountName != null && accountName != '')   q+= ' AND name LIKE \'%'+accountName+'%\' ';
        if(accountNumber != null && accountNumber != '') q+= ' AND  AccountNumber LIKE \'%'+accountNumber+'%\' ';
        if(accountEmail != null && accountEmail != '') q+= ' AND  PersonEmail LIKE \'%'+accountEmail+'%\' ';
        if(isPersonAccount == 'true') q+= ' AND  isPersonAccount = true ';
        system.debug(q);
        accountList = database.query(q);
        system.debug(accountList);
        if(accountList.size() == 0) resultsMessage = 'No Results';
        //get contacts on the account
    }

    public void searchContacts(){
        resultsMessage= '';
        if(contactName == null || contactName == '') contactName = ApexPages.CurrentPage().getParameters().get('contactName');
        if(contactEmail == null || contactEmail == '') contactEmail = ApexPages.CurrentPage().getParameters().get('contactEmail');
        if(o.accountId != null) {
            //if we are here, the account is a business account     
            String q1 = '';
            q1 = 'SELECT Id,AccountId,Account.name,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId = \''+o.AccountId+'\' ';
            if(contactName != null && contactName != '')   q1 += ' AND name LIKE \'%'+contactName+'%\' ';
            if(contactEmail != null && contactEmail != '') q1 += ' AND email LIKE \'%'+contactEmail+'%\' ';             

            system.debug(q1);
            contactList = database.query(q1);
            if(contactList.size() == 0) resultsMessage = 'No Results';
        }
    }

    public boolean renderContactSearch {get;set;}
    public void updateAccount() {
        Account a = [select id, name,firstname,lastname, isPersonAccount from account where id=:updateAccountId limit 1];
        orderAccountName = a.name;
        if(a.isPersonAccount){
            // updating the record with a person account
            // is there a contract associated with the order?
            // if so, delete it and change the record type of the order
            if(o.contractid != null) {
                //delete the contract
                c = returnContractById(o.contractId);
                //o.recordTypeId = '012o0000000xFMF';
                o.recordType = personalOrderType;
                o.contractid = null;
                update o;
                delete c;
                //change the record type of the order to Personal
            }
            o.accountId = updateAccountId;
            try{
                Contact tempContact = [select firstname, lastname,id from contact where firstname =:a.firstname and lastname=:a.lastname limit 1];
                o.CustomerAuthorizedById = tempContact.id;
            }catch(exception e) {
                system.debug('EXCEPTION : ' + e.getMessage());
            }
            update o;
            renderContactSearch = false;
        }else {
            //business account
            //change record type to business
            //o.recordTypeId = '012o0000000xFMK';
            o.recordType = businessOrderType;
            renderContactSearch = true;

            //is there a contract associated with the account/orer? 
            if(o.contractid != null) {
                //update existing contract with new account id
                c = returnContractById(o.contractId);
                c.accountId = updateAccountId;
                update c;
            } else {
                //create new contract with new account id
                User u = [select id from user where id=:Userinfo.getUserId() limit 1];
                /*
                c = new Contract();
                c.accountid = updateAccountId;
                c.status = 'Draft';
                c.ownerId = u.id;
                insert c;
                o.contractId = c.id;
                */
            }
            o.accountId = updateAccountId;
            update o;
        }
        String orderId = o.id;
        //
        o = [SELECT Account.isPersonAccount,Contract.Account.Name,Account.name,AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,BillingLongitude,
                    BillingPostalCode,BillingState,BillingStreet,CompanyAuthorizedById,ContractId,CreatedById,CreatedDate,CustomerAuthorizedById,
                    CustomerAuthorizedBy.name,CustomerAuthorizedBy.email,CustomerAuthorizedBy.mailingstreet,CustomerAuthorizedBy.mailingcity,
                    CustomerAuthorizedBy.mailingstate,CustomerAuthorizedBy.mailingpostalcode,
                    Description,EffectiveDate,EndDate,Id,Indicator__c,IsDeleted,IsReductionOrder,LastModifiedById,LastModifiedDate,
                    OpportunityId,OrderNumber,OriginalOrderId,Pricebook2Id,QuoteId,RecordTypeId,RecordType.Name,ShippingCity,
                    ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Status,StatusCode,SystemModstamp,
                    TotalAmount,Type,URLsrc__c,Credit_Card_Expiration_Date__c,Credit_Card_Name__c,Credit_Card_Number__c FROM Order where id=:orderId];
    }

    public Contract returnContractById(String cid) {
        return [SELECT AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,
                BillingLongitude,BillingPostalCode,BillingState,BillingStreet,CompanySignedDate,CompanySignedId,
                ContractNumber,ContractTerm,CreatedById,CreatedDate,CustomerSignedDate,CustomerSignedId,
                CustomerSignedTitle,Description,EndDate,External_ID__c,Id,IsDeleted,LastActivityDate,
                LastApprovedDate,LastModifiedById,LastModifiedDate,
                OwnerExpirationNotice,OwnerId,ShippingCity,ShippingCountry,ShippingLatitude,
                ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,SpecialTerms,StartDate,Status,
                StatusCode,SystemModstamp FROM Contract where id =:cid limit 1];
    }

    public void updateContact() {
        if(updateContactId == null || updateContactId == '') updateContactId = ApexPages.CurrentPage().getParameters().get('updateContactId');
        String orderId = o.id;
        o.CustomerAuthorizedById = updateContactId;
        Contact myContact = [select id,name from contact where id=:updateContactId];
        orderContactName = myContact.name;
        update o;
        //
        o = [SELECT Account.isPersonAccount,Contract.Account.Name,Account.name,AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,BillingLongitude,
                BillingPostalCode,BillingState,BillingStreet,CompanyAuthorizedById,ContractId,CreatedById,CreatedDate,CustomerAuthorizedById,
                CustomerAuthorizedBy.name,CustomerAuthorizedBy.email,CustomerAuthorizedBy.mailingstreet,CustomerAuthorizedBy.mailingcity,
                CustomerAuthorizedBy.mailingstate,CustomerAuthorizedBy.mailingpostalcode,
                Description,EffectiveDate,EndDate,Id,Indicator__c,IsDeleted,IsReductionOrder,LastModifiedById,LastModifiedDate,
                OpportunityId,OrderNumber,OriginalOrderId,Pricebook2Id,QuoteId,RecordTypeId,RecordType.Name,ShippingCity,
                ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Status,StatusCode,SystemModstamp,
                TotalAmount,Type,URLsrc__c,Credit_Card_Expiration_Date__c,Credit_Card_Name__c,Credit_Card_Number__c FROM Order where id=:orderId];
    }

    public void updatePaymentInfo(){
        String orderId = o.id;
        //
        o = [SELECT Account.isPersonAccount,Contract.Account.Name,Account.name,AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,BillingLongitude,
                BillingPostalCode,BillingState,BillingStreet,CompanyAuthorizedById,ContractId,CreatedById,CreatedDate,CustomerAuthorizedById,
                CustomerAuthorizedBy.name,CustomerAuthorizedBy.email,CustomerAuthorizedBy.mailingstreet,CustomerAuthorizedBy.mailingcity,
                CustomerAuthorizedBy.mailingstate,CustomerAuthorizedBy.mailingpostalcode,
                Description,EffectiveDate,EndDate,Id,Indicator__c,IsDeleted,IsReductionOrder,LastModifiedById,LastModifiedDate,LastReferencedDate,
                LastViewedDate,OpportunityId,OrderNumber,OriginalOrderId,Pricebook2Id,QuoteId,RecordTypeId,RecordType.Name,ShippingCity,
                ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Status,StatusCode,SystemModstamp,
                TotalAmount,Type,URLsrc__c,Credit_Card_Expiration_Date__c,Credit_Card_Name__c,Credit_Card_Number__c FROM Order where id=:orderId];
    }
}
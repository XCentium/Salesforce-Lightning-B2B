public with sharing class SDO_CatalogCheckout {
    //Person Account 
    public List<Account> pAccountResults {Get;set;}
    public String pNameQuery {Get;set;}
    public String pEmailQuery {Get;set;}


    //Business Account
    public List<Account> bAccountResults {Get;set;}
    public String bNameQuery {Get;set;}
    public String bNumberQuery {Get;set;}

    public String bAccountId {Get;set;}
    public String pAccountId {get;set;}

    public Account businessAccount {Get;set;}
    public Account personAccount {get;set;}

    public List<Contact> bContactResults {get;set;}
    public String bContactName{get;set;}
    public String bContactEmail {get;set;}
    public String bContactId {get;set;}

    public String orderId {Get;set;}
    public Order o {get;set;}

    public String errorMessage {get;set;}

    public Account newAccount {get;set;}

    public SDO_CatalogCheckout(ApexPages.StandardController std) {
        orderId = std.getId();
        errorMessage='';
        newAccount = new Account();
        o = [SELECT AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,BillingLongitude,
                BillingPostalCode,BillingState,BillingStreet,CompanyAuthorizedById,ContractId,CreatedById,CreatedDate,CustomerAuthorizedById,
                CustomerAuthorizedBy.name,CustomerAuthorizedBy.email,CustomerAuthorizedBy.mailingstreet,CustomerAuthorizedBy.mailingcity,
                CustomerAuthorizedBy.mailingstate,CustomerAuthorizedBy.mailingpostalcode, DB_Days__c,
                Description,EffectiveDate,EndDate,Id,Indicator__c,IsDeleted,IsReductionOrder,LastModifiedById,LastModifiedDate,LastReferencedDate,
                LastViewedDate,OpportunityId,OrderNumber,OriginalOrderId,Pricebook2Id,QuoteId,RecordTypeId,ShippingCity,
                ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Status,StatusCode,SystemModstamp,
                TotalAmount,Type,URLsrc__c FROM Order where id=:orderId];
        if(o.accountid != null) {
            bContactResults = [SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId =:o.accountid];
        }       
    }

    public void pSearch() {
        errorMessage= '';
        if(pNameQuery == null || pNameQuery == '') pNameQuery = ApexPages.CurrentPage().getParameters().get('pNameQuery');
        if(pEmailQuery == null || pEmailQuery == '') pEmailQuery = ApexPages.CurrentPage().getParameters().get('pEmailQuery');
        String q = 'SELECT AccountNumber,personemail,BillingCity,BillingPostalCode,BillingState,BillingStreet,IsPersonAccount,Name,PersonMailingAddress,PersonMailingCity,PersonMailingCountry,PersonMailingState,PersonMailingStreet,PersonOtherCity FROM Account where IsPersonAccount = true ';
        if(pNameQuery != null && pNameQuery != '')   q+= ' AND  name LIKE \'%'+pNameQuery+'%\' ';
        if(pEmailQuery != null && pEmailQuery != '') q+= ' AND  personemail LIKE \'%'+pEmailQuery+'%\' ';
        system.debug(q);
        pAccountResults = database.query(q);
        system.debug(pAccountResults);
    }

    public void bSearch() {
        errorMessage = '';
        if(bNameQuery == null || bNameQuery == '') bNameQuery = ApexPages.CurrentPage().getParameters().get('bNameQuery');
        if(bNumberQuery == null || bNumberQuery == '') bNumberQuery = ApexPages.CurrentPage().getParameters().get('bNumberQuery');
        String q = 'SELECT AccountNumber,personemail,BillingCity,BillingPostalCode,BillingState,BillingStreet,IsPersonAccount,Name,PersonMailingAddress,PersonMailingCity,PersonMailingCountry,PersonMailingState,PersonMailingStreet,PersonOtherCity FROM Account where IsPersonAccount = false ';
        if(bNameQuery != null && bNameQuery != '')   q+= ' AND name LIKE \''+bNameQuery+'%\' ';
        if(bNumberQuery != null && bNumberQuery != '') q+= ' AND  AccountNumber LIKE \'%'+bNumberQuery+'%\' ';
        system.debug(q);
        bAccountResults = database.query(q);
        system.debug(bAccountResults);

        //get contacts on the account

    }

    public void bAccount() {
        if(bAccountId == null || bAccountId == '') bAccountId = ApexPages.CurrentPage().getParameters().get('bAccountId');
        
        //get the order
        Order o =  [select accountid,Contractid, id from order where id=:orderId];

        // delete old contract
        Contract oldC = [select accountid,status, id from contract where id = :o.contractid limit 1];
        if(oldC != null) {
            if(oldC.status == 'Activated') {
                    errorMessage = 'Exception: You cannot change the account on an order with an Activated Contract.';
            }else {
                //update old contract and order with new account
                oldc.accountid = bAccountId;
                update oldc;
                o.accountid = bAccountId;
                update o;
                // get all the contats associated with the account
                if(bAccountId != null) {
                    bContactResults = [SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId =:bAccountId];
                }
            }
        }else {
            User u = [select id from user where id=:Userinfo.getUserId() limit 1];
            //create new contract
            Contract nc = new Contract();
            nc.accountid = bAccountId;
            nc.status = 'Draft';
            nc.ownerId = u.id;
            insert nc;
            o.contractid = nc.id;
            o.accountid = bAccountId;
            update o;
            if(bAccountId != null) {
                    bContactResults = [SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId =:bAccountId];
                }
        }
    }

    public void bContact() {
        try {
            system.debug('Attempting to update order contact...');
            if(bContactId == null || bContactId == '') bContactId = ApexPages.CurrentPage().getParameters().get('bContactId');
            Contact c = [select id from contact where id=:bContactId];
            o.BillToContactId = c.id;
            o.ShipToContactId = c.id;
            o.CustomerAuthorizedById = c.id;
            update o;
            o = [SELECT AccountId,ActivatedById,ActivatedDate,BillingCity,BillingCountry,BillingLatitude,BillingLongitude,
                BillingPostalCode,BillingState,BillingStreet,CompanyAuthorizedById,ContractId,CreatedById,CreatedDate,CustomerAuthorizedById,
                CustomerAuthorizedBy.name,CustomerAuthorizedBy.email,CustomerAuthorizedBy.mailingstreet,CustomerAuthorizedBy.mailingcity,
                CustomerAuthorizedBy.mailingstate,CustomerAuthorizedBy.mailingpostalcode, DB_Days__c,
                Description,EffectiveDate,EndDate,Id,Indicator__c,IsDeleted,IsReductionOrder,LastModifiedById,LastModifiedDate,LastReferencedDate,
                LastViewedDate,OpportunityId,OrderNumber,OriginalOrderId,Pricebook2Id,QuoteId,RecordTypeId,ShippingCity,
                ShippingCountry,ShippingLatitude,ShippingLongitude,ShippingPostalCode,ShippingState,ShippingStreet,Status,StatusCode,SystemModstamp,
                TotalAmount,Type,URLsrc__c FROM Order where id=:orderId];
        } catch(exception e){
            system.debug('error: ' + e.getMessage());
        }
        
    }

    public void bContactSearch(){
        if(bContactName == null || bContactName == '') bContactName = ApexPages.CurrentPage().getParameters().get('bContactName');
        if(bContactEmail == null || bContactEmail == '') bContactEmail = ApexPages.CurrentPage().getParameters().get('bContactEmail');
        if(o.accountId != null) {
            List<Contact> cList = [SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId =:bAccountId];   
            String q1 = '';
            if(cList == null){
                //query all contacts
                q1 = 'SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where name IS NOT NULL ';
                if(bContactName != null && bContactName != '')   q1 += ' AND name LIKE \''+bContactName+'%\' ';
                if(bContactEmail != null && bContactEmail != '') q1 += ' AND email LIKE \'%'+bContactEmail+'%\' ';              
            }else {
                //query only the contacts on the account
                q1 = 'SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId = \''+o.AccountId+'\' ';
                if(bContactName != null && bContactName != '')   q1 += ' AND name LIKE \''+bContactName+'%\' ';
                if(bContactEmail != null && bContactEmail != '') q1 += ' AND email LIKE \'%'+bContactEmail+'%\' ';  
            }
            system.debug(q1);
            bContactResults = database.query(q1);
        }
    }

    public void createBusinessAccount(){
        //insert newAccount;
        //bAccountId = newAccount.id;
        //bAccount();
    }

    public Account getbAccount() {
        return businessAccount;
    }

    public void pAccount() {
        if(pAccountId == null || pAccountId == '') pAccountId = ApexPages.CurrentPage().getParameters().get('pAccountId');
        //if(pAccountId != null) personAccount = [SELECT AccountNumber,personemail,BillingCity,BillingPostalCode,BillingState,BillingStreet,IsPersonAccount,Name,PersonMailingAddress,PersonMailingCity,PersonMailingCountry,PersonMailingState,PersonMailingStreet,PersonOtherCity FROM Account where id = :pAccountId limit 1];
        //if(bAccountId == null || bAccountId == '') bAccountId = ApexPages.CurrentPage().getParameters().get('bAccountId');
        
        //get the order
        Order o =  [select accountid,Contractid, id from order where id=:orderId];

        // delete old contract
        Contract oldC = [select accountid,status, id from contract where id = :o.contractid limit 1];
        if(oldC != null) {
            if(oldC.status == 'Activated') {
                    errorMessage = 'Exception: You cannot change the account on an order with an Activated Contract.';
            }else {
                //update old contract and order with new account
                oldc.accountid = pAccountId;
                update oldc;
                o.accountid = pAccountId;
                update o;
                // get all the contats associated with the account
                if(pAccountId != null) {
                    bContactResults = [SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId =:bAccountId];
                }
            }
        }else {
            User u = [select id from user where id=:Userinfo.getUserId() limit 1];
            //create new contract
            Contract nc = new Contract();
            nc.accountid = pAccountId;
            nc.status = 'Draft';
            nc.ownerId = u.id;
            insert nc;
            o.contractid = nc.id;
            o.accountid = pAccountId;
            update o;
            if(pAccountId != null) {
                    bContactResults = [SELECT Id,AccountId,Email,MailingCity,MailingCountry,MailingPostalCode,MailingState,MailingStreet,Name FROM Contact where AccountId =:bAccountId];
                }
        }
    }
    public Account getpAccount() {
        return personAccount;
    }
}
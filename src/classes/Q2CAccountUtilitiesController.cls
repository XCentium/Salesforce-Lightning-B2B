public without sharing class Q2CAccountUtilitiesController {

    public Q2C_Demo_Settings__c settings { get; set; }
    public Id AccountId { get; set; }
    public Account ThisAccount { get; set; }
    public Contact ThisContact { get; set; }
    private ApexPages.StandardController Controller;
    private Id[] QuotesToDelete;

    //CONSTRUCTOR for VF Pages
    public Q2CAccountUtilitiesController(ApexPages.StandardController stdController) {
        this.AccountId = stdController.getId();
        Id acctId = this.AccountId;
        ThisAccount = [SELECT SBQQ__CoTermedContractsCombined__c, SBQQ__AssetQuantitiesCombined__c, SBQQ__RenewalModel__c,SBQQ__ContractCoTermination__c, ShippingAddress, BillingAddress,SBQQ__CoTerminationEvent__c,SBQQ__RenewalPricingMethod__c FROM Account where Id = :acctId];
        this.Controller = stdController;
        settings = Q2C_Demo_Settings__c.getOrgDefaults();
        IF([SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :acctId LIMIT 1].size()>0){
            ThisContact = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :acctId LIMIT 1];
        }
      
    }

    public PageReference insertContact() {
        Id acctId = this.AccountId;
        IF([SELECT Id, FirstName, LastName, Email FROM Contact WHERE AccountId = :acctId LIMIT 1].size()>0){ThisContact.Email = 'steelbrick_demo@salesforce.com';
            update ThisContact;
        }
        return ApexPages.currentPage();
        
    }

    public PageReference updateAccount() {
        update ThisAccount;
        return ApexPages.currentPage();
    }

    public PageReference CloseRedirect() {
        return this.Controller.view();
    }

    public PageReference resetAccountQuickQuote() {
        resetAccount();
        return Q2CGenerateQuickQuote.genQuote();
    }
    /**public PageReference resetAccountQuickInvoice() {
        resetAccount();
        return Q2CGenerateQuickInvoice.genQuote();
    }
    **/
    public PageReference resetAccountMasterQuote() {
        Id a = this.AccountId;
        Id quotetocopy = settings.Master_Quote__c;
        String AcctName = [SELECT Name FROM Account WHERE Id = :a].Name;
        resetAccount();
        Opportunity NewOpp = new Opportunity(Name = 'New Opportunity for ' + AcctName, CloseDate = Date.today(), StageName = 'Qualification', AccountId = a);
        insert NewOpp;
        List<SBQQ__Quote__c> Myquote = new List <SBQQ__Quote__c>();
        SObjectType objToken = Schema.getGlobalDescribe().get('SBQQ__Quote__c');
        DescribeSObjectResult objDef = objToken.getDescribe();
        Map<String, SObjectField> fields = objDef.fields.getMap();
        List<String> fieldslist = new List<String>();
        for (String s : fields.keySet()) {
            fieldslist.add(s);
        }
        String qq = 'SELECT ' + String.join(fieldslist, ',') + ' FROM SBQQ__Quote__c WHERE Id=:quotetocopy';
        System.debug(qq);
        Myquote = Database.query(qq);
        SBQQ__Quote__c Quote = Myquote.get(0).clone(false, true); //set new quotes
        Quote.SBQQ__StartDate__c = NewOpp.CloseDate.addDays(1);
        Quote.SBQQ__Opportunity2__c = NewOpp.Id;
        Quote.SBQQ__Account__c = NewOpp.Account.Id;
        Quote.SBQQ__Primary__c = true;
        insert Quote;

        List<SBQQ__QuoteLine__c> QLtoCopy = new List<SBQQ__QuoteLine__c>();

        SObjectType objToken1 = Schema.getGlobalDescribe().get('SBQQ__QuoteLine__c');
        DescribeSObjectResult objDef1 = objToken1.getDescribe();
        Map<String, SObjectField> fields1 = objDef1.fields.getMap();
        List<String> fieldslist1 = new List<String>();
        for (String s1 : fields1.keySet()) {
            fieldslist1.add(s1);
        }
        String q = 'SELECT ' + String.join(fieldslist1, ',') + ' FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:quotetocopy';
        System.debug(q);
        QLtoCopy = Database.query(q);


        List<SBQQ__QuoteLine__c> newQuoteLines = new List<SBQQ__QuoteLine__c>();
        
        Id newQuoteId=Quote.Id;
        SBQQ.TriggerControl.disable();
        for (Integer j = 0; j < QLtoCopy.size(); j++) { //through each quoteline (j)
            SBQQ__QuoteLine__c QuoteLine = QLtoCopy.get(j).clone(false, true);
            if (QLtoCopy.get(j).SBQQ__RequiredBy__c != null) {
                Id parent = QLtoCopy.get(j).SBQQ__RequiredBy__c;
                Decimal qlnumber = [SELECT SBQQ__Number__c FROM SBQQ__QuoteLine__c WHERE Id = :parent].SBQQ__Number__c;
                QuoteLine.SBQQ__RequiredBy__c = [SELECT Id FROM SBQQ__QuoteLine__c WHERE SBQQ__Number__c = :qlnumber AND SBQQ__Quote__c = :newQuoteId].Id;
            }
            QuoteLine.SBQQ__Group__c = null;
            QuoteLine.SBQQ__Quote__c = Quote.Id;

            insert QuoteLine;
            newQuoteLines.add(QuoteLine);
            
        }
        SBQQ.TriggerControl.enable();
        //insert newQuoteLines;

        return this.Controller.view();
    }
    //public PageReference quickInvoice() {
    //    resetAccount();
    //    return Q2CGenerateQuickInvoice.genQuote();
    //
    //}


    public PageReference resetAccountNewOpp() {
        Id a = this.AccountId;
        String AcctName = [SELECT Name FROM Account WHERE Id = :a].Name;
        resetAccount();
        Opportunity NewOpp = new Opportunity(Name = 'New Opportunity for ' + AcctName, CloseDate = Date.today(), StageName = 'Qualification', AccountId = a);
        insert NewOpp;
        return this.Controller.view();
    }

    public PageReference resetAccount() {
        updateCustomSettings();
        this.disableBillingTriggers();
        this.deleteDiscScheds();
        this.deletePaymentTransactions();
        this.deletePayments();
        this.deleteCreditNotes();
        this.deleteDebitNotes();
        this.deleteRefunds();
        this.deleteInvoices();
        this.deleteQuotes();
        this.deleteOpportunities();
        this.deleteAssets();
        this.deleteSubscriptions();
        this.deleteContracts();
        this.deleteOrders();
        this.deleteCreditNotes();
        this.deleteContractedPrices();
        this.deleteOrderConsumption();
        this.enableBillingTriggers();

        System.debug('Total Number of SOQL Queries in this apex code context: ' + Limits.getQueries());

        return this.Controller.view();
    }

    private Boolean updateCustomSettings() {
        try {
            update settings;

        } catch (Exception e) {
            return false;
        }
        return true;
    }

    private Boolean disableBillingTriggers() {
        blng__BillingConfig__c triggerConfig = [SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        triggerConfig.blng__BooleanValue__c = true;
        SObject s = (SObject) triggerConfig;
        Database.SaveResult sr = Database.updateImmediate(s);
        if (sr.isSuccess()) {
            System.debug('Successfully disabled Billing Triggers');
            return true;
        } else {
            for (Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
            return false;
        }
    }

    private Boolean enableBillingTriggers() {
        blng__BillingConfig__c triggerConfig = [SELECT Id, Name, blng__BooleanValue__c FROM blng__BillingConfig__c WHERE Name = 'DISABLE_TRIGGERS'];
        triggerConfig.blng__BooleanValue__c = false;
        SObject s = (SObject) triggerConfig;
        Database.SaveResult sr = Database.updateImmediate(s);
        if (sr.isSuccess()) {
            System.debug('Successfully enabled Billing Triggers');
            return true;
        } else {
            for (Database.Error err : sr.getErrors()) {
                System.debug('The following error has occurred.');
                System.debug(err.getStatusCode() + ': ' + err.getMessage());
            }
            return false;
        }
    }

    private Boolean deleteDiscScheds() {
        Id a = this.AccountId;
        SBQQ__DiscountSchedule__c[] dsToDelete = [SELECT Id FROM SBQQ__DiscountSchedule__c WHERE SBQQ__Account__c = :a];
        if (!dsToDelete.isEmpty()) {
            Database.delete(dsToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteDiscScheds(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteProcessInputValues(Set<Id> quotes) {
        Id a = this.AccountId;
        SBQQ__ProcessInputValue__c[] valuesToDelete = [SELECT Id FROM SBQQ__ProcessInputValue__c WHERE SBQQ__QuoteId__c IN :quotes];
        if (!valuesToDelete.isEmpty()) {
            Database.delete(valuesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteProcessInputValues(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deletePaymentTransactions() {
        Id a = this.AccountId;
        blng__PaymentTransaction__c[] trxToDelete = [SELECT Id FROM blng__PaymentTransaction__c WHERE blng__Account__c = :a];
        if (!trxToDelete.isEmpty()) {
            Database.delete(trxToDelete);
        }

        System.debug('Total Number of SOQL Queries after deletePaymentTransactions(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteCreditNotes() {
        Id a = this.AccountId;
        blng__CreditNote__c[] creditNotesToDelete = [SELECT Id FROM blng__CreditNote__c WHERE blng__Account__c = :a];
        if (!creditNotesToDelete.isEmpty()) {
            Database.delete(creditNotesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteCreditNotes(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteDebitNotes() {
        Id a = this.AccountId;
        blng__DebitNote__c[] debitNotesToDelete = [SELECT Id FROM blng__DebitNote__c WHERE blng__Account__c = :a];
        if (!debitNotesToDelete.isEmpty()) {
            Database.delete(debitNotesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteDebitNotes(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteInvoices() {
        Id a = this.AccountId;
        blng__Invoice__c[] invoicesToDelete = [SELECT Id, blng__InvoiceStatus__c FROM blng__Invoice__c WHERE blng__Account__r.Id = :a];
        if (!invoicesToDelete.isEmpty()) {
            Set<Id> invoiceIds = new Set<Id>();
            blng__Invoice__c[] invoicesToUpdate = new List<blng__Invoice__c>();

            for (blng__Invoice__c invoice : invoicesToDelete) {
                invoiceIds.add(invoice.Id);
                if (invoice.blng__InvoiceStatus__c == 'Posted') {
                    blng.InvoiceAPI.creditInvoice(invoice.Id, 'Cancel and Re-bill');
                    invoicesToUpdate.add(invoice);
                }
            }
            if (!invoicesToUpdate.isEmpty()) {
                Database.update(invoicesToUpdate);
            }
            blng__InvoiceLine__c[] invoiceLines = getInvoiceLines(invoiceIds);
            if (!invoiceLines.isEmpty()) {
                this.deleteRevenueSchedules(invoiceLines);
            }
            Database.delete(invoicesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteInvoices(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteOrders() {
        Id a = this.AccountId;
        blng__BillingSchedule__c[] BS = [SELECT Id FROM blng__BillingSchedule__c WHERE blng__OrderProduct__r.Order.AccountId=:a];
        delete BS;
        Order[] ordersToDelete = [SELECT Id FROM Order WHERE AccountId = :a];
        if (!ordersToDelete.isEmpty()) {
            Set<Id> orderIds = new Set<Id>();
            for (Order o : ordersToDelete) {
                orderIds.add(o.Id);
                //o.Status = 'Draft';
                o.SBQQ__Contracted__c = false;
            }
            update ordersToDelete;
            OrderItem[] orderItems = getOrderItems(orderIds);
            if (!orderItems.isEmpty()) {
                for (OrderItem oi : orderItems) {
                    oi.SBQQ__Contracted__c = false;
                }

                this.deleteRevenueSchedules(orderItems);
                this.deleteUsages(orderItems);
                this.deleteUsageSummaries(orderItems);
                Database.update(orderItems);
            }
            for (Order o : ordersToDelete) {
                orderIds.add(o.Id);
                o.Status = 'Draft';
                o.SBQQ__Contracted__c = false;
            }
            Database.update(ordersToDelete);
            Database.delete(ordersToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteOrders(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteUsages(OrderItem[] orderItems) {
        if (!orderItems.isEmpty()) {
            Set<Id> orderItemIds = new Set<Id>();
            for (OrderItem oi : orderItems) {
                orderItemIds.add(oi.Id);
            }
            blng__Usage__c[] usagesToDelete = [SELECT Id FROM blng__Usage__c WHERE blng__OrderProduct__c IN :orderItemIds];
            if (!usagesToDelete.isEmpty()) {
                Database.delete(usagesToDelete);
            }
        }

        System.debug('Total Number of SOQL Queries after deleteUsages(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteUsageSummaries(OrderItem[] orderItems) {
        if (!orderItems.isEmpty()) {
            Set<Id> orderItemIds = new Set<Id>();
            for (OrderItem oi : orderItems) {
                orderItemIds.add(oi.Id);
            }
            blng__UsageSummary__c[] usageSummariesToDelete = [SELECT Id FROM blng__UsageSummary__c WHERE blng__OrderProduct__c IN :orderItemIds];
            if (!usageSummariesToDelete.isEmpty()) {
                Database.delete(usageSummariesToDelete);
            }
        }

        System.debug('Total Number of SOQL Queries after deleteUsageSummaries(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteRevenueSchedules(OrderItem[] orderItems) {
        if (!orderItems.isEmpty()) {
            Set<Id> orderItemIds = new Set<Id>();
            for (OrderItem oi : orderItems) {
                orderItemIds.add(oi.Id);
            }
            blng__RevenueSchedule__c[] revenueSchedulesToDelete = [SELECT Id FROM blng__RevenueSchedule__c WHERE blng__OrderProduct__c IN :orderItemIds];
            if (!revenueSchedulesToDelete.isEmpty()) {
                Database.delete(revenueSchedulesToDelete);
            }
        }

        System.debug('Total Number of SOQL Queries after deleteRevenueSchedules(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteRevenueSchedules(blng__InvoiceLine__c[] invLines) {
        if (!invLines.isEmpty()) {
            Set<Id> invLineIds = new Set<Id>();
            for (blng__InvoiceLine__c line : invLines) {
                invLineIds.add(line.Id);
            }
            blng__RevenueSchedule__c[] revenueSchedulesToDelete = [SELECT Id FROM blng__RevenueSchedule__c WHERE blng__InvoiceLine__c IN :invLineIds];
            if (!revenueSchedulesToDelete.isEmpty()) {
                Database.delete(revenueSchedulesToDelete);
            }
        }

        System.debug('Total Number of SOQL Queries after deleteRevenueSchedules(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteOpportunities() {
        Id a = this.AccountId;
        Opportunity[] opportinitiesToDelete = [SELECT Id FROM Opportunity WHERE AccountId = :a];
        if (!opportinitiesToDelete.isEmpty()) {
            Database.delete(opportinitiesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteOpportunities(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteAssets() {
        Id a = this.AccountId;
        Asset[] assetsToDelete = [SELECT Id FROM Asset WHERE AccountId = :a];
        if (!assetsToDelete.isEmpty()) {
            Database.delete(assetsToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteAssets(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteSubscriptions() {
        Id a = this.AccountId;
        SBQQ__Subscription__c[] subscriptionsToDelete = [SELECT Id FROM SBQQ__Subscription__c WHERE SBQQ__Account__r.Id = :a];
        if (!subscriptionsToDelete.isEmpty()) {
            Database.delete(subscriptionsToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteSubscriptions(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteContracts() {
        Id a = this.AccountId;
        Contract[] contractsToDelete = [SELECT Id, SBQQ__RenewalOpportunity__c FROM Contract WHERE AccountId = :a];
        if (!contractsToDelete.isEmpty()) {
            for (Contract c : contractsToDelete) {
                c.SBQQ__RenewalOpportunity__c = null;
            }
            Database.update(contractsToDelete);
            Database.delete(contractsToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteContracts(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteQuotes() {
        Id a = this.AccountId;
        SBQQ__Quote__c[] quotesToDelete = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Account__r.Id = :a];
        if (!quotesToDelete.isEmpty()) {
            Set<Id> quoteIds = new Set<Id>();
            for (SBQQ__Quote__c q : quotesToDelete) {
                quoteIds.add(q.Id);
            }
            this.deleteProcessInputValues(quoteIds);
            Database.delete(quotesToDelete);
        }

        System.debug('Total Number of SOQL Queries after deleteQuotes(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deletePayments() {
        Id a = this.AccountId;
        blng__Payment__c[] payments = [SELECT Id FROM blng__Payment__c WHERE blng__Account__c = :a];
        if (!payments.isEmpty()) {
            Database.delete(payments);
        }

        System.debug('Total Number of SOQL Queries after deletePayments(): ' + Limits.getQueries());

        return true;
    }

    private Boolean deleteRefunds() {
        Id a = this.AccountId;
        blng__Refund__c[] refunds = [SELECT Id FROM blng__Refund__c WHERE blng__Account__c = :a];
        if (!refunds.isEmpty()) {
            Database.delete(refunds);
        }

        System.debug('Total Number of SOQL Queries after deleteRefunds(): ' + Limits.getQueries());

        return true;
    }

    private static List<OrderItem> getOrderItems(Set<Id> orderIds) {
        OrderItem[] orderItems = [SELECT Id FROM OrderItem WHERE OrderId IN :orderIds];
        return orderItems;
    }

    private static List<blng__InvoiceLine__c> getInvoiceLines(Set<Id> invoiceIds) {
        blng__InvoiceLine__c[] invoiceLines = [SELECT Id FROM blng__InvoiceLine__c WHERE blng__Invoice__c IN :invoiceIds];
        return invoiceLines;
    }

    private Boolean deleteContractedPrices() {
        Id a = this.AccountId;
        if (settings.Delete_Contracted_Prices__c == true) {
            SBQQ__ContractedPrice__c[] cpToDelete = [SELECT Id FROM SBQQ__ContractedPrice__c WHERE SBQQ__Account__c = :a];
            if (!cpToDelete.isEmpty()) {
                Database.delete(cpToDelete);
            }
        }
        System.debug('Total Number of SOQL Queries after deletePaymentTransactions(): ' + Limits.getQueries());

        return true;
    }
    private Boolean deleteOrderConsumption() {
        Id a = this.AccountId;
        if (settings.Delete_Contracted_Prices__c == true) {
            SBQQ__OrderItemConsumptionSchedule__c[] ocToDelete = [SELECT Id FROM SBQQ__OrderItemConsumptionSchedule__c WHERE SBQQ__OrderItem__r.Order.AccountId = :a];
            if (!ocToDelete.isEmpty()) {
                Database.delete(ocToDelete);
            }
        }
        System.debug('Total Number of SOQL Queries after deletePaymentTransactions(): ' + Limits.getQueries());

        return true;
    }
   
}
trigger MaintenanceOrderProduct on OrderItem (before insert) {

    if(System.isBatch()) return;
    
    Id defaultEntity = null;
    Id defaultTaxTreatment = null;
    Id defaultBillingTreatment = null;
    
    if([SELECT Id From blng__LegalEntity__c Where Name = 'Corporate - AMER' Limit 1].size()>0){
        defaultEntity = [SELECT Id From blng__LegalEntity__c Where Name = 'Corporate - AMER' Limit 1].Id;
    }
    if([SELECT Id From blng__TaxTreatment__c Where Name = 'Tax Exempt Treatment' Limit 1].size()>0){
        defaultTaxTreatment = [SELECT Id From blng__TaxTreatment__c Where Name = 'Tax Exempt Treatment - AMER' Limit 1].Id;
    }
    if([SELECT Id From blng__BillingTreatment__c Where Name = 'Combine Partial Periods Treatment' Limit 1].size()>0){
        defaultBillingTreatment = [SELECT Id From blng__BillingTreatment__c Where Name = 'Combine Partial Periods Treatment - AMER' Limit 1].Id;
    }
    
    
    for(OrderItem Oitem : trigger.new){
        Oitem.blng__LegalEntity__c=defaultEntity;
        Oitem.blng__TaxTreatment__c=defaultTaxTreatment;
        //Oitem.SBQQ__TaxCode__c='A234';
        oitem.blng__BillingTreatment__c = defaultBillingTreatment;
        
    }
}
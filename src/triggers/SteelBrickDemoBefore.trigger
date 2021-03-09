trigger SteelBrickDemoBefore on SBQQ__Quote__c (before update, before insert) {
    /*
     *
     * INSERT
     *
    */
    if(trigger.isInsert){
        List<SBQQ__QuoteProcess__c> process = new List<SBQQ__QuoteProcess__c>();
        process = [SELECT Id FROM SBQQ__QuoteProcess__c ORDER BY CreatedDate ASC LIMIT 1];
        List<Pricebook2> pbook = new List<Pricebook2>();
        pbook = [SELECT Id FROM Pricebook2 Where isStandard=true];
        for(SBQQ__Quote__c quote : trigger.new){
            quote.Print_Notes__c = (quote.SBQQ__Notes__c != null);
            if(process.size() == 1){
                quote.SBQQ__QuoteProcessId__c = process.get(0).Id;
                quote.SBQQ__PricebookId__c = pbook.get(0).Id;
            }
        }
    }
    
    
    /*
     *
     * UPDATE
     *
    */
    else if(trigger.isupdate){
        for(SBQQ__Quote__c quote : trigger.new){
            quote.Print_Notes__c = (quote.SBQQ__Notes__c != null);
        }
    }
}
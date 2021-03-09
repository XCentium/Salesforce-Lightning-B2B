@IsTest(SeeAllData=true)
private class LightningProductPricerTestClass {

    public testMethod  static void ProductPricerTestMethod() {
        Account oTestAccount;

                oTestAccount = new Account(name='testAccount');
                insert oTestAccount;
                system.debug('account:'+oTestAccount.id);

        Opportunity oTestOpp;
                oTestOpp = new Opportunity(AccountId=oTestAccount.id,Name='testopp',stagename='Qualification',CloseDate=Date.today());
                insert oTestOpp;
                system.debug('opp:'+oTestOpp.id);

    Pricebook2 standardPB = [select name, isactive from Pricebook2 where IsStandard = true limit 1];
    system.debug('standardPB:'+standardPB.Id);

        Quote oTestQuote;
                oTestQuote = new Quote(OpportunityId=oTestOpp.id,Name='testQuote');
                oTestQuote.PriceBook2Id = standardPB.Id;
                insert oTestQuote;
                system.debug('quote:'+oTestQuote.id);

     Product2 pr = new Product2(Name='Test Product 1',IsActive=true);
     insert pr;
     Product2 pr2 = new Product2(Name='Test Product 2',IsActive=true);
     insert pr2;
        
     IDO_upsell_product__c up = new IDO_upsell_product__c(source_product__c=pr.Id,suggestion__c=pr2.Id);
     insert up;   
     system.debug('product:'+pr.id);

     PricebookEntry pbe = new PricebookEntry(Pricebook2Id = standardPB.Id, Product2Id = pr.Id, UnitPrice = 10000, IsActive = true, UseStandardPrice = false);
   insert pbe;
     system.debug('standardprice:'+pbe.id);


        QuoteLineItem testLine = new QuoteLineItem(PricebookentryId=pbe.Id,unitprice=pbe.unitPrice,quantity=1,quoteId=oTestQUote.Id); 
        insert testLine;
        system.debug('Line:'+testLine.id);

        IDO_Section__c testsection = new IDO_Section__c();
        testsection.Quote__c = oTestQuote.Id;
        testsection.Name='test Section';
        insert testsection;
        
        QuoteLineItem testLine2 = new QuoteLineItem(PricebookentryId=pbe.Id,unitprice=pbe.unitPrice,quantity=1,quoteId=oTestQUote.Id); 
        testLine2.Section__c=testsection.id;
        insert testLine2;
        system.debug('Line:'+testLine.id);

        
        system.debug('testSection:'+testsection.id);

        LightningProductPricer.Section[] secList = new list< LightningProductPricer.Section>();
        secList.add(new LightningProductPricer.Section(testsection));
        String secListJson = json.serialize(secList);
        
        
        Test.startTest();

        LightningProductPricer.loadLines('Quote',oTestQUote.Id);
        LightningProductPricer.saveLines(secListJson,'Quote',oTestQuote.Id);
        LightningProductPricer.getLineDetails('Quote',oTestQUote.Id,pr.Id);

        LightningProductPricer.fetchOrgInfo('Quote',oTestQUote.Id);
        LightningProductPricer.getActivePricebooks('Quote',oTestQUote.Id);
        LightningProductPricer.setPricebook('Quote',oTestQUote.Id,standardPB.Id);
        LightningProductPricer.createNewParentRec(oTestAccount.id,'Opportunity');
         LightningProductPricer.createNewParentRec(oTestAccount.id,'Order');
        
        
        /*List<Quote_Section__c> QS = new List<Quote_Section__c>();
        QS.add(testsection);
        string sectionsJson  = JSON.serializePretty(QS);
        LightningProductPricer.saveLines(sectionsJson);*/

    }


}
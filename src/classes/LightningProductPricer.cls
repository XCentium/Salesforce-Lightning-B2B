global class LightningProductPricer {

        
    static final String APP_NAME = 'Lightning Pricer';
    static final String APP_VERSION = 'Sept 11th, 2019';
    
           
    /*loadLines is called to return all existing sections and lines at initial load of the component*/
    @auraEnabled
    public static list<Section> loadLines(string parentObjName, string parentRecId){
        
     //first we need to query all the line items associated with the parent object : a quote, an opportunity or an order  
     Map<String, Section> sectionsMap = new Map<String, Section>();   
     sObject[] lineItems;   
     if (parentObjName=='Quote'){
       lineItems = [select id,quoteId,PricebookEntry.Pricebook2Id,PricebookEntry.Product2.id,PricebookEntry.Product2.Name,PricebookEntry.Product2.ProductCode,PriceBookEntryId,PriceBookEntry.Id,PriceBookEntry.UnitPrice,PriceBookEntry.Product2.Product_cost__c,PriceBookEntry.Product2.Increment__c,  UnitPrice,Discount,quantity,TotalPrice,Section__c,Section_Name__c
                                    from QuoteLineItem where quoteId=:parentRecId order by CreatedDate asc];
   
     }
     if (parentObjName=='Opportunity'){ 
       lineItems = [select id,opportunityId,PricebookEntry.Pricebook2Id,PricebookEntry.Product2.id,PricebookEntry.Product2.Name,PricebookEntry.Product2.ProductCode,PriceBookEntryId,PriceBookEntry.Id,PriceBookEntry.UnitPrice,PriceBookEntry.Product2.Product_cost__c,PriceBookEntry.Product2.Increment__c,  UnitPrice,Discount,quantity,TotalPrice,Section__c,Section_Name__c
                                    from OpportunityLineItem where opportunityId=:parentRecId order by CreatedDate asc];  
     } 
     if (parentObjName=='Order'){ 
       lineItems = [select id,orderId,PricebookEntry.Pricebook2Id,PricebookEntry.Product2.id,PricebookEntry.Product2.Name,PricebookEntry.Product2.ProductCode,PriceBookEntryId,PriceBookEntry.Id,PriceBookEntry.UnitPrice,PriceBookEntry.Product2.Product_cost__c,PriceBookEntry.Product2.Increment__c,  UnitPrice,Discount__c,quantity,TotalPrice,Section__c,Section_Name__c
                                    from OrderItem where orderId=:parentRecId order by CreatedDate asc];  
     }     
        

     // then we need to translate the "saved" unitprice to the "runtime" unitprice.
     // rules are not the same for opportunity quote and orders because order object do not natively propose a "discount" field. 
     for(sObject lineItem:lineItems){
             String discountFieldName = (parentObjName=='Quote' || parentObjName=='Opportunity') ? 'Discount' : 'Discount__c';
             Decimal Discount = (Decimal) lineItem.get(discountFieldName);
             Discount = (Discount==null) ? 0 : Discount;
             Decimal UnitPrice = (Decimal) lineItem.get('UnitPrice');  
             lineItem.put(discountFieldName, Discount );
             if (parentObjName=='Quote' || parentObjName=='Opportunity')
                lineItem.put('UnitPrice' , UnitPrice * (1-(Discount/100)) );
     }   
        
     // now, let's regroup our lines according to the section they belong to. 
     // lines without section will be regrouped in a new section  
     for(sObject lineItem:lineItems){   
         String sectionId = (string) lineItem.get('IDO_Section__c');
         Section lineSection;
         if (sectionId!=null)
             lineSection = sectionsMap.get(sectionId)!=null ? sectionsMap.get(sectionId) : new Section(sectionId,(string) lineItem.get('Section_Name__c'));
         if (sectionId==null)
             lineSection = sectionsMap.get(sectionId)!=null ? sectionsMap.get(sectionId) : new Section(System.Label.Pricer_NewSection,parentObjName,parentRecId);
         Line line=new Line(lineItem);
         lineSection.lines.add(line);
         sectionsMap.put(sectionId,lineSection);
     }
       
     //let's move all unparented lines (they belong to the section with a null id) to the 1st section
     //But if we have only unparented lines, we have nothing to move as they are already in a new section
     if (sectionsMap.get(null)!=null){
         if (sectionsMap.size() > 1) {
             string firstNonNullSection;
             for (string sectionId : sectionsMap.keyset()){
                 if (sectionId!=null) firstNonNullSection=sectionId;
                 break;
             }
             Section sectionToOverwrite=sectionsMap.get(firstNonNullSection);
             sectionToOverwrite.lines.addAll(sectionsMap.get(null).lines);
             sectionsMap.put(firstNonNullSection,sectionToOverwrite);
             sectionsMap.remove(null);
         } 
     }
     // finally, let's convert our map to a list so we can return it to the lightning component
     list<Section> sectionsList = new list<Section>();  
     for (string key:sectionsMap.keySet()){
        sectionsList.add(sectionsMap.get(key));       
     }   
     system.debug('load lines result (as JSON):');   
     system.debug(JSON.serialize(sectionsList));     
     return sectionsList;
        
    }

    
    @auraEnabled
    global static string saveLines(string linesJSON, String parentObjName, Id parentRecId){
    
        try {
            system.debug('linesJSON');
            system.debug(linesJSON);
            //first let's check if the quote has a pricebook, if not, let's assign the standard price book.
            sObject parentRec;
            if (parentObjName=='Quote') parentRec = [select Id, Pricebook2Id from Quote where id=:parentRecId LIMIT 1];
            if (parentObjName=='Opportunity') parentRec = [select Id, Pricebook2Id from Opportunity where id=:parentRecId LIMIT 1];
            if (parentObjName=='Order') parentRec = [select Id, Pricebook2Id from Order where id=:parentRecId LIMIT 1];
            
            if (parentRec.get('Pricebook2Id')==null) {
                Pricebook2 stdPb = [select Id, Name, IsActive from PriceBook2 where IsStandard=True LIMIT 1];
                parentRec.put('Pricebook2Id',stdPb.Id);
                update parentRec;
            }
            
            // prepare some vars for  the lists that we will need to upsert or delete. 
            list<IDO_Section__c> sectionToUpsertList = new list<IDO_Section__c>();
            list<sObject> linesToUpsertList = new list<sObject>();
            list<sObject> linesToDeleteList = new list<sObject>();
            
            //Parse our JSON input with our section class
            
            /*system.debug('trying alternate method:');
            Section[] sectionTest = (List<Section>)System.JSON.deserialize(linesJSON, List<Section>.class);
            system.debug('alternate method success');*/
            
            

            list<Section> sectionList = new list<Section>();
            JSONParser parser = JSON.createParser(linesJSON);
            while (parser.nextToken() != null) {
                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                    while (parser.nextToken() != null) {
                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                            //system.debug(parser.getCurrentName());
                            Section section = (Section)parser.readValueAs(Section.class);
                            if (!section.isDeleted) sectionList.add(section);
                        }
                        
                    }
                }
            }
            
            
            for (Section section:sectionList){
                sectionToUpsertList.add(section.oSection);
            }
            
            //remove all sections from current quote except for the ones that are planned to be upserted.
            //This will delete all sections tagged for removal in the pricer. 
            IDO_Section__c[] STBR = [select id from IDO_Section__c where (Quote__c=:parentRecId OR Opportunity__c=:parentRecId OR Order__c=:parentRecId) AND (id NOT IN :sectionToUpsertList)];
            delete STBR;
            if (sectionToUpsertList.size()>0) upsert sectionToUpsertList;
            
            
            
            for (Section section:sectionList){
                if (section.lines!=null){    
                    for (Line line:section.lines){
                        if (line<>null && line.isDeleted==true) continue;
                        if ( ((Decimal) line.oLine.get('Quantity')) > 0){
                            line.oLine.put('IDO_Section__c', (ID) section.oSection.id);
                            Decimal UnitPrice = (Decimal) line.oLine.get('UnitPrice');
                            Decimal Discount;
                            if (parentObjName=='Opportunity' || parentObjName=='Quote'){
                                Discount = (Decimal) line.oLine.get('Discount');
                                line.oLine.put('UnitPrice', (UnitPrice / (1-(Discount/100)))); // This line is to translate pricer data model into quote & quoteline item standard object           
                            } 
                            if (parentObjName=='Order')
                                Discount = (Decimal) line.oLine.get('Discount__c');
                            //if (((Id) line.oLine.get('Id')==null) && (parentObjName=='Opportunity')) line.oLine.put('TotalPrice',null); //weird bug fix... I've found that while doing an Insert, that you must not provide TotalPrice, but you must provide UnitPrice.  While doing an update, you provide both.  
                            linesToUpsertList.add(line.oLine);
                        }
                    }
                }      
            }
            
            //remove all lines from current Quote, Opportunity or Order except for the one planned to be upserted.
            sObject[] linesToRemove;
            if (parentObjName=='Quote') linesToRemove = [select id from QuoteLineItem where quoteId=:parentRecId AND id NOT IN :linesToUpsertList];
            if (parentObjName=='Opportunity') linesToRemove = [select id from OpportunityLineItem where OpportunityId=:parentRecId AND id NOT IN :linesToUpsertList];
            if (parentObjName=='Order') linesToRemove = [select id from OrderItem where OrderId=:parentRecId AND id NOT IN :linesToUpsertList];
            delete linesToRemove;
            
            // Now that our Quote, Opportunity or order has been cleaned, it is time to upsert the lines we want to save
            if (linesToUpsertList.size()>0) {
                //GENERIC SOBJECTS CANNOT BE UPSERTED. WE NEED TO CAST OUR LINES TO THE CORRECT OBJECT.
                String listType;
                if (parentObjName=='Quote') listType = 'List<' + 'QuoteLineItem' + '>';
                if (parentObjName=='Opportunity') listType = 'List<' + 'OpportunityLineItem' + '>';
                if (parentObjName=='Order') listType = 'List<' + 'OrderItem' + '>';
                List<SObject> castRecords = (List<SObject>)Type.forName(listType).newInstance();
                //system.debug(linesToUpsertList);
                castRecords.addAll(linesToUpsertList);
                upsert castRecords;
            }
            
            
            return 'Apex Save Method Done!';

        }
        catch (Exception e) {
            // "Convert" the exception into an AuraHandledException
            throw new AuraHandledException('Darn it! Something went wrong: '
                + e.getMessage());    
        }
     
    }
    
    
     public static Pricebook2 getRecPricebook(string parentObjName,Id parentRecId){
        sObject parentRec;   
        if (parentObjName=='Quote')
           parentRec = [select Pricebook2Id,Pricebook2.Id,Pricebook2.Name,Pricebook2.IsActive,Pricebook2.IsStandard from Quote where id=:parentRecId];
        if (parentObjName=='Opportunity')
           parentRec = [select Pricebook2Id,Pricebook2.Id,Pricebook2.Name,Pricebook2.IsActive,Pricebook2.IsStandard from Opportunity where id=:parentRecId];        
        if (parentObjName=='Order')
           parentRec = [select Pricebook2Id,Pricebook2.Id,Pricebook2.Name,Pricebook2.IsActive,Pricebook2.IsStandard from Order where id=:parentRecId];
        
        
        ID pbId = (id) parentRec.get('Pricebook2Id');
        if (pbId!=null){
            return (Pricebook2) parentRec.getSObject('Pricebook2');
         }    
        else {
          //if no pricebook was found, then let's revert to the standard pricebook.  
          Pricebook2 stdPb = [select Id, Name,IsStandard,IsActive from PriceBook2 where IsStandard=True LIMIT 1];
          return stdPb;
        }
    }
    
    //return all active pricebooks as picklist options
    @AuraEnabled
    public static PLE[] getActivePricebooks (string parentObjName,Id parentRecId){
    PLE[] options = new list<PLE>();
    Pricebook2 currentPB = getRecPricebook(parentObjName,parentRecId);
    Pricebook2[] allActivePB = [select Id, Name from PriceBook2 where IsActive=True];
    for (Pricebook2 PB : allActivePB){
      Boolean isSelected = (PB.Id == currentPB.Id);
      options.add(new PLE(PB.Id,PB.Name,isSelected));  
    }      
    return options;
    }
    
    
    @AuraEnabled
    public static void setPricebook (string parentObjName,Id parentRecId,Id pricebookId){
        //remove all line items
        sObject[] lineItems;   
        if (parentObjName=='Quote')
           lineItems = [select Id from QuoteLineItem where quoteId=:parentRecId];
        if (parentObjName=='Opportunity')
           lineItems = [select Id from OpportunityLineItem where opportunityId=:parentRecId];
        if (parentObjName=='Order')
           lineItems = [select Id from OrderItem where orderId=:parentRecId];
        delete lineItems;
        
        //change pricebook
        sObject parentRec = (sObject) Type.forName(parentObjName).newInstance();
        parentRec.put('Id',parentRecId);
        parentRec.put('Pricebook2Id',pricebookId);
        update parentRec;
    }
    

    

    @AuraEnabled
    public static Line getLineDetails(string parentObjName, Id parentRecId, string productId){
        
        //first we need to determine the pricebook in which we will look for the product price. 
        //let's find the pricebook from the parent object. 
        Pricebook2 pb = getRecPricebook(parentObjName,parentRecId); 
        
        //let's create a new line
        Line line= getNewLine(parentObjName);
        line.product.id=productId;
        line.pricebookId=pb.Id;
        line.pricebookName=pb.Name;
        line.oLine.put(parentObjName+'Id',parentRecId);
        if (parentObjName == 'Quote' || parentObjName == 'Opportunity'){
           line.oLine.put('Discount',0); 
        }
        else {
          line.oLine.put('Discount__c',0);    
        }
        line.oLine.put('quantity',1);
        

        PriceBookEntry[] pbeList = [select id,product2id,UnitPrice, product2.Id,product2.Name,product2.Product_cost__c,product2.Increment__c,product2.description,product2.productCode from PriceBookEntry where Product2.Id =:line.product.id and pricebook2.id=:pb.Id];

        if (pbeList.size()>0) {
        PriceBookEntry pbe = pbeList[0];
        system.debug('found pricebook entry - id:'+pbe.id);


            line.oProduct=pbe.product2;

            line.oLine.put('PriceBookEntryId',pbe.Id);
            line.oLine.putSObject('PriceBookEntry',pbe);
            line.productCost = pbe.product2.Product_cost__c;

            Integer qty=1;
            if (pbe.product2.Increment__c!=null) {
              integer increment = Integer.valueOf(pbe.product2.Increment__c);   
              line.increment=increment;
              line.product.increment=increment;
              qty =increment; 
              line.oLine.put('quantity', increment);  
              }

            UnitPriceQueryResult UPQR = queryNewUnitPrice(productId,parentObjName, parentRecId, pb.Id, qty, pbe.UnitPrice);
            line.UPQR=UPQR;
            line.oLine.put('UnitPrice',UPQR.UnitPrice);
            
            if ((decimal) line.oLine.get('quantity')!=null && UPQR.UnitPrice!=null) {
            line.totalPrice = (decimal) line.oLine.get('quantity') * UPQR.UnitPrice;
            line.totalPrice= ((decimal) line.totalPrice).setscale(2);
            }    
            
            
            if (line.productCost!=null && UPQR.UnitPrice!=null && line.productCost!=0 && UPQR.UnitPrice!=0)
                line.margin=(((UPQR.UnitPrice/line.productCost)-1)).setscale(4); 



            for(IDO_upsell_product__c oAssociation:[select id,Suggestion__c,Suggestion__r.Name,Suggestion__r.Description,Comment__c,quantity__c,Suggestion__r.ProductCode  from IDO_upsell_product__c where Source_product__c =:line.product.id])    {
                if (line.upsellProductList==null) line.upsellProductList=new list<line>();
                Line newUpsellLine = getLineDetails(parentObjName,parentRecId,oAssociation.Suggestion__c);
                newUpsellLine.quantity = Integer.valueOf(oAssociation.quantity__c);
                newUpsellLine.oLine.put('quantity', Integer.valueOf(oAssociation.quantity__c) );
                newUpsellLine.upsellPitch=oAssociation.Comment__c;
                line.upsellProductList.add(newUpsellLine);
            }



        } else {
          //If no price in catalog, let's return a price of 0.
          line.UPQR=new UnitPriceQueryResult();
          line.UPQR.UnitPrice=0;
          line.oLine.put('UnitPrice',0);  

          line.UPQR.Explanation=System.Label.PricerNoCatalogPriceFound+'<br>';
          Product2[] foundProduct = [select Id, name, Product_cost__c, Increment__c, description,productCode from Product2 where id=:productId LIMIT 1];
          if (foundProduct.size() > 0 )line.oProduct = foundProduct[0];
          else throw new AuraHandledException('This product either doesn\'t exist or you don\'t have access to it');
            
          line.oLine.putSObject('PriceBookEntry',new PriceBookEntry(Id=null,UnitPrice=0));  
          line.oLine.put('PriceBookEntryId',null); 

        }
        system.debug('pricebookId'+line.pricebookId);
        system.debug(line);
        system.debug(line.product.increment);
        return line;
    }
    
    @AuraEnabled
    public static UnitPriceQueryResult queryNewUnitPrice(Id productId,string parentObjName, Id parentRecId, Id pricebookId, Integer qty, Decimal listPrice){
      String currencyCode = UserInfo.getDefaultCurrency();
      if (currencyCode=='EUR') currencyCode='€';
      if (currencyCode=='USD') currencyCode='$';
      if (currencyCode=='GBP') currencyCode='£';   
        
      UnitPriceQueryResult UPQR = new UnitPriceQueryResult();
      UPQR.UnitPrice = listPrice;
      //UPQR.Explanation = 'Unit price is  :  <b>'+listPrice+' €</b><br/>';
      UPQR.Explanation = System.Label.Pricer_BaseUnitPrice+' <b>'+listPrice+' '+currencyCode+'</b><br/>';  

      // let's check the price per quantity
       system.debug('pricebookIdRequested : '+pricebookId);
       IDO_Price_per_quantity__c[] PricePerQTY =  [select id,Qty__c,Price__c,Pricebook__c from IDO_Price_per_quantity__c where Pricebook__c=:pricebookId AND Produit__c =:productId AND Qty__c <= :qty ORDER BY Qty__c DESC LIMIT 1];
       system.debug(PricePerQty);
       if (PricePerQTY.size()>0 && PricePerQTY[0].Price__c < listPrice) {
          UPQR.UnitPrice = PricePerQTY[0].Price__c;
          UPQR.Explanation = System.Label.Pricer_UnitPriceIs+' <b>'+PricePerQTY[0].Price__c+' '+currencyCode+'</b> '+System.Label.Pricer_ForMinQuantity+' <b>'+PricePerQTY[0].Qty__c+'</b><br/>';
       }

      //Get information about the account linked to the opportunity, quote or order.  
       sObject parentRec; 
       system.debug('parentObjName='+parentObjName+' parentRecId='+parentRecId); 
       if (parentObjName=='Quote'){
            parentRec = [select id, accountId, account.Global_Discount__c from Quote where id=:parentRecId];
       }
       if (parentObjName=='Opportunity'){
            parentRec = [select id, accountId, account.Global_Discount__c from Opportunity where id=:parentRecId];
       }
       if (parentObjName=='Order'){
            parentRec = [select id, accountId, account.Global_Discount__c from Order where id=:parentRecId];
       }
        
       String accountId = (string) parentRec.get('accountId'); 
       Decimal accountGlobalDiscount = null;
       if (accountId!=null) accountGlobalDiscount = (Decimal) parentRec.getSObject('account').get('Global_Discount__c');
       
        
        
      // Apply the global discount for this account if it exists
       if ((accountGlobalDiscount!=null) && (accountGlobalDiscount > 0 )) {
         UPQR.UnitPrice = UPQR.UnitPrice * (1-(accountGlobalDiscount/100));
         UPQR.Explanation += System.Label.Pricer_AccountDiscountOnAllArticles+' : <b>'+accountGlobalDiscount+' %</b><br/>';
        }

      //Check if there is a special rate negociated for this product on this account.
      // And if this special rate is better than the other prices, let's apply it !
      IDO_Product_special_terms__c[] pst = [select id, Price__c from IDO_Product_special_terms__c where Product__c = :productId AND Account__c = : accountId];
      if (pst.size()>0 && pst[0].Price__c!=null && pst[0].Price__c>0 && pst[0].Price__c < UPQR.UnitPrice ) {
        UPQR.UnitPrice=pst[0].Price__c;
        UPQR.Explanation = System.Label.Pricer_NegotiatedPriceOf+' <b>'+pst[0].Price__c+' '+currencyCode+'</b> '+System.Label.Pricer_ForThisArticle+' <br/>';
        }


       return UPQR;
    }



    global class Section{
        @AuraEnabled
        public Boolean isEditMode{get;set;}
        @AuraEnabled
        public list<line> lines{get;set;}
        @AuraEnabled
        public IDO_Section__c oSection {get;set;}
        @AuraEnabled
        public integer sequence{get;set;}
        @AuraEnabled
        public decimal total{get;set;}
        @AuraEnabled
        public string discountLevel{get;set;}
        @AuraEnabled
        public boolean isDeleted {get;set;}

        private void initSection(){
            this.lines = new list<line>();
            this.total=0;this.discountLevel='Green';
            this.isEditMode=false;this.isDeleted=false;
        }
        
        public Section(IDO_Section__c oSection){
            this.oSection = oSection;
            this.initSection();
        }
        
        public Section(string sectionId, string sectionName){
            this.oSection = new IDO_Section__c(id=sectionId,name=sectionName);
            this.initSection();
        }
        public Section(string newSectionName,string parentRecObj,string parentRecId){
            if (parentRecObj=='Quote')
                  this.oSection = new IDO_Section__c(Quote__c=parentRecId,name=newSectionName);
            if (parentRecObj=='Opportunity')
                  this.oSection = new IDO_Section__c(Opportunity__c=parentRecId,name=newSectionName);
            if (parentRecObj=='Order')
                  this.oSection = new IDO_Section__c(Order__c=parentRecId,name=newSectionName);
            this.initSection();
        } 

    }

    @Auraenabled
    public static Line getNewLine(string parentObjName){
        sObject oLine;
        if (parentObjName=='Quote'){
            oLine = new QuoteLineItem();
        }
        if (parentObjName=='Opportunity'){
            oLine = new OpportunityLineItem();
        }
        if (parentObjName=='Order'){
            oLine = new OrderItem();
        }  
        oLine.put('PricebookEntryId',null);
        return new Line(oLine);
    }
    
    @Auraenabled
    public static string createNewParentRec(string accountId, string parentType){
        Account acc = [select id, name from Account where id=:accountId];
        sObject recToCreate;
        
        if (parentType=='Opportunity') {
        String stageName=Opportunity.stagename.getDescribe().getPicklistValues()[0].getValue(); //Get 1st value of stageName picklist
        String oppName=acc.Name+' - '+System.Label.Pricer_opportunity_generated_from_pricer;
        recToCreate = new Opportunity(name=oppName,accountId=accountId,
                                          closeDate=Date.today(),amount=0,
                                          stageName=stageName);
        }
        if (parentType=='Order') {
           String statusName=Order.status.getDescribe().getPicklistValues()[0].getValue(); //Get 1st value of status picklist 
           recToCreate = new Order(Status=statusName,EffectiveDate=Date.today(),accountId=accountId);            
        }    
        
        insert recToCreate;
        return recToCreate.Id;
    }     
    
    
    @AuraEnabled    
    public static string getStatsURL (string namespace) {
        String url='https://sdo-demo-main-15259e2fa59.secure.force.com/services/apexrest/Pricer_Stats?';
        url+='AppName='+toBase64(APP_NAME)+'&AppVersion='+toBase64(APP_VERSION)+'&PackageVersion='+toBase64(getPackageVersion(namespace));
        url+='&UserName='+toBase64(UserInfo.getUserName())+'&UserEmail='+toBase64(UserInfo.getUserEmail());
        url+='&FirstName='+toBase64(UserInfo.getFirstName())+'&LastName='+toBase64(UserInfo.getLastName());
        url+='&OrgName='+toBase64(UserInfo.getOrganizationName())+'&OrgId='+toBase64(UserInfo.getOrganizationId());
        url+='&Language='+toBase64(UserInfo.getLanguage())+'&Locale='+toBase64(UserInfo.getLocale());
        url+='&TZ='+toBase64(UserInfo.getTimeZone().toString())+'&isCommunity='+toBase64(String.valueOf((Site.getSiteId()!=null)));
        url+='&Namespace='+ toBase64(((namespace == null) ? 'c' : namespace));
        return url;
    }

    private static string toBase64(string s) {
        return  EncodingUtil.base64Encode(Blob.valueOf(s));
    }    
    



    public class line{
        @AuraEnabled
        public sObject oLine {get;set;}
        @AuraEnabled
        public integer quantity {get;set;}
        @AuraEnabled
        public integer increment {get;set;}
        @AuraEnabled
        public double totalPrice {get;set;}
        @AuraEnabled
        public double discount {get;set;}
        @AuraEnabled
        public double productCost {get;set;}
        @AuraEnabled
        public double margin {get;set;}
        @AuraEnabled
        public Product2 oProduct{get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public String productId {get;set;}
        @AuraEnabled
        public String pricebookId {get;set;}
        @AuraEnabled
        public String pricebookName {get;set;}
        @AuraEnabled
        public String lot{get;set;}
        @AuraEnabled
        public boolean selected {get;set;}
        @AuraEnabled
        public String modificationText {get;set;}
        @AuraEnabled
        public Product product {get;set;}
        @AuraEnabled
        public list<Line> upsellProductList {get;set;}
        @AuraEnabled
        public boolean isDeleted {get;set;}
        @AuraEnabled
        public boolean isSelected {get;set;}
        @AuraEnabled
        public UnitPriceQueryResult UPQR {get;set;}
        @AuraEnabled
        public String upsellPitch {get;set;}
        @AuraEnabled
        public Boolean initialApexQueryDone {get;set;}

        public line(sObject oLine){
            this.initialApexQueryDone=true;
            this.oLine = oLine;
            Decimal oLineTotalPrice = (Decimal) oLine.get('TotalPrice');
            String lineType = oLine.getSObjectType().getDescribe().getName();
            Decimal oLineDiscount = (lineType == 'OrderItem') ? (Decimal) oLine.get('Discount__c') : (Decimal) oLine.get('Discount');
            Decimal oLineUnitPrice = (Decimal) oLine.get('UnitPrice');
            PriceBookEntry PBE = (PriceBookEntry) oLine.getSObject('Pricebookentry');
            //system.debug('oLine and PBE');
            //system.debug(oLine);system.debug(PBE);
            this.totalPrice=(oLineTotalPrice!=null)?oLineTotalPrice:0;
            this.discount=(oLineDiscount!=null)?oLineDiscount/100:0;
            this.Product=new Product();
            this.Product.Id='';
            this.Product.Name='';
            this.upsellPitch='';
            this.increment=1;
            this.Product.increment=1;
            this.pricebookId=(PBE!=null)?PBE.Pricebook2Id:null;
            selected=false;
            this.isSelected=false;
            upsellProductList = new list<Line>();
            try {
                this.oProduct = (PBE!=null)?PBE.Product2:null;
                this.increment=Integer.valueOf(this.oProduct.Increment__c);
                if (this.increment==null) this.increment=1;
                this.Product.increment=this.increment;
                this.productCost=this.oProduct.Product_cost__c;
                //if (this.oProduct.Product_cost__c==null) this.oProduct.Product_cost__c=0;
            } catch (Exception e){}
            this.margin=(oLineUnitPrice!=null && this.productCost!=null) ? (oLineUnitPrice/this.productCost)-1 : null;
            if (oLine.get('quantity')==null) quantity=1;
            this.UPQR=new UnitPriceQueryResult();
            this.UPQR.Explanation='';

        }




    }

    public class Product{
        @AuraEnabled
        public String Id;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public Integer increment;
    }

    public class result{
        public Boolean isSuccess;
        public String errorText;
    }

    public class UnitPriceQueryResult{
        @AuraEnabled
        public Decimal UnitPrice;
        @AuraEnabled
        public String Explanation;
    }
    

    @AuraEnabled
    public static OrgInfo fetchOrgInfo(string parentObjName, string parentRecId){
        string url = URL.getSalesforceBaseUrl().toExternalForm();
        string namespace  = getNamespacePrefix(); //get namespace in which Mass Edit Related Lists is running.
        pricebook2 recordPricebook;
        if (parentObjName!=null && parentRecId!=null)
            recordPricebook = getRecPricebook(parentObjName, parentRecId);
        OrgInfo org = new OrgInfo(url,namespace,getStatsURL(namespace),APP_VERSION,getPackageVersion(namespace),recordPricebook);
        return org;
    }
    
    public static string getPackageVersion(string namespace){
        string packageVersion='unknown';
        if (namespace!=null) {
            packageVersion=String.valueOf(System.requestVersion().major());
            packageVersion+='.'+String.valueOf(System.requestVersion().minor());  
        }
        return packageVersion;
    }
    
    
    // getNamespacePrefix() retrieves the namespace in which the component is running
    // method will return different answers depending on wheter were are running as managed packaged or as an unmanaged package. 
    public static String getNamespacePrefix() {
        String namespacePrefix;
        String[] classNameParts = String.valueOf(LightningProductPricer.class).split('\\.', 2);
        
        if(classNameParts.size() > 1) {
            Type classType = Type.forName(classNameParts[0], classNameParts[1]);
            if(classType == LightningProductPricer.class) {
                namespacePrefix = classNameParts[0];
            } else {
                namespacePrefix = null;
            }
        } else {
            //If there is only one part, the class has no namespace
            namespacePrefix = null;
        }
        return namespacePrefix; 
    }
    
    
    
    public class OrgInfo {
      @AuraEnabled
      public String baseURL;  
      @AuraEnabled
      public String namespace;
      @AuraEnabled
      public string statsUrl;
      @AuraEnabled
      public string appVersion;
      @AuraEnabled
      public pricebook2 recordPricebook;
      @AuraEnabled
      public string packageVersion;  
      public OrgInfo(string baseURL,string namespace,string statsUrl,string appVersion,string packageVersion,pricebook2 pb){
        this.baseURL=baseURL; this.namespace=namespace; this.statsUrl=statsUrl;
        this.packageVersion=packageVersion;this.appVersion=appVersion;
        this.recordPricebook=pb;
      }  
            
    }

  //PicklistEntry Class
  public class PLE {
    @AuraEnabled
    public String label;
    @AuraEnabled
    public String value;
    @AuraEnabled
    public boolean selected;
    public PLE(String value, String label, Boolean selected) {
      this.value=value; this.label=label; this.selected=selected;    
    }  
   }

}
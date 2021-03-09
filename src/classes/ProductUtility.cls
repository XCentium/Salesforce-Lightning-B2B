/**
 * QTC CDEMO Template Org Product Utility 
 * @author Matthew Seeger
 *
 * Modified by sean crowe November 21 2017
 *
 */
public class ProductUtility {
    public static void BeforeTriggerProcessor(List<Product2> allProds) {
        Id DefaultBilling = null;
        Id DefaultRevRec = null;
        Id DefaultTax = null;
        
        if([SELECT Id FROM blng__BillingRule__c WHERE Name = 'Separate Partial Periods' LIMIT 1].size()>0){
            DefaultBilling = [SELECT Id FROM blng__BillingRule__c WHERE Name = 'Separate Partial Periods' LIMIT 1].Id;
        }
        if([SELECT Id FROM blng__RevenueRecognitionRule__c WHERE Name = 'Order Based.50% Full,50% Ratable Split' LIMIT 1].size()>0){
            DefaultRevRec = [SELECT Id FROM blng__RevenueRecognitionRule__c WHERE Name = 'Order Based.50% Full,50% Ratable Split' LIMIT 1].Id;
        
        } 
        if([SELECT Id FROM blng__TaxRule__c WHERE Name = 'Tax Exempt' LIMIT 1].size()>0){
            DefaultTax = [SELECT Id FROM blng__TaxRule__c WHERE Name = 'Tax Exempt' LIMIT 1].Id;
            
        }
        
        for (Product2 thisProd : allProds) {
            if (thisProd.Description == '' || thisProd.Description == null) {
                thisProd.Description = thisProd.Name;
            }

            if (!thisProd.IsActive) {
                thisProd.IsActive = true;
            }
            if (thisProd.SBQQ__ChargeType__c == '' || thisProd.SBQQ__ChargeType__c == null) {
                thisProd.SBQQ__ChargeType__c = 'One-Time';
            }
            if (thisProd.blng__BillingRule__c == null) {
                thisProd.blng__BillingRule__c = DefaultBilling;
            }
            if (thisProd.blng__RevenueRecognitionRule__c == null) {
                thisProd.blng__RevenueRecognitionRule__c = DefaultRevRec;
            }
            if (thisProd.blng__TaxRule__c == null) {
                thisProd.blng__TaxRule__c = DefaultTax;
            }
        }
    }

    /**
     * Process all of the trigger items if After
     * @author Matthew Seeger
     *
     * Modified on October 13 2017 to separate clones vs net new
     */
    public static void AfterTriggerProcessor(List<Product2> allProds, Boolean isInsert) {
        List<Product2> prodsWithoutDescription = new List<Product2>();
        List<Product2> prodsWithPrice = new List<Product2>();
        List<Product2> netNewProducts = new List<Product2>();
        List<Product2> cloneProducts = new List<Product2>();

        for (Product2 thisProd : allProds) {

            if (thisProd.Standard_Pricebook_Price__c != null) {
                prodsWithPrice.add(thisProd);
            }

            if (thisProd.isClone()) {
                cloneProducts.add(thisProd);
            } else {
                netNewProducts.add(thisProd);
            }
        }

        if (prodsWithPrice.size() > 0) {
            ProductUtility.CreatePricebookEntries(prodsWithPrice);
        }

        
    }


    

    /**
     * When a product was inserted through cloning, use the approval thresholds form the cloned product instead
     * Added October 13 2017
     * @author Matthew Seeger
     *
     */
    


    public static void CreatePricebookEntries(List<Product2> prods) {
        
        List<Pricebook2> PBs = [SELECT Id FROM Pricebook2 Order By isStandard DESC];
        Boolean StdCreated = false;
       for(Pricebook2 PB:PBs){
       Map<String, Decimal> conversionRateMap = new Map<String, Decimal>();
       Set<Id> productIdsInThisLoad = new Set<Id>();

        //List<SBQQ__Cost__c> costsToUpsert = new List<SBQQ__Cost__c>();
        List<SBQQ__Cost__c> costsToUpdate = new List<SBQQ__Cost__c>();
        List<SBQQ__Cost__c> costsToInsert = new List<SBQQ__Cost__c>();

        List<PricebookEntry> pbesToUpdate = new List<PricebookEntry>();
        List<PricebookEntry> pbesToInsert = new List<PricebookEntry>();

        for (Product2 prod : prods) {

            productIdsInThisLoad.add(prod.Id);

        }

        List<PricebookEntry> existingPBEs = [SELECT Id, Product2Id, UnitPrice  FROM PricebookEntry WHERE Product2Id IN :productIdsInThisLoad and PriceBook2Id=:PB.id];
        Map<String, PricebookEntry> utilityKeyToPbeMap = new Map<String, PricebookEntry>();
        for (PricebookEntry pbe : existingPBEs) {
            string mapkey = string.valueof(pbe.Product2Id) + String.Valueof(PB.Id);
            utilityKeyToPbeMap.put(mapkey, pbe);
        }
       
        Decimal costFactor = 0.60;

        List<SBQQ__Cost__c> existingCosts = [SELECT Id, SBQQ__Product__c, SBQQ__UnitCost__c FROM SBQQ__Cost__c WHERE SBQQ__Product__c IN :productIdsInThisLoad];
        Map<String, SBQQ__Cost__c> utilityKeyToCostMap = new Map<String, SBQQ__Cost__c>();
        for (SBQQ__Cost__c cost : existingCosts) {
            utilityKeyToCostMap.put(cost.SBQQ__Product__c, cost);
        }
        
        List<SBQQ__Cost__c> costsToClone = new List<SBQQ__Cost__c>();

        List<SBQQ__Cost__c> costsCloned = new List<SBQQ__Cost__c>();

        for (Product2 prod : prods) {

            /**  if(costsToUpsert.size() + currencyCount >= 200){
                  database.upsert(costsToUpsert, SBQQ__Cost__c.Product_Utility_Key__c, TRUE);
                  costsToUpsert = new List<SBQQ__Cost__c>();
              }**/
            if (costsToInsert.size()  >= 200) {
                Database.insert(costsToInsert);
                costsToInsert = new List<SBQQ__Cost__c>();
            }
            if (costsToUpdate.size()  >= 200) {
                Database.update(costsToUpdate);
                costsToUpdate = new List<SBQQ__Cost__c>();
            }

            if (pbesToInsert.size()  >= 200) {
                Database.insert(pbesToInsert);
                pbesToInsert = new List<PricebookEntry>();
            }
            if (pbesToUpdate.size()  >= 200) {
                Database.update(pbesToUpdate);
                pbesToUpdate = new List<PricebookEntry>();
            }


            Decimal corporateCurrencyPrice = prod.Standard_Pricebook_Price__c;
            Decimal corporateCurrencyCost = corporateCurrencyPrice * costFactor;

            Decimal thisPrice = corporateCurrencyPrice;
            Decimal thisCost = corporateCurrencyCost;

            //costsToUpsert.add(new SBQQ__Cost__c(CurrencyIsoCode=currencyCode, SBQQ__Active__c=true, SBQQ__Product__c=prod.Id, SBQQ__UnitCost__c=thisCost, Product_Utility_Key__c = prod.Id + currencyCode));

            if (!prod.isClone()) {
                if (utilityKeyToCostMap.containsKey(prod.Id)) {
                    costsToUpdate.add(new SBQQ__Cost__c(Id = utilityKeyToCostMap.get(prod.Id).Id, SBQQ__UnitCost__c = thisPrice * costFactor, SBQQ__Active__c = true));
                } else {
                    costsToInsert.add(new SBQQ__Cost__c(SBQQ__Product__c = prod.Id, SBQQ__UnitCost__c = thisCost, SBQQ__Active__c = true));
                }
            }
            if (prod.isClone()) {

                // costsToInsert.add(new SBQQ__Cost__c(SBQQ__Product__c = prod.Id, SBQQ__UnitCost__c=thisCost, CurrencyIsoCode=currencyCode, SBQQ__Active__c=true));
                //costsToClone= [Select SBQQ__UnitCost__c from SBQQ__Cost__c where SBQQ__Product__c=:prod.getCloneSourceId()];
                /** costsToClone= [Select SBQQ__UnitCost__c, SBQQ__Product__c, SBQQ__Active__c from SBQQ__Cost__c where SBQQ__Product__c=:prod.getCloneSourceId()];
                for(integer i =0; i<costsToClone.size();i++){
                    SBQQ__Cost__c Cost = costsToClone.get(i).clone(false,true);
                    //SBQQ__Cost__c Cost= new SBQQ__Cost__c();
                    Cost.SBQQ__Product__c= prod.Id;

                    costsCloned.add(Cost);


                }**/


            }
            if (!prod.isClone()) {
                if (utilityKeyToPbeMap.containsKey(string.valueof(prod.Id) + String.Valueof(PB.Id))) {
                    pbesToUpdate.add(new PricebookEntry(Id = utilityKeyToPbeMap.get(string.valueof(prod.Id) + String.Valueof(PB.Id)).Id, Pricebook2Id = PB.Id, UnitPrice = thisPrice, IsActive = true));
                } else {
                    pbesToInsert.add(new PricebookEntry(Product2Id = prod.Id, Pricebook2Id = PB.Id, UnitPrice = thisPrice, IsActive = true));
                }
            }
        


        }
        Database.insert(costsCloned);
        Database.insert(costsToInsert);
        Database.update(costsToUpdate);
        Database.insert(pbesToInsert);
        Database.update(pbesToUpdate);
    }
    }
}
public with sharing class Catalog_Controller {

    // Primarily Catalog variables
    public Map<String, String> familyMap {get;set;}
    public Map<String, List<Product2>> productMap {get;set;}
    public Integer numberOfFamilies {get;set;}
    public List<Product2> productsInFamily {get;set;}
    public String hostURL {get;set;}
    public Catalog_Template__c myCatalogTemplate {get;set;}
    public String backgroundURL {get;set;}

    // Primarily Cart variables
    public Set<String> productSet {get;set;}
    public String productId {get;set;}
    public String accountId {get;set;}
    public String orderId {get;set;}
    public Integer productQuantity {get;set;}
    public Catalog_Order__c myOrder {get;set;}
    public List<Catalog_Line_item__c> myLineItems {get;set;}

    // Lookup Component variables
    public string debugString {get;set;}
    public String lookupValue {get;set;}
    public sObject myObject {get;set;}
    public String objectName {get;set;}
    public String objectField {get;set;}
    public String filter {get;set;}
    public List<Item> myValues {get;set;}

    // Custom Item class for use with Lookup Component 
    // contains query results (Name and ID)
    public class Item{
        public String value {get;set;}
        public String label {get;set;}

        public Item(String v, String l){
          value = v;
          label = l;
        }
    }

    public Catalog_Controller() {
        prepareBackground();
        prepareCatalog();
        prepareCart();
        prepareCatalogTemplate();
        debugString = 'My debug';
    }

    /* 
     *  prepareBackground()
     *  Additional constructor helper method grabbing the appropriate background image. 
     */
    public void prepareBackground() {
        String servlet = '/servlet/servlet.FileDownload?file=';
        String backgroundName = 'Catalog_BG';
        Document backgroundDoc = [SELECT Id FROM Document WHERE Name = :backgroundName];
        backgroundURL = servlet + backgroundDoc.Id;
    }

    /*
     *  prepareCatalog()
     *  This method contains all initialization for the catalog, and notably aids in 
     *  navigation with the FamilyMap (used in the category nav on the first page). 
     */
    public pageReference prepareCatalog() {
        if(!Product2.sObjectType.getDescribe().isAccessible()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        // Initialize maps, run queries
        productMap = new Map<String, List<Product2>>();
        familyMap = new Map<String, String>();
        numberOfFamilies = 0;

        // Prepare the picklist values from Family field on Product2
        Schema.DescribeFieldResult familyResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> familyPLE = familyResult.getPicklistValues();

        // For each Family picklist value, clean the value and continue
        for( Schema.PicklistEntry f : familyPLE ) {
            String familyLabel = f.getLabel().trim();
            String familyValue = f.getValue().trim();
            String familyNoWhtSpc = familyValue.replaceAll('\\s+','');
            // Now that we have a clean Family, get all Products with that Family
            // Then add it to the map for Family -> ProductList
            Integer countProductsInFamily = 0;
            try {
                countProductsInFamily = 0;
                countProductsInFamily = [SELECT count() FROM Product2 WHERE Family = :familyValue AND Mobile_Ready__c = true];
                if(countProductsInFamily > 0) {
                    productsInFamily = [SELECT Id,Name,Description,Family,ProductCode,Blurb__c,Default_Price__c,VF_Image__c,Inventory__c,Mobile_Ready__c FROM Product2 WHERE Mobile_Ready__c = true AND Family = :familyValue ORDER BY Name DESC NULLS FIRST];
                    FamilyMap.put(familyNoWhtSpc, familyLabel);
                    ProductMap.put(familyNoWhtSpc, productsInFamily);
                    numberOfFamilies += 1;
                }
            } catch (exception e) {System.debug(e.getMessage());}
        }

        //Prep the host URL for use in Catalog images
        hostURL  = 'https://' + ApexPages.currentPage().getHeaders().get('Host');
        return null;
    }

    /* 
     *  prepareCart()
     *  Additional constructor helper method for initializing Cart variables. 
     */
    public pageReference prepareCart() {
        if(!Catalog_Order__c.sObjectType.getDescribe().isCreateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        productSet = new Set<String>();
        myOrder = new Catalog_Order__c();
        myLineItems = new List<Catalog_Line_item__c>();

        // This query tries to eliminate the constant creation of more and more Orders
        // It grabs the last catalog modified by the current user with the status of Cart
        Catalog_Order__c[] orderQuery = [SELECT Items__c,Total_Cost__c,Account__c,Id,(SELECT Id,Product__c,Product_Short_Description__c,Product_Price__c,Product_Name__c,Quantity__c,VF_Image__c FROM Catalog_Line_Items__r) FROM Catalog_Order__c WHERE Status__c = 'Cart' AND CreatedById =:UserInfo.getUserId() ORDER BY LastModifiedDate DESC NULLS FIRST LIMIT 1];
        if( orderQuery.size() > 0 ) {
            myOrder = orderQuery[0];
            
            List<Catalog_Line_Item__c> cliList =  myOrder.getSObjects('Catalog_Line_Items__r'); //Get all Line Items for Order
            if (cliList == null || cliList.size() < 1) {
                // No Line Items in related list so do nothing
            } else {
                // Line Items returned, so add them to product set
                for(Catalog_Line_Item__c cli : cliList) {
                    productSet.add( cli.Product__c );
                }
            }
        }
        
        
        return null;
    }

    /* 
     *  prepareCatalogTemplate()
     *  Additional constructor helper method for initializing Catalog Template variables. 
     */
    public pageReference prepareCatalogTemplate() {
        if(!Catalog_Template__c.sObjectType.getDescribe().isCreateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        myCatalogTemplate = new Catalog_Template__c();

        // This query tries to eliminate the constant creation of more and more Templates
        // It grabs the Template with the name we set in the Brander Controller
        Catalog_Template__c[] templateQuery = [SELECT Category_Text_Color__c,Header_Left_Text_Color__c,Header_Right_Text_Color__c,Id,Name,Subtitle_Text_Color__c,Subtitle_Text_Size__c,Subtitle_Text__c,Title_Text_Color__c,Title_Text_Size__c,Title_Text__c FROM Catalog_Template__c WHERE Name = 'Catalog Template 1'];
        if( templateQuery.size() > 0 ) {
            myCatalogTemplate = templateQuery[0];
        }
        return null;
    }

    /* 
     *  addToCart()
     *  Handles the complexity of adding a product as a line item to the Order from Actionfunction
     */
    public pageReference addToCart() {
        if(!Catalog_Order__c.sObjectType.getDescribe().isUpdateable() || !Catalog_Line_Item__c.sObjectType.getDescribe().isCreateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        if( productId == null ) {} else {
        // First make sure that our Order is in the database
        upsert myOrder;
        orderId = myOrder.Id;

        // Check if the product is already in the Cart
        if( productSet.contains( productId ) ) { } else {
            // Here is where we add the ID to the set...
            productSet.add( productId );
            // ...and to the Order.
            Catalog_Line_Item__c li =  new Catalog_Line_item__c();
            li.Product__c = productId;
            li.Catalog_Order__c = myOrder.Id;
            li.Quantity__c = 1;
            insert li;
            // Added to Cart
        }}
        // Clear the parameter and reupsert
        productId = null;
        upsert myOrder;
        return null;
    }

    /* 
     *  deleteFromCart()
     *  Handles the complexity of deleting a product as a line item from the Order
     */
    public PageReference deleteFromCart() {
        if(!Catalog_Order__c.sObjectType.getDescribe().isUpdateable() || !Catalog_Line_Item__c.sObjectType.getDescribe().isDeletable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        if( productId == null ) {system.debug('Empty delete.'); return null;} 
        else {
            Catalog_Line_Item__c li = [SELECT Id FROM Catalog_Line_Item__c WHERE Id =: productId];
            try {
                // About to delete Line Item
                if(!Catalog_Order__c.sObjectType.getDescribe().isDeletable()){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
                    return null;
                }
                delete li;
            } catch (DmlException e) {System.debug(e.getMessage());}
    
            // Check if the product is already in the Cart
            if( productSet.contains( productId ) ) { 
                // Here is where we remove the ID from the set...
                productSet.remove( productId );
            }
        }
        // Clear the parameter and reupsert
        productId = null;
        upsert myOrder;

        return null;
    }
    
    /* 
     *  updateQuantity(String ID) 
     *  Updates the Quantity field of the Catalog Line Item with the given Id 
     */
    public PageReference updateQuantity() {
        if(!Catalog_Line_Item__c.sObjectType.getDescribe().isUpdateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        Catalog_Line_Item__c li = [SELECT Quantity__c FROM Catalog_Line_Item__c WHERE Id =: productId];
        li.Quantity__c = productQuantity;
        update li;
        update myOrder;
        // Stay on current page
        return null;
    }
    
    /* 
     *  updateAccount(String ID) 
     *  Updates the Account field of the Order with the given Id 
     */
    public PageReference updateAccount() {
        if(!Catalog_Order__c.sObjectType.getDescribe().isUpdateable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        myOrder.Account__c = accountId;
        update myOrder;
        // Stay on current page
        return null;
    }
    
    /* 
     *  getProduct(String ID) 
     *  queries and returns relevant product info from a string ID 
     */
    public Product2 getProduct(String stringID) {
        if(!Product2.sObjectType.getDescribe().isAccessible()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        Product2 product = [SELECT Id,Name,Description,Family,ProductCode,Blurb__c,Default_Price__c,VF_Image__c,Inventory__c,Mobile_Ready__c FROM Product2 WHERE Id =: stringID LIMIT 1];
        return product;
    }
    
    /* 
     *  clearOrder() 
     *  clears all line items on the order and navigates to the catalog page 
     */
    public PageReference clearOrder() {
        if(!Catalog_Line_Item__c.sObjectType.getDescribe().isDeletable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        // Remove all line items from the order
        List<Catalog_Line_Item__c> toDelete = [SELECT Id,Product__c,Product_Short_Description__c,Product_Price__c,Product_Name__c,Price__c,Quantity__c,Subtotal__c,VF_Image__c FROM Catalog_Line_Item__c WHERE Catalog_Order__c =: myOrder.Id];
        delete toDelete;

        // Stay on current page
        return null;
    }
    
    /* 
     *  completeOrder() 
     *  Completes the current order and prepares a new one for the user
     */
    public PageReference completeOrder() {
        if(!Catalog_Order__c.sObjectType.getDescribe().isCreateable() || !Catalog_Order__c.sObjectType.getDescribe().isDeletable()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        //Preparing to complete myOrder
        // Set status of current order
        myOrder.Status__c = 'Submitted';
        update myOrder;
        // myOrder was submitted
        
        // create new order and set it to myOrder
        // This allows us to continue operations when the user returns to the Catalog
        productSet = new Set<String>();
        myOrder = new Catalog_Order__c();
        myOrder.Status__c = 'Cart';
        // myOrder reinitiated and set to Cart
        myLineItems = new List<Catalog_Line_item__c>();

        // Stay on current page
        return null;
    }

    /* 
     *  toCart() 
     *  navigates to the cart page 
     */
    public PageReference toCart() {
        if(!Catalog_Order__c.sObjectType.getDescribe().isAccessible()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        try{
            myOrder = [SELECT Items__c,Lines__c,Total_Cost__c,Account__c,Id,(SELECT Id,Product__c,Product_Short_Description__c,Product_Price__c,Product_Name__c,Price__c,Quantity__c,Subtotal__c,VF_Image__c FROM Catalog_Line_Items__r) FROM Catalog_Order__c WHERE Id =: orderId LIMIT 1];
        } catch (exception e) {System.debug(e.getMessage());}

        PageReference next = new PageReference('/apex/catalog_cart');
        next.setRedirect(false);
        // Directing to Cart
        return next;
    }
    
    /*
     *  toCatalog() 
     *  navigates to the catalog page 
     */
    public PageReference toCatalog() {
        if(!Product2.sObjectType.getDescribe().isAccessible()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        PageReference next = new PageReference('/apex/catalog_products');
        next.setRedirect(false);
        // Directing to Catalog
        return next;
    }



    /***************************
     *  Lookup Component Methods
     ***************************/

    /*
     *  PopulateValues() 
     *  Creates the values for the lookup
     */
    public PageReference PopulateValues() {
        if(!Account.sObjectType.getDescribe().isAccessible()) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'Insufficient access'));
            return null;
        }
        Schema.DescribeSObjectResult objDescribe;
        
        myValues = new List<Item>();
        if (filter != null) filter = escapeReservedCharacters(filter);
        String protectFilter = '%' + filter + '%';
        String myQuery = 'SELECT Id, Name FROM Account WHERE Name LIKE ' + protectFilter;
        List<SObject> recList = [SELECT Id, Name FROM Account WHERE Name LIKE :protectFilter];
        for (SObject rec : recList) {
            myValues.add(new Item((String)rec.get('Id'), (String)rec.get('Name')));
        }
        return null;
    }

    /*
     *  escapeReservedCharacters(String) 
     *  Cleans up the dishonorable...
     */
    private String escapeReservedCharacters(String s) {
        String reservedCharacters = '—&|!{}[]()^~:\\\"\'+-';
        for (Integer i = 0; i < reservedCharacters.length(); i++)
        s = s.replace(reservedCharacters.substring(i,i+1), '\\' + reservedCharacters.substring(i,i+1));
        return s;
    }

    public void TestFunction(){
        System.assert(1 == 1,'WTF');
    }
}
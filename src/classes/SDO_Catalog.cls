public with sharing class SDO_Catalog {

    public List<ProductWrapper> pwList {get;set;}
    public blob b {Get;set;}

    //filter & search

    public List<String> Attribute1 {get;set;}
    public List<String> Attribute2 {get;set;}
    public List<String> Attribute3 {get;set;}
    public List<String> Attribute4 {get;set;}
    public List<String> Attribute5 {get;set;}

    public string Attribute1Name {get;set;}
    public string Attribute2Name {get;set;}
    public string Attribute3Name {get;set;}
    public string Attribute4Name {get;set;}
    public string Attribute5Name {get;set;}


    public string attributes {get;set;}
    public string searchTerm {get;set;}
    public string catalogInput {get;set;}
    public string searchOrder {get;set;}
    public Product2 testProduct {Get;set;}

    public String debugString {Get;set;}

    public String pricebookName {get;set;}
    public List<Pricebook2> pricebookList {get;set;}

    public Pricebook2 pb2 {get;set;}

    public SDO_Catalog(APexPages.StandardController std) {
        system.debug(std);
        Order o = [select id,pricebook2id from order where id=:std.getId()];
        system.debug(o);
        if(o.pricebook2id == null) {
                pb2 = [select id,name,isactive,Default_Order_Pricebook__c from pricebook2 where Default_Order_Pricebook__c = true and isactive = true];
                pricebookName = pb2.name;
            }else {
                pb2 = [select id,name,isactive from pricebook2 where id=:o.pricebook2id and isactive = true];
                system.debug(pb2);
                pricebookName = pb2.name;
            }
        
        init();
    }

    public SDO_Catalog() {
        init();
    }

    public void init() {
        pricebookList = [select id, name from pricebook2 where isactive = true];
        Attribute1 = new List<String>();
        Attribute2 = new List<String>();
        Attribute3 = new List<String>();
        Attribute4 = new List<String>();
        Attribute5 = new List<String>();

        testProduct = new PRoduct2();
        List<PricebookEntry> peList = [select product2Id,product2.Image__c,product2.Product_Catalog__c,product2.id,product2.ProductCode,product2.attribute_1__c,product2.attribute_2__c,product2.attribute_3__c,product2.attribute_4__c,product2.attribute_5__c,product2.Family, pricebook2id, name, unitprice,UseStandardPrice from PricebookEntry where pricebook2id =:pb2.id order by name asc];
        pwList = new List<ProductWrapper>();
        Set<Id> productIds = new Set<Id>();
        for (PricebookEntry pe : peList) {
            if(!productIds.contains(pe.product2Id)) {
                productIds.add(pe.product2Id);
                pwList.add(new ProductWrapper(pe));
            }
        }

        Schema.DescribeFieldResult attributeField1 = Schema.sObjectType.product2.fields.attribute_1__c;
        Attribute1Name = attributeField1.getLabel();

        Schema.DescribeFieldResult attributeField2 = Schema.sObjectType.product2.fields.attribute_2__c;
        Attribute2Name = attributeField2.getLabel();
   
        Schema.DescribeFieldResult attributeField3 = Schema.sObjectType.product2.fields.attribute_3__c;
        Attribute3Name = attributeField3.getLabel();
     
        Schema.DescribeFieldResult attributeField4 = Schema.sObjectType.product2.fields.attribute_4__c;
        Attribute4Name = attributeField4.getLabel();
    
        Schema.DescribeFieldResult attributeField5 = Schema.sObjectType.product2.fields.attribute_5__c;
        Attribute5Name = attributeField5.getLabel();
    }

    public String getAttributesFromArray(List<String> arr){
        String s = '(';
        for(String a : arr) {
            a = a.trim();
            if(a != '|' && a != ',' && a != null && a != ''){
                s+='\''+a+'\',';
            }
        }
        s = s.trim();
        //integer i = s.lastIndexOf(';');
        String s2 = s.Substring(0,s.length()-1);
        s2+=')';
        return s2;
    }

public PageReference search3() {
        if(searchTerm == null || searchTerm == '') {
            searchTerm = ApexPages.CurrentPage().getParameters().get('searchTerm');
        }
        if(catalogInput == null || catalogInput == '') {
            catalogInput = ApexPages.CurrentPage().getParameters().get('catalogInput');
        }
        if(attributes == null || attributes == '') {
            attributes = ApexPages.CurrentPage().getParameters().get('attributes');
        }
        if(searchOrder == null || searchOrder == '') {
            searchOrder = ApexPages.CurrentPage().getParameters().get('searchOrder');
        }
        //system.assert(false, 'DEBUG: attributes: ' + attributes);
        String attr1;
        String attr2;
        String attr3;
        String attr4;
        String attr5;
        system.debug(attributes);
        if(attributes != null && attributes != '') {
            List<String> attributeArray = attributes.split('--');
            system.debug('attributeArray:' + attributeArray);
            if(attributeArray.size() > 4) {
                integer i = 0;
                for(string aa : attributeArray) {
                    if(i == 0) {
                         attr1  = getAttributesFromArray(aa.split(','));
                    }
                    if(i == 1) {
                         attr2  = getAttributesFromArray(aa.split(','));
                    }
                    if(i == 2) {
                         attr3  = getAttributesFromArray(aa.split(','));
                    }
                    if(i == 3) {
                         attr4  = getAttributesFromArray(aa.split(','));
                    }
                    if(i == 4) {
                         attr5  = getAttributesFromArray(aa.split(','));
                    }
                    i++;
                }
                /*
                attr1  = getAttributesFromArray(attributeArray[0].split(','));
                attr2  = getAttributesFromArray(attributeArray[1].split(','));
                attr3  = getAttributesFromArray(attributeArray[2].split(','));
                attr4  = getAttributesFromArray(attributeArray[3].split(','));
                attr5  = getAttributesFromArray(attributeArray[4].split(','));  
                */    
            }
        }

        String query = 'select product2Id,product2.Image__c,product2.Product_Catalog__c,product2.Family,product2.id,product2.ProductCode,product2.attribute_1__c,product2.attribute_2__c,product2.attribute_3__c,product2.attribute_4__c,product2.attribute_5__c, pricebook2id, name, unitprice,UseStandardPrice';
        query +=' from PricebookEntry ';
        query +=' where (Pricebook2id = \''+pb2.id+'\'';
        //query +=' AND product2.Family = \'Product\' ';
        query +=' AND (name LIKE \'%' + searchTerm  + '%\'';
        query +=' OR product2.ProductCode LIKE \'%' + searchTerm  + '%\')';
        query +=' AND product2.Product_Catalog__c LIKE \'%' + catalogInput  + '%\')';
        
        boolean hasAttr = false;
        if(attr1 != ')' && attr1 != null){
            if(!hasAttr){
                query += ' AND (product2.attribute_1__c includes ' + attr1 + ' ';
            }else {
                query += ' OR product2.attribute_1__c includes ' + attr1 + ' ';
            } 
            hasAttr = true;
        } 
        if(attr2 != ')' && attr2 != null) {
            if(!hasAttr){
                query += ' AND (product2.attribute_2__c includes ' + attr2 + ' ';
            }else {
                query += ' OR product2.attribute_2__c includes ' + attr2 + ' ';
            } 
            hasAttr = true;
        } 
        if(attr3 != ')' && attr3 != null){
            if(!hasAttr){
                query += ' AND (product2.attribute_3__c includes ' + attr3 + ' ';
            }else {
                query += ' OR product2.attribute_3__c includes ' + attr3 + ' ';
            } 
            hasAttr = true;
        } 
        if(attr4 != ')' && attr4 != null){
            if(!hasAttr){
                query += ' AND (product2.attribute_4__c includes ' + attr4 + ' ';
            }else {
                query += ' AND product2.attribute_4__c includes ' + attr4 + ' ';
            } 
            hasAttr = true;
        } 
        if(attr5 != ')' && attr5 != null){
            if(!hasAttr){
                query += ' AND (product2.attribute_5__c includes ' + attr5 + ' ';
            }else {
                query += ' OR product2.attribute_5__c includes ' + attr5 + ' ';
            } 
            hasAttr = true;
        } 
        if(hasAttr) query+= ')';

        debugString = 'DEBUG : ' + attr1 + attr2 + attr3 + attr4 + attr5;
        
        //query
        query +=' order by name ' + searchOrder;
        system.debug(query);
        //system.assert(false, query);
        List<PricebookEntry> peList = database.query(query);
        pwList = new List<ProductWrapper>();
        Set<Id> productIds = new Set<Id>();
        for (PricebookEntry pe : peList) {
            if(!productIds.contains(pe.product2Id)) {
                productIds.add(pe.product2Id);
                pwList.add(new ProductWrapper(pe));
            }
        }
        return null;                                
    }





    public List<SelectOption> getAttributes1() {
        List<SelectOption> productAttributes = new List<SelectOption>();     
        Schema.DescribeFieldResult attributeField = Schema.sObjectType.product2.fields.attribute_1__c;
        Attribute1Name = attributeField.getLabel();
        Schema.PicklistEntry [] values = attributeField.getPickListValues();
            
        for(Schema.PicklistEntry val : values){
         productAttributes.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        return productAttributes;
    }
    public List<SelectOption> getAttributes2() {
        List<SelectOption> productAttributes = new List<SelectOption>();     
        Schema.DescribeFieldResult attributeField = Schema.sObjectType.product2.fields.attribute_2__c;
        Attribute2Name = attributeField.getLabel();
        Schema.PicklistEntry [] values = attributeField.getPickListValues();
            
        for(Schema.PicklistEntry val : values){
         productAttributes.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        return productAttributes;
    }
    public List<SelectOption> getAttributes3() {
        List<SelectOption> productAttributes = new List<SelectOption>();     
        Schema.DescribeFieldResult attributeField = Schema.sObjectType.product2.fields.attribute_3__c;
        Attribute3Name = attributeField.getLabel();
        Schema.PicklistEntry [] values = attributeField.getPickListValues();
            
        for(Schema.PicklistEntry val : values){
         productAttributes.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        return productAttributes;
    }
    public List<SelectOption> getAttributes4() {
        List<SelectOption> productAttributes = new List<SelectOption>();     
        Schema.DescribeFieldResult attributeField = Schema.sObjectType.product2.fields.attribute_4__c;
        Attribute4Name = attributeField.getLabel();
        Schema.PicklistEntry [] values = attributeField.getPickListValues();
            
        for(Schema.PicklistEntry val : values){
         productAttributes.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        return productAttributes;
    }
    public List<SelectOption> getAttributes5() {
        List<SelectOption> productAttributes = new List<SelectOption>();     
        Schema.DescribeFieldResult attributeField = Schema.sObjectType.product2.fields.attribute_5__c;
        Attribute5Name = attributeField.getLabel();
        Schema.PicklistEntry [] values = attributeField.getPickListValues();
            
        for(Schema.PicklistEntry val : values){
         productAttributes.add(new SelectOption(val.getValue(), val.getLabel()));
        }
        return productAttributes;
    }

    public class ProductWrapper {
        public PricebookEntry p {get;set;}
        public boolean selected {get;set;}
        public ProductWrapper(PricebookEntry pe) {
            p = pe;
        }
    }
}
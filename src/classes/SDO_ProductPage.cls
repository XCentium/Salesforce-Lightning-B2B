public with sharing class SDO_ProductPage {
	public List<Offer_sdo__c> oList {get;set;}
	public Product2 testProduct {Get;set;}

	public string attribute1Value {Get;set;}
	public string attribute2Value {Get;set;}
	public string attribute3Value {Get;set;}
	public string attribute4Value {Get;set;}
	public string attribute5Value {Get;set;}

	public PricebookEntry pbe {get;set;}

	public List<RecommendedProductWrapper> rpwList {Get;set;}


	public SDO_ProductPage(ApexPages.StandardController std) {
		testProduct = new Product2();
		pbe = [select id, product2Id from PricebookEntry where id=:std.getId()];
		oList = [SELECT ConnectionReceivedId,product__r.image__c,ConnectionSentId,CreatedById,CreatedDate,End_Date__c,Id,IsDeleted,
				LastModifiedById,LastModifiedDate,LastReferencedDate,LastViewedDate,Name,OwnerId,Price__c,Product_Image__c,Product__c,
				Recommended_Product_Image__c,Recommended_Product_Parent__c,Recommended_Product__c,Recommended_Product__r.name,Recommended_Product__r.image__c,
				RecordTypeId,Start_Date__c,SystemModstamp 
				FROM Offer_sdo__c where Recommended_Product_Parent__c = :pbe.product2id AND RecordTypeId = '012o0000000x8CjAAI'];
		rpwList = new List<RecommendedProductWrapper>();
		for(Offer_sdo__c o : oList) {
			rpwList.add(new RecommendedProductWrapper(o));
		}
	}

	public class RecommendedProductWrapper {
		public Offer_sdo__c o {get;set;}
		public PricebookEntry pbe {get;set;}
		public RecommendedProductWrapper(Offer_sdo__c offer) {
			o = offer;
			pbe = [select id,product2Id,product2.Image__c,product2.Product_Catalog__c,product2.id,product2.ProductCode,product2.attribute_1__c,product2.attribute_2__c,product2.attribute_3__c,product2.attribute_4__c,product2.attribute_5__c,product2.Family, pricebook2id, name, unitprice,UseStandardPrice from PricebookEntry where product2id=:o.Recommended_Product__c AND UseStandardPrice = true  limit 1];
		}
	}





	public List<SelectOption> getAttribute1Options() {
	  List<SelectOption> options = new List<SelectOption>();
	   Schema.DescribeFieldResult fieldResult =
	   Product2.Attribute_1__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
	   for( Schema.PicklistEntry f : ple) {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	public List<SelectOption> getAttribute2Options() {
	  List<SelectOption> options = new List<SelectOption>();
	   Schema.DescribeFieldResult fieldResult =
	   Product2.Attribute_2__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
	   for( Schema.PicklistEntry f : ple) {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	public List<SelectOption> getAttribute3Options() {
	  List<SelectOption> options = new List<SelectOption>();
	   Schema.DescribeFieldResult fieldResult =
	   Product2.Attribute_3__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
	   for( Schema.PicklistEntry f : ple) {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	public List<SelectOption> getAttribute4Options() {
	  List<SelectOption> options = new List<SelectOption>();
	   Schema.DescribeFieldResult fieldResult =
	   Product2.Attribute_4__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
	   for( Schema.PicklistEntry f : ple) {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
	public List<SelectOption> getAttribute5Options() {
	  List<SelectOption> options = new List<SelectOption>();
	   Schema.DescribeFieldResult fieldResult =
	   Product2.Attribute_5__c.getDescribe();
	   List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();  
	   for( Schema.PicklistEntry f : ple) {
	      options.add(new SelectOption(f.getLabel(), f.getValue()));
	   }       
	   return options;
	}
}
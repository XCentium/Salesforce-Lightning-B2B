global class LightningCatalogController {
    
    static final String APP_NAME = 'Anything Catalog';
    static final String APP_VERSION = 'Feb 1st, 2019';

    @AuraEnabled
    public static FieldsDescResult getFieldsDesc(String objName, String fields){
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
    	if (objType==null) throw new AuraHandledException(objName+' is an invalid Object Name. Please verify');
        map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        list <string> fieldsArray = fields.split(',');
        Set<String> fieldsSet = new Set<String>(fieldsArray);
        list<FieldDesc> FDesc= new list<FieldDesc>();
        for (string field:fieldsSet){
             Schema.SObjectField F = fieldMap.get(field.trim());
             if (F!=null) {
                Schema.DescribeFieldResult FD = F.getDescribe();
                String fieldType=String.ValueOf(FD.getType());
                FDesc.add(new FieldDesc(FD.getName(),FD.getLabel(),fieldType));  
              }    
        }
        FieldsDescResult toReturn = new FieldsDescResult();
        toReturn.fields=FDesc;
        return toReturn;
    }    
    
    
    @AuraEnabled
    public static list<PicklistOption> getPicklistOptions(String objName, String fieldName){
     Schema.SObjectType objType = Schema.getGlobalDescribe().get(objName);
     if (objType==null) throw new AuraHandledException(objName+' is an invalid Object Name. Please verify');
     map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
     Schema.SObjectField F = fieldMap.get(fieldName.trim());
     if (F==null) throw new AuraHandledException(fieldName.trim()+' is an invalid Field Name. Please verify');   
     Schema.DescribeFieldResult FD = F.getDescribe();
     if (String.ValueOf(FD.getType())!='PICKLIST') throw new AuraHandledException('Expected Picklist. Received '+String.ValueOf(FD.getType()));
     list<Schema.PicklistEntry> entries = FD.getPickListValues();
     list<PicklistOption> PLO =  new list<PicklistOption>()  ;   
     For (Schema.PicklistEntry entry : entries){
        if (entry.isActive()) 
          PLO.add(new PicklistOption(entry.getLabel(),entry.getValue()));     
      }
      return PLO;
    }
        
    @AuraEnabled
    public static CatalogPage getProducts(String fields,string sObjectName, string rootWhereClause, 
                                          String orderByField,String orderByDir,
                                          integer queryOffset, integer queryLimit){
                                     
    //Sanitize Aura Integer parameters to avoid Salesforce internal error
    //Bug fix suggested here : https://developer.salesforce.com/forums/?id=906F00000005FxqIAE 
	 queryLimit = Integer.valueOf(queryLimit); 
     queryOffset = Integer.valueOf(queryOffset);
                                                      
	//Verify objectname validity
        Schema.SObjectType objType = Schema.getGlobalDescribe().get(sObjectName);
	    if (objType==null) throw new AuraHandledException(sObjectName+' is an invalid Object Name. Please verify');
   		
   //Sanitize fields by removing unexisting fields and duplicates	
        map<String, Schema.SObjectField> fieldMap = objType.getDescribe().fields.getMap();
        String[] fieldsArray=fields.split(',');
        Set<String> sanitizedFields = new Set<String>();
        for (String fieldName:fieldsArray) {
            Schema.SObjectField mySObjectField = fieldMap.get(fieldName.trim());
            if (mySObjectField!=null) sanitizedFields.add(fieldName.trim());
        }
        String sanitizedFieldsConcat='';
        for (String sanitizedField: sanitizedFields) {
           sanitizedFieldsConcat+=sanitizedField+','; 
        }
        sanitizedFieldsConcat=sanitizedFieldsConcat.removeEnd(',');
        
     //If we are working on Product2, let's manage an exception to get unit prices
        if (sObjectName.toLowerCase()=='product2'){
        Pricebook2 standardPB = [select id from Pricebook2 where isStandard=true limit 1];    
        sanitizedFieldsConcat+=',(Select UnitPrice, Pricebook2Id From PricebookEntries where isActive=true AND Pricebook2Id  = \''+standardPB.id+'\')';  
        }
            
     //create sanitized query   
        String query='Select '+sanitizedFieldsConcat+' from '+sObjectName;
        String queryCount='Select count() from '+sObjectName;                                              
        if ((rootWhereClause!=null) && (rootWhereClause.length()>4)){
           query+=' where '+rootWhereClause;
           queryCount+=' where '+rootWhereClause; 
            
         }
        
       	system.debug(queryCount);                                              
        Integer totalRecordsCount= database.countQuery(queryCount);                                         
     
      
       //If we are working on product2 and user is asking to sort by unitprice, soql sorting is not possible.
       //Reason we'll use a standard way and a custom way specially when we need to sort by UnitPrice 
       list<CatalogRecord> records = new list<CatalogRecord>();
       if (!((sObjectName.toLowerCase()=='product2') && (orderByField=='UnitPrice')))
           records = getRecords(sObjectName,query,queryOffset,queryLimit,orderByField,orderByDir);  
       else                                                    
	       records = getProductsOrderedByUnitPrice(query,queryOffset,queryLimit,orderByDir); 
      
                                              
        Pagination pagination = new Pagination(totalRecordsCount,queryOffset,queryLimit,records.size());                                              
        CatalogPage page = new CatalogPage(records,pagination);
                                                      
        return page;
    }
    
    @AuraEnabled
    public static PriceBounds getPriceBounds(string pricebookId,boolean activeOnly){
     Decimal min=0; Decimal max=0;   
     String query='Select UnitPrice, Pricebook2Id From PricebookEntry ';
     integer clauseCount=0;
     if (activeOnly) {
     query+=(clauseCount==0)?' where ':' and';
     query+=' isActive=true ';    
     clauseCount++;
     }
     if (pricebookId!=null && pricebookId.length()>14) {
     query+=(clauseCount==0)?' where ':' and';
     query+=' Pricebook2Id = \''+pricebookId+'\'';    
     clauseCount++;
     }   
     String queryMin=query+' ORDER BY UnitPrice ASC LIMIT 1';
     String queryMax=query+' ORDER BY UnitPrice DESC LIMIT 1';
     sObject minPBE = database.query(queryMin);
     sObject maxPBE = database.query(queryMax);
     if (minPBE != null) min = (Decimal) minPBE.get('UnitPrice');
	 if (maxPBE != null) max = (Decimal) maxPBE.get('UnitPrice');        
     return new PriceBounds(min,max);    
    }
    
   	public static list<CatalogRecord> getRecords(string objectName,string query,integer queryOffset, integer queryLimit,String orderByField, String orderByDir){
        list<CatalogRecord> records = new list<CatalogRecord>();  
        //add orderby clause    
        if (orderByField.length()+orderByDir.length()>5)
            query += ' ORDER BY '+orderByField+' '+orderByDir;                                              
        // add limits and offset
        query +=' LIMIT '+String.valueOf(queryLimit)+' OFFSET '+String.valueOf(queryOffset);                                              
        system.debug(query);                                            
        list<sObject> queryResults = Database.query(query);
        
        //If working on product object, we extract the UnitPrice from pricebook entry
        //And we combine it with the record. If price filter ligthning component is enabled, we
        //remove from the returned records all records without price.                                                       
        
        for (sObject result:queryResults){
            double price = null;
            if (objectName.toLowerCase()=='product2' && result.getSObjects('PricebookEntries')!=null  && result.getSObjects('PricebookEntries').size() > 0)
                price = (double) result.getSObjects('PricebookEntries')[0].get('UnitPrice');
            records.add(new CatalogRecord(result,price));
        }     
        
    return records;
    }    
    
    public static list<CatalogRecord> getProductsOrderedByUnitPrice(string query,integer queryOffset, integer queryLimit,String orderByDir){
        //we cannot order products by price because SOQL is not capable of ordering records (here products) by
        // a field located in a child record (pricebookentries). 
        // As a consequence, we need to use an alternate slower method.
        // We get all records and then we filter and add pagination in apex
        
        list<CatalogRecord> allRecords = new list<CatalogRecord>();        
        for (sObject result : Database.query(query)) {
            double price = null;
            if (result.getSObjects('PricebookEntries')!=null  && result.getSObjects('PricebookEntries').size() > 0)
	 			price = (double) result.getSObjects('PricebookEntries')[0].get('UnitPrice');
           	allRecords.add(new CatalogRecord(result,price));
		}
        
       allRecords.sort();
       
      if (orderByDir=='DESC') {
          list<CatalogRecord> allRecordsReversed = new list<CatalogRecord>();
          for (Integer n = allRecords.size()-1; n>=0 ; n--) {
                 allRecordsReversed.add(allRecords[n]);
           }
          allRecords=allRecordsReversed;
      }
      
      integer max =  ((queryOffset+queryLimit)>=allRecords.size()) ? allRecords.size() : queryOffset+queryLimit; 
      list<CatalogRecord> recordsToKeep = new list<CatalogRecord>();
      for (Integer i = queryOffset; i < max; i++) {
   			 recordsToKeep.add(allRecords[i]);
	  }
        
      return recordsToKeep;
    }
    
    
    @AuraEnabled
    public static OrgInfo fetchOrgInfo(){
        string url = URL.getSalesforceBaseUrl().toExternalForm();
        string namespace  = getNamespacePrefix(); //get namespace in which Mass Edit Related Lists is running.
        OrgInfo org = new OrgInfo(url,namespace,getStatsURL(namespace),APP_VERSION,getPackageVersion(namespace));
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
        String[] classNameParts = String.valueOf(LightningCatalogController.class).split('\\.', 2);
        
        if(classNameParts.size() > 1) {
            Type classType = Type.forName(classNameParts[0], classNameParts[1]);
            if(classType == LightningCatalogController.class) {
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
    
    @AuraEnabled    
    public static string getStatsURL (string namespace) {
        String url='https://sdo-demo-main-15259e2fa59.secure.force.com/services/apexrest/Stats_Rest?';
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
      public string packageVersion;  
      public OrgInfo(string baseURL,string namespace,string statsUrl,string appVersion,string packageVersion){
        this.baseURL=baseURL; this.namespace=namespace; this.statsUrl=statsUrl;
        this.packageVersion=packageVersion;this.appVersion=appVersion;
      }  
            
	}

    
    
    
   public class CatalogPage{
       @AuraEnabled 
       public list<CatalogRecord> records;
       @AuraEnabled 
       public Pagination pagination;
       CatalogPage(list<CatalogRecord> records, Pagination pagination){
           this.pagination=pagination;
           this.records=records;
       }
  	   }	
    
    
   public class Pagination{ 
       @AuraEnabled 
       public integer totalRecordsCount; 
       @AuraEnabled 
       public integer pageRecordsCount;
       @AuraEnabled 
       public integer pageNumber;
       @AuraEnabled 
       public integer pagesCount;
       @AuraEnabled 
       public boolean isNext;
       @AuraEnabled 
       public boolean isPrev;
       @AuraEnabled 
       public integer nextOffset;
       @AuraEnabled 
       public integer prevOffset;
       @AuraEnabled 
       public integer startRecIndex;
       @AuraEnabled 
       public integer endRecIndex;
       public Pagination (integer totalRecordsCount, integer queryOffset, integer queryLimit,
                           integer pageRecordsCount){
       	this.pageRecordsCount = pageRecordsCount;
        this.totalRecordsCount = totalRecordsCount;   
        this.pagesCount = Math.mod(totalRecordsCount,queryLimit) == 0 ?  totalRecordsCount/queryLimit : totalRecordsCount/queryLimit + 1; 
        this.pageNumber = Math.mod(queryOffset,queryLimit) == 0 ? queryOffset/queryLimit+1 : queryOffset/queryLimit + 2 ;   
        this.isNext = ((queryOffset+pageRecordsCount) < totalRecordsCount); 
        this.isPrev =  ((queryOffset - queryLimit) >= 0 ); 
        this.nextOffset = this.isNext ? (queryOffset + pageRecordsCount) : null;
        this.prevOffset = this.isPrev ? (queryOffset - queryLimit) : 0;
        this.startRecIndex=(pageRecordsCount>0)?queryOffset+1:null;
        this.endRecIndex=(pageRecordsCount>0)?queryOffset+pageRecordsCount:null;                       
       }
       
    }
    
    
    public class CatalogRecord implements Comparable{
       @AuraEnabled 
       public sObject record;
       @AuraEnabled         
       public double UnitPrice; 
       CatalogRecord(sObject record, double UnitPrice){
       this.record=record;this.UnitPrice=UnitPrice;   
       }
       // Implement the compareTo() method to make sure this class is sortable
       public Integer compareTo(Object compareTo) {
            CatalogRecord compareToCR = (CatalogRecord)compareTo;
            if (UnitPrice == null) return -1;
            if ((UnitPrice != null) && (compareToCR.UnitPrice==null)) return 1;
            if (UnitPrice == compareToCR.UnitPrice) return 0;
            if (UnitPrice > compareToCR.UnitPrice) return 1;
            return -1;        
        } 
        
    }
    
    
    public class PicklistOption{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        PicklistOption(string label, string value){
        this.label=label;
        this.value=value;    
        }
    }
    
    public class PriceBounds{
        @AuraEnabled
        public Decimal min;
        @AuraEnabled
        public Decimal max;
        @AuraEnabled
        public Integer minAsInt;
        @AuraEnabled
        public Integer maxAsInt;
        PriceBounds(Decimal min, Decimal max){
        this.min=min;this.max=max;    
        this.minAsInt=Integer.valueOf(min.round(System.RoundingMode.DOWN));
        this.maxAsInt=Integer.valueOf(max.round(System.RoundingMode.UP));    
        }
    }
    
    public class FieldsDescResult{
     	@AuraEnabled
        public string defaultCurrencyCode;
        @AuraEnabled
        public list<FieldDesc> fields;
        @AuraEnabled 
        public Boolean isCommunity;
        @AuraEnabled 
        public String communityPrefix;
        FieldsDescResult(){
        this.defaultCurrencyCode=UserInfo.getDefaultCurrency();
        isCommunity=(Site.getSiteId()!=null);
        communityPrefix=Site.getPathPrefix().removeEnd('/s');
        }    
    }
    
    public class FieldDesc{
      @AuraEnabled
      public string label;
      @AuraEnabled
      public string fieldType;
      @AuraEnabled
      public string fieldName;
      @AuraEnabled
      public TypeAttributes typeAttributes;  
      FieldDesc(string fieldName, string label, string fieldType){
      this.label=label;this.fieldName=fieldName;
      this.fieldType=fieldType.toLowerCase();
      if (this.fieldType=='string') this.fieldType='text';    
      this.typeAttributes=new TypeAttributes(this.fieldType);    
      }  
        
    }
    
    public class TypeAttributes{
     @AuraEnabled
     public string currencyCode;
     TypeAttributes (string fieldType){
         	if (fieldType.toLowerCase()=='currency')
            this.currencyCode=UserInfo.getDefaultCurrency();
        }           
    }
    
}
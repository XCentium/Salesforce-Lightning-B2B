/**

 */

 /**
 * Apex Controller for looking up an SObject via SOSL
 */
public with sharing class PricerLookupFieldController
{

    /**
     * Aura enabled method to get the name of the initial record to load
     */

    @AuraEnabled
    public static String getRecordName (Id theRecordId, String sObjectAPIName){
      String myQuery = 'SELECT Id, Name FROM '+sObjectAPIName+' WHERE Id = \'' + theRecordID+'\'';
      List<sObject> results = Database.query(myQuery);
        if (results.size()>0) {
        return String.valueOf(results[0].get('Name'));
        } else {
            return 'Invalid record id';
        }
    }

    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, String pricebookId)
    {
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        String sanitizedPricebookId = String.escapeSingleQuotes(pricebookId);

		List<Result> results = new List<Result>();

        // Build our SOSL query
        if (sanitizedSObjectAPIName == 'Product2' && sanitizedPricebookId !=null && sanitizedPricebookId.length()>12) {
            string sss = '%'+sanitizedSearchString+'%';
            PricebookEntry[] pbeList = [select id,name,productcode,product2Id,product2.name,product2.productcode from Pricebookentry
                                    where isActive=true and pricebook2Id = :sanitizedPricebookId
                                    and (product2.name like :sss or product2.productcode like :sss) 
                                    order by product2.productcode ASC];
            for (PricebookEntry pbe : pbeList) {
               results.add(new Result(pbe.product2.productcode+' - '+pbe.product2.name, pbe.product2Id)); 
            }
        } else if (sanitizedSObjectAPIName == 'Product2') { 
            String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name,ProductCode) Limit 50';
            List<List<SObject>> searchList = search.query(searchQuery);  // Execute the Query
            for (SObject so : searchList[0]) // Create a list of matches to return
            {
              results.add(new Result((String)so.get('ProductCode')+' - '+(String)so.get('Name'), so.Id));
            }
		} else if (sanitizedSObjectAPIName != 'Product2') {
            String searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name) Limit 50';
            List<List<SObject>> searchList = search.query(searchQuery);  // Execute the Query
            for (SObject so : searchList[0]) // Create a list of matches to return
            {
              results.add(new Result((String)so.get('Name'), so.Id));
            }  
        }    
        return results;
            
    }

    /**
     * Inner class to wrap up an SObject Label and its Id
     */
	public class Result
    {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}

        public Result(String sObjectLabel, Id sObjectId)
        {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}
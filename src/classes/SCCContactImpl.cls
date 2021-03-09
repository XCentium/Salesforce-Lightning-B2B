/**
* Impl class of contact that implements interface
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2018-01-15
*/
public class SCCContactImpl implements SCCSynchronisedInterface {

    // related contact record
    public static Contact contactRecord;

    // customer number for commerce cloud
    public static String customerNo                     {get; set;}

    // customer number for commerce cloud
    public static String customerId                     {get; set;}

    // customer original site for commerce cloud
    public static String siteId                         {get; set;}

    // customer list for commerce cloud
    public static String customerListId                 {get; set;}

    // json map after deserialization
    public static Map<String, Object> jsonMap           {get; set;}

    /**
    * This method used for implementing related operations and update object status as Synchronised for contact records
    * @param contactObj: SObject
    * @return None.
    */
    public void continueWithObject(SObject contactObj) {

        syncContact(contactObj.Id);
    }

    public static Boolean syncContact(String contactId){

        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Initialize the Commerce Cloud Connect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        try {
            Map<String, SObject> contactFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Contact', logger);
            contactRecord = [SELECT Id, FirstName, LastName, Email, SFCC_Customer_Id__c, SFCC_Customer_Number__c, SFCC_Site_ID__c, SFCC_CustomerList_ID__c FROM Contact WHERE Id =: contactId];

            // Seed the local variables
            customerNo = contactRecord.SFCC_Customer_Number__c;
            customerId = contactRecord.SFCC_Customer_Id__c;
            siteId = contactRecord.SFCC_Site_ID__c;
            customerListId = contactRecord.SFCC_CustomerList_ID__c;

            // Seed the siteId and customerListId
            ccConnect.setSiteId(siteId);
            ccConnect.setCustomerListId(customerListId);

            //List<SCCCustomerWrapper> returnList = new List<SCCCustomerWrapper>();
            String resBody = ccConnect.getCustomerDetails(customerNo, ccConnect.connectToCommerceCloud());
            String addressBody = ccConnect.getAddressDetails(customerNo, ccConnect.connectToCommerceCloud());

            logger.debug('SCCContactImpl.syncContact','resBody: ' + resBody + ' addressBody: '+addressBody);
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
            Map<String, Object> addressJsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(addressBody);
            Contact updatedContact = (Contact)SCCUtilityClass.initializeObject(jsonMap, 'Contact', contactFieldMappings, logger);
            updatedContact.Contact_Status__c = 'Synchronised';
            updatedContact.From_SFCC__c = true;
            updatedContact.Id = contactRecord.Id;
            Database.update(updatedContact, true);
            if(addressJsonMap.containsKey('data') &&
               !((List<Object>)addressJsonMap.get('data')).isEmpty()){
                upsertAddressBook(updatedContact.Id, (List<Object>)addressJsonMap.get('data'));
            }
            return true;
        } catch(Exception e) {
            logger.error('SCCContactRefreshComponentController.syncContact', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return false;
        }finally{
            logger.flush();
        }
    }

    public static void upsertAddressBook(Id recordId, List<Object> addressJsonMap) {
        SCCFileLogger logger = SCCFileLogger.getInstance();
		try {
			logger.debug('SCCAccountHelper.upsertAddressBook',' recordId: ' + recordId + ' addressJsonMap: ' + addressJsonMap);
			Map<String, SObject> addressFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Address', logger);
            List<Address__c> contactAddressList = new List<Address__c>();
			for(Object obj : addressJsonMap) {
				Map<String, Object> tempMap = (Map<String, Object>)obj;
				Address__c record = (Address__c)SCCUtilityClass.initializeObject(tempMap, 'Address__c', addressFieldMappings, logger);
				Address__c address = SCCUtilityClass.getContactAddress(String.valueOf(tempMap.get('address_id')), recordId, null);
                if(address != null && address.Id != null){
                    record.Id = address.Id;
                }
                record.Contact__c = recordId;
				record.from_SFCC__c = true;
				contactAddressList.add(record);
			}
			Database.upsert(contactAddressList);
        } catch(Exception e) {
            logger.error('SCCAccountHelper.upsertAddressBook', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
        } finally{
            logger.flush();
        }

    }

}
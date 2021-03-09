/**
* This is a helper class to support the Account specific Synch operations with SFCC.
* @author  Neeraj Yadav
* @version 1.0
* @since   2018-01-15
*/

public class SCCOrderHelper {

    /**
    * This method used for implementing related operations and update object status as Synchronised for order records
    * @param orderObj: SObject
    * @return None.
    */
    public Boolean continueWithObject(Id orderRecordID) {


        // Initialize an instance of the current logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        //Get the order object from record ID
        Order record = getOrderObjectFromID(orderRecordID);

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        try {

            // Scope the Commerce Cloud interactions by the order's site
            ccConnect.setSiteId(record.SFCC_Site_ID__c);
            ccConnect.setCustomerListId(record.SFCC_CustomerList_ID__c);

            // Retrieve the order details from Commerce Cloud
            String body = ccConnect.getOrderDetails(record.SFCC_Order_Number__c, ccConnect.connectToCommerceCloud());
            logger.debug('SCCOrderHelper.continueWithObject','response body: ' + body);
            Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);

            // Manually seed the status fed by Commerce Cloud
            record.Status = (String)jsonMap.get('status');

            // Does the order contain customer details?
            if (jsonMap.containsKey('customer_info')) {

                // Determine if Accounts or Contacts should be processed
                if (SCCUtilityClass.isPersonAccountEnabled()) {

                    // Process the account / order association
                    SCCOrderHelper.syncAccountOrder(record, jsonMap, logger);

                }

                // Comment these out if you dont want to sync order items.
                SCCOrderHelper.upsertProductShipping(record, jsonMap, logger);
                SCCOrderHelper.upsertPaymentInformation(record, jsonMap, logger);
            } else {

                // Audit that an error was caught or experienced when processing the order response
                logger.error('SCCOrderHelper.continueWithObject','Invaid Order JSON response. customer_info missing');

            }
            return true;
        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCOrderHelper.continueWithObject', 'Exception message : ' + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return false;
        } finally {

            logger.flush();

        }

    }

   /**
    * This method is synchronise Account orders
    * @param record: Order
    * @param jsonMap: Map<String, Object>
    * @param logger: SCCFileLogger
    * @return None.
    */
    public static void syncAccountOrder(Order record, Map<String, Object> jsonMap, SCCFileLogger logger){



        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize the logger
        ccConnect.logger = logger;

        // Scope all SCCCommerceCloudConnect interactions by site and customerList;
        ccConnect.setSiteId(record.SFCC_Site_ID__c);
        ccConnect.setCustomerListId(record.SFCC_CustomerList_ID__c);

        // Retrieve the order field mappings that will drive synchronization
        Map<String, SObject> orderFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Order', logger);

        // Confirm that this order is associated to an account
        if (!String.isEmpty(record.AccountId) && SCCUtilityClass.isPersonAccountExist(record.AccountId)) {

            // Retrieve an instance of the personAccount associated to the current order
            Account personAcc = [SELECT Id, PersonContactId FROM Account WHERE IsPersonAccount=TRUE AND Id =: record.AccountId];

            // Initialize an order object containing the Commerce order details driven by field mappings
            SObject obj = SCCUtilityClass.initializeObject(jsonMap, 'Order', orderFieldMappings, logger);

            // Update the remaining manual properties on the order
            obj.put('Id', record.Id);
            obj.put('Order_SCCSync_Status__c', 'Synchronised');
            obj.put('AccountId', personAcc.Id);
            obj.put('Order_Contact__c', personAcc.PersonContactId);
            obj.put('SFCC_OrderSourceType__c', getOrderSourceType(jsonMap));

            // Update the order details
            Database.update(obj, true);

        } else {

            // If this order is not associated to a personAccount, then let's find a relatedAccount by email address
            Map<String, Object> customerInfoMap = (Map<String, Object>)jsonMap.get('customer_info');

            // Find a personAccount scoped by email and customerList
            List<Account> accountList = getPersonAccountByEmail((String)customerInfoMap.get('email'), record.SFCC_CustomerList_ID__c);

            // Was a valid account-list provided?
            if (!accountList.isEmpty()) {

                // Initialize an order object containing the Commerce order details driven by field mappings
                SObject obj = SCCUtilityClass.initializeObject(jsonMap, 'Order', orderFieldMappings,logger);

                // Map the required associative fields; associate the found account to this order
                obj.put('Id', record.Id);
                obj.put('Order_SCCSync_Status__c', 'Synchronised');
                obj.put('AccountId', accountList[0].Id);
                obj.put('Order_Contact__c', accountList[0].PersonContactId);
                obj.put('SFCC_OrderSourceType__c', getOrderSourceType(jsonMap));

                // Update the order details
                Database.update(obj, true);

            } else {

                // Create a collection of the accountFieldMappings used to synchronize customer / account details
                Map<String, SObject> accountFieldMappings = SCCUtilityClass.getAllCustomSettingValues('Account', logger);

                // Search for customer details in Commerce Cloud by email-address
                String resBody = ccConnect.searchCustomerByEmail((String)customerInfoMap.get('email'), ccConnect.connectToCommerceCloud2ProfileOperations());
                logger.debug('SCCOrderHelper.syncAccountOrder','searchCustomerByEmail resBody: '+ resBody);

                // Parse the search results into JSON map for processing
                Map<String, Object> resJsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);

                // Did the search yield any results?
                if (resJsonMap.containsKey('hits')) {

                    // If so, pull the collection of hits from the searchResults
                    List<Object> hitList = (List<Object>)resJsonMap.get('hits');

                    // Create a reference to the first hit / search-result found
                    Map<String, Object> hitMap = (Map<String, Object>)hitList[0];
                    Map<String, Object> dataMap = (Map<String, Object>)hitMap.get('data');

                    // Retrieve the details on this customer via their customer-number
                    resBody = ccConnect.getCustomerDetails((String)dataMap.get('customer_no'), ccConnect.connectToCommerceCloud2ProfileOperations());

                    // Deserialize the customer details -- and decorate the personAccount being created with these details
                    Map<String, Object> customerMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);
                    Account accountRecord = (Account)SCCUtilityClass.initializeObject(customerMap, 'Account', accountFieldMappings, logger);
                    accountRecord = SCCUtilityClass.additionalFieldsforAccount(accountRecord, customerMap);
                    RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');

                    // Attach the site and customerList to the personAccount being created
                    accountRecord.SFCC_CustomerList_ID__pc = record.SFCC_CustomerList_ID__c;
                    accountRecord.SFCC_Site_ID__pc = record.SFCC_Site_ID__c;
                    accountRecord.RecordTypeId = recordType.Id;
                    accountRecord.From_SFCC__pc = true;

                    // Create the personAccount
                    Database.insert(accountRecord, true);

                    // Attach the personAccount to the order
                    record.AccountId = accountRecord.Id;
                    record.Order_Contact__c = accountRecord.PersonContactId;
                    record.Order_SCCSync_Status__c = 'Synchronised';
                    record.SFCC_OrderSourceType__c = getOrderSourceType(jsonMap);

                    // Update the order record
                    Database.update(record, true);
                    logger.debug('SCCOrderHelper.syncAccountOrder','accountRecord.Id: '+accountRecord.Id+' accountRecord.SFCC_Customer_Number__pc: '+accountRecord.SFCC_Customer_Number__pc);

                    // Update the Commerce Cloud with the account and personContact identifiers
                    SCCPostCustomerUpdatesQueueable customerUpdateQueueable = new SCCPostCustomerUpdatesQueueable(accountRecord.Id, accountRecord.PersonContactId, accountRecord.SFCC_CustomerList_ID__pc, accountRecord.SFCC_Site_ID__pc, accountRecord.SFCC_Customer_Number__pc);
                    Id jobID = System.enqueueJob(customerUpdateQueueable);
                    logger.debug('SCCOrderHelper.syncAccountOrder, calling SCCPostCustomerUpdatesQueueable',' jobID: ' + jobID);

                } else {

                    // If no account was found, then build out a customer profile off the order details provided
                    Account accountRecord = (Account)SCCUtilityClass.initializeObject(customerInfoMap, 'Account', accountFieldMappings, logger);
                    accountRecord = SCCUtilityClass.additionalFieldsforAccount(accountRecord, customerInfoMap);
                    RecordType recordType = SCCUtilityClass.getPersonAccountRecordType('Person Account');

                    // Attach the site and customerList to the personAccount being created
                    accountRecord.SFCC_CustomerList_ID__pc = record.SFCC_CustomerList_ID__c;
                    accountRecord.SFCC_Site_ID__pc = record.SFCC_Site_ID__c;
                    accountRecord.RecordTypeId = recordType.Id;
                    accountRecord.From_SFCC__pc = true;

                    // Setting null as every guest customer id is same.
                    accountRecord.SFCC_Customer_Id__pc = null;
                    Database.insert(accountRecord, true);

                    // Update the order with the account properties
                    record.AccountId = accountRecord.Id;
                    record.Order_Contact__c = accountRecord.PersonContactId;
                    record.Order_SCCSync_Status__c = 'Synchronised';
                    record.SFCC_OrderSourceType__c = getOrderSourceType(jsonMap);

                    // Persist the order updates
                    Database.update(record, true);

                }

            }

        }

    }


    /**
    * This method used for separate shipping and product details to upsert them under the related order record
    * @param record: Order
    * @param jsonMap, Map<String, Object>
    * @return None.
    */
    public static void upsertProductShipping(Order record, Map<String, Object> jsonMap, SCCFileLogger logger) {

        logger.debug('SCCOrderHelper.upsertProductShipping','record: ' + record);
        List<Order_Line_Item__c> orderLineItemList = new List<Order_Line_Item__c>();
        List<Shipment__c> shipmentList = new List<Shipment__c>();

        if (jsonMap.containsKey('product_items')) {

            orderLineItemList.addAll(SCCOrderHelper.determineProducts(record.Id, record.Order_Contact__c, jsonMap, logger));
        }

        if (jsonMap.containsKey('shipments')) {
            shipmentList.addAll(SCCOrderHelper.determineShippings(record.Id, record.Order_Contact__c, jsonMap, logger));
        }

        if (!orderLineItemList.isEmpty()) {
            System.debug('orderLineItemList:' + orderLineItemList);
            Database.upsert(orderLineItemList, true);
        }

        if (!shipmentList.isEmpty()) {
            System.debug('shipmentList:' + shipmentList);
            Database.upsert(shipmentList, true);
        }

    }

    /**
    * This method used for payment details to upsert them under the related order record
    * @param record: Order
    * @param jsonMap, Map<String, Object>
    * @return None.
    */
    public static void upsertPaymentInformation(Order record, Map<String, Object> jsonMap, SCCFileLogger logger) {

        logger.debug('SCCOrderHelper.upsertPaymentInformation','record: ' + record);
        List<Payment_Information__c> paymentInformationList = new List<Payment_Information__c>();

        if (jsonMap.containsKey('payment_instruments')) {
            paymentInformationList.addAll(SCCOrderHelper.determinePaymentInformation(record.Id, record.Order_Contact__c, jsonMap, logger));
        }

        if (!paymentInformationList.isEmpty()) {
            System.debug('paymentInformationList:' + paymentInformationList);
            Database.upsert(paymentInformationList, true);
        }
    }

    /**
    * This method used for determining products
    * @param recordId: Id
    * @param contactId: Id
    * @param jsonMap: Map<String, Object>
    * @return None.
    */
    private static List<Order_Line_Item__c> determineProducts(Id recordId, Id contactId, Map<String, Object> jsonMap, SCCFileLogger logger) {

        List<Order_Line_Item__c> returnList = new List<Order_Line_Item__c>();
        List<Object> productItemsList = (List<Object>)jsonMap.get('product_items');
        logger.debug('SCCOrderHelper.determineProducts','productItemsList: ' + productItemsList);

        for (Object obj : productItemsList) {
            Map<String, Object> productMap = (Map<String, Object>)obj;
            Order_Line_Item__c orderLineItem = new Order_Line_Item__c();

            // Changes to handle the duplicate records upon synchronisation
            String recordType = 'Order_Line_Item__c';
            String clause = 'ProductLineItemID__c = \'' + (String)productMap.get('item_id') + '\'';
            ensureUniqueRecords(recordType,clause, orderLineItem);

            //Setting the product options related attributes
            List<Object> optionItemsList = (List<Object>)productMap.get('option_items');
            if (optionItemsList!= null && !optionItemsList.isEmpty()) {
                for (Object option_item: optionItemsList) {
                   Order_Line_Item__c optionOrderLineItem = new Order_Line_Item__c();
                   Map<String, Object> OptionItemMap = (Map<String, Object>)option_item;

                   // Ensure uniqueness of each individual product entry
                   String recordTypeOptions = 'Order_Line_Item__c';
                   String clauseOptions = 'ProductLineItemID__c = \'' + (String)OptionItemMap.get('item_id') + '\'';
                   ensureUniqueRecords(recordTypeOptions,clauseOptions, optionOrderLineItem);

                   // Setting the attributes of option product
                   optionOrderLineItem.ProductLineItemID__c = (String)OptionItemMap.get('item_id');
                   optionOrderLineItem.Name = (String)OptionItemMap.get('item_text');
                   optionOrderLineItem.Product_Id__c = (String)OptionItemMap.get('product_id');
                   optionOrderLineItem.Unit_Price__c  = (Decimal)OptionItemMap.get('base_price');
                   optionOrderLineItem.Order_Line_Item_Price__c  = (Decimal)OptionItemMap.get('price');

                   // Relating option items
                   optionOrderLineItem.Order_Line_Item_Product_Id__c  = (String)productMap.get('product_id');
                   optionOrderLineItem.Order__c = recordId;
                   optionOrderLineItem.Quantity__c = (Decimal)OptionItemMap.get('quantity');
                   returnList.add(optionOrderLineItem);
                }
            }

            // Setting the PLI related attributes
            orderLineItem.ProductLineItemID__c = (String)productMap.get('item_id');
            orderLineItem.Unit_Price__c = (Decimal)productMap.get('base_price');
            orderLineItem.Variant_Info__c  = (String)productMap.get('c_variantInfo');
            orderLineItem.Name = (String)productMap.get('item_text');
            orderLineItem.Order_Line_Item_Price__c = (Decimal)productMap.get('price');
            orderLineItem.Price_After_Item_Discount__c = (Decimal)productMap.get('price_after_item_discount');
            orderLineItem.Price_After_Order_Discount__c = (Decimal)productMap.get('price_after_order_discount');
            orderLineItem.Product_Id__c = (String)productMap.get('product_id');
            orderLineItem.Product_Name__c  = (String)productMap.get('product_name');
            orderLineItem.Quantity__c = (Integer)productMap.get('quantity');
            orderLineItem.Tax__c  = (Decimal)productMap.get('tax');
            orderLineItem.Order__c = recordId;
            returnList.add(orderLineItem);

        }


        return returnList;
    }

    /**
    * This method used for determining shippings
    * @param recordId: Id
    * @param contactId: Id
    * @param jsonMap: Map<String, Object>
    * @return None.
    */
    private static List<Shipment__c> determineShippings(Id recordId, Id contactId, Map<String, Object> jsonMap, SCCFileLogger logger) {

        List<Shipment__c> returnList = new List<Shipment__c>();
        List<Object> shipmentItemList = (List<Object>)jsonMap.get('shipments');

        // Loop over the collection of shipment items
        for(Object obj : shipmentItemList) {

            Map<String, Object> productMap = (Map<String, Object>)obj;
            Shipment__c shipmentItem = new Shipment__c();

            //Changes to handle the duplicate records upon synchronisation.ApexPages
            String recordType = 'Shipment__c';
            String clause = 'Shipment_No__c = \'' + (String)productMap.get('shipment_no') + '\'';
            ensureUniqueRecords(recordType,clause, shipmentItem);

            //Setting the values in Shipment object
            shipmentItem.Name = (String)productMap.get('item_text');
            shipmentItem.Order__c = recordId;
            shipmentItem.Shipment_No__c = (String)productMap.get('shipment_no');
            Map <String, Object> addr = (Map <String, Object>) productMap.get('shipping_address');
            Map <String, Object> method = (Map <String, Object>) productMap.get('shipping_method');
            shipmentItem.Shipping_Address__c  = (String)getShippingAddress(addr);
            shipmentItem.Shipment_Contact__c  = (String)getShipmentContact(addr);
            shipmentItem.Shipping_Method__c  = (String)getShippingMethod(method);
            shipmentItem.Shipment_Total__c = (Decimal)productMap.get('shipment_total');
            shipmentItem.Shipping_Total__c = (Decimal)productMap.get('shipping_total');
            shipmentItem.Shipping_Total_Tax__c = (Decimal)productMap.get('shipping_total_tax');
            shipmentItem.Tracking_Number__c = (String)productMap.get('tracking_number');
            returnList.add(shipmentItem);
        }

        
        return returnList;

    }

    private static String getShippingAddress(Map<String, Object> addr){
        // System.debug('Address: ' + addr);
        String result = '';
        result += addr.get('address1').toString() + ', ';
	    if (addr.get('address2') != null) {
            result += addr.get('address2').toString() + ', ';
        }
        result += addr.get('city').toString() + ', ';
        result += addr.get('state_code').toString() + ' ';
        result += addr.get('postal_code').toString();
        // System.debug('Address result: ' + result);
	return result;
    }

    private static String getShippingMethod(Map<String, Object> method){
        // System.debug('Method: ' + method);
        // System.debug('Method result: ' + method.get('name').toString());
        return method.get('name').toString();
    }

    private static String getShipmentContact(Map<String, Object> addr){
        return 'Name: ' + addr.get('full_name').toString() + ', Phone: ' + addr.get('phone').toString();
    }

    /**
    * This method used for determining payment information
    * @param recordId: Id
    * @param contactId: Id
    * @param jsonMap: Map<String, Object>
    * @return List<Payment_Information__c>.
    */
    private static List<Payment_Information__c> determinePaymentInformation(Id recordId, Id contactId, Map<String, Object> jsonMap, SCCFileLogger logger) {

		List<Payment_Information__c> returnList = new List<Payment_Information__c>();
        List<Object> paymentInstructionsList = (List<Object>)jsonMap.get('payment_instruments');

        // Loop through all the payment instruments
        for (Object obj : paymentInstructionsList) {
            Map<String, Object> paymentInstructionMap = (Map<String, Object>)obj;
            Map<String, Object> paymentCard = (Map<String, Object>)paymentInstructionMap.get('payment_card');
            Payment_Information__c PaymentInformationItem = new Payment_Information__c();

            // Changes to handle the duplicate records upon synchronisation
            String recordType = 'Payment_Information__c';
            String clause = 'Payment_Instrument_Id__c = \'' + (String)paymentInstructionMap.get('payment_instrument_id') + '\'';
            ensureUniqueRecords(recordType, clause, PaymentInformationItem);

            //Setting the payment instrument attributes
            PaymentInformationItem.Payment_Instrument_Id__c = (String)paymentInstructionMap.get('payment_instrument_id');
            PaymentInformationItem.Amount_Charged_to_Card__c = (Decimal)paymentInstructionMap.get('amount');
            PaymentInformationItem.Card_Number__c = (String)paymentCard.get('masked_number');
            PaymentInformationItem.Expiration__c = paymentCard.get('expiration_month') + '/' + paymentCard.get('expiration_year');
            PaymentInformationItem.Cardholder_Name__c  = (String)paymentCard.get('holder');
            PaymentInformationItem.Name = (String)paymentCard.get('card_type');
            PaymentInformationItem.Payment_Method__c = (String)paymentInstructionMap.get('payment_method_id');
            PaymentInformationItem.Order__c = recordId;
            returnList.add(PaymentInformationItem);
        }
        return returnList;

    }

    private static List<Account> getPersonAccountByEmail(String email, String customerListId){

        // Initialize the account-list
        List<Account> accounts;

        try {

            // Attempt to retrieve the account that matches on email-address using the customerList attached to the order
            accounts = [SELECT Id, PersonEmail, PersonContactId FROM Account WHERE IsPersonAccount = TRUE AND PersonEmail = :email AND SFCC_CustomerList_ID__pc = :customerListId];

            // Return the account details
            return accounts;

        } catch(Exception e) {

            // On an error -- return the empty account list
            return accounts;

        }
    }

    private static List<Contact> getContactByEmail(String email){
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName('Contact')
            .setRelatedFields(new Set<String>{'Id', 'Email'})
            .setClause('Email', '=', '\'' + email + '\'')
            .getQuery();
        return (List<Contact>)SCCQueryUtilClass.getRecords(query);
    }

    /**
    * This method used to determine the created_by field value from SFCC order response.A
    * For Guest Users value woule be 'strorefront', 'registered' for loggedin users & agent user-name for the CSR orders
    * @param jsonMap: Map<String, Object>
    * @return sourceTypeValue: String.
    */
    private static String getOrderSourceType(Map<String, Object> jsonMap){

        // Initialize the output value
        String sourceTypeValue;

        // Confirm that we have a valid jsonMap to process
        if (jsonMap != null && !jsonMap.isEmpty()) {

            // First check the created_by value - both for registered & guest, the value of this attribute will be 'Customer'.
            if (jsonMap.get('created_by') != null && jsonMap.get('created_by').toString().equalsIgnoreCase('Customer')) {

                // Check customer_info.customer_no - for registered users, this attribute will be present in response but not for guest orders.
                if (jsonMap.containsKey('customer_info') && ((Map<String, Object>)jsonMap.get('customer_info')).get('customer_no') != null){
                    sourceTypeValue  = 'registered';
                } else {
                    sourceTypeValue  = 'storefront';
                }

            // Otherwise, this is an agent order where the username represents the agent
            } else if (jsonMap.get('created_by') != null){
                sourceTypeValue  =  jsonMap.get('created_by').toString();
            }

        }

        return sourceTypeValue;

    }

    /**
    * This method is used to avoid duplicate Shipments, PaymentInstruments & ProductLineItems in an order.
    * @param relatedFields: Set<String>
    * @param recordType: String
    * @param clause: String
    * @param recordObject: SObject
    * @return None.
    */
    private static void ensureUniqueRecords(String recordType, String clause, SObject recordObject){
        Set<String> relatedFields = new Set<String>{'Id'};
        String query = SCCQueryUtilClass.getInstance()
            .getQueryInstance()
            .setObjectName(recordType)
            .setRelatedFields(relatedFields)
            .setClause(clause)
            .getQuery();
        List<SObject> lineItemsList = (List<SObject>)SCCQueryUtilClass.getRecords(query);
        if (!lineItemsList.isEmpty()) {
            recordObject.Id = lineItemsList[0].Id;
        }
    }

    /**
     * Method to get the order object from the supplied record ID.
     * @param objectId String
     * @return orderRecord Order
     */
    private static Order getOrderObjectFromID(String objectId){

        SCCFileLogger logger = SCCFileLogger.getInstance();
        Order orderRecord;

        try {
            String objectName = 'Order';
            String query = SCCQueryUtilClass.getInstance()
                                          .getQueryInstance()
                                          .setObjectName(objectName)
                                          .setAllFields()
                                          .setClause('Id', '=', '\'' + objectId + '\'')
                                          .getQuery();
            List<SObject> objList = SCCQueryUtilClass.getRecords(query);
            if(!objList.isEmpty()) {
            	orderRecord = (Order)objList[0];
            }
        } catch(Exception e) {
        	if(logger!=null){
            	logger.error('SCCOrderHelper.getOrderObjectFromID', 'Exception message : '
                         + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            }

        }finally{
        	if(logger!=null){
            	logger.flush();
        	}

        }
        return orderRecord;
    }

}
/**
* Lightning component controller for refreshing order with sfcc
*
*
* @author  Neeraj Yadav
* @version 1.0
*/
public class SCCOrderRefreshPageController  {

    // related order record
    public static Order record;

    // order number for commerce cloud
    public static String orderNo                       {get; set;}

    // user friendly message of error
    public static String errorMessage                  {get; set;}

    // order information details
    public static List<SCCOrderWrapper> orderList      {get; set;}

    // json map after deserialization
    public static Map<String, Object> jsonMap          {get; set;}

    // json key - label mapping
    public static Map<String, String> jsonKeyMap = new Map<String, String> {
        'c_sscid'=>'SFSC Order Id',
        'site_id'=> 'SFCC Site Id',
        'order_no'=>'Order Number',
        'order_total'=>'Order Total',
        'status'=>'Status',
        'currency'=>'Currency',
        'customer_name'=>'Customer Name',
        'taxation'=>'Taxation'
    };

    /**
    * This method used to getting order informations from commerce cloud
    * @return List<kOrderWrapper>.
    */
    @AuraEnabled
    public static List<SCCOrderWrapper> getOrders(String orderId) {

        // Initialize the file-logger in-use
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        // Initialize local variables
        orderList = new List<SCCOrderWrapper>();
        jsonMap = new Map<String, Object>();

        try {

            // Attempt to retrieve the order details -- including the site / customerList properties
            Order order = [SELECT Id, Name, SFCC_Site_ID__c, SFCC_CustomerList_ID__c, SFCC_Order_Total__c, SFCC_Order_Number__c FROM Order WHERE Id =: orderId];

            // Shorthand a reference to the order number
            orderNo = order.SFCC_Order_Number__c;

            // Create the placeholder list which will contain order properties
            List<SCCOrderWrapper> returnList = new List<SCCOrderWrapper>();

            // Set the site / customerlist context via the Commerce connector
            ccConnect.setSiteId(order.SFCC_Site_ID__c);
            ccConnect.setCustomerListId(order.SFCC_CustomerList_ID__c);

            // Retrieve the order details from Commerce Cloud for the current order
            String resBody = ccConnect.getOrderDetails(orderNo, ccConnect.connectToCommerceCloud());

            // Create a map of the order attributes retrieved via Commerce Cloud
            jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(resBody);

            // Loop over the collection of properties retrieved
            for (String key : jsonMap.keySet()) {

                // Is this property is the list of properties to display via the refresh-component?
                if (jsonKeyMap.keySet().contains(key)) {

                    // If so, then add the key / value pair to the key-map
                    returnList.add(new SCCOrderWrapper(jsonKeyMap.get(key), String.valueOf(jsonMap.get(key))));

                }

            }

            // Add all of the properties to the order-listing
            orderList.addAll(returnList);

            // Return the property list
            return returnList;

        } catch(Exception e) {

            // Clear the orderList and retrieve the error message
            orderList.clear();
            errorMessage = e.getMessage();

            // Audit any errors or exceptions caught during processing
            logger.error('SCCOrderRefreshPageController.getOrders', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
            return new List<SCCOrderWrapper>();

        } finally {

            logger.flush();

        }

    }

    /**
    * This method used to synchronize with orders from SFCC to SFSC
    * @return None.
    */
    @AuraEnabled
    public static Boolean syncOrder(String orderId) {
        
		// First, validate that an orderId is provided
        if (String.isEmpty(orderId)) {
            throw new SObjectException('orderId is empty: ' + orderId);
        }

        // Retrieve the order-details and include the SiteId and CustomerListId
        SCCOrderHelper orderHelper = new SCCOrderHelper();
        return orderHelper.continueWithObject(orderId);
    }

}
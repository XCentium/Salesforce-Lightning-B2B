public class SCCCancelledOrderComponentController {

	/**
    * This method used to getting order information and check the shipment status
	* @param orderId: String
    * @return Boolean.
    */
    @AuraEnabled
    public static Boolean checkOrderStatus(String orderId) {

        // Initialize the logger
       	SCCFileLogger logger = SCCFileLogger.getInstance();

        try {

            // Retrieve the order details
            String query = SCCQueryUtilClass.getInstance()
                    .getQueryInstance()
                    .setObjectName('Order')
                    .setRelatedFields(new Set<String>{'Id', 'Status', 'SFCC_Site_ID__c', 'SFCC_CustomerList_ID__c', 'SFCC_Order_Number__c'})
                    .setClause('Id', '=', '\'' + orderId + '\'')
                    .setLimit('1')
                    .getQuery();
            List<Order> orderList = (List<Order>) SCCQueryUtilClass.getRecords(query);

            // Has this order NOT been shipped?
            if (orderList[0].Status != 'Cancelled') {

                // This order can be cancelled
				return true;

            } else {

                // Otherwise, do not allow this order to be cancelled
                return false;

            }

		} catch(Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCCancelledOrderComponentController.checkOrderStatus', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			return false;

		} finally {

			// logger.flush();

		}

    }

	/**
    * This method used to cancelled order and update order to commerce cloud and service cloud
	* @param orderId: String
    * @return Boolean.
    */
    @AuraEnabled
    public static Boolean cancelledOrder(String orderId) {

        // Initialize the logger
        SCCFileLogger logger = SCCFileLogger.getInstance();

        // Create a new instance of the SCCCommerceCloudConnect class
        SCCCommerceCloudConnect ccConnect = new SCCCommerceCloudConnect();

        logger.debug('SCCCancelledOrderComponentController.cancelledOrder', '-- initializing method');

		try {

            // Retrieve the details of the order being cancelled
            String query = SCCQueryUtilClass.getInstance()
                .getQueryInstance()
                .setObjectName('Order')
                .setRelatedFields(new Set<String>{'Id', 'Status', 'SFCC_Site_ID__c', 'SFCC_CustomerList_ID__c', 'SFCC_Order_Number__c'})
                .setClause('Id', '=', '\'' + orderId + '\'')
                .setLimit('1')
                .getQuery();
            List<Order> orderList = (List<Order>)SCCQueryUtilClass.getRecords(query);

            logger.debug('SCCCancelledOrderComponentController.cancelledOrder', '-- order status: ' + orderList[0].Status);

            // Has this order not been cancelled?
           	if (orderList[0].Status != 'Cancelled') {

                logger.debug('SCCCancelledOrderComponentController.cancelledOrder', '-- order has not been cancelled');

                // Scope the order update by site and customerList
                ccConnect.setSiteId(orderList[0].SFCC_Site_ID__c);
                ccConnect.setCustomerListId(orderList[0].SFCC_CustomerList_ID__c);

                // If not, then push the order updates and change the status accordingly
           	    String responseBody = ccConnect.pushOrderDetails('{"status":"cancelled"}', orderList[0].SFCC_Order_Number__c, ccConnect.connectToCommerceCloud());
			    logger.debug('SCCCancelledOrderComponentController.cancelledOrder', 'responseBody: '+ responseBody);

                // Update the status of the local order
				orderList[0].Status = 'Cancelled';
                Database.update(orderList, true);

                // Flag that the order was cancelled successfully
                return true;

            }

            logger.debug('SCCCancelledOrderComponentController.cancelledOrder', '-- returning false (no error)');

            // Otherwise, return false (the order was already cancelled)
            return false;

        } catch (Exception e) {

            // Audit any errors or exceptions caught during processing
            logger.error('SCCCancelledOrderComponentController.cancelledOrder', 'Exception message : '
                 + e.getMessage() + ' StackTrack '+ e.getStackTraceString());
			return false;

		} finally {

			logger.flush();

		}

    }

}
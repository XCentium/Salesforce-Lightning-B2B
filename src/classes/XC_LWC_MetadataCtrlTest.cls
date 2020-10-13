/**
 * @FileName: XC_LWC_MetadataCtrlTest
 * @Description: Test methods for metadata controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       8/16/2020         Created
 *-----------------------------------------------------------  
 */
@IsTest
private class XC_LWC_MetadataCtrlTest {

    @TestSetup
    static void setupTest() {
        setupHelper();
    }

    @IsTest
    static void getActiveApexClasses() {
        Test.startTest();
        List<ApexClass> classes = XC_LWC_MetadataCtrl.getActiveApexClasses();
        Test.stopTest();

        System.assertNotEquals(null, classes);
    }

    @IsTest
    static void registerExternalService() {
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        Id inventoryClassId = [SELECT Id FROM ApexClass WHERE Name = 'B2BCheckInventorySample'].Id;

        Test.startTest();
        XC_LWC_CheckoutRegistrationWrapper wrapper = XC_LWC_MetadataCtrl.registerExternalService(
                webStore.Id,
                inventoryClassId,
                '49.0',
                'Inventory'
        );
        Test.stopTest();

        System.assert(String.isNotBlank(wrapper.registeredIntegrationId));
    }

    @IsTest
    static void registerExternalServiceError() {
        Id inventoryClassId = [SELECT Id FROM ApexClass WHERE Name = 'XC_LWC_MetadataCtrl'].Id;

        Test.startTest();
        XC_LWC_CheckoutRegistrationWrapper wrapper = XC_LWC_MetadataCtrl.registerExternalService(
                'null',
                inventoryClassId,
                '49.0',
                'Inventory'
        );
        Test.stopTest();

        System.assert(!wrapper.errorMessages.isEmptY());
    }

    @IsTest
    static void createStoreIntegrationService() {
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        Id inventoryClassId = [SELECT Id FROM ApexClass WHERE Name = 'B2BCheckInventorySample'].Id;

        XC_LWC_CheckoutRegistrationWrapper registrationWrapper = XC_LWC_MetadataCtrl.registerExternalService(
                webStore.Id,
                inventoryClassId,
                '49.0',
                'Inventory'
        );

        Test.startTest();
        XC_LWC_CheckoutRegistrationWrapper serviceWrapper = XC_LWC_MetadataCtrl.createStoreIntegratedService(
                webStore.Id,
                registrationWrapper.registeredIntegrationId,
                'Inventory'
        );
        Test.stopTest();

        System.assert(String.isNotBlank(serviceWrapper.storeIntegratedServiceId));
    }

    @IsTest
    static void createStoreIntegrationServiceError() {
        Test.startTest();
        XC_LWC_CheckoutRegistrationWrapper wrapper = XC_LWC_MetadataCtrl.createStoreIntegratedService(
                null,
                null,
                'Inventory'
        );
        Test.stopTest();

        System.assert(!wrapper.errorMessages.isEmptY());
    }

    @IsTest
    static void getCheckoutExternalServices() {
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        Id inventoryClassId = [SELECT Id FROM ApexClass WHERE Name = 'B2BCheckInventorySample'].Id;

        XC_LWC_CheckoutRegistrationWrapper registrationWrapper = XC_LWC_MetadataCtrl.registerExternalService(
                webStore.Id,
                inventoryClassId,
                '49.0',
                'Inventory'
        );

        XC_LWC_MetadataCtrl.createStoreIntegratedService(
                webStore.Id,
                registrationWrapper.registeredIntegrationId,
                'Inventory'
        );

        Test.startTest();
        List<XC_LWC_CheckoutRegistrationHelper.StoreExternalService> services = XC_LWC_MetadataCtrl.getCheckoutExternalServices(webStore.Id);
        Test.stopTest();

        System.assert(!services.isEmpty());
    }

    @IsTest
    static void removeExternalService() {
        WebStore webStore = [SELECT Id FROM WebStore LIMIT 1];
        Id inventoryClassId = [SELECT Id FROM ApexClass WHERE Name = 'B2BCheckInventorySample'].Id;

        XC_LWC_CheckoutRegistrationWrapper registrationWrapper = XC_LWC_MetadataCtrl.registerExternalService(
                webStore.Id,
                inventoryClassId,
                '49.0',
                'Inventory'
        );

        XC_LWC_CheckoutRegistrationWrapper serviceWrapper = XC_LWC_MetadataCtrl.createStoreIntegratedService(
                webStore.Id,
                registrationWrapper.registeredIntegrationId,
                'Inventory'
        );

        Test.startTest();
        XC_LWC_MetadataCtrl.removeExternalService(serviceWrapper.storeIntegratedServiceId);
        Test.stopTest();

        List<XC_LWC_CheckoutRegistrationHelper.StoreExternalService> services = XC_LWC_MetadataCtrl.getCheckoutExternalServices(webStore.Id);

        System.assert(services.isEmpty());
    }

    @IsTest
    static void removeExternalServiceError() {
        String errorMessage;

        Test.startTest();
        try {
            XC_LWC_MetadataCtrl.removeExternalService('null');
        }
        catch (Exception e) {
            errorMessage = e.getMessage();
        }
        Test.stopTest();

        System.assert(String.isNotBlank(errorMessage));
    }

    // HELPER METHODS
    static void setupHelper() {
        XC_Util_TestData.createSObject(new WebStore(), true);
    }
}
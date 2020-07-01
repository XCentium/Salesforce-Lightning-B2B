/**
 * @FileName: XC_LWC_CheckoutRegistrationWrapper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/25/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_CheckoutRegistrationWrapper {
    public String webstoreId;
    public String apexClassId;
    public Decimal apiVersion;
    public String serviceType;
    public String devName;
    public String prefixedName;
    public String storeIntegratedServiceId;

    @AuraEnabled public String registeredIntegrationId;
    @AuraEnabled public List<String> messages;
    @AuraEnabled public List<String> errorMessages;

    public XC_LWC_CheckoutRegistrationWrapper(String webstoreId, String apexClassId, String apiVersion, String serviceType) {
        this.webstoreId = webstoreId;
        this.apexClassId = apexClassId;
        this.apiVersion = Decimal.valueOf(apiVersion);
        this.serviceType = serviceType;
        this.messages = new List<String>();
        this.errorMessages = new List<String>();

        setRegistrationParameters();
    }

    public XC_LWC_CheckoutRegistrationWrapper(String webstoreId, String registeredIntegrationId, String serviceType) {
        this.webstoreId = webstoreId;
        this.registeredIntegrationId = registeredIntegrationId;
        this.serviceType = serviceType;
        this.messages = new List<String>();
        this.errorMessages = new List<String>();

        setRegistrationParameters();
    }

    private void setRegistrationParameters() {
        switch on serviceType {
            when 'Inventory' {
                this.devName = 'CHECK_INVENTORY';
                this.prefixedName = serviceType + '__' + devName;
            }
            when 'Price' {
                this.devName = 'COMPUTE_SHIPPING';
                this.prefixedName = serviceType + '__' + devName;
            }
            when 'Shipment' {
                this.devName = 'COMPUTE_PRICE';
                this.prefixedName = serviceType + '__' + devName;
            }
            when 'Tax' {
                this.devName = 'COMPUTE_TAXES';
                this.prefixedName = serviceType + '__' + devName;
            }
        }
    }

    public void registerExternalService() {
        try {
            RegisteredExternalService registeredExternalService = Database.query(
                    'SELECT Id FROM RegisteredExternalService ' +
                    'WHERE ExternalServiceProviderId = :apexClassId ' +
                    'AND DeveloperName = :devName ' +
                    'AND ExternalServiceProviderType = :serviceType ' +
                    'LIMIT 1'
            );
            this.registeredIntegrationId = registeredExternalService.Id;

            System.debug('Registered External Service: FOUND ' + this.registeredIntegrationId);
            this.messages.add('Registered External Service: FOUND ' + this.registeredIntegrationId);
        } catch (QueryException q) {
            System.debug('Registered External Service: MISSING ' + this.apexClassId);

            RegisteredExternalService registeredExternalService = new RegisteredExternalService(
                    DeveloperName = this.devName,
                    MasterLabel = this.devName,
                    ExternalServiceProviderId = apexClassId,
                    ExternalServiceProviderType = this.serviceType
            );

            insert registeredExternalService;

            this.registeredIntegrationId = registeredExternalService.Id;

            System.debug('Registered External Service: INSERTED ' + this.registeredIntegrationId);
            this.messages.add('Registered External Service: INSERTED ' + this.registeredIntegrationId);
        }
    }

    public void storeIntegratedService() {
        // locate and map in StoreIntegratedService
        try {
            StoreIntegratedService registeredMappingObj = Database.query(
                    'SELECT Id FROM StoreIntegratedService ' +
                    'WHERE Integration = :prefixedName ' +
                    'AND ServiceProviderType = :serviceType ' +
                    'AND StoreId = :webstoreId ' +
                    'LIMIT 1'
            );

            this.storeIntegratedServiceId = registeredMappingObj.Id;

            System.debug('Store Integrated Service: FOUND ' + this.storeIntegratedServiceId);
            this.messages.add('Store Integrated Service: FOUND ' + this.storeIntegratedServiceId);

            // delete registeredMappingObj; // optionally remove if needed
        } catch (QueryException q) {
            System.debug('Store Integrated Service: MISSING ' + this.prefixedName);

            StoreIntegratedService storeIntegratedService = new StoreIntegratedService(
                    Integration = this.prefixedName,
                    ServiceProviderType = this.serviceType,
                    StoreId = this.webstoreId
            );

            insert storeIntegratedService;

            this.storeIntegratedServiceId = storeIntegratedService.Id;

            System.debug('Store Integrated Service: INSERTED ' + this.storeIntegratedServiceId);
            this.messages.add('Store Integrated Service: INSERTED ' + this.storeIntegratedServiceId);
        }
    }
}
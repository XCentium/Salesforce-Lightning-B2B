global class SCCConnectorPostInstallScript implements InstallHandler {
    global void onInstall(InstallContext context) {
        insertCustomSettingsData();
    }

    public static void insertCustomSettingsData(){
        insertAccountFieldMapping();
        insertAddressFieldMapping();
        insertContactFieldMapping();
        insertCaseFieldMapping();
        insertOrderFieldMapping();
        createDefaultAccount();
        createGlobalConfiguration();
    }

    /**
    * This method inserts Contact object field mapping between salesforce and commerce cloud.
    */
    private static void insertAccountFieldMapping() {
        List<AccountFieldMapping__c> accountFieldMappings = AccountFieldMapping__c.getAll().values();
        delete accountFieldMappings;
        upsert new AccountFieldMapping__c(Name = 'customerlist_id', CC_Attribute__c = 'customerlist_id', Field_Api_Name__c  = 'SFCC_CustomerList_ID__pc', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'customer_id', CC_Attribute__c = 'customer_id', Field_Api_Name__c  = 'SFCC_Customer_Id__pc', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new AccountFieldMapping__c(Name = 'customer_no', CC_Attribute__c = 'customer_no', Field_Api_Name__c  = 'SFCC_Customer_Number__pc', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new AccountFieldMapping__c(Name = 'email', CC_Attribute__c = 'email', Field_Api_Name__c  = 'personEmail', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'enabled', CC_Attribute__c = 'credentials.enabled', Field_Api_Name__c  = 'Active__c', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'first_name', CC_Attribute__c = 'first_name', Field_Api_Name__c  = 'FirstName', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'last_name', CC_Attribute__c = 'last_name', Field_Api_Name__c  = 'LastName', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'phone_home', CC_Attribute__c = 'phone_home', Field_Api_Name__c  = 'PersonHomePhone', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'site_id', CC_Attribute__c = 'site_id', Field_Api_Name__c  = 'SFCC_Site_ID__pc', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AccountFieldMapping__c(Name = 'username', CC_Attribute__c = 'credentials.login', Field_Api_Name__c  = 'CC_Username__pc', Enable_Patch__c = false, Enable_Sync__c = true);
    }

    /**
    * This method inserts Contact object field mapping between salesforce and commerce cloud.
    */
    private static void insertAddressFieldMapping() {
        List<AddressFieldMapping__c> addressFieldMappings = AddressFieldMapping__c.getAll().values();
        delete addressFieldMappings;
        upsert new AddressFieldMapping__c(Name = 'address1', CC_Attribute__c = 'address1', Field_Api_Name__c  = 'Address_Line_1__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'address2', CC_Attribute__c = 'address2', Field_Api_Name__c  = 'Address_Line_2__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'address_id', CC_Attribute__c = 'address_id', Field_Api_Name__c  = 'Name', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'city', CC_Attribute__c = 'city', Field_Api_Name__c  = 'City__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'country', CC_Attribute__c = 'country_code', Field_Api_Name__c  = 'Country__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'first_name', CC_Attribute__c = 'first_name', Field_Api_Name__c  = 'First_Name__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'full_name', CC_Attribute__c = 'full_name', Field_Api_Name__c  = 'Full_Name__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'last_name', CC_Attribute__c = 'last_name', Field_Api_Name__c  = 'Last_Name__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'phone', CC_Attribute__c = 'phone', Field_Api_Name__c  = 'Phone__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'postal_code', CC_Attribute__c = 'postal_code', Field_Api_Name__c  = 'Postal_Code__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'post_box', CC_Attribute__c = 'post_box', Field_Api_Name__c  = 'Post_Box__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'preferred', CC_Attribute__c = 'preferred', Field_Api_Name__c  = 'preferred__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'second_name', CC_Attribute__c = 'second_name', Field_Api_Name__c  = 'Second_Name__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new AddressFieldMapping__c(Name = 'state', CC_Attribute__c = 'state_code', Field_Api_Name__c  = 'State__c', Enable_Patch__c = false, Enable_Sync__c = true);
    }

    /**
    * This method inserts Contact object field mapping between salesforce and commerce cloud.
    */
    private static void insertContactFieldMapping() {
        List<ContactFieldMapping__c> contactFieldMappings = ContactFieldMapping__c.getAll().values();
        delete contactFieldMappings;
        upsert new ContactFieldMapping__c(Name = 'customer_id', CC_Attribute__c = 'customer_id', Field_Api_Name__c  = 'SFCC_Customer_Id__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new ContactFieldMapping__c(Name = 'customer_no', CC_Attribute__c = 'customer_no', Field_Api_Name__c  = 'SFCC_Customer_Number__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new ContactFieldMapping__c(Name = 'email', CC_Attribute__c = 'email', Field_Api_Name__c  = 'Email', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new ContactFieldMapping__c(Name = 'first_name', CC_Attribute__c = 'first_name', Field_Api_Name__c  = 'FirstName', Enable_Patch__c = true, Enable_Sync__c = true);
        upsert new ContactFieldMapping__c(Name = 'last_name', CC_Attribute__c = 'last_name', Field_Api_Name__c  = 'LastName', Enable_Patch__c = true, Enable_Sync__c = true);
    }

    /**
    * This method inserts Order object field mapping between salesforce and commerce cloud.
    */
    private static void insertOrderFieldMapping() {
        List<OrderFieldMapping__c> orderFieldMappings = OrderFieldMapping__c.getAll().values();
        delete orderFieldMappings;
        upsert new OrderFieldMapping__c(Name = 'account_id', CC_Attribute__c = 'account_id', Field_Api_Name__c  = 'AccountId', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'billing_city', CC_Attribute__c = 'billing_city', Field_Api_Name__c  = 'BillingCity', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'billing_postal_code', CC_Attribute__c = 'billing_postal_code', Field_Api_Name__c  = 'BillingPostalCode', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'billing_state', CC_Attribute__c = 'billing_state', Field_Api_Name__c  = 'BillingState', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'billing_street', CC_Attribute__c = 'billing_street', Field_Api_Name__c  = 'BillingStreet', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'blling_country', CC_Attribute__c = 'billing_country', Field_Api_Name__c  = 'BillingCountry', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'crmcontact_id', CC_Attribute__c = 'crmcontact_Id', Field_Api_Name__c  = 'Order_Contact__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'contact_id', CC_Attribute__c = 'contact_id', Field_Api_Name__c  = 'Order_Contact__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'customerlist_id', CC_Attribute__c = 'customerlist_id', Field_Api_Name__c  = 'SFCC_CustomerList_ID__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'customer_no', CC_Attribute__c = 'customer_info.customer_no', Field_Api_Name__c  = 'SFCC_Customer_Number__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'globalparty_Id', CC_Attribute__c = 'global_party_id', Field_Api_Name__c  = 'SFCC_GPID__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'order_email_address', CC_Attribute__c = 'customer_info.email', Field_Api_Name__c  = 'SFCC_Order_Email__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new OrderFieldMapping__c(Name = 'order_no', CC_Attribute__c = 'order_no', Field_Api_Name__c  = 'SFCC_Order_Number__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'order_total', CC_Attribute__c = 'order_total', Field_Api_Name__c  = 'SFCC_Order_Total__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'scc_sync_status', CC_Attribute__c = 'scc_sync_status', Field_Api_Name__c  = 'Order_SCCSync_Status__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'shipping_city', CC_Attribute__c = 'shipping_city', Field_Api_Name__c  = 'ShippingCity', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'shipping_country', CC_Attribute__c = 'shipping_country', Field_Api_Name__c  = 'ShippingCountry', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'shipping_postal_code', CC_Attribute__c = 'shipping_postal_code', Field_Api_Name__c  = 'ShippingPostalCode', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'shipping_state', CC_Attribute__c = 'shipping_state', Field_Api_Name__c  = 'ShippingState', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'shipping_street', CC_Attribute__c = 'shipping_street', Field_Api_Name__c  = 'ShippingStreet', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new OrderFieldMapping__c(Name = 'site_id', CC_Attribute__c = 'site_id', Field_Api_Name__c  = 'SFCC_Site_ID__c', Enable_Patch__c = false, Enable_Sync__c = true);
        upsert new OrderFieldMapping__c(Name = 'status', CC_Attribute__c = 'status', Field_Api_Name__c  = 'Status', Enable_Patch__c = false, Enable_Sync__c = true);
    }

    /**
    * This method inserts Case object field mapping between salesforce and commerce cloud.
    */
    private static void insertCaseFieldMapping() {
        List<CaseFieldMapping__c> caseFieldMappings = CaseFieldMapping__c.getAll().values();
        delete caseFieldMappings;
        upsert new CaseFieldMapping__c(Name = 'account_id', CC_Attribute__c = 'account_id', Field_Api_Name__c  = 'AccountId', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'case_sub_type', CC_Attribute__c = 'case_sub_type', Field_Api_Name__c  = 'Case_Sub_Type__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'case_type', CC_Attribute__c = 'case_type', Field_Api_Name__c  = 'Type', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'contact_id', CC_Attribute__c = 'contact_id', Field_Api_Name__c  = 'ContactId', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'customerlist_id', CC_Attribute__c = 'customerlist_id', Field_Api_Name__c  = 'SFCC_CustomerList_ID__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'customer_id', CC_Attribute__c = 'customer_id', Field_Api_Name__c  = 'SFCC_Customer_Id__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'customer_no', CC_Attribute__c = 'customer_no', Field_Api_Name__c  = 'SFCC_Customer_Number__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'description', CC_Attribute__c = 'description', Field_Api_Name__c  = 'Description', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'email', CC_Attribute__c = 'email', Field_Api_Name__c  = 'SuppliedEmail', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'first_name', CC_Attribute__c = 'first_name', Field_Api_Name__c  = 'SuppliedName', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'last_name', CC_Attribute__c = 'last_name', Field_Api_Name__c  = 'SuppliedLastName__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'order_no', CC_Attribute__c = 'order_no', Field_Api_Name__c  = 'SFCC_Order_No__c', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'origin', CC_Attribute__c = 'origin', Field_Api_Name__c  = 'Origin', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'phone', CC_Attribute__c = 'phone', Field_Api_Name__c  = 'SuppliedPhone', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'site_id', CC_Attribute__c = 'site_id', Field_Api_Name__c  = 'SFCC_Site_ID__pc', Enable_Patch__c = false, Enable_Sync__c = false);
        upsert new CaseFieldMapping__c(Name = 'subject', CC_Attribute__c = 'subject', Field_Api_Name__c  = 'Subject', Enable_Patch__c = false, Enable_Sync__c = false);
    }

    /**
     * Create the global configuration setting for all sites
     */
    private static void createGlobalConfiguration() {
        List<GlobalSFCCConfigurations__c> globalConfig = GlobalSFCCConfigurations__c.getAll().values();
        delete globalConfig;
        upsert new GlobalSFCCConfigurations__c(Name = 'Global SCC Configuration', Enable_Customer_Synch_Triggers__c = true, Enable_SFCC_Customers__c = true, Enable_SFCC_Orders__c = true);
    }

    /**
    * Create default account for Salesforce commerce cloud.
    */
    private static void createDefaultAccount() {
        RecordType recordType = [SELECT Id FROM RecordType WHERE SobjectType='Account' AND Name = 'Business Account'];
        List<Account> defaultAccountList = [SELECT Id FROM Account WHERE Name ='Default'];
        if(defaultAccountList.isEmpty()){
            Account record = new Account();
            record.Name = 'Default';
            record.RecordTypeId = recordType.Id;
            Database.insert(record, true);
        }
    }
}
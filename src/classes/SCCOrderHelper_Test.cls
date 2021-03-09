/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @IsTest class annotation indicates this class only contains test
 * methods. Classes defined with the @IsTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */

@IsTest
public class SCCOrderHelper_Test {

    @TestSetup
    static void setup() {
        SCCTestDataFactory.createSFCCConfigDefaultCustomSetting();
        SCCTestDataFactory.createSFCCCredentialDefaultCustomSetting();
        SCCTestDataFactory.createSFCCLogDefaultCustomSetting();
        SCCTestDataFactory.createContact(new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'}, new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'}, new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'});
        SCCTestDataFactory.createAccount (
                new Map<Integer, String>{1=>'fname', 2=>'fname', 3=>'fname'},
                new Map<Integer, String>{1=>'lname', 2=>'lname', 3=>'lname'},
                new Map<Integer, String>{1=>'test@hotmail.com', 2=>'test@yahoo.com', 3=>'test@salesforce.com'},
                new Map<Integer, String>{1=>'12345', 2=>'23456', 3=>'34567'},
                new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'},
                new Map<Integer, String>{1=>'RefArch', 2=>'RefArch', 3=>'RefArch'}
        );
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'personEmail', 'birthday'=>'personBirthDate', 'customer_no'=>'SFCC_Customer_Number__pc', 'customer_id'=>'SFCC_Customer_Id__pc'}, 'Account');
        SCCTestDataFactory.createFieldMappingCustomSettings(new Map<String, String>{'first_name'=>'FirstName', 'last_name'=>'LastName', 'enabled'=>'Active__c', 'email'=>'Email', 'birthday'=>'BirthDate', 'customer_no'=>'SFCC_Customer_Number__c', 'customer_id'=>'SFCC_Customer_Id__c'}, 'Contact');
        SCCTestDataFactory.createAccountCase(1, [SELECT Id FROM Account LIMIT 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
        SCCTestDataFactory.createCase(1, [SELECT Id FROM Contact LIMIT 1].Id, 'Test Case Description', 'ContactUs', 'Test Case Title');
        SCCTestDataFactory.createOrder(5, [SELECT Id FROM Account LIMIT 1].Id, System.today(), 'Draft', '12345', [SELECT Id FROM Contact LIMIT 1].Id);
        SCCTestDataFactory.createAccount(1, 'Default', false);
    }

    @IsTest
    static void test_continueWithObject_one(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetails'));
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
		(new SCCOrderHelper()).continueWithObject(order.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_continueWithObject_two(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetailsWithoutContact'));
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
		(new SCCOrderHelper()).continueWithObject(order.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_continueWithObject_three(){
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('OrderDetailsWithoutCustomerInfo'));
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
        (new SCCOrderHelper()).continueWithObject(order.Id);
        Test.stopTest();
    }

    @IsTest
    static void test_syncAccountOrder_one(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"test@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
		Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('CustomerSearch'));
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
		SCCOrderHelper.syncAccountOrder(order, jsonMap, logger);
        Test.stopTest();
    }

    @IsTest
    static void test_syncAccountOrder_two(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Test.startTest();
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"vinnie@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
		Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, SFCC_Order_Number__c FROM Order LIMIT 1];
		SCCOrderHelper.syncAccountOrder(order, jsonMap, logger);
        Test.stopTest();
    }

    @IsTest
    static void test_syncAccountOrder_three(){
    	Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        Test.startTest();
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"vinnie@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
		Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, SFCC_Order_Number__c FROM Order LIMIT 1];
		SCCOrderHelper.syncAccountOrder(order, jsonMap, logger);
        Test.stopTest();
    }

    @IsTest
    static void test_syncAccountOrder_four(){
        SCCTestDataFactory.createOrder(1, [SELECT Id FROM Account WHERE Name='Default'].Id, System.today(), 'Draft', '98765', null);
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        Test.startTest();
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"vinnie@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, SFCC_Order_Number__c FROM Order WHERE SFCC_Order_Number__c = '987650'];
        SCCOrderHelper.syncAccountOrder(order, jsonMap, logger);
        Test.stopTest();
    }

    @IsTest
    static void test_syncAccountOrder_five(){
        SCCTestDataFactory.createOrder(1, [SELECT Id FROM Account WHERE Name='Default'].Id, System.today(), 'Draft', '98765', null);
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        Test.startTest();
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"test@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, SFCC_Order_Number__c FROM Order WHERE SFCC_Order_Number__c = '987650'];
        SCCOrderHelper.syncAccountOrder(order, jsonMap, logger);
        Test.stopTest();
    }

    @IsTest
    static void test_syncAccountOrder_six(){
        SCCTestDataFactory.createOrder(1, [SELECT Id FROM Account WHERE Name='Default'].Id, System.today(), 'Draft', '98765', null);
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test('ZeroCustomerSearch'));
        Test.startTest();
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"fake@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
        Test.setMock(HttpCalloutMock.class, new SCCHttpCalloutMockGenerator_Test());
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, SFCC_Order_Number__c FROM Order WHERE SFCC_Order_Number__c = '987650'];
        SCCOrderHelper.syncAccountOrder(order, jsonMap, logger);
        Test.stopTest();
    }



    @IsTest
    static void test_upsertProductShipping_one(){
        SCCFileLogger logger = SCCFileLogger.getInstance();
        String body = '{"_v":"17.8",';
        body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
        body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
        body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
        body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"test@hotmail.com"},"customer_name":"Vinnie Jones",';
        body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
        body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
        body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,';
        body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
        body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
        body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
        body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
        body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
        body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
        body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        Map<String, Object> jsonMap = (Map<String, Object>)System.JSON.deserializeUntyped(body);
        Order order = [SELECT Id, SFCC_CustomerList_ID__c, SFCC_Site_ID__c, AccountId, Order_Contact__c, SFCC_Order_Number__c FROM Order LIMIT 1];
        Test.startTest();
        SCCOrderHelper.upsertProductShipping(order, jsonMap, logger);
        Test.stopTest();
    }
}
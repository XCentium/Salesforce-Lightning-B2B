/**
* HttpCalloutMock interface to specify the response sent in the respond method, which the Apex runtime calls to send a response for a callout.
*
*
* @author  Neeraj Yadav
* @version 1.0
* @since   2017-11-15
*/
@IsTest
global class SCCHttpCalloutMockGenerator_Test implements HttpCalloutMock {

    private String callouttype;

    public SCCHttpCalloutMockGenerator_Test(){
        this.callouttype = 'Order';
    }

    public SCCHttpCalloutMockGenerator_Test(String reqType){
        this.callouttype = reqType;
    }

    global HttpResponse respond(HttpRequest req) {

        String body = null;
        if(this.callouttype.equalsIgnoreCase('OrderDetails')){
            //Order details by order id
            body = '{"_v":"17.8",';
            body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
            body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
            body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
            body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
            body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"test@hotmail.com"},"customer_name":"Vinnie Jones",';
            body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
            body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
            body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00, "c_orderPickedQuantity":5,"c_orderUpdateAlternateDetails":"picked",';
            body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
            body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
            body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
            body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
            body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
            body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
            body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
            body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
            body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        }else if(this.callouttype.equalsIgnoreCase('OrderDetailsWithoutContact')){
            //Order details by order id without matching email
            body = '{"_v":"17.8",';
            body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
            body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
            body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
            body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
            body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"vinnie.jones@xaebo.com"},"customer_name":"Vinnie Jones",';
            body += '"export_status":"not_exported","last_modified":"2017-11-15T07:53:59.000Z","merchandize_total_tax":2.70,"notes":{"_type":"simple_link","link":"https://xxxx-dw.demandware.net/s/RefArch/dw/shop/v17_8/orders/00001603/notes"';
            body += '},"order_no":"00001603","order_token":"Q1h8Xbhkuf0a9iAnHGvaRJ-vgtyU6ijbc_opepJmY8g","order_total":62.99,"payment_instruments":[{"_type":"order_payment_instrument","amount":62.99,';
            body += '"payment_instrument_id":"220c0f5b041fd6dfeb70f52c3b","payment_method_id":"BML"}],"payment_status":"not_paid","product_items":[{"_type":"product_item","adjusted_tax":2.70,"base_price":54.00,"c_orderPickedQuantity":5,"c_orderUpdateAlternateDetails":"picked",';
            body += '"bonus_product_line_item":false,"gift":false,"item_id":"612e2cee8f5900307bdea7233c","item_text":"Cut Away Tank","price":54.00,"price_after_item_discount":54.00,"price_after_order_discount":54.00,';
            body += '"product_id":"701644393953","product_name":"Cut Away Tank","quantity":1,"shipment_id":"me","tax":2.70,"tax_basis":54.00,"tax_class_id":"standard","tax_rate":0.05}],"product_sub_total":54.00,';
            body += '"product_total":54.00,"shipments":[{"_type":"shipment","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,"gift":false,"merchandize_total_tax":2.70,"product_sub_total":54.00,';
            body += '"product_total":54.00,"shipment_id":"me","shipment_no":"00005502","shipment_total":62.99,"shipping_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
            body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"0906b645b89cfb94adbbbec977","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"';
            body += '},"shipping_method":{"_type":"shipping_method","description":"Order received within 7-10 business days","id":"001","name":"Ground","price":5.99},"shipping_status":"not_shipped","shipping_total":5.99,';
            body += '"shipping_total_tax":0.30,"tax_total":3.00}],"shipping_items":[{"_type":"shipping_item","adjusted_tax":0.30,"base_price":5.99,"item_id":"e530faa190ff22a48cdc12c651","item_text":"Shipping",';
            body += '"price":5.99,"price_after_item_discount":5.99,"shipment_id":"me","tax":0.30,"tax_basis":5.99,"tax_class_id":"standard","tax_rate":0.05}],"shipping_status":"not_shipped","shipping_total":5.99,';
            body += '"shipping_total_tax":0.30,"site_id":"RefArch","status":"open","taxation":"net","tax_total":3.00,"c_poid":"a42B0000000CaaaIAC","c_sforderid":"801B0000000CmlOIAS"}';
        }else if(this.callouttype.equalsIgnoreCase('OrderDetailsWithoutCustomerInfo')){
            //Order details by order id
            body = '{"_v":"17.8",';
            body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
            body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
            body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
            body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_name":"Vinnie Jones",';
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
        }else if(this.callouttype.equalsIgnoreCase('ZeroCustomerSearch')){
            //Customer doesnt exist in commerce cloud
            body = '{"_v":"17.8","_type":"customer_search_result","count":0,"query":{"text_query":{"_type":"text_query","fields":["email"],"search_phrase":"nirajyadav@gmail2001.com"}},"start":0,"total":0}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerSearch')){
            //Found customer based on email id
            body = '{"_v":"17.8","_type":"customer_search_result","count":1,"hits":[{"_type":"customer_search_hit","data":{"_type":"customer","customer_no":"00018502"},"relevance":8.243810653686523}],"query":{"text_query":{"_type":"text_query","fields":["email"],"search_phrase":"nirajyadav@gmail2002.com"}},"start":0,"total":1}';
        }else if(this.callouttype.equalsIgnoreCase('AccessToken')){
            body = '{"access_token": "2016f5bd-59bd-4c06-9233-8d807c8dc613", "expires_in": 899, "token_type": "Bearer"}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerAuthAccessToken')){
            body ='{"_v" : "18.1","_type" : "customer","auth_type" : "registered","creation_date" : "2012-03-30T08:23:51.000Z","customer_id" : "acI4Lg0fMrBZ6shBanPpvkIKHZ","customer_no" : "00001140",';
            body +='"email" : "mail@example.com","enabled" : true,"first_name" : "John","gender" : 1,"last_login_time" : "2012-04-05T06:08:38.000Z","last_name" : "Doe","last_visit_time" : "2012-04-05T06:08:38.000Z",';
            body +='"login" : "johndoe", "previous_login_time" : "2012-04-05T06:08:38.000Z", "previous_visit_time" : "2012-04-05T06:08:38.000Z"}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerDetails')){
            body = '{"_resource_state": "5391ed5a7a479d5e7daacc73177a9215235401a68dc161cff49e50abe7558249",';
            body +='"_type": "customer","_v": "17.8","birthday": "1981-08-28","c_sscSyncResponseText": ["Successfully Exported"],';
            body +='"c_sscSyncStatus": "exported","c_sscid": "0011I00000QkVb5QAF", "creation_date": "2018-05-13T17:58:24.000Z", "credentials": {"_type": "credentials","enabled": false,"locked": false,"login": "nirajyadav@gmail606.com"},';
            body += '"customer_id": "ad5cpbLbK64iOkrhjDaYXibHFS","customer_no": "00030501","email": "nirajyadav@gmail6088.com", "first_name": "Neeraj", "last_login_time": "2018-05-14T12:24:47.000Z","last_modified": "2018-05-25T11:31:38.375Z",';
            body += '"last_name": "Yadav","last_visit_time": "2018-05-14T12:24:47.000Z","previous_login_time": "2018-05-14T12:24:47.000Z","previous_visit_time": "2018-05-14T12:24:47.000Z"}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerDetailsWithAddress')){
            body = '{"_resource_state": "5391ed5a7a479d5e7daacc73177a9215235401a68dc161cff49e50abe7558249",';
            body +='"_type": "customer","_v": "17.8","birthday": "1981-08-28","c_sscSyncResponseText": ["Successfully Exported"],';
            body +='"c_sscSyncStatus": "exported","c_sscid": "0011I00000QkVb5QAF", "creation_date": "2018-05-13T17:58:24.000Z", "credentials": {"_type": "credentials","enabled": false,"locked": false,"login": "nirajyadav@gmail606.com"},';
            body += '"customer_id": "ad5cpbLbK64iOkrhjDaYXibHFS","customer_no": "00030501","email": "nirajyadav@gmail6088.com", "first_name": "Neeraj", "last_login_time": "2018-05-14T12:24:47.000Z","last_modified": "2018-05-25T11:31:38.375Z",';
            body += '"last_name": "Yadav","last_visit_time": "2018-05-14T12:24:47.000Z","previous_login_time": "2018-05-14T12:24:47.000Z","previous_visit_time": "2018-05-14T12:24:47.000Z",';
            body += '"data" : [ {"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5","address1" : "Lodyweg","address_id" : "my_home_address","city" : "Washingtonville",';
            body += '"company_name" : "Salesforce Commerce Cloud","country_code" : "SH","first_name" : "Pit","full_name" : "Pit Snipes","job_title" : "","last_name" : "Snipes","phone" : "001-111-1111","postal_code" : "15361","state_code" : "DE"}]}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerAddresses')){
            body += '{"_v" : "18.3","_type":"customer_address_result","count" : 10,"data" : [ {"_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5","address1" : "Lodyweg","address_id" : "my_home_address",';
            body += '"city" : "Washingtonville","company_name" : "Salesforce Commerce Cloud","country_code" : "SH","first_name" : "Pit","full_name" : "Pit Snipes","job_title" : "","last_name" : "Snipes","phone" : "001-111-1111",';
            body += '"postal_code" : "15361","state_code" : "DE"}],"next" : "https://example.com/dw/data/v18_3/customer_lists/4711/customers/0815/addresses?count=1&start=1","start" : 0,"total" : 1}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerAddress')){
            body += '{"_v":"18.3","_resource_state" : "860cde3040519cce439cd99e209f8a87c3ad0b7e2813edbf6f5501f763b73bd5","_type":"customer_address","address_id":"my_home_address""salutation":"","title":"","company_name":"","first_name":"",';
            body += '"second_name":"","last_name":"","postal_code":"","address1":"","address2":"","city":"","post_box":"","country_code":"","state_code":"","phone":"","suffix":""}';
        }else if(this.callouttype.equalsIgnoreCase('CustomerDetailsNotFound')){
            body = '{"_v":"18.3","_type":"fault","fault":{"type":"CustomerListCustomerNotFoundException","message":"No customer with number 0815 for customer list 4711 was found."}}';
        }else{
            if (req.getEndpoint().endsWith('customer_search')) {
                //Found customer based on email id
                body = '{"_v":"17.8","_type":"customer_search_result","count":1,"hits":[{"_type":"customer_search_hit","data":{"_type":"customer","customer_no":"00018502"},"relevance":8.243810653686523}],"query":{"text_query":{"_type":"text_query","fields":["email"],"search_phrase":"nirajyadav@gmail2002.com"}},"start":0,"total":1}';
            }else if(req.getEndpoint().contains('/customers/')){
                //customer details
                body = '{"_resource_state": "5391ed5a7a479d5e7daacc73177a9215235401a68dc161cff49e50abe7558249",';
                body +='"_type": "customer","_v": "17.8","birthday": "1981-08-28","c_sscSyncResponseText": ["Successfully Exported"],';
                body +='"c_sscSyncStatus": "exported","c_sscid": "0011I00000QkVb5QAF", "creation_date": "2018-05-13T17:58:24.000Z", "credentials": {"_type": "credentials","enabled": false,"locked": false,"login": "nirajyadav@gmail606.com"},';
                body += '"customer_id": "ad5cpbLbK64iOkrhjDaYXibHFS","customer_no": "00030501","email": "nirajyadav@gmail6088.com", "first_name": "Neeraj", "last_login_time": "2018-05-14T12:24:47.000Z","last_modified": "2018-05-25T11:31:38.375Z",';
                body += '"last_name": "Yadav","last_visit_time": "2018-05-14T12:24:47.000Z","previous_login_time": "2018-05-14T12:24:47.000Z","previous_visit_time": "2018-05-14T12:24:47.000Z"}';
            }else{
                //default to order
                body = '{"_v":"17.8",';
                body += '"_type":"order","_resource_state":"f726660b5866272edba660b7efb5fcf6c096613b9f13c305352e2cc1b1e4fe05","adjusted_merchandize_total_tax":2.70,"adjusted_shipping_total_tax":0.30,';
                body += '"first_name":"fname","last_name":"lname","email":"test@gmail.com","billing_address":{"_type":"order_address","address1":"2555 MAIN ST","address2":"address","city":"Irvine",';
                body += '"country_code":"us","first_name":"Vinnie","full_name":"Vinnie Jones","id":"a21c94d653714e6f5c27f73370","last_name":"Jones","phone":"333-333-3333","postal_code":"92614","state_code":"CA"},';
                body += '"channel_type":"callcenter","confirmation_status":"not_confirmed","created_by":"admin","creation_date":"2017-08-18T13:38:01.000Z","currency":"USD","customer_info":{';
                body += '"_type":"customer_info","customer_id":"abYQGNjpuzk559PmDmM2gBBaIM","customer_name":"Vinnie Jones","customer_no":"00009001","email":"vinnie.jones@xaebo.com"},"customer_name":"Vinnie Jones",';
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
            }
        }
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(body);
        res.setStatusCode(200);
        return res;

    }

}
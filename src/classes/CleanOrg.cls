public class CleanOrg {

    public static void HT3() {

        List<SBQQ__ProductOption__c> OptionsToInsert = new List<SBQQ__ProductOption__c>();
        List<SBQQ__ProductFeature__c> FeaturesToInsert = new List<SBQQ__ProductFeature__c>();
        List<SBQQ__DiscountSchedule__c> DStoInsert = new List<SBQQ__DiscountSchedule__c>();
        SBQQ__DiscountSchedule__c DS = New SBQQ__DiscountSchedule__c(
            Name = 'T&E User Discount Schedule',
            SBQQ__Type__c = 'Range',
            SBQQ__DiscountUnit__c = 'Percent',
            SBQQ__CrossProducts__c = true,
            SBQQ__CrossOrders__c = true,
            SBQQ__PriceScale__c = 2,
            SBQQ__OverrideBehavior__c = 'All',
            SBQQ__QuoteLineQuantityField__c = 'Quantity'
        );
        DStoInsert.add(DS);
        SBQQ__DiscountSchedule__c DSR = New SBQQ__DiscountSchedule__c(
            Name = 'Finance and Reporting User Discount Schedule',
            SBQQ__Type__c = 'Range',
            SBQQ__DiscountUnit__c = 'Percent',
            SBQQ__CrossProducts__c = true,
            SBQQ__CrossOrders__c = true,
            SBQQ__PriceScale__c = 2,
            SBQQ__OverrideBehavior__c = 'All',
            SBQQ__QuoteLineQuantityField__c = 'Quantity'
        );
        DStoInsert.add(DSR);
        insert DStoInsert;
        List<SBQQ__DiscountTier__c> DTs = new List<SBQQ__DiscountTier__c>();
        SBQQ__DiscountTier__c DT1 = new SBQQ__DiscountTier__c(
                Name = '0-75',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 0,
                SBQQ__UpperBound__c = 76,
                SBQQ__Discount__c = 0,
                SBQQ__Number__c =1

            );
        DTs.add(DT1);
        SBQQ__DiscountTier__c DT2 = new SBQQ__DiscountTier__c(
                Name = '76-150',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 76,
                SBQQ__UpperBound__c = 151,
                SBQQ__Discount__c = 5,
                SBQQ__Number__c =2

            );
        DTs.add(DT2);
        SBQQ__DiscountTier__c DT3 = new SBQQ__DiscountTier__c(
                Name = '151-250',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 151,
                SBQQ__UpperBound__c = 251,
                SBQQ__Discount__c = 7.5,
                SBQQ__Number__c =3

            );
        DTs.add(DT3);
        SBQQ__DiscountTier__c DT4 = new SBQQ__DiscountTier__c(
                Name = '251-350',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 251,
                SBQQ__UpperBound__c = 351,
                SBQQ__Discount__c = 10,
                SBQQ__Number__c =4

            );
        DTs.add(DT4);
        SBQQ__DiscountTier__c DT5 = new SBQQ__DiscountTier__c(
                Name = '351-500',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 351,
                SBQQ__UpperBound__c = 501,
                SBQQ__Discount__c = 12.5,
                SBQQ__Number__c =5

            );
        DTs.add(DT5);
        SBQQ__DiscountTier__c DT6 = new SBQQ__DiscountTier__c(
                Name = '501-1000',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 501,
                SBQQ__UpperBound__c = 1001,
                SBQQ__Discount__c = 15,
                SBQQ__Number__c =6

            );
        DTs.add(DT6);
        SBQQ__DiscountTier__c DT7 = new SBQQ__DiscountTier__c(
                Name = '1000+',
                SBQQ__Schedule__c = DS.id,
                SBQQ__LowerBound__c = 1001,
                SBQQ__Discount__c = 20,
                SBQQ__Number__c =7

            );
        DTs.add(DT7);
              SBQQ__DiscountTier__c DT8 = new SBQQ__DiscountTier__c(
                Name = '1-10',
                SBQQ__Schedule__c = DSR.id,
                SBQQ__LowerBound__c = 1,
                SBQQ__UpperBound__c = 11,
                SBQQ__Discount__c = 15,
                SBQQ__Number__c =1

            );
        DTs.add(DT8);
        SBQQ__DiscountTier__c DT9 = new SBQQ__DiscountTier__c(
                Name = '11-25',
                SBQQ__Schedule__c = DSR.id,
                SBQQ__LowerBound__c = 11,
                SBQQ__UpperBound__c = 26,
                SBQQ__Discount__c = 10,
                SBQQ__Number__c =2

            );
        DTs.add(DT9);
        SBQQ__DiscountTier__c DT10 = new SBQQ__DiscountTier__c(
                Name = '26-50',
                SBQQ__Schedule__c = DSR.id,
                SBQQ__LowerBound__c = 26,
                SBQQ__UpperBound__c = 51,
                SBQQ__Discount__c = 20,
                SBQQ__Number__c =3

            );
        DTs.add(DT10);
        SBQQ__DiscountTier__c DT11 = new SBQQ__DiscountTier__c(
                Name = '50+',
                SBQQ__Schedule__c = DSR.id,
                SBQQ__LowerBound__c = 51,
                SBQQ__Discount__c = 25,
                SBQQ__Number__c =4

            );
        DTs.add(DT11);
        insert DTs;

        SBQQ__SummaryVariable__c SV1 = new SBQQ__SummaryVariable__c(
                Name = 'Count of T&E Reporting Licenses',
                SBQQ__TargetObject__c = 'Product Option',
                SBQQ__Scope__c = 'Quote',
                SBQQ__AggregateFunction__c = 'Sum',
                SBQQ__AggregateField__c ='Quantity',
                SBQQ__FilterField__c ='Product Code',
                SBQQ__FilterValue__c ='S-TE-FR',
                SBQQ__Operator__c ='equals'

            );
        insert SV1;
         SBQQ__SummaryVariable__c SV2 = new SBQQ__SummaryVariable__c(
                Name = 'Count of T&E Admin Training',
                SBQQ__TargetObject__c = 'Product Option',
                SBQQ__Scope__c = 'Quote',
                SBQQ__AggregateFunction__c = 'Sum',
                SBQQ__AggregateField__c ='Quantity',
                SBQQ__FilterField__c ='Product Code',
                SBQQ__FilterValue__c ='S-TE-ADTR',
                SBQQ__Operator__c ='equals'

            );
        insert SV2;
        
            System.debug('SOQL Count167 ' + Limits.getQueries());
            
            List<Product2> P = new List<Product2>();

        Product2 TE = new Product2(
            Name = 'Time and Expense SaaS Suite',
            ProductCode = 'S-TE-SAAS',
            Family = 'Bundle',
            Description = 'Time and Expense SaaS Suite',
            SBQQ__ConfigurationType__c = 'Required',
            SBQQ__ConfigurationEvent__c = 'Always',
            SBQQ__OptionSelectionMethod__c = 'Click',
            SBQQ__OptionLayout__c = 'Sections',
            SBQQ__Hidden__c = true,
            SBQQ__QuantityEditable__c = true,
            SBQQ__HidePriceInSearchResults__c = true,
            SBQQ__DefaultQuantity__c = 1,
            SBQQ__NonDiscountable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 0,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p2&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE);
        Product2 TE1 = new Product2(
            Name = 'T&E Suite Admin License',
            ProductCode = 'S-TE-ADM',
            Family = 'Software',
            Description = 'Subscription for one (1) Time and Expense Administrator.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__DefaultPricingTable__c = 'Standard',
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 1,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 80,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p7&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE1);
        Product2 TE2 = new Product2(
            Name = 'T&E Suite Time and Expense User License',
            ProductCode = 'S-TE-USER',
            Family = 'Software',
            Description = 'Subscription for one (1) Time and Expense user.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 1,
            SBQQ__DiscountSchedule__c= DS.Id,
            SBQQ__DefaultPricingTable__c = 'Standard',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 60,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p3&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE2);
        Product2 TE3 = new Product2(
            Name = 'T&E Suite Finance and Reporting License',
            ProductCode = 'S-TE-FR',
            Family = 'Software',
            Description = 'Subscription for one (1) Finance and Reporting user.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 1,
            SBQQ__DiscountSchedule__c= DSR.Id,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__DefaultPricingTable__c = 'Standard',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 25,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p5&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE3);
        Product2 TE4 = new Product2(
            Name = 'Report Exporting Tools',
            ProductCode = 'S-TE-REPX',
            Family = 'Software',
            Description = 'Module that enables the export of your Time and Expense data to Access, Excel, and JDBC Databases.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 7000,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p1&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE4);
        Product2 TE5 = new Product2(
            Name = 'Expense Reimbursement Block',
            ProductCode = 'S-TE-PAY',
            Family = 'Software',
            Description = 'Automatically Reimburse from Credit Card, ACH, or Wire Sources to ACH Accounts. Blocks of 1000 Expense Reports.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__PricingMethod__c= 'Block',
            SBQQ__ConfigurationType__c= 'Disabled',
            SBQQ__ConfigurationEvent__c= 'Always',
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 1000,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ok&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE5);
        Product2 TE6 = new Product2(
            Name = 'Additional Expense Report Fee',
            ProductCode = 'S-TE-ADDR',
            Family = 'Software',
            Description = 'Overage Rate per additional Expense Reports',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Monthly',
            SBQQ__PriceEditable__c = true,
            SBQQ__Component__c = true,
            SBQQ__ChargeType__c = 'Usage',
            Standard_Pricebook_Price__c = 1.25,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pA&oid=00D41000000emZ2'
            );
        P.add(TE6);
        
        Product2 TE7 = new Product2(
            Name = 'Expense Reimbursement Unlimited',
            ProductCode = 'S-TE-PAYU',
            Family = 'Software',
            Description = 'Automatically Reimburse an Unlimited Number of Expense Reports from Credit Card, ACH, or Wire Sources to ACH Accounts.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__NonDiscountable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 6000,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ok&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE7);
        Product2 TE8 = new Product2(
            Name = 'Billing Hours Tracking',
            ProductCode = 'S-TE-BILL',
            Family = 'Software',
            Description = 'This module allows users to reduce billing errors and eliminate inefficiencies with accurate time tracking.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 8000,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4oh&oid=00D41000000emZ2&lastMod=1478804178000'
            );
        P.add(TE8);
        Product2 TE9 = new Product2(
            Name = 'Project Cost Tracking',
            ProductCode = 'S-TE-COST',
            Family = 'Software',
            Description = 'Module to allow users to track project costs and ensure on-time project delivery.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 5000,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ow&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE9);
        Product2 TE10 = new Product2(
            Name = 'T&E Admin Training',
            ProductCode = 'S-TE-ADTR',
            Family = 'Services',
            Description = 'Online Admin Training for the Time & Expense Suite',
            SBQQ__QuantityEditable__c = true,
            SBQQ__ChargeType__c = 'One-Time',
            Standard_Pricebook_Price__c = 550,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p4&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE10);
        Product2 TE11 = new Product2(
            Name = 'T&E Training Portal for End Users',
            ProductCode = 'S-TE-UTP',
            Family = 'Services',
            Description = 'Online Time and Expense training for end users includes education and certification modules. Annual Subscription.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            SBQQ__DefaultPricingTable__c = 'Standard',
            Standard_Pricebook_Price__c = 8500,
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p8&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE11);
       
        Product2 TE12 = new Product2(
            Name = 'T&E Reporting Training Portal for End Users',
            ProductCode = 'S-TE-FTP',
            Family = 'Services',
            Description = 'Online Time and Expense Finance and Reporting training for end users includes education and certification modules. Annual Subscription.',
            SBQQ__QuantityEditable__c = true,
            SBQQ__SubscriptionType__c = 'Renewable',
            SBQQ__SubscriptionTerm__c = 12,
            SBQQ__SubscriptionPricing__c = 'Fixed Price',
            SBQQ__BillingFrequency__c = 'Annual',
            SBQQ__BillingType__c = 'Advance',
            SBQQ__ChargeType__c = 'Recurring',
            Standard_Pricebook_Price__c = 5500,
            SBQQ__DefaultPricingTable__c = 'Standard',
            Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4p6&oid=00D41000000emZ2&lastMod=1478804179000'
            );
        P.add(TE12);
        
        System.debug('SOQL Count 404 ' + Limits.getQueries());
        List<SBQQ__BlockPrice__c> InsertBlocks = new List<SBQQ__BlockPrice__c>();

       
        Product2 PS1 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ox&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Name = 'Quick Start Enablement', ProductCode = 'SV-QSE', Description = 'Basic Consulting package for implementation managed by 3rd party SI/Partner on Fixed Fee basis.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 5000);
        Product2 PS2 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pS&oid=00D41000000emZ2&lastMod=1478804180000', IsActive = true, Name = 'Professional Services Hours (Blended Rate)', ProductCode = 'SV-PSH', Description = 'Consulting implementation package managed by in-house professional services. Rate is a blended rate with both time and materials.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 225);
        Product2 PS3 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pU&oid=00D41000000emZ2&lastMod=1478804180000', IsActive = true, Name = 'Professional Services Scope of Work', ProductCode = 'SV-SOW', Description = 'Implementation managed by in-house professional services with an agreed upon scope of work.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = true, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 14000);
        Product2 PS4 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pT&oid=00D41000000emZ2&lastMod=1478804180000', IsActive = true, Name = 'Professional Services Project', ProductCode = 'SV-PRJ', Description = 'Custom Implementation managed by in-house professional services, charged on a Time and Material basis.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 0, SBQQ__ConfigurationType__c = 'Required', SBQQ__ConfigurationEvent__c = 'Always');
        Product2 PS5 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 250, Name = 'Data Normalization Expert', ProductCode = 'SV-DNE', Description = 'Data Normalization Experts engage early in the project and assist customers in normalizing, cleaning, and de-duping data, and can perform upload and update functions.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS6 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 100, Name = 'Implementation Engineer', ProductCode = 'SV-IMP', Description = 'Our certified Implementation Engineers bring a wealth of application expertise and integration experience to ensure the clients other systems are connected.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS7 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 225, Name = 'Integration Specialist Engineer', ProductCode = 'SV-ISE', Description = 'Our certified Integration Specialist Engineers bring a wealth of application expertise and integration experience to ensure the clients other systems are connected.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS8 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 525, Name = 'Module Extension Engineer', ProductCode = 'SV-MEE', Description = 'Our certified Module Extension Engineers specialize in configuring and customizing the additional modules to a clients specifications, and work closely with the Core System Engineers.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS9 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 525, Name = 'Program Director', ProductCode = 'SV-PD', Description = 'The Program Director provides executive leadership, subject matter expertise, and program oversight.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS10 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 170, Name = 'Project Manager', ProductCode = 'SV-PMN', Description = 'The Project Manager ensures a projects timely and efficient delivery by coordinating meetings, tracking progress, escalating issues, and proctoring weekly status reports.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS11 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 150, Name = 'Quality Assurance Engineer', ProductCode = 'SV-QAE', Description = 'Quality Assurance Engineers test and support the activities prior to a successful Go-Live launch.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS12 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 300, Name = 'Solutions Architect', ProductCode = 'SV-SAT', Description = 'Our Solution Architects are responsible for analyzing customer requirements and designing the optimal solution capabilities.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);

        P.add(PS1);
        P.add(PS2);
        P.add(PS3);
        P.add(PS4);
        P.add(PS5);
        P.add(PS6);
        P.add(PS7);
        P.add(PS8);
        P.add(PS9);
        P.add(PS10);
        P.add(PS11);
        P.add(PS12);
        
        insert P;
         SBQQ__Dimension__c MD1 = new SBQQ__Dimension__c(SBQQ__Product__c = TE11.Id, Name = 'Monthly Price Dimension');
        insert MD1;
        SBQQ__Dimension__c MD2 = new SBQQ__Dimension__c(SBQQ__Product__c = TE12.Id, Name = 'Monthly Price Dimension');
        insert MD2;
        
        
            for(Integer i = 1;i<=5; i++){
                integer UpperBound=0;
                if(i==5){
                    UpperBound=999999;
                }else{
                    UpperBound=i+1;
                }
                SBQQ__BlockPrice__c Block = new SBQQ__BlockPrice__c(
                        Name = String.valueof(i)+'000 Reports',
                        SBQQ__LowerBound__c=i,
                        SBQQ__UpperBound__c= UpperBound,
                        SBQQ__Price__c= (1000 + (i-1)*800),
                        SBQQ__Product__c = TE5.id


                    );

                InsertBlocks.add(Block);
            }
                
        

        insert InsertBlocks;
        List<SBQQ__ProductFeature__c> Features = new List<SBQQ__ProductFeature__c>();
        List<SBQQ__ProductOption__c> Options = new List<SBQQ__ProductOption__c>();

        SBQQ__ProductFeature__c F1 = new SBQQ__ProductFeature__c(Name = 'Project Management', SBQQ__MinOptionCount__c = 0, SBQQ__Number__c = 10, SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductFeature__c F2 = new SBQQ__ProductFeature__c(Name = 'Solution Architecture', SBQQ__MinOptionCount__c = 0, SBQQ__Number__c = 20, SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductFeature__c F3 = new SBQQ__ProductFeature__c(Name = 'Engineering Resources', SBQQ__MinOptionCount__c = 0, SBQQ__Number__c = 30, SBQQ__ConfiguredSKU__c = PS4.Id);

        Features.add(F1);
        Features.add(F2);
        Features.add(F3);

        insert Features;

        SBQQ__ProductOption__c PO1 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS9.Id, SBQQ__Feature__c = F1.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 110, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO2 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS10.Id, SBQQ__Feature__c = F1.Id, SBQQ__Selected__c = true, SBQQ__Required__c = true, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 120, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO3 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS12.Id, SBQQ__Feature__c = F2.Id, SBQQ__Selected__c = true, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 210, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO4 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS6.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 310, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 8, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO5 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS5.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 320, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO6 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS8.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 330, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 1, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO7 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS11.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 340, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO8 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS7.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 350, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);

        Options.add(PO1);
        Options.add(PO2);
        Options.add(PO3);
        Options.add(PO4);
        Options.add(PO5);
        Options.add(PO6);
        Options.add(PO7);
        Options.add(PO8);

        insert Options;



        //features

        SBQQ__ProductFeature__c Feature1 = new SBQQ__ProductFeature__c(
                Name='Licenses',
                SBQQ__MinOptionCount__c=1,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Number__c=10
            );
        insert Feature1;

        SBQQ__ProductFeature__c Feature2 = new SBQQ__ProductFeature__c(
                Name='Add-Ons',
                SBQQ__MinOptionCount__c=0,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Number__c=20
            );
        insert Feature2;

        SBQQ__ProductFeature__c Feature3 = new SBQQ__ProductFeature__c(
                Name='Training',
                SBQQ__MinOptionCount__c=0,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Number__c=30
            );
        insert Feature3;

        SBQQ__ProductFeature__c Feature4 = new SBQQ__ProductFeature__c(
                Name='Services',
                SBQQ__MinOptionCount__c=1,
                SBQQ__MaxOptionCount__c=1,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Number__c=40
            );
        insert Feature4;

        //Options
        SBQQ__ProductOption__c NewOp = new SBQQ__ProductOption__c(
                SBQQ__Number__c=100,
                SBQQ__Quantity__c=1,
                SBQQ__Selected__c=true,
                SBQQ__Required__c=true,
                SBQQ__ConfiguredSKU__c=TE5.Id,
                SBQQ__OptionalSKU__c=TE6.Id,
                SBQQ__Type__c='Accessory'
            );
        insert NewOp;

        SBQQ__ProductOption__c Option1 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=110,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=true,
                SBQQ__Selected__c=true,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Related Product',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE1.id,
                SBQQ__Feature__c= Feature1.id

            );
        insert Option1;
        SBQQ__ProductOption__c Option2 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=120,
                SBQQ__Quantity__c=350,
                SBQQ__QuantityEditable__c=true,
                SBQQ__Selected__c=true,
                SBQQ__Required__c=true,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Related Product',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE2.id,
                SBQQ__Feature__c= Feature1.id

            );
        insert Option2;
        SBQQ__ProductOption__c Option3 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=130,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=true,
                SBQQ__AppliedImmediatelyContext__c='On Selection',
                SBQQ__AppliedImmediately__c=true,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Related Product',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE3.id,
                SBQQ__Feature__c= Feature1.id

            );
        insert Option3;

        SBQQ__ProductOption__c Option4 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=210,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE4.id,
                SBQQ__Feature__c= Feature2.id

            );
        insert Option4;
        SBQQ__ProductOption__c Option5 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=220,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=true,
                SBQQ__Selected__c=true,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Accessory',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE5.id,
                SBQQ__Feature__c= Feature2.id

            );
        insert Option5;

        SBQQ__ProductOption__c Option6 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=230,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__MaxQuantity__c=5,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Accessory',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE7.id,
                SBQQ__Feature__c= Feature2.id

            );
        insert Option6;

        SBQQ__ProductOption__c Option7 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=240,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE8.id,
                SBQQ__Feature__c= Feature2.id

            );
        insert Option7;

        SBQQ__ProductOption__c Option8 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=250,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE9.id,
                SBQQ__Feature__c= Feature2.id

            );
        insert Option8;

        SBQQ__ProductOption__c Option9 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=310,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=true,
                SBQQ__Selected__c=true,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Related Product',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE10.id,
                SBQQ__Feature__c= Feature3.id

            );
        insert Option9;

        SBQQ__ProductOption__c Option10 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=320,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE11.id,
                SBQQ__Feature__c= Feature3.id

            );
        insert Option10;

        SBQQ__ProductOption__c Option11 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=330,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=TE12.id,
                SBQQ__Feature__c= Feature3.id

            );
        insert Option11;

        SBQQ__ProductOption__c Option12 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=410,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=PS1.id,
                SBQQ__Feature__c= Feature4.id

            );
        insert Option12;

        SBQQ__ProductOption__c Option13 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=420,
                SBQQ__Quantity__c=25,
                SBQQ__QuantityEditable__c=true,
                SBQQ__Selected__c=true,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Related Product',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=PS2.id,
                SBQQ__Feature__c= Feature4.id

            );
        insert Option13;

        SBQQ__ProductOption__c Option14 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=430,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=PS3.id,
                SBQQ__Feature__c= Feature4.id

            );
        insert Option14;

        SBQQ__ProductOption__c Option15 = new SBQQ__ProductOption__c(
                SBQQ__Number__c=440,
                SBQQ__Quantity__c=1,
                SBQQ__QuantityEditable__c=false,
                SBQQ__Selected__c=false,
                SBQQ__Required__c=false,
                SBQQ__Bundled__c=false,
                SBQQ__Type__c='Component',
                SBQQ__ConfiguredSKU__c=TE.id,
                SBQQ__OptionalSKU__c=PS4.id,
                SBQQ__Feature__c= Feature4.id

            );
        insert Option15;

        //Option Constraints
        SBQQ__OptionConstraint__c Constraint1 = new SBQQ__OptionConstraint__c(
                Name='Block and Unlimited Exclusion',
                SBQQ__ConstrainedOption__c=Option5.Id,
                SBQQ__ConstrainingOption__c=Option6.Id,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Type__c='Exclusion'
            );
        insert Constraint1;
        SBQQ__OptionConstraint__c Constraint2 = new SBQQ__OptionConstraint__c(
                Name='User Training Needs Admin Training',
                SBQQ__ConstrainedOption__c=Option10.Id,
                SBQQ__ConstrainingOption__c=Option9.Id,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Type__c='Dependency'
            );
        insert Constraint2;
        SBQQ__OptionConstraint__c Constraint3 = new SBQQ__OptionConstraint__c(
                Name='Reporting User Training Needs Admin Training',
                SBQQ__ConstrainedOption__c=Option11.Id,
                SBQQ__ConstrainingOption__c=Option9.Id,
                SBQQ__ConfiguredSKU__c=TE.Id,
                SBQQ__Type__c='Dependency'
            );
        insert Constraint3;
        //Product Rules
        SBQQ__ProductRule__c Rule1 = new SBQQ__ProductRule__c(
                Name='Show Reporting Products when Reporting License Count Greater than 0',
                SBQQ__ConditionsMet__c='All',
                SBQQ__Scope__c='Product',
                SBQQ__EvaluationEvent__c='Always',
                SBQQ__Type__c='Selection',
                SBQQ__Active__c = true
            );
        insert Rule1;

         SBQQ__ProductRule__c Rule2 = new SBQQ__ProductRule__c(
                Name='Hide Reporting Products when Reporting License Count Equals 0',
                SBQQ__ConditionsMet__c='All',
                SBQQ__Scope__c='Product',
                SBQQ__EvaluationEvent__c='Always',
                SBQQ__Type__c='Selection',
                SBQQ__Active__c = true
            );
        insert Rule2;

        SBQQ__ProductRule__c Rule3 = new SBQQ__ProductRule__c(
                Name='Recommend Admin Training',
                SBQQ__ConditionsMet__c='All',
                SBQQ__Scope__c='Product',
                SBQQ__EvaluationEvent__c='Always',
                SBQQ__Type__c='Alert',
                SBQQ__ErrorMessage__c='Recommendation:  It is suggested that net new implementations have administrative training.',
                SBQQ__Active__c = true
            );
        insert Rule3;
        //Error Conditions

        SBQQ__ErrorCondition__c Condition1 = new SBQQ__ErrorCondition__c(
                SBQQ__Rule__c = Rule1.Id,
                SBQQ__TestedVariable__c=SV1.Id,
                SBQQ__Operator__c='greater than',
                SBQQ__FilterType__c='Value',
                SBQQ__FilterValue__c='0'
            );
        insert Condition1;

        SBQQ__ErrorCondition__c Condition2 = new SBQQ__ErrorCondition__c(
                SBQQ__Rule__c= Rule2.Id,
                SBQQ__TestedVariable__c=SV1.Id,
                SBQQ__Operator__c='equals',
                SBQQ__FilterType__c='Value',
                SBQQ__FilterValue__c='0'
            );
        insert Condition2;

        SBQQ__ErrorCondition__c Condition3 = new SBQQ__ErrorCondition__c(
                SBQQ__Rule__c= Rule3.Id,
                SBQQ__TestedVariable__c=SV2.Id,
                SBQQ__Operator__c='equals',
                SBQQ__FilterType__c='Value',
                SBQQ__FilterValue__c='0'
            );
        insert Condition3;

        //Product Actions

        SBQQ__ProductAction__c Action1 = new SBQQ__ProductAction__c(
                SBQQ__Rule__c= Rule1.Id,
                SBQQ__Type__c='Show & Add',
                SBQQ__Product__c=TE4.Id
            );
        insert Action1;

        SBQQ__ProductAction__c Action2 = new SBQQ__ProductAction__c(
                SBQQ__Rule__c= Rule1.Id,
                SBQQ__Type__c='Show',
                SBQQ__Product__c=TE12.Id
            );
        insert Action2;

         SBQQ__ProductAction__c Action3 = new SBQQ__ProductAction__c(
                SBQQ__Rule__c= Rule2.Id,
                SBQQ__Type__c='Hide & Remove',
                SBQQ__Product__c=TE4.Id
            );
        insert Action3;

        SBQQ__ProductAction__c Action4 = new SBQQ__ProductAction__c(
                SBQQ__Rule__c= Rule2.Id,
                SBQQ__Type__c='Hide & Remove',
                SBQQ__Product__c=TE12.Id
            );
        insert Action4;

        //Configuration Rules

        SBQQ__ConfigurationRule__c CR1 = new SBQQ__ConfigurationRule__c(
                SBQQ__Active__c= true,
                SBQQ__ProductRule__c= Rule1.Id,
                SBQQ__Product__c=TE.Id
            );
        insert CR1;    

        SBQQ__ConfigurationRule__c CR2 = new SBQQ__ConfigurationRule__c(
                SBQQ__Active__c= true,
                SBQQ__ProductRule__c= Rule2.Id,
                SBQQ__Product__c=TE.Id
            );
        insert CR2;  

        SBQQ__ConfigurationRule__c CR3 = new SBQQ__ConfigurationRule__c(
                SBQQ__Active__c= true,
                SBQQ__ProductRule__c= Rule3.Id,
                SBQQ__Product__c=TE.Id
            );
        insert CR3;     


        List<Product2> pdProds = new List<Product2>();
        pdProds.add(TE1);
        pdProds.add(TE2);
        pdProds.add(TE3);
        
        List<SBQQ__Dimension__c> PDs = new List<SBQQ__Dimension__c>();
        
            for(Product2 Prod : pdProds){
                SBQQ__Dimension__c NewPD = New SBQQ__Dimension__c(
                    name = 'Yearly Price Dimension',
                    SBQQ__Type__c = 'Year',
                    SBQQ__Product__c = Prod.Id
                    );
                PDs.add(newPD);
            }
        

        insert PDs;




    }
    public static void profServ() {

        Product2 PS1 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ox&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Name = 'Quick Start Enablement', ProductCode = 'SV-QSE', Description = 'Basic Consulting package for implementation managed by 3rd party SI/Partner on Fixed Fee basis.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 5000);
        Product2 PS2 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pS&oid=00D41000000emZ2&lastMod=1478804180000', IsActive = true, Name = 'Professional Services Hours (Blended Rate)', ProductCode = 'SV-PSH', Description = 'Consulting implementation package managed by in-house professional services. Rate is a blended rate with both time and materials.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 225);
        Product2 PS3 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pU&oid=00D41000000emZ2&lastMod=1478804180000', IsActive = true, Name = 'Professional Services Scope of Work', ProductCode = 'SV-SOW', Description = 'Implementation managed by in-house professional services with an agreed upon scope of work.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = true, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 14000);
        Product2 PS4 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4pT&oid=00D41000000emZ2&lastMod=1478804180000', IsActive = true, Name = 'Professional Services Project', ProductCode = 'SV-PRJ', Description = 'Custom Implementation managed by in-house professional services, charged on a Time and Material basis.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true, Standard_Pricebook_Price__c = 0, SBQQ__ConfigurationType__c = 'Required', SBQQ__ConfigurationEvent__c = 'Always');
        Product2 PS5 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 250, Name = 'Data Normalization Expert', ProductCode = 'SV-DNE', Description = 'Data Normalization Experts engage early in the project and assist customers in normalizing, cleaning, and de-duping data, and can perform upload and update functions.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS6 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 100, Name = 'Implementation Engineer', ProductCode = 'SV-IMP', Description = 'Our certified Implementation Engineers bring a wealth of application expertise and integration experience to ensure the clients other systems are connected.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS7 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 225, Name = 'Integration Specialist Engineer', ProductCode = 'SV-ISE', Description = 'Our certified Integration Specialist Engineers bring a wealth of application expertise and integration experience to ensure the clients other systems are connected.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS8 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 525, Name = 'Module Extension Engineer', ProductCode = 'SV-MEE', Description = 'Our certified Module Extension Engineers specialize in configuring and customizing the additional modules to a clients specifications, and work closely with the Core System Engineers.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS9 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 525, Name = 'Program Director', ProductCode = 'SV-PD', Description = 'The Program Director provides executive leadership, subject matter expertise, and program oversight.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS10 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 170, Name = 'Project Manager', ProductCode = 'SV-PMN', Description = 'The Project Manager ensures a projects timely and efficient delivery by coordinating meetings, tracking progress, escalating issues, and proctoring weekly status reports.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS11 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 150, Name = 'Quality Assurance Engineer', ProductCode = 'SV-QAE', Description = 'Quality Assurance Engineers test and support the activities prior to a successful Go-Live launch.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);
        Product2 PS12 = new Product2(Product_Picture_ID_URL__c = 'https://c.na35.content.force.com/servlet/servlet.ImageServer?id=01541000000H4ov&oid=00D41000000emZ2&lastMod=1478804179000', IsActive = true, Standard_Pricebook_Price__c = 300, Name = 'Solutions Architect', ProductCode = 'SV-SAT', Description = 'Our Solution Architects are responsible for analyzing customer requirements and designing the optimal solution capabilities.', Family = 'Services', SBQQ__ChargeType__c = 'One-Time', SBQQ__QuantityEditable__c = true, SBQQ__PriceEditable__c = false, SBQQ__NonDiscountable__c = true);

        Database.insert(PS1);
        Database.insert(PS2);
        Database.insert(PS3);
        Database.insert(PS4);
        Database.insert(PS5);
        Database.insert(PS6);
        Database.insert(PS7);
        Database.insert(PS8);
        Database.insert(PS9);
        Database.insert(PS10);
        Database.insert(PS11);
        Database.insert(PS12);

        SBQQ__ProductFeature__c F1 = new SBQQ__ProductFeature__c(Name = 'Project Management', SBQQ__MinOptionCount__c = 0, SBQQ__Number__c = 10, SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductFeature__c F2 = new SBQQ__ProductFeature__c(Name = 'Solution Architecture', SBQQ__MinOptionCount__c = 0, SBQQ__Number__c = 20, SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductFeature__c F3 = new SBQQ__ProductFeature__c(Name = 'Engineering Resources', SBQQ__MinOptionCount__c = 0, SBQQ__Number__c = 30, SBQQ__ConfiguredSKU__c = PS4.Id);

        Database.insert(F1);
        Database.insert(F2);
        Database.insert(F3);

        SBQQ__ProductOption__c PO1 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS9.Id, SBQQ__Feature__c = F1.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 110, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO2 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS10.Id, SBQQ__Feature__c = F1.Id, SBQQ__Selected__c = true, SBQQ__Required__c = true, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 120, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO3 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS12.Id, SBQQ__Feature__c = F2.Id, SBQQ__Selected__c = true, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 210, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO4 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS6.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 310, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 8, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO5 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS5.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 320, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO6 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS8.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 330, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 1, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO7 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS11.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 340, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);
        SBQQ__ProductOption__c PO8 = new SBQQ__ProductOption__c(SBQQ__OptionalSKU__c = PS7.Id, SBQQ__Feature__c = F3.Id, SBQQ__Selected__c = false, SBQQ__Required__c = false, SBQQ__QuantityEditable__c = true, SBQQ__Number__c = 350, SBQQ__Quantity__c = 8, SBQQ__MinQuantity__c = 2, SBQQ__Type__c = 'Related Product', SBQQ__ConfiguredSKU__c = PS4.Id);

        Database.insert(PO1);
        Database.insert(PO2);
        Database.insert(PO3);
        Database.insert(PO4);
        Database.insert(PO5);
        Database.insert(PO6);
        Database.insert(PO7);
        Database.insert(PO8);


    }
    public static Boolean ClearProducts() {
        //Products
        SBQQ.TriggerControl.disable();
        Product2[] ProductsToDelete = [SELECT Id FROM Product2];
        Set<Id> ProductIds = new Set<Id>();
        for (Product2 q : ProductsToDelete) {
            ProductIds.add(q.Id);
        }
        Database.delete(ProductsToDelete);
        /**Thresholds
        Approval_Threshold__c[] AppsToDelete = [SELECT Id FROM Approval_Threshold__c];
        Set<Id> AppIds = new Set<Id>();
        for (Approval_Threshold__c q : AppsToDelete) {
            AppIds.add(q.Id);
        }
        Database.delete(AppsToDelete);
        **/
        //Features
        SBQQ__ProductFeature__c[] ProductFeaturesToDelete = [SELECT Id FROM SBQQ__ProductFeature__c];
        Set<Id> ProductFeatureIds = new Set<Id>();
        for (SBQQ__ProductFeature__c q : ProductFeaturesToDelete) {
            ProductFeatureIds.add(q.Id);
        }
        Database.delete(ProductFeaturesToDelete);
    //options
        SBQQ__ProductOption__c[] ProductOpsToDelete = [SELECT Id FROM SBQQ__ProductOption__c];
        Set<Id> ProductOPIds = new Set<Id>();
        for (SBQQ__ProductOption__c q : ProductOpsToDelete) {
            ProductOPIds.add(q.Id);
        }
        Database.delete(ProductOpsToDelete);
        SBQQ__BlockPrice__c[] bpDelete = [SELECT Id FROM SBQQ__BlockPrice__c];
        delete bpDelete;
        
        SBQQ__Dimension__c[] DeleteDim = [SELECT Id FROM SBQQ__Dimension__c];
        delete DeleteDim;
        SBQQ.TriggerControl.enable();

        return true;
    }
    public static Boolean ClearTerms() {
        //Products
        SBQQ__QuoteTerm__c[] ProductsToDelete = [SELECT Id FROM SBQQ__QuoteTerm__c];
        Set<Id> ProductIds = new Set<Id>();
        for (SBQQ__QuoteTerm__c q : ProductsToDelete) {
            ProductIds.add(q.Id);
        }
        Database.delete(ProductsToDelete);
        return true;
    }

    public static Boolean ClearRecords() {
        //Quotelines
        SBQQ__QuoteLine__c[] quotelinesToDelete = [SELECT Id FROM SBQQ__QuoteLine__c];
        Set<Id> quotelineIds = new Set<Id>();
        for (SBQQ__QuoteLine__c q : quotelinesToDelete) {
            quotelineIds.add(q.Id);
        }
        Database.delete(quotelinesToDelete);
        //Quotes
        SBQQ__Quote__c[] quotesToDelete = [SELECT Id FROM SBQQ__Quote__c];
        Set<Id> quoteIds = new Set<Id>();
        for (SBQQ__Quote__c q : quotesToDelete) {
            quoteIds.add(q.Id);
        }
        Database.delete(quotesToDelete);
        //Opps
        Opportunity[] OppsToDelete = [SELECT Id FROM Opportunity];
        Set<Id> OppIds = new Set<Id>();
        for (Opportunity q : OppsToDelete) {
            OppIds.add(q.Id);
        }
        Database.delete(OppsToDelete);
        //Subs
        SBQQ__Subscription__c[] SubsToDelete = [SELECT Id FROM SBQQ__Subscription__c];
        Set<Id> SubIds = new Set<Id>();
        for (SBQQ__Subscription__c q : SubsToDelete) {
            SubIds.add(q.Id);
        }
        Database.delete(SubsToDelete);
        //Assets
        Asset[] AssetsToDelete = [SELECT Id FROM Asset];
        Set<Id> AssetIds = new Set<Id>();
        for (Asset q : AssetsToDelete) {
            AssetIds.add(q.Id);
        }
        Database.delete(AssetsToDelete);
        //Contracts
        Contract[] ContractsToDelete = [SELECT Id FROM Contract];
        Set<Id> ContractIds = new Set<Id>();
        for (Contract q : ContractsToDelete) {
            ContractIds.add(q.Id);
        }
        Database.delete(ContractsToDelete);


        return true;
    }

    public static void DefaultTerms() {

        List<SBQQ__QuoteTerm__c> QTs = new List<SBQQ__QuoteTerm__c>();
        SBQQ__QuoteTerm__c QT1 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT1.SBQQ__PrintOrder__c = 1;
        QT1.SBQQ__Body__c = 'THIS MASTER SUBSCRIPTION AGREEMENT (AGREEMENT ) GOVERNS YOUR USE OF OUR SERVICES, AS FURTHER DEFINED BELOW.<br><br>IF YOU PURCHASE SUBSCRIPTIONS TO OUR APPLICATIONS AND/OR RELATED SERVICES, THIS AGREEMENT WILL ALSO GOVERN YOUR PURCHASE AND ACQUISITION OF SUCH SUBSCRIPTIONS AND/OR RELATED SERVICES AND YOUR ONGOING USE OF THOSE SUBSCRIPTIONS AND THE SERVICES.<br><br>BY ACCEPTING THIS AGREEMENT, YOU AGREE TO THE TERMS OF THIS AGREEMENT. IF YOU ARE ENTERING INTO THIS AGREEMENT ON BEHALF OF A COMPANY OR OTHER LEGAL ENTITY, YOU REPRESENT THAT YOU HAVE THE AUTHORITY TO BIND SUCH ENTITY AND ITS AFFILIATES TO THESE TERMS AND CONDITIONS, IN WHICH CASE THE TERMS &quot;YOU&quot; OR &quot;YOUR&quot; SHALL REFER TO SUCH ENTITY AND ITS AFFILIATES. IF YOU DO NOT HAVE SUCH AUTHORITY, OR IF YOU DO NOT AGREE WITH THESE TERMS AND CONDITIONS, YOU MUST NOT ACCEPT THIS AGREEMENT AND MAY NOT USE THE SERVICES.<br>';
        QTs.add(QT1);

        SBQQ__QuoteTerm__c QT2 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT2.SBQQ__PrintOrder__c = 2;
        QT2.SBQQ__Body__c = '<b>DEFINITIONS</b><br>&quot;Affiliate&quot; means any entity which directly or indirectly controls, is controlled by, or is under common control with the subject entity. &quot;Control,&quot; for purposes of this definition, means direct or indirect ownership or control of more than 50% of the voting interests of the subject entity.<br><br>&quot;Agreement&quot;  means this Master Subscription Agreement.<br><br>&quot;Documentation&quot;  means Our online help and training materials for the Services accessible via Our portals as updated from time to time.<br><br>&quot;Malicious Code&quot; means code, files, scripts, agents or programs intended to do harm, including, for example, viruses, worms, time bombs and Trojan horses.<br><br>&quot;Order Form&quot; means the ordering documents for purchases hereunder, including addenda thereto, that are entered into between You and Us from time to time. By entering into an Order Form hereunder, an Affiliate agrees to be bound by the terms of this Agreement as if it were an original party hereto. Order Forms shall be deemed incorporated herein by reference.<br><br>&quot;Purchased Services&quot; means Services that You or Your Affiliates purchase under an Order Form, as distinguished from those provided pursuant to a free trial.<br><br>&quot;Services&quot; means the online, Web-based applications and platform provided by Us via or other designated websites as described in the Documentation, that are ordered by You or Your Affiliates as part of a free trial or under an Order Form, including any associated offline components but excluding Third-Party Applications.<br><br>&quot;Subscription Term&quot; means the period of time from the start date to the end date specified in each Order Form for each subscription purchased thereunder. Each renewal of a subscription, whether automatic or in writing, shall constitute a new Subscription Term.<br><br>&quot;Third-Party Applications&quot; means online, Web-based applications and offline software products that are provided by third parties but may be configured to interoperate with the Services.<br><br>&quot;Users&quot; means individuals who are authorized by You to use the Services, for whom subscriptions to the Services have been purchased, and who have been supplied user identifications and passwords by You. Users may include but are not limited to Your employees, consultants, contractors, and agents.<br><br>&quot;We&quot;, &quot;Us&quot;, or &quot;Our&quot; means {!template.SBQQ__CompanyName__c}.<br><br>&quot;You&quot; or &quot;Your&quot; means the company or other legal entity for which You are accepting this Agreement, and Affiliates of that company or entity.<br>';
        QTs.add(QT2);

        SBQQ__QuoteTerm__c QT3 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT3.SBQQ__PrintOrder__c = 3;
        QT3.SBQQ__Body__c = '<b>PURCHASED SERVICES<br>Provision of Purchased Services.</b> We shall make the Purchased Services available to You pursuant to this Agreement and the relevant Order Forms during each Subscription Term and your timely payment of all applicable fees. You agree that Your purchases hereunder are neither contingent on the delivery of any future functionality or features nor dependent on any oral or written public comments made by Us regarding future functionality or features.';
        QTs.add(QT3);

        SBQQ__QuoteTerm__c QT4 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT4.SBQQ__PrintOrder__c = 4;
        QT4.SBQQ__Body__c = '<b>FEES AND PAYMENT FOR SERVICES</b><br><b>User Fees.</b> You shall pay all fees specified in all Order Forms hereunder. Except as otherwise specified herein or in an Order Form, (a) fees are quoted and payable in United States dollars, (b) fees are based on services purchased and not actual usage, (c) payment obligations are non-cancellable and fees paid are non-refundable, and (d) the number of User subscriptions purchased cannot be decreased during the relevant subscription term stated on the Order Form. User subscription fees are based on annual periods that begin on the subscription start date and each year anniversary thereof; fees for User subscriptions added in the middle of a yearly period will be prorated based on the month in which they are added and thereafter will be charge for the full yearly periods remaining in the subscription term.<br> <br><b>Invoicing and Payment.</b> Fees will be invoiced in advance and otherwise in accordance with the relevant Order Form. Unless otherwise stated in the Order Form, fees are due {!quote.SBQQ__PaymentTerms__c} days from the invoice date. You are responsible for maintaining complete and accurate billing and contact information with Us, as well as for payment of any fees or charges associated with Your payment, other than those charged by Our bank.<br> <br><b>Overdue Charges.</b> If any fees are not received from You by the due date, then at Our discretion, (a) such fees may accrue late interest at the rate of 1.5% of the outstanding balance per month, or the maximum rate permitted by law, whichever is lower, from the date such payment was due until the date paid and/or (b) We may condition future subscriptions on payment terms shorter than those specified in Section 4.2 (Invoicing and Payment).<br><br><b>Suspension of Services.</b> If any amount owing by You under this Agreement for the Services is 30 or more days overdue, We may, without limiting Our other rights and remedies, suspend Your access to the Services until such amounts are paid in full.<br> <br><b>Payment Disputes.</b> We shall not exercise Our rights under Section 4.3 (Overdue Charges) or 4.4 (Suspension of Services) until after 60 days from the payment due date if the applicable fees are under reasonable and good-faith dispute and You are cooperating diligently to resolve the dispute.<br> <br><b>Taxes.</b> Unless otherwise stated, Our fees do not include any taxes, levies, duties, or similar governmental assessments of any nature, including but not limited to value-added, sales, use, or withholding taxes, assessable by any local, state, provincial, federal, or foreign jurisdiction (collectively, &quot;Taxes&quot;). You are responsible for paying all Taxes associated with Your purchases hereunder. If We have the legal obligation to pay or collect Taxes for which You are responsible under this Section 4.6, the appropriate amount shall be invoiced to and paid by You, unless You provide Us with a valid tax exemption certificate authorized by the appropriate taxing authority. For clarity, We are solely responsible for taxes assessable against Us based on Our income, property, and employees.<br><br>';
        QTs.add(QT4);

        SBQQ__QuoteTerm__c QT5 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT5.SBQQ__PrintOrder__c = 5;
        QT5.SBQQ__Body__c = '<b>USE OF THE SERVICES<br>Our Responsibilities.</b> In addition to providing the Purchased Services as described, We shall provide You with standard support, in accordance with Our then-current support policy for the Purchased Services, during the applicable Subscription Term and at no additional charge.<br><br><b>Your Responsibilities.</b> You shall (a) be responsible for Users compliance with this Agreement, (b) be solely responsible for the accuracy, quality, integrity, and legality of Your Data and of the means by which You acquired Your Data, (c) use commercially reasonable efforts to prevent unauthorized access to or use of the Services, and notify Us promptly of any such unauthorized access or use, and (d) use the Services only in accordance with the Documentation and applicable laws and government regulations.<br><br><b>Your Data.</b> The Services access and process Your Data in order to generate reports, analyses, documents, and/or results. If You choose to save such output, it will be saved as Your Data. However, Your ability to recreate or duplicate such output will cease upon expiration or termination of this Agreement. We will not access Your Data except; (a) at Your request, to provide technical support or to assist in the implementation or configuration of the Services; or (b) as compelled by law in accordance with Section (Compelled Disclosure).<br><br>';
        QTs.add(QT5);

        SBQQ__QuoteTerm__c QT6 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT6.SBQQ__PrintOrder__c = 6;
        QT6.SBQQ__Body__c = '<b>User Subscriptions.</b> Unless otherwise specified in the applicable Order Form, (i) Purchased Services are purchased as User subscriptions and may be accessed by no more than the specified number of Users, (ii) additional User subscriptions may be purchased during the Subscription Term by signing an additional Order Form and paying the additional fees for such additional User subscriptions, prorated for the portion of that Subscription Term remaining at the time the Subscriptions are added and (iii) the added User subscriptions shall terminate on the same date as the underlying subscriptions.<br>';
        QTs.add(QT6);

        SBQQ__QuoteTerm__c QT7 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT7.SBQQ__PrintOrder__c = 7;
        QT7.SBQQ__Body__c = '<b>PROPRIETARY RIGHTS<br>Reservation of Rights.</b> Subject to the limited rights expressly granted hereunder, We and Our licensors reserve all rights, title, and interest in and to the Services, including all related intellectual property rights. No rights are granted to You hereunder other than as expressly set forth herein.<br><br><b>Ownership of Your Data. </b>As between Us and You, You exclusively own all rights, title, and interest in and to all of Your Data.<br><br><b>Suggestions.</b> We shall have a royalty-free, worldwide, transferable, sublicenseable, irrevocable, perpetual license to use or incorporate into the Services any suggestions, enhancement requests, recommendations, correction or other feedback provided by You, including Users, relating to the functionality and/or operation of the Services.<br>';
        QTs.add(QT7);

        SBQQ__QuoteTerm__c QT8 = new SBQQ__QuoteTerm__c(SBQQ__Active__c = true, SBQQ__Locked__c = false, SBQQ__ConditionsMet__c = 'All', SBQQ__Status__c = 'Approved');
        QT8.SBQQ__PrintOrder__c = 8;
        QT8.SBQQ__Body__c = '<b>LIMITATION OF LIABILITY<br>Limitation of Liability.</b> EXCEPT FOR A PARTY&#39;S INDEMNIFICATION OBLIGATIONS UNDER SECTION 9 (MUTUAL INDEMNIFICATION), IN NO EVENT SHALL EITHER PARTY&#39;S AGGREGATE LIABILITY ARISING OUT OF OR RELATED TO THIS AGREEMENT, WHETHER IN CONTRACT, TORT OR UNDER ANY OTHER THEORY OF LIABILITY, EXCEED THE TOTAL AMOUNT PAID BY YOU HEREUNDER OR, WITH RESPECT TO ANY SINGLE INCIDENT THE AMOUNT PAID BY YOU HEREUNDER IN THE 12 MONTHS PRECEDING THE INCIDENT.<br><br><b>Exclusion of Consequential and Related Damages.</b> IN NO EVENT SHALL EITHER PARTY HAVE ANY LIABILITY TO THE OTHER PARTY FOR ANY LOST PROFITS OR REVENUES OR FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, COVER, OR PUNITIVE DAMAGES HOWEVER CAUSED, WHETHER IN CONTRACT, TORT, OR UNDER ANY OTHER THEORY OF LIABILITY, AND WHETHER OR NOT THE PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES. THE FOREGOING DISCLAIMER SHALL NOT APPLY TO THE EXTENT PROHIBITED BY APPLICABLE LAW.<br>';
        QTs.add(QT8);
        Database.insert(QTs);
        List<SBQQ__TermCondition__c> TermCs = new List<SBQQ__TermCondition__c>();
        SBQQ__TermCondition__c TC = new SBQQ__TermCondition__c(SBQQ__Operator__c = 'greater than', SBQQ__Value__c = '0', SBQQ__QuoteTerm__c = QTs.get(5).Id);
        TC.SBQQ__TestedVariable__c = [SELECT Id FROM SBQQ__SummaryVariable__c WHERE Name = 'Subs' LIMIT 1].Id;
        TermCs.add(TC);
        Database.insert(TermCs);
    }

    /**private Boolean DeleteQuotes() {
          Id a = this.AccountId;
          SBQQ__Quote__c[] quotesToDelete = [SELECT Id FROM SBQQ__Quote__c WHERE SBQQ__Account__r.Id = :a];
          Set<Id> quoteIds = new Set<Id>();
          for (SBQQ__Quote__c q : quotesToDelete) {
              quoteIds.add(q.Id);
          }
          this.DeleteProcessInputValues(quoteIds);
          Database.delete(quotesToDelete);
          return TRUE;
      }**/
}
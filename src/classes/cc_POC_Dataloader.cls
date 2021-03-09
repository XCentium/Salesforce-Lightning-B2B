/**
 * Created by michael.sobczak on 4/9/18.
 *
 * Also requires parseCSV.cls
 */

public with sharing class cc_POC_Dataloader {

    public String csvFileName {get;set;}
    public Blob csvData {get;set;}
    public List<String> fieldList {get;set;}
    public Set<String> dataStrings {get;set;}
    public Integer errorCounter {get;set;}
    public Boolean hasError {get; set;}
    public Boolean hasFile {get;set;}

    public Integer totProc {get; set;}

    public String selectedStorefront {get; set;}
    public String selectedPriceList1 {get; set;}
    public String selectedPriceList2 {get; set;}
    public String selectedPriceList3 {get; set;}
    public String selectedRootCategoryId {get; set;}
    public String selectedRootCategoryObjId {get; set;}

    public Map<Id, String> priceListNames {get; set;}

    public List<DataRecord> dataList {get;set;}

    Set<String> errorList = new Set<String>();
    public Map<Integer, List<String>> errorMap {get; set;}

    public Boolean productImageCloneExists {get; set;}


    // Map of all categories that descend from the root
    Map<Id, Category> categoryMap = new Map<Id, Category>();

    // Create Map of branches
    Map<String, Category> categoryBranchMap = new Map<String, Category>();

    Map<Id, List<Id>> parentCategoryMap = new Map<Id, List<Id>>();


    public Set<String> relatedProductTypes = new Set<String>{'Accessories', 'Competitive', 'Complementary',
            'CrossSell', 'Plugins', 'Related', 'RequiredItem', 'UpSell'};

    public Set<String> specFiltertypes = new Set<String>{'Checkbox', 'Slider'};

    public Set<String> mediaTypes = new Set<String>{
            'Product Image',
            'Product Image Thumbnail',
            'Product Search Image',
            'Alternate Images',
            'SVG Interactive Diagram',
            'Datasheets',
            'Alternate Thumbnails',
            'Safety Documents',
            'Sales Brochures',
            'Owner\'s Manuals',
            'Assembly Guides',
            'JPG Image',
            'Flash Files',
            'Media'};

    public Set<String> defaultMediaTypes = new Set<String>{
            'Product Image',
            'Product Image Thumbnail',
            'Product Search Image'};

    public Set<String> mediaSources = new Set<String>{
            'Attachment',
            'Static Resource',
            'URI'
    };

    public cc_POC_Dataloader() {

        fieldList = new List<String>();
        dataList = new List<DataRecord>();
        hasFile = false;

        priceListNames = new Map<Id, String>();

        productImageCloneExists = this.doesMediaProcessFlowExist();

        System.debug('productImageCloneExists: ' + productImageCloneExists);

        clearErrors();

    }

    private void resetFields () {

        csvData = null;
        fieldList = new List<String>();
        dataList = new List<DataRecord>();
        hasFile = false;
    }

    public void getPriceListNames () {

        System.debug('begin getPriceListNames');

        priceListNames = new Map<Id, String>();

        System.debug('selectedStorefront: ' + selectedStorefront);

        List<ccrz__E_PriceList__c> priceLists = [SELECT Id, Name
        FROM ccrz__E_PriceList__c
        WHERE ccrz__Enabled__c = TRUE
        AND ccrz__Storefront__c INCLUDES(:selectedStorefront)
        ORDER BY Name];

        for(ccrz__E_PriceList__c priceList : priceLists) {
            priceListNames.put(priceList.Id, priceList.Name);
        }

        System.debug('priceListNames: ' + priceListNames);

        System.debug('exit getPriceListNames');

    }

    /*
        This method is invoked via the VF page.
     */
    public List<SelectOption> getPriceListOptions()
    {
        System.debug('begin getPriceListOptions');

        getPriceListNames();

        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','-- Select --'));

        for(Id key : priceListNames.keySet()){
            String priceListName = priceListNames.get(key);
            options.add(new SelectOption(key, priceListName));
        }

        System.debug('exit getPriceListOptions');

        return options;
    }

    /*
        This method is invoked via the VF page.
     */
    public List<SelectOption> getStorefrontOptions()
    {
        List<String> storefronts = new List<String>();

        List<AggregateResult> configs = [SELECT ccrz__Storefront__c FROM ccrz__E_Configuration__c GROUP BY ccrz__Storefront__c];

        for(AggregateResult ag : configs) {
            storefronts.add((String)ag.get('ccrz__Storefront__c'));
        }

        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','-- Select --'));

        for(String storefrontName : storefronts){

            options.add(new SelectOption(storefrontName, storefrontName));
        }

        return options;
    }

    /*
        This method is invoked via the VF page.
     */
    public List<SelectOption> getRootCategoryOptions() {

        // Get the top category for everything
        List<ccrz__E_Category__c> temp = [SELECT Id, Name, ccrz__CategoryID__c FROM ccrz__E_Category__c WHERE ccrz__CategoryID__c = '0' ORDER BY ccrz__Sequence__c];

        ccrz__E_Category__c topCat = temp.get(0);

        List<ccrz__E_Category__c> ccCategories = [SELECT Id, Name, ccrz__CategoryID__c FROM ccrz__E_Category__c WHERE ccrz__ParentCategory__c = :topCat.Id ORDER BY Name];

        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('','-- Select --'));

        for(ccrz__E_Category__c ccCategory : ccCategories) {
            options.add(new SelectOption(ccCategory.Id, ccCategory.Name));
        }

        return options;

    }

    public String getStorefrontRootCategory() {

        String selectedRootCategoryName = null;

        if(selectedStorefront != null && selectedStorefront != '') {
            ccrz.ccContext ctx = new ccrz.ccContext();
            ctx.storefront = selectedStorefront;
            ccrz.cc_CallContext.initContext(ctx);
            Map<String, Object> sfSettings = ccrz.cc_CallContext.storeFrontSettings;

            selectedRootCategoryId = (String) sfSettings.get('Root_Category_ID__c');
            System.debug('---Root Category Id---' + sfSettings.get('Root_Category_ID__c'));


            List<ccrz__E_Category__c> ccCategories = [SELECT Id, Name, ccrz__CategoryID__c FROM ccrz__E_Category__c WHERE ccrz__CategoryID__c = :selectedRootCategoryId ORDER BY ccrz__Sequence__c];

            if(ccCategories.size() > 0) {
                ccrz__E_Category__c ccCategory = ccCategories.get(0);
                selectedRootCategoryName = ccCategory.Name;
                selectedRootCategoryObjId = ccCategory.Id;
            }

        }

        return selectedRootCategoryName;
    }

    /*
        Read the CSV file, so the user will see a preview of the data before it is uploaded into the Org.
     */
    public void readCsvFile() {

        dataStrings = new Set<String>();
        errorCounter = 0;

        dataList = new List<DataRecord>();

        List<List<String>> csvFileLines = null;

        try {
            if (csvData != null) {

                String csvStringFileData = csvData.toString();

                /*
                    Handle Google Docs issue, where an end of line char is not added to the last row.
                 */
                if(csvStringFileData.endsWith('\r') == false) {
                    csvStringFileData += '\r';
                }

                //csvStringFileData += '\r';

                // TODO replace with new logic
                //csvFilelines = csvStringFileData.split('\n');

                csvFileLines = parseCSV.parseCSV(csvStringFileData, true);

                // The first row is the column headers
                //for (String st : csvFilelines[0].split(',')) {
                //    fieldList.add(st);
                //}

                // The subsequent rows are the data records
                for (Integer i = 0; i < csvFileLines.size(); i++) {

                    System.debug('csvfilelines[' + i + '] ' + csvFileLines[i]);

                    //String[] csvRecordData = csvFilelines[i].split(',');
                    String[] csvRecordData = csvFileLines[i];

                    System.debug('csvRecordData: ' + csvRecordData);

                    System.debug('csvRecordData.size = ' + csvRecordData.size());

                    // Skip empty rows
                    if(csvRecordData.size() == 1) {
                        continue;
                    }

                    if (csvRecordData.size() < 41) {
                        //throw new Exception('row ' + (i+1) + ' does not have enough columns defined');
                        recordError(i, 'row does not have enough columns defined');
                    }

                    DataRecord dataRecord = new DataRecord();

                    dataRecord.sku = csvRecordData[0].trim();
                    dataRecord.productName = csvRecordData[1].trim();
                    dataRecord.shortDesc = csvRecordData[2].trim();
                    dataRecord.longDesc = csvRecordData[3].trim();
                    dataRecord.seoTitle = csvRecordData[4].trim();

                    dataRecord.cat1 = csvRecordData[5].trim();
                    dataRecord.cat2 = csvRecordData[6].trim();
                    dataRecord.cat3 = csvRecordData[7].trim();
                    dataRecord.cat4 = csvRecordData[8].trim();
                    dataRecord.cat5 = csvRecordData[9].trim();

                    if (csvRecordData[10] != null && csvRecordData[10].trim() != '') {
                        //System.debug('price1 = ' + csvRecordData[10]);
                        dataRecord.price1 = Decimal.valueOf(csvRecordData[10].trim());
                    }

                    if (csvRecordData[11] != null && csvRecordData[11].trim() != '') {
                        dataRecord.price2 = Decimal.valueOf(csvRecordData[11].trim());
                    }

                    if (csvRecordData[12] != null && csvRecordData[12].trim() != '') {
                        dataRecord.price3 = Decimal.valueOf(csvRecordData[12].trim());
                    }

                    // Spec 1
                    if ((csvRecordData[13] != null && csvRecordData[13].trim() != '') &&
                            (csvRecordData[15] != null && csvRecordData[15].trim() != '')) {

                        Spec spec = new Spec();
                        spec.name = csvRecordData[13].trim();
                        spec.filterType = csvRecordData[14].trim();
                        spec.value = csvRecordData[15].trim();
                        dataRecord.specList.add(spec);
                    }

                    // Spec 2
                    if ((csvRecordData[16] != null && csvRecordData[16].trim() != '') &&
                            (csvRecordData[18] != null && csvRecordData[18].trim() != '')) {

                        Spec spec = new Spec();
                        spec.name = csvRecordData[16].trim();
                        spec.filterType = csvRecordData[17].trim();
                        spec.value = csvRecordData[18].trim();
                        dataRecord.specList.add(spec);
                    }

                    // Spec 3
                    if ((csvRecordData[19] != null && csvRecordData[19].trim() != '') &&
                            (csvRecordData[21] != null && csvRecordData[21].trim() != '')) {

                        Spec spec = new Spec();
                        spec.name = csvRecordData[19].trim();
                        spec.filterType = csvRecordData[20].trim();
                        spec.value = csvRecordData[21].trim();
                        dataRecord.specList.add(spec);
                    }

                    // Spec 4
                    if ((csvRecordData[22] != null && csvRecordData[22].trim() != '') &&
                            (csvRecordData[24] != null && csvRecordData[24].trim() != '')) {

                        Spec spec = new Spec();
                        spec.name = csvRecordData[22].trim();
                        spec.filterType = csvRecordData[23].trim();
                        spec.value = csvRecordData[24].trim();
                        dataRecord.specList.add(spec);
                    }

                    // Spec 5
                    if ((csvRecordData[25] != null && csvRecordData[25].trim() != '') &&
                            (csvRecordData[27] != null && csvRecordData[27].trim() != '')) {

                        Spec spec = new Spec();
                        spec.name = csvRecordData[25].trim();
                        spec.filterType = csvRecordData[26].trim();
                        spec.value = csvRecordData[27].trim();
                        dataRecord.specList.add(spec);
                    }

                    // Related Product 1
                    if (csvRecordData[28] != null && csvRecordData[28].trim() != '') {
                        RelatedProduct rp = new RelatedProduct();
                        rp.sku = csvRecordData[28].trim();
                        rp.type = csvRecordData[29].trim();
                        dataRecord.relatedProducts.add(rp);
                    }

                    // Related Product 2
                    if (csvRecordData[30] != null && csvRecordData[30].trim() != '') {
                        RelatedProduct rp = new RelatedProduct();
                        rp.sku = csvRecordData[30].trim();
                        rp.type = csvRecordData[31].trim();
                        dataRecord.relatedProducts.add(rp);
                    }

                    // Related Product 3
                    if (csvRecordData[32] != null && csvRecordData[32].trim() != '') {
                        RelatedProduct rp = new RelatedProduct();
                        rp.sku = csvRecordData[32].trim();
                        rp.type = csvRecordData[33].trim();
                        dataRecord.relatedProducts.add(rp);
                    }

                    // Related Product 4
                    if (csvRecordData[34] != null && csvRecordData[34].trim() != '') {
                        RelatedProduct rp = new RelatedProduct();
                        rp.sku = csvRecordData[34].trim();
                        rp.type = csvRecordData[35].trim();
                        dataRecord.relatedProducts.add(rp);
                    }

                    // Related Product 5
                    if (csvRecordData[36] != null && csvRecordData[36].trim() != '') {
                        RelatedProduct rp = new RelatedProduct();
                        rp.sku = csvRecordData[36].trim();
                        rp.type = csvRecordData[37].trim();
                        dataRecord.relatedProducts.add(rp);
                    }

                    // Product Media 1
                    if (csvRecordData[38] != null && csvRecordData[38].trim() != '') {

                        //System.debug('path: ' + csvRecordData[38]);
                        //System.debug('type: ' + csvRecordData[39]);
                        //System.debug('source: >' + csvRecordData[40] + '<');

                        ProductMedia pm = new ProductMedia();
                        pm.path = csvRecordData[38].trim();

                        if(csvRecordData[39] != null && csvRecordData[39].trim() != '') {
                            pm.type = csvRecordData[39].trim();
                        }
                        else {
                            pm.type = 'Product Image';
                        }

                        if(csvRecordData[40] != null && csvRecordData[40].trim() != '') {
                            //System.debug('field 40 is not null');
                            pm.mediaSource = csvRecordData[40].trim();
                        }
                        else {
                            //System.debug('field 40 is null');
                            pm.mediaSource = 'URI';
                        }


                        if (csvRecordData.size() >= 42) {
                            if (csvRecordData[41] != null && csvRecordData[41].trim() != '') {
                                //System.debug('field 40 is not null');
                                pm.staticResourceName = csvRecordData[41].trim();
                            }
                        }


                        System.debug('pm: ' + pm);

                        dataRecord.productMediaList.add(pm);
                    }

                    dataList.add(dataRecord);

                    for (String st : dataStrings) {
                        System.debug('dataStrings ' + st);
                    }
                }

                //System.debug('CTAs ' + ctaStrings );
                System.debug('---------- All DONE ---------');
                hasFile = true;
            }
        }
        catch (Exception e) {
            String msg = e.getMessage();

            System.debug('Message: ' + e.getMessage());
            System.debug('Line number: ' + e.getLineNumber());
            System.debug('Stack: ' + e.getStackTraceString());

            addError(msg);
        }

    }

    public PageReference saveCsvFile() {

        clearErrors();

        System.debug('begin saveCsvFile()');

        String url = null;

        // Get a list of all products currently in the org
        Map<String, ccrz__E_Product__c> products = getProducts();

        // Get all the Specs currently in the Org.
        Map<String, ccrz__E_Spec__c> specMap = getSpecs();

        // Validate the input
        Set<String> errorList = validateInput(dataList, products, specMap);

        if(errorList.size() > 0) {
            hasError = true;
            for(String errorMsg : errorList) {
                addError(errorMsg);
            }

            url = '/apex/cc_POC_DataLoaderError';
            PageReference pageRef = new PageReference(url);
            return pageRef;
        }

        // Get all the categories currently in the org.  Each branch is a key in the Map.
        Map<String, Category> categoryBranchMap = createCategoryBranchMap();

        importCategories(dataList, categoryBranchMap);

        importProducts(dataList, products);

        // Map contains all products in the Org, including those just created via this process.
        Map<String, Product> productMap = getProductMap();

        assignProductsToCategories(dataList, productMap, categoryBranchMap);

        importPriceListItems(dataList, productMap);

        // Create specs.
        importSpecs(dataList, specMap);

        // Create product specs.
        importProductSpecs(dataList, productMap, specMap);

        // Create related products
        importRelatedProducts(dataList, productMap);

        // Create product media
        importProductMedia(dataList, productMap);

        resetFields();
        csvFileName = null;

        addInfo('Data saved');

        // 2018-09-24  msobczak
        CkzUpdateCacheService.doUpdate();

        System.debug('exit saveCsvFile()');

        PageReference pageRef = null;
        return pageRef;

    }

    private Set<String> validateInput(List<DataRecord> dataList, Map<String, ccrz__E_Product__c> products, Map<String, ccrz__E_Spec__c> currentSpecMap) {

        System.debug('begin validateInput');

        // Verify that a Storefront has been selected
        if(selectedStorefront == null) {
            recordError(0, 'Storefront must be selected');
        }

        // Verify that the three selected price lists are unique
        Set<String> selectedPriceLists = new Set<String>();

        if(selectedPriceList1 != null && selectedPriceList1 != '') {
            selectedPriceLists.add(selectedPriceList1);
        }

        if((selectedPriceList2 != null && selectedPriceList2 != '') && selectedPriceLists.contains(selectedPriceList2)) {
            recordError(0, 'Selected price lists must be unique: ' + priceListNames.get(selectedPriceList2));
        }
        else {
            if(selectedPriceList2 != null && selectedPriceList2 != '') {
                selectedPriceLists.add(selectedPriceList2);
            }
        }

        if(selectedPriceList3 != null && selectedPriceList3 != '' && selectedPriceLists.contains(selectedPriceList3)) {
            recordError(0, 'Selected price lists must be unique: ' + priceListNames.get(selectedPriceList3));
        }
        else {
            if(selectedPriceList3 != null && selectedPriceList3 != '') {
                selectedPriceLists.add(selectedPriceList3);
            }
        }

        // Verify that a price list was selected
        System.debug('selectedPriceLists: ' + selectedPriceLists);
        if(selectedPriceLists.size() == 0) {
            recordError(0, 'A Price List must be selected');
        }

        // Verify that the user selected a root category for all new categories
        if(selectedRootCategoryId == null) {
            recordError(0, 'Please specify the root category ID for the selected storefront in CC Admin');
        }

        // Get all SKUs defined in the CSV

        Set<String> inputSKUs = new Set<String>();
        for(DataRecord dataRecord : dataList) {
            if(dataRecord.sku != null && dataRecord.sku != '') {
                inputSKUs.add(dataRecord.sku);
            }
        }

        /*
            Get all new products defined in the input file.
            These products have a SKU and a Product Name.
         */
        Set<String> newSKUs = new Set<String>();
        for(DataRecord dataRecord : dataList) {
            if((dataRecord.sku != null && dataRecord.sku != '') && (dataRecord.productName != null && dataRecord.productName != '')) {
                newSKUs.add(dataRecord.sku);
            }
        }

        Integer i = 1;

        // Validate each record in the input file
        for(DataRecord dataRecord : dataList) {

            System.debug(i + '. dataRecord' + dataRecord);

            /*
                Verify that the Product SKU either already exists in the Org,
                or that it has the fields necessary to create it.
                Essentially, the first appearance of a new SKU must have a Name setting.
            */
            if (products.containsKey(dataRecord.sku)) {
                // Product is already in the Org
            }
            else {
                // New Product must have a name
                if(newSKUs.contains(dataRecord.sku) == false && (dataRecord.productName == null || dataRecord.productName == '')) {
                    recordError(i, 'New SKU must have a Product Name: ' + dataRecord.sku);
                }
            }

            // Verify Product field lengths

            // Product Name length must be <= 80
            if(dataRecord.productName != null && dataRecord.productName.length() > 80) {
                recordError(i, 'Product Name must be <= 80 chars: ' + dataRecord.sku);
            }

            // SKU must be <= 100
            if(dataRecord.sku != null && dataRecord.sku.length() > 100) {
                recordError(i, 'SKU must be <= 100 chars: ' + dataRecord.sku);
            }

            // Short Description must be <= 2000
            if(dataRecord.shortDesc != null && dataRecord.shortDesc.length() > 2000) {
                recordError(i, 'Short Description must be <= 2000 chars: ' + dataRecord.sku);
            }

            // Long Description must be <= 5000
            if(dataRecord.longDesc != null && dataRecord.longDesc.length() > 5000) {
                recordError(i, 'Short Description must be <= 5000 chars: ' + dataRecord.sku);
            }

            // SEO Title must be <= 100
            if(dataRecord.seoTitle != null && dataRecord.seoTitle.length() > 100) {
                recordError(i, 'SEO Title must be <= 100 chars: ' + dataRecord.sku);
            }

            // Verify the Price List Items
            if((dataRecord.price1 != null) && ((dataRecord.sku == null) || (dataRecord.sku == ''))) {
                recordError(i, 'Price 1 must have a SKU: ' + dataRecord.price1);
            }

            if((dataRecord.price2 != null) && ((dataRecord.sku == null) || (dataRecord.sku == ''))) {
                recordError(i, 'Price 2 must have a SKU: ' + dataRecord.price2);
            }

            if((dataRecord.price3 != null) && ((dataRecord.sku == null) || (dataRecord.sku == ''))) {
                recordError(i, 'Price 3 must have a SKU: ' + dataRecord.price3);
            }

            // Verify Spec fields
            for(Spec spec : dataRecord.specList) {

                // Spec Name must be <= 80
                if (spec.name != null && spec.name.length() > 80) {
                    recordError(i, 'Spec Name must be <= 80 chars: ' + dataRecord.sku);
                    //continue;
                }

                // If the Spec Filter Type is specified, it must be a valid value.
                // When a new Spec is created, it is given a Filter Type of Checkbox by default.
                if (currentSpecMap.containsKey(spec.name) == false) {
                    if (spec.filterType != null && spec.filterType != '' && specFiltertypes.contains(spec.filterType) == false) {
                        recordError(i, 'Spec Filter Type not valid: ' + dataRecord.sku + '/' + spec.filterType);
                        //continue;
                    }
                }

                if (currentSpecMap.containsKey(spec.name) == false) {
                    if(spec.value == null || spec.value == '') {
                        recordError(i, 'Spec must have a value: ' + spec.name);
                    }
                }

                if(spec.value != null && spec.value.length() > 255) {
                    recordError(i, 'Spec Value must be <= 255 chars: ' + dataRecord.sku);
                    //continue;
                }

                /*
                    If the Spec has a value, it must have an associated Product SKU.
                 */
                if((spec.value != null && spec.value != '') && (dataRecord.sku == null || dataRecord.sku == '')) {
                    recordError(i, 'Spec value must have a SKU: ' + spec.name + ' / ' + spec.value);
                }

            }

            // Verify Related Product fields

            // Verify the Related product SKU either already exists in the Org, or is defined in the input file
            for(RelatedProduct rp : dataRecord.relatedProducts) {
                if(inputSKUs.contains(rp.sku) == false && products.containsKey(rp.sku) == false) {
                    recordError(i, 'Related Product not found in Org or defined in input file: ' + dataRecord.sku);
                    //continue;
                }

                if(rp.type != null && rp.type != '' && relatedProductTypes.contains(rp.type) == false) {
                    recordError(i, 'Related Product Type not valid: ' + dataRecord.sku);
                    //continue;
                }

                /*
                    If the Related Product has a SKU, it must have an associated Product SKU.
                 */
                if((rp.sku != null && rp.sku != '') && (dataRecord.sku == null || dataRecord.sku == '')) {
                    recordError(i, 'Related product must have a SKU: ' + rp.sku);
                }

            }

            // Verify Media fields

            for(ProductMedia pm : dataRecord.productMediaList) {

                // Verify the Media Source.
                // NOTE: this value defaults to URI if it is not provided in the import file
                if(pm.mediaSource != null && pm.mediaSource != '' && mediaSources.contains(pm.mediaSource) == false) {
                    recordError(i, 'Product Media Type not valid: ' + dataRecord.sku);
                    //continue;
                }

                if(pm.path == null || pm.path == '') {
                    recordError(i, 'Product Media Path cannot be empty: ' + dataRecord.sku);
                    //continue;
                }

                if(pm.mediaSource == 'URI' && pm.path.length() > 255) {
                    recordError(i, 'Product Media Path must be <= 255 chars: ' + dataRecord.sku);
                    //continue;
                }

                if(pm.mediaSource == 'Static Resource' && pm.path.length() > 128) {
                    recordError(i, 'Product Media Path must be <= 128 chars: ' + dataRecord.sku);
                    //continue;
                }

                /*
                    If the Media has a path, it must have an associated Product SKU.
                 */
                if((pm.path != null && pm.path != '') && (dataRecord.sku == null || dataRecord.sku == '')) {
                    recordError(i, 'Product Media must have a SKU: ' + pm.path);
                }

            }

            i++;

        }

        System.debug('exit validateInput');

        return errorList;

    }

    private void recordError(Integer rowNum, String msg) {
        errorList.add(msg);

        List<String> errors = null;

        if(errorMap.containsKey(rowNum)) {
            errors = errorMap.get(rowNum);
        }
        else {
            errors = new List<String>();
        }

        errors.add(msg);

        errorMap.put(rowNum, errors);
    }

    /*
        Import any new categories found in the file.
        Product Categories are not being created here.
     */
    private void importCategories(List<DataRecord> dataList, Map<String, Category> categoryBranchMap) {

        // Create categories at each level

        System.debug('importing categories level 1');
        //importCategoryLevel(1, dataList, categoryBranchMap, selectedRootCategoryId);
        importCategoryLevel(1, dataList, categoryBranchMap, selectedRootCategoryObjId);

        System.debug('importing categories level 2');
        importCategoryLevel(2, dataList, categoryBranchMap, null);

        System.debug('importing categories level 3');
        importCategoryLevel(3, dataList, categoryBranchMap, null);

        System.debug('importing categories level 4');
        importCategoryLevel(4, dataList, categoryBranchMap, null);

        System.debug('importing categories level 5');
        importCategoryLevel(5, dataList, categoryBranchMap, null);

    }

    private void importCategoryLevel(Integer level, List<DataRecord> dataList, Map<String, Category> categoryBranchMap, String rootCategoryId) {

        List<ccrz__E_Category__c> objectsAdd = new List<ccrz__E_Category__c>();

        for(DataRecord dataRecord : dataList) {

            //System.debug('dataRecord.getCategoryBranch(level): ' + dataRecord.getCategoryBranch(level));

            if (dataRecord.getCategoryBranch(level) != null) {

                String categoryBranch = dataRecord.getCategoryBranch(level);
                //System.debug('categoryBranch: ' + categoryBranch);
                //System.debug('categoryBranchMap: ' + categoryBranchMap);

                if (categoryBranchMap.containsKey(categoryBranch) == false) {

                    System.debug('category NOT found');

                    ccrz__E_Category__c ccCategory = new ccrz__E_Category__c();
                    ccCategory.Name = dataRecord.getCategoryValue(level);

                    if(rootCategoryId != null) {
                        ccCategory.ccrz__ParentCategory__c = rootCategoryId;  // The user selected this in the UI
                    }
                    else {
                        // Get the parent category from the Map
                        String parentCategoryBranch = categoryBranch.substringBeforeLast('/');
                        //String parentCategoryBranch = null;
                        //Integer pos = categoryBranch.lastIndexOf('/');
                        //parentCategoryBranch = categoryBranch.substring(0, pos);

                        Category cat = categoryBranchMap.get(parentCategoryBranch);

                        ccCategory.ccrz__ParentCategory__c = cat.Id;
                    }

                    ccCategory.ccrz__CategoryID__c = getGuid();  // A calculated GUID
                    objectsAdd.add(ccCategory);

                    /*
                        Add the new category to the map temporarily.
                        This will ensure the new category doesn't get inserted twice,
                        if the category exists more than once in the input file.
                      */
                    categoryBranchMap.put(categoryBranch, null);
                }
                else {
                    System.debug('category found');
                }

            }

        }

        // Insert all of the new ccCategory objects
        if(objectsAdd.size() > 0) {
            insert objectsAdd;

            System.debug('objectsAdd: ' + objectsAdd);

            // Add all of the new categories to the catgoryMap
            this.updateCategoryMap(objectsAdd);
        }

    }

    /*
        Creates a new product for any SKU in the file that does not already exist in the Org.
        Updates the existing product if found.
     */
    private void importProducts(List<DataRecord> dataList, Map<String, ccrz__E_Product__c> products) {

        System.debug('begin importProducts()');

        List<ccrz__E_Product__c> objectsAdd = new List<ccrz__E_Product__c>();
        List<ccrz__E_Product__c> objectsUpsert = new List<ccrz__E_Product__c>();

        Set<String> newSKUs = new Set<String>();

        for(DataRecord dataRecord : dataList) {
            if(products.containsKey(dataRecord.sku)) {

                System.debug('Product found');

                Boolean changed = false;

                ccrz__E_Product__c product = products.get(dataRecord.sku);

                if(dataRecord.productName != '' && product.Name != dataRecord.productName) {
                    System.debug('Product Name changed');
                    product.Name = dataRecord.productName;
                    changed = true;
                }

                if(dataRecord.sku != '' && product.ccrz__SKU__c != dataRecord.sku) {
                    System.debug('Product SKU changed');
                    product.ccrz__SKU__c = dataRecord.sku;
                    changed = true;
                }

                if(dataRecord.shortDesc != '' && product.ccrz__ShortDesc__c != dataRecord.shortDesc) {
                    System.debug('Product Short Desc changed');
                    product.ccrz__ShortDesc__c = dataRecord.shortDesc;
                    product.ccrz__ShortDescRT__c = dataRecord.shortDesc;  // 2018-09-05  msobczak
                    changed = true;
                }

                if(dataRecord.longDesc != '' && product.ccrz__LongDesc__c != dataRecord.longDesc) {
                    System.debug('Product Long Desc changed');
                    product.ccrz__LongDesc__c = dataRecord.longDesc;
                    product.ccrz__LongDescRT__c = dataRecord.longDesc;  // 2018-09-05  msobczak
                    changed = true;
                }

                if(dataRecord.seoTitle != '' && product.ccrz__SEOTitle__c != dataRecord.seoTitle) {
                    System.debug('Product SEO Title changed');
                    product.ccrz__SEOTitle__c = dataRecord.seoTitle;
                    changed = true;
                }

                if(product.ccrz__Storefront__c == null) {
                    System.debug('Product Storefront changed 1');
                    product.ccrz__Storefront__c = selectedStorefront;
                    changed = true;
                }
                else if (product.ccrz__Storefront__c.indexOf(selectedStorefront) < 0) {
                    product.ccrz__Storefront__c = product.ccrz__Storefront__c + ';' + selectedStorefront;
                    System.debug('Product Storefront changed 2');
                    changed = true;
                }

                if(changed) {
                    objectsUpsert.add(product);
                }
            }
            else {

                // Only insert the new Product once.
                if(newSKUs.contains(dataRecord.sku) == false) {
                    System.debug('Product NOT found');

                    ccrz__E_Product__c product = new ccrz__E_Product__c();
                    product.Name = dataRecord.productName;
                    product.ccrz__SKU__c = dataRecord.sku;
                    product.ccrz__ShortDesc__c = dataRecord.shortDesc;
                    product.ccrz__ShortDescRT__c = dataRecord.shortDesc;  // 2018-09-05  msobczak
                    product.ccrz__LongDesc__c = dataRecord.longDesc;
                    product.ccrz__LongDescRT__c = dataRecord.longDesc;  // 2018-09-05  msobczak
                    product.ccrz__SEOTitle__c = dataRecord.seoTitle;
                    product.ccrz__Storefront__c = selectedStorefront;
                    product.ccrz__ProductStatus__c = 'Released';

                    objectsAdd.add(product);

                    newSKUs.add(dataRecord.sku);
                }
            }
        }

        if(objectsAdd.size() > 0) {
            System.debug('Total products added = ' + objectsAdd.size());
            insert objectsAdd;
        }

        if(objectsUpsert.size() > 0) {
            System.debug('Total products updated = ' + objectsUpsert.size());
            upsert objectsUpsert;
        }

        System.debug('exit importProducts()');
    }

    private void assignProductsToCategories(List<DataRecord> dataList, Map<String, Product> productMap, Map<String, Category> categoryBranchMap) {

        System.debug('begin assignProductsToCategories()');

        List<ccrz__E_ProductCategory__c> objectsAdd = new List<ccrz__E_ProductCategory__c>();

        for(DataRecord dataRecord : dataList) {

            // If the record does not have a SKU, skip it.
            if(dataRecord.sku == null || dataRecord.equals('')) {
                continue;
            }

            String productCategoryBranch = dataRecord.getCategory();

            if(productCategoryBranch == null || productCategoryBranch == '') {
                continue;
            }

            Product product = productMap.get(dataRecord.sku);
            ccrz__E_Product__c ccProduct = product.ccProduct;

            System.debug('product: ' + ccProduct.ccrz__SKU__c);
            System.debug('productCategoryBranch: ' + productCategoryBranch);

            // Is the Product currently in the branch in the import file?

            // Get the category ID from the Map
            if(categoryBranchMap.containsKey(productCategoryBranch)) {

                System.debug('productCategoryBranch found in categoryBranchMap');

                Category category = categoryBranchMap.get(productCategoryBranch);
                Id categoryId = category.Id;

                System.debug('categoryId: ' + categoryId);
                System.debug('productCategoryMap: ' + product.productCategoryMap);

                if(product.productCategoryMap.containsKey(categoryId) == false) {

                    System.debug('categoryId NOT found in productCategoryMap');

                    // Create a Product Category object
                    ccrz__E_ProductCategory__c ccProductCategory = new ccrz__E_ProductCategory__c();
                    ccProductCategory.ccrz__Category__c = categoryId;
                    ccProductCategory.ccrz__Product__c = ccProduct.Id;

                    // TODO default value
                    ccProductCategory.ccrz__Sequence__c = 500;

                    objectsAdd.add(ccProductCategory);

                    // Add the Product Category to the Map.  This will ensure it doesn't get added twice.

                    product.productCategoryMap.put(categoryId, ccProductCategory);
                }
            }
            else {
                // TODO throw error?
            }

        }

        if(objectsAdd.size() > 0) {
            insert objectsAdd;
        }

        System.debug('exit assignProductsToCategories()');

    }

    /*
        Creates a new Spec for any spec in the file that does not already exist in the Org.
     */
    private void importSpecs(List<DataRecord> dataList, Map<String, ccrz__E_Spec__c> specMap) {

        System.debug('begin importSpecs()');

        Map<String, ccrz__E_Spec__c> newSpecMap = new Map<String, ccrz__E_Spec__c>();

        /*
            The same spec can come in the file more than once.
            Need to prevent duplicates from being added.
            The code will only add the first "new" Spec found in the import file.
          */
        for(DataRecord dataRecord : dataList) {

            for(Spec spec : dataRecord.specList) {

                if(specMap.containsKey(spec.name) == false) {

                    if(newSpecMap.containsKey(spec.name) == false) {
                        ccrz__E_Spec__c newSpec = new ccrz__E_Spec__c();
                        newSpec.Name = spec.name;
                        newSpec.ccrz__DisplayName__c = spec.name;
                        newSpec.ccrz__FilterDisplayName__c = spec.name;

                        newSpec.ccrz__Locale__c = 'en_US';  // Required or won't show in site
                        newSpec.ccrz__SelectType__c = 'Multiple';  // Picklist value
                        newSpec.ccrz__SpecGroup__c = 'General';  // Picklist value
                        newSpec.ccrz__Sequence__c = 500;

                        // If the Filter Type was not provided, default to Checkbox
                        if (spec.filterType != null && spec.filterType != '') {
                            newSpec.ccrz__FilterType__c = spec.filterType;
                        }
                        else {
                            newSpec.ccrz__FilterType__c = 'Checkbox';
                        }

                        // 2018-08-29  msobczak:
                        newSpec.ccrz__IsComparable__c = true;

                        newSpecMap.put(spec.name, newSpec);
                    }

                }
            }
        }

        if(newSpecMap.size() > 0) {
            insert newSpecMap.values();
        }

        /*
            Add all new Spec objects created to the master Map
         */
        for(String key : newSpecMap.keySet()) {
            ccrz__E_Spec__c newSpec = newSpecMap.get(key);
            specMap.put(newSpec.Name, newSpec);
        }

        System.debug('exit importSpecs()');
    }

    /*
        Update the specs associated with the product, along with the value specific to the product.
     */
    private void importProductSpecs(List<DataRecord> dataList, Map<String, Product> productMap, Map<String, ccrz__E_Spec__c> specMap) {

        System.debug('begin importProductSpecs()');

        //Map<String, ccrz__E_ProductSpec__c> newProdSpecMap = new Map<String, ccrz__E_ProductSpec__c>();

        List<ccrz__E_ProductSpec__c> objectsAdd = new List<ccrz__E_ProductSpec__c>();
        List<ccrz__E_ProductSpec__c> objectsUpsert = new List<ccrz__E_ProductSpec__c>();

        for(DataRecord dataRecord : dataList) {

            // If the record does not have a SKU, skip it.
            if(dataRecord.sku == null || dataRecord.equals('')) {
                continue;
            }

            Product product = productMap.get(dataRecord.sku);
            ccrz__E_Product__c ccProduct = product.ccProduct;

            System.debug('product: ' + ccProduct.ccrz__SKU__c);

            for(Spec spec : dataRecord.specList) {

                System.debug('spec to add: ' + spec.name + ' / ' + spec.value);
                System.debug('productSpecMap: ' + product.productSpecMap);

                if(product.productSpecMap.containsKey(spec.name)) {

                    System.debug('product spec found');

                    if(spec.value != null && spec.value != '') {
                        ccrz__E_ProductSpec__c ccProductSpec = product.productSpecMap.get(spec.name);
                        if(ccProductSpec.ccrz__SpecValue__c != spec.value) {
                            ccProductSpec.ccrz__SpecValue__c = spec.value;
                            objectsUpsert.add(ccProductSpec);
                        }
                    }
                }
                else {
                    System.debug('product spec NOT found');

                    ccrz__E_ProductSpec__c ccProductSpec = new ccrz__E_ProductSpec__c();

                    ccProductSpec.ccrz__Product__c = ccProduct.Id;
                    ccProductSpec.ccrz__Spec__c = specMap.get(spec.name).Id;
                    ccProductSpec.ccrz__SpecValue__c = spec.value;

                    objectsAdd.add(ccProductSpec);

                    /*
                        Not sure if this will work, if the user has the same spec defined multiple times in the file,
                        and the first time out it is a new spec.
                      */
                    product.productSpecMap.put(spec.name, ccProductSpec);
                }

            }

        }

        if(objectsAdd.size() > 0) {
            insert objectsAdd;
        }

        if(objectsUpsert.size() > 0) {
            upsert objectsUpsert;
        }

        System.debug('exit importProductSpecs()');
    }

    /*
        Update the specs associated with the product, along with the value specific to the product.
     */
    private void importRelatedProducts(List<DataRecord> dataList, Map<String, Product> productMap) {

        System.debug('begin importRelatedProducts()');

        List<ccrz__E_RelatedProduct__c> objectsAdd = new List<ccrz__E_RelatedProduct__c>();
        List<ccrz__E_RelatedProduct__c> objectsUpsert = new List<ccrz__E_RelatedProduct__c>();

        for(DataRecord dataRecord : dataList) {

            // If the record does not have a SKU, skip it.
            if(dataRecord.sku == null || dataRecord.equals('')) {
                continue;
            }

            // Get the current product
            Product product = productMap.get(dataRecord.sku);
            ccrz__E_Product__c ccProduct = product.ccProduct;

            List<RelatedProduct> relatedProducts = dataRecord.relatedProducts;

            for (RelatedProduct rp : relatedProducts) {

                System.debug('product: ' + dataRecord.sku);

                // Does the product already have this related product?

                System.debug('related product to add: ' + rp.sku + ' / ' + rp.type);

                if (product.relatedProductMap.containsKey(rp.sku)) {

                    System.debug('related product found');

                    // Get the related product
                    ccrz__E_RelatedProduct__c relatedProduct = product.relatedProductMap.get(rp.sku);

                    // Update the related product type
                    if ((rp.type != null && rp.type != '') &&
                            (relatedProduct.ccrz__RelatedProductType__c != rp.type)){

                        relatedProduct.ccrz__RelatedProductType__c = rp.type;
                        objectsUpsert.add(relatedProduct);

                    }
                } else {

                    System.debug('related product NOT found');

                    // Get the product to be related
                    Product product2 = productMap.get(rp.sku);
                    ccrz__E_Product__c ccProduct2 = product2.ccProduct;

                    ccrz__E_RelatedProduct__c relatedProduct = new ccrz__E_RelatedProduct__c();

                    relatedProduct.ccrz__Product__c = ccProduct.Id;
                    relatedProduct.ccrz__RelatedProduct__c = ccProduct2.Id;

                    if(rp.type != null && !rp.type.equals('')) {
                        relatedProduct.ccrz__RelatedProductType__c = rp.type;
                    }
                    else {
                        relatedProduct.ccrz__RelatedProductType__c = 'CrossSell';
                    }

                    objectsAdd.add(relatedProduct);

                }

            }
        }

        if(objectsAdd.size() > 0) {
            insert objectsAdd;
        }

        if(objectsUpsert.size() > 0) {
            upsert objectsUpsert;
        }

        System.debug('exit importRelatedProducts()');
    }

    /*
        Update the media associated with the product.
        If the type + source combination is found, skip it.
     */
    private void importProductMedia(List<DataRecord> dataList, Map<String, Product> productMap) {

        System.debug('begin importProductMedias()');

        List<ccrz__E_ProductMedia__c> objectsAdd = new List<ccrz__E_ProductMedia__c>();
        List<ccrz__E_ProductMedia__c> objectsUpsert = new List<ccrz__E_ProductMedia__c>();

        for(DataRecord dataRecord : dataList) {

            // If the record does not have a SKU, skip it.
            if(dataRecord.sku == null || dataRecord.equals('')) {
                continue;
            }

            // Get the current product
            Product product = productMap.get(dataRecord.sku);
            ccrz__E_Product__c ccProduct = product.ccProduct;

            List<ProductMedia> productMediaList = dataRecord.productMediaList;

            for (ProductMedia pm : productMediaList) {

                System.debug('product: ' + dataRecord.sku);

                // Does the product already have this related product?

                // Media Type - Product Image, Product Search Image, Product Image Thumbnail
                // Media Source - URI, Static Resource

                System.debug('product media to process: ' + pm.type + ' / ' + pm.mediaSource + ' / ' + pm.path);

                if (defaultMediaTypes.contains(pm.type) && product.productMediaTypes.contains(pm.type)) {

                    System.debug('default product media found - updating');

                    if(pm.type == 'Product Image') {

                        // Product Image
                        updateProductMediaType('Product Image', pm, product, objectsUpsert);

                        // Product Search Image
                        updateProductMediaType('Product Search Image', pm, product, objectsUpsert);

                        // Product Image Thumbnail
                        updateProductMediaType('Product Image Thumbnail', pm, product, objectsUpsert);

                    }

                }
                // This is for all of the other product media types
                // The only update we can do is to look by Media Type + Media Source
                else if (product.productMediaTypes.contains(pm.type + '-' + pm.mediaSource)) {

                    System.debug('product media found - updating');

                    ccrz__E_ProductMedia__c productMediaObj = product.productMediaMap.get(pm.type + '-' + pm.mediaSource);
                    updateProductMediaObj(pm, productMediaObj, objectsUpsert);
                }
                else {

                    System.debug('product media NOT found - creating');

                    ccrz__E_ProductMedia__c productMedia = new ccrz__E_ProductMedia__c();

                    productMedia.ccrz__Product__c = ccProduct.Id;
                    productMedia.ccrz__MediaType__c = pm.type;
                    productMedia.ccrz__ProductMediaSource__c = pm.mediaSource;

                    if(pm.mediaSource == 'Static Resource') {
                        productMedia.ccrz__FilePath__c = pm.path;
                        productMedia.ccrz__StaticResourceName__c = pm.staticResourceName;
                    }
                    else {
                        productMedia.ccrz__URI__c = pm.path;
                    }

                    objectsAdd.add(productMedia);

                    /*
                        This code is only for the SDO.
                        The cloned images will only be created if the Process Flow exists in the current org.
                        In the SDO, it does not.
                        In the CC source org, and its clones, it does.
                     */
                    if((productImageCloneExists == false) && (pm.type == 'Product Image')) {
                        ccrz__E_ProductMedia__c productMedia2 = productMedia.clone(false, true);
                        productMedia2.ccrz__MediaType__c = 'Product Search Image';

                        objectsAdd.add(productMedia2);

                        ccrz__E_ProductMedia__c productMedia3 = productMedia.clone(false, true);
                        productMedia3.ccrz__MediaType__c = 'Product Image Thumbnail';

                        objectsAdd.add(productMedia3);

                    }

                }

            }
        }

        if(objectsAdd.size() > 0) {
            insert objectsAdd;
        }

        if(objectsUpsert.size() > 0) {
            upsert objectsUpsert;
        }

        System.debug('exit importProductMedias()');
    }

    // 2018-09-24  msobczak
    private void updateProductMediaType(String productMediaType, ProductMedia pm, Product product, List<ccrz__E_ProductMedia__c> objectsUpsert) {
        
        System.debug('begin updateProductMediaType()');
        
        boolean typeFound = false;
        ccrz__E_ProductMedia__c productMediaObj = null;

        // Product Search Image

        for(ccrz__E_ProductMedia__c temp : product.productMediaList) {
            if(temp.ccrz__MediaType__c == productMediaType) {
                productMediaObj = temp;
                typeFound = true;
                break;
            }
        }

        if(typeFound) {
            updateProductMediaObj(pm, productMediaObj, objectsUpsert);
        }
    }

    // 2018-09-24  msobczak
    private void updateProductMediaObj(ProductMedia pm, ccrz__E_ProductMedia__c productMediaObj, List<ccrz__E_ProductMedia__c> objectsUpsert) {

        Boolean updated = false;

        System.debug('begin updateProductMediaObj()');

        System.debug('productMediaObj.ccrz__ProductMediaSource__c: ' + productMediaObj.ccrz__ProductMediaSource__c);
        System.debug('pm.mediaSource: ' + pm.mediaSource);
        
        // Media Source - URI, Static Resource (URI is the default)

        if(productMediaObj.ccrz__ProductMediaSource__c != pm.mediaSource) {
            
            System.debug('inside check 1');
            
            productMediaObj.ccrz__ProductMediaSource__c = pm.mediaSource;

            if(pm.mediaSource == 'URI' && productMediaObj.ccrz__ProductMediaSource__c == 'Static Resource') {
                productMediaObj.ccrz__FilePath__c = null;
                productMediaObj.ccrz__StaticResourceName__c = null;
            }

            if(pm.mediaSource == 'Static Resource' && productMediaObj.ccrz__ProductMediaSource__c == 'URI') {
                productMediaObj.ccrz__URI__c = null;
            }

            updated = true;
        }

        if(pm.mediaSource == 'Static Resource') {
            
            System.debug('inside check 2');

            if(pm.path != '' && productMediaObj.ccrz__FilePath__c != pm.path) {
                productMediaObj.ccrz__FilePath__c = pm.path;
                updated = true;
            }

            if(pm.staticResourceName != '' && productMediaObj.ccrz__StaticResourceName__c != pm.staticResourceName) {
                productMediaObj.ccrz__StaticResourceName__c = pm.staticResourceName;
                updated = true;
            }

        }

        if(pm.mediaSource == 'URI') {
            
            System.debug('inside check 3');
            
            System.debug('pm.path: ' + pm.path);
            System.debug('productMediaObj.ccrz__URI__c: ' + productMediaObj.ccrz__URI__c);
            
            if(pm.path != '' && productMediaObj.ccrz__URI__c != pm.path) {
                productMediaObj.ccrz__URI__c = pm.path;
                
                // 2020-05-13 msobczak: added
                updated = true;
            }
        }
        
        System.debug('updated = ' + updated);

        if(updated) {
            objectsUpsert.add(productMediaObj);
        }
        
    }

    /*
        Creates a Price List Item object if one doesn't already exist for the Product + Price List.
        Updates the price of the existing Price List Item if found.
     */
    private void importPriceListItems(List<DataRecord> dataList,  Map<String, Product> productMap) {

        System.debug('begin importPriceListItems()');

        List<ccrz__E_PriceListItem__c> objectsAdd = new List<ccrz__E_PriceListItem__c>();
        List<ccrz__E_PriceListItem__c> objectsUpsert = new List<ccrz__E_PriceListItem__c>();

        for(DataRecord dataRecord : dataList) {

            // If the record does not have a SKU, skip it.
            if(dataRecord.sku == null || dataRecord.equals('')) {
                continue;
            }

            /*
                Get the associated product.
                Assumption here is that the product must exist.
                The product in the CSV file would have been created at this point if it didn't exist.
             */
            Product product = productMap.get(dataRecord.sku);
            ccrz__E_Product__c ccProduct = product.ccProduct;

            System.debug('Got product: ' + ccProduct.Name);

            System.debug('selectedPriceList1: ' + selectedPriceList1);
            System.debug('selectedPriceList2: ' + selectedPriceList2);
            System.debug('selectedPriceList3: ' + selectedPriceList3);

            if (selectedPriceList1 != null) {
                if (dataRecord.price1 != null) {
                    updatePriceList(product, selectedPriceList1, dataRecord.price1, objectsAdd, objectsUpsert);
                }
            }

            if (selectedPriceList2 != null) {
                if (dataRecord.price2 != null) {
                    updatePriceList(product, selectedPriceList2, dataRecord.price2, objectsAdd, objectsUpsert);
                }
            }

            if (selectedPriceList3 != null) {
                if (dataRecord.price3 != null) {
                    updatePriceList(product, selectedPriceList3, dataRecord.price3, objectsAdd, objectsUpsert);
                }
            }

        }

        if(objectsAdd.size() > 0) {
            System.debug('pli items added: ' + objectsAdd.size());
            insert objectsAdd;
        }

        if(objectsUpsert.size() > 0) {
            System.debug('pli items updated: ' + objectsUpsert.size());
            upsert objectsUpsert;
        }

        System.debug('exit importPriceListItems()');

    }

    /*
        Update an existing price list item for a product.
     */
    private void updatePriceList(Product product, String selectedPriceList, Decimal price,
            List<ccrz__E_PriceListItem__c> objectsAdd, List<ccrz__E_PriceListItem__c> objectsUpsert) {

        /*
            Loop through all price list items associated with the product.
            If a price list item is found, update the price.
            If a price list item is not found, create the new object.
        */

        System.debug('updating product for price list: ' + selectedPriceList);

        Boolean pliFound = false;

        ccrz__E_PriceListItem__c pli = null;

        if(product.priceListItemMap.containsKey(selectedPriceList)) {
            pliFound = true;
            pli = product.priceListItemMap.get(selectedPriceList);
        }

        System.debug('pliFound: ' + pliFound);

        if(pliFound) {
            // Only update the Price List Item if the price has changed.
            if(pli.ccrz__Price__c != price) {
                pli.ccrz__Price__c = price;
                objectsUpsert.add(pli);
            }
        }
        else {
            pli = new ccrz__E_PriceListItem__c();
            pli.ccrz__Pricelist__c = selectedPriceList;
            pli.ccrz__Product__c = product.ccProduct.Id;
            pli.ccrz__MinQty__c = 1;
            pli.ccrz__Price__c = price;
            objectsAdd.add(pli);
        }

    }

    /*
        Returns a Map of products, where the key is the SKU.
     */
    private Map<String, ccrz__E_Product__c> getProducts() {
        List<ccrz__E_Product__c> productList = [SELECT Id, Name,
                ccrz__SKU__c,
                ccrz__Storefront__c,
                ccrz__ShortDesc__c,
                ccrz__LongDesc__c,
                ccrz__SEOTitle__c
        FROM ccrz__E_Product__c];

        Map<String, ccrz__E_Product__c> productMap = new Map<String, ccrz__E_Product__c>();

        for(ccrz__E_Product__c product : productList) {
            productMap.put(product.ccrz__SKU__c, product);
        }

        return productMap;
    }

    /*
        Get all products in the Org, including these related objects:
            Price List Item
            Product Spec

            Related Product
            Product Medias
            Categories
     */
    private Map<String, ccrz__E_Product__c> getProductsAndRelatedObjects() {
        List<ccrz__E_Product__c> productList = [SELECT Id, Name,
                ccrz__SKU__c,
                ccrz__Storefront__c,
                ccrz__ShortDesc__c,
                ccrz__LongDesc__c,
                ccrz__SEOTitle__c,
        (SELECT Id, Name, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__MinQty__c, ccrz__Price__c, ccrz__Product__c, ccrz__Pricelist__c FROM ccrz__E_PriceListItems__r),
        (SELECT Id, Name, ccrz__Product__c, ccrz__Spec__c, ccrz__SpecValue__c FROM ccrz__Product_Specs__r)
        FROM ccrz__E_Product__c];

        Map<String, ccrz__E_Product__c> productSet = new Map<String, ccrz__E_Product__c>();

        for(ccrz__E_Product__c product : productList) {
            productSet.put(product.ccrz__SKU__c, product);
        }

        return productSet;
    }

    /*
        This is the new method.
     */
    private Map<String, Product> getProductMap() {
        List<ccrz__E_Product__c> productList = [SELECT Id, Name,
                ccrz__SKU__c,
                ccrz__Storefront__c,
                ccrz__ShortDesc__c,
                ccrz__LongDesc__c,
                ccrz__SEOTitle__c,
        (SELECT Id, Name, ccrz__StartDate__c, ccrz__EndDate__c, ccrz__MinQty__c, ccrz__Price__c, ccrz__Product__c, ccrz__Pricelist__c FROM ccrz__E_PriceListItems__r),
        (SELECT Id, Name, ccrz__Product__c, ccrz__Spec__c, ccrz__SpecValue__c, ccrz__Spec__r.Name FROM ccrz__Product_Specs__r),
        (SELECT Id, Name, ccrz__Product__c, ccrz__RelatedProduct__c, ccrz__RelatedProductType__c, ccrz__Sequence__c, ccrz__RelatedProduct__r.ccrz__SKU__c FROM ccrz__E_RelatedProducts__r),
        (SELECT Id, Name, ccrz__Product__c, ccrz__FilePath__c, ccrz__MediaType__c, ccrz__ProductMediaSource__c, ccrz__StaticResourceName__c, ccrz__URI__c, ccrz__Product__r.ccrz__SKU__c FROM ccrz__E_ProductMedias__r),
        (SELECT Id, Name, ccrz__Product__c, ccrz__Category__c, ccrz__Product__r.ccrz__SKU__c, ccrz__Category__r.Id FROM ccrz__Product_Categories__r)
        FROM ccrz__E_Product__c];

        Map<String, Product> productSet = new Map<String, Product>();

        for(ccrz__E_Product__c ccProduct : productList) {

            // Stash the Product object
            Product product = new Product();
            product.ccProduct = ccProduct;

            // Stash the Product's Price List Items
            Map<String, ccrz__E_PriceListItem__c> priceListItemMap = new Map<String, ccrz__E_PriceListItem__c>();
            for(ccrz__E_PriceListItem__c pli : ccProduct.ccrz__E_PriceListItems__r) {
                priceListItemMap.put(pli.ccrz__Pricelist__c, pli);
            }

            // 2018-08-30  msobczak
            product.priceListItemMap = priceListItemMap;

            // Stash the Product's Specs
            Map<String, ccrz__E_ProductSpec__c> productSpecMap = new Map<String, ccrz__E_ProductSpec__c>();
            for(ccrz__E_ProductSpec__c ccProductSpec : ccProduct.ccrz__Product_Specs__r) {
                // 2018-08-30  msobczak: fixed to use the related Spec object's name as the key, not the Product Spec object's Name
                productSpecMap.put(ccProductSpec.ccrz__Spec__r.Name, ccProductSpec);
            }

            // 2018-08-30  msobczak
            product.productSpecMap = productSpecMap;

            // Stash the Product's Related Products
            Map<String, ccrz__E_RelatedProduct__c> relatedProductMap = new Map<String, ccrz__E_RelatedProduct__c>();
            for(ccrz__E_RelatedProduct__c rp : ccProduct.ccrz__E_RelatedProducts__r) {
                relatedProductMap.put(rp.ccrz__RelatedProduct__r.ccrz__SKU__c, rp);
            }

            // 2018-08-30  msobczak
            product.relatedProductMap = relatedProductMap;

            // Stash the Product's Media
            Map<String, ccrz__E_ProductMedia__c> productMediaMap = new Map<String, ccrz__E_ProductMedia__c>();

            // *** PRODUCT MEDIA ***

            // 2018-09-24  msobczak
            List<ccrz__E_ProductMedia__c> productMediaList = new List<ccrz__E_ProductMedia__c>();
            Set<String> productMediaTypes = new Set<String>();

            for(ccrz__E_ProductMedia__c mp : ccProduct.ccrz__E_ProductMedias__r) {
                // 2018-08-30  msobczak: removed extra spaces before and after the hyphen
                productMediaMap.put(mp.ccrz__MediaType__c + '-' + mp.ccrz__ProductMediaSource__c, mp);

                // 2018-09-24  msobczak
                productMediaList.add(mp);
                productMediaTypes.add(mp.ccrz__MediaType__c);
            }

            // 2018-08-30  msobczak
            product.productMediaMap = productMediaMap;

            // 2018-09-24  msobczak
            product.productMediaList = productMediaList;
            product.productMediaTypes = productMediaTypes;


            // *** PRODUCT CATEGORIES ***

            // Stash the Product Categories
            // A product may be in more than one category at a time
            Map<String, ccrz__E_ProductCategory__c> productCategoryMap = new Map<String, ccrz__E_ProductCategory__c>();
            for(ccrz__E_ProductCategory__c category : ccProduct.ccrz__Product_Categories__r) {
                // 2018-08-30  msobczak: fixed to use the related category's ID as the key, not the product category object Id
                productCategoryMap.put(category.ccrz__Category__r.Id, category);
            }

            // 2018-08-30  msobczak
            product.productCategoryMap = productCategoryMap;

            productSet.put(ccProduct.ccrz__SKU__c, product);
        }

        return productSet;
    }

    /*
        Get a Map of all Specs.  The key is the Name.
     */
    private Map<String, ccrz__E_Spec__c> getSpecs() {
        Map<String, ccrz__E_Spec__c> specMap = new Map<String, ccrz__E_Spec__c>();

        List<ccrz__E_Spec__c> specList = [SELECT Id, Name,
                ccrz__UseForFilter__c,
                ccrz__Desc__c,
                ccrz__DisplayName__c,
                ccrz__FilterDisplayName__c,
                ccrz__FilterType__c,
                ccrz__IsComparable__c,
                ccrz__Locale__c,
                ccrz__SelectType__c,
                ccrz__Sequence__c,
                ccrz__SpecGroup__c
        FROM ccrz__E_Spec__c];

        for (ccrz__E_Spec__c spec : specList) {
            specMap.put(spec.Name, spec);
        }

        return specMap;

    }

    public class DataRecord {
        public String productName {get; set;}
        public String sku {get; set;}
        public String shortDesc {get; set;}
        public String longDesc {get; set;}
        public String seoTitle {get; set;}

        public String cat1 {get; set;}
        public String cat2 {get; set;}
        public String cat3 {get; set;}
        public String cat4 {get; set;}
        public String cat5 {get; set;}

        public Decimal price1 {get; set;}
        public Decimal price2 {get; set;}
        public Decimal price3 {get; set;}

        public List<Spec> specList {get; set;}

        public List<RelatedProduct> relatedProducts {get; set;}
        public List<ProductMedia> productMediaList {get; set;}

        public DataRecord() {
            specList = new List<Spec>();
            relatedProducts = new List<RelatedProduct>();
            productMediaList = new List<ProductMedia>();
        }
        /*
            Helper method to create a user friendly display of the category tree.
        */
        public String concat (String value, String existingValue) {

            //System.debug('value: ' + value);
            //System.debug('existingValue: ' + existingValue);

            String temp = '';

            if(value != null && value != '') {
                if(existingValue == '') {
                    temp = '/' + value;
                }
                else {
                    temp = existingValue + '/' + value;
                }
            }
            else {
                temp = existingValue;
            }

            //System.debug('temp: ' + temp);

            return temp;
        }

        public String getCategory () {
            String temp = '';

            temp = concat(cat1, temp);
            temp = concat(cat2, temp);
            temp = concat(cat3, temp);
            temp = concat(cat4, temp);
            temp = concat(cat5, temp);

            //System.debug('Category: ' + temp);

            return temp;
        }

        public String getCategoryValue(Integer level) {
            if(level == 1) {
                return cat1;
            }

            if(level == 2) {
                return cat2;
            }

            if(level == 3) {
                return cat3;
            }

            if(level == 4) {
                return cat4;
            }

            if(level == 5) {
                return cat5;
            }

            return null;
        }

        public String getCategoryBranch(Integer level) {
            String temp = null;

            if (level == 1) {
                if (cat1 == null || cat1 == '') {
                    return temp;
                }

                return '/' + cat1;
            }

            if (level == 2) {
                if (cat2 == null || cat2 == '') {
                    return temp;
                }

                return temp = '/' + cat1 + '/' + cat2;
            }

            if (level == 3) {
                if(cat3 == null || cat3 == '') {
                    return temp;
                }

                return temp = '/' + cat1 + '/' + cat2 + '/' + cat3;
            }

            if (level == 4) {
                if (cat4 == null || cat4 == '') {
                    return temp;
                }

                return '/' + cat1 + '/' + cat2 + '/' + cat3 + '/' + cat4;
            }

            if(level == 5) {
                if(cat5 == null || cat5 == '') {
                    return temp;
                }

                return temp = '/' + cat1 + '/' + cat2 + '/' + cat3 + '/' + cat4 + '/' + cat5;
            }

            return temp;
        }
    }

    public class Spec {
        public String name {get; set;}
        public String filterType {get; set;}
        public String value {get; set;}
    }

    public class ProductMedia {
        public String type {get; set;}
        public String mediaSource {get; set;}
        public String path {get; set;}
        public String staticResourceName {get; set;}
    }

    public class Product {
        public ccrz__E_Product__c ccProduct {get; set;}

        public Map<String, ccrz__E_PriceListItem__c> priceListItemMap {get; set;}
        public Map<String, ccrz__E_ProductSpec__c> productSpecMap {get; set;}
        public Map<String, ccrz__E_RelatedProduct__c> relatedProductMap {get; set;}
        public Map<String, ccrz__E_ProductMedia__c> productMediaMap {get; set;}
        public Map<String, ccrz__E_ProductCategory__c> productCategoryMap {get; set;}

        // 2018-09-24  msobczak
        public List<ccrz__E_ProductMedia__c> productMediaList {get; set;}
        public Set<String> productMediaTypes {get; set;}

        public Product() {
            priceListItemMap = new Map<String, ccrz__E_PriceListItem__c>();
            productSpecMap = new Map<String, ccrz__E_ProductSpec__c>();
            relatedProductMap = new Map<String, ccrz__E_RelatedProduct__c>();
            productMediaMap = new Map<String, ccrz__E_ProductMedia__c>();
            productCategoryMap = new Map<String, ccrz__E_ProductCategory__c>();

            // 2018-09-24  msobczak
            productMediaList = new List<ccrz__E_ProductMedia__c>();
            productMediaTypes = new Set<String>();

        }
    }

    public class RelatedProduct {
        public String sku {get; set;}
        public String type {get; set;}
    }

    private void addError(String msg)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    }

    public void addInfo(String msg)
    {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));
    }

    private String removeDoubleQuotes(String inputString) {
        String outputString = null;

        if(inputString.startsWith('"')) {
            outputString = inputString.substring(1);
        }

        if(outputString.endsWith('"')) {
            outputString = outputString.substringBeforeLast('"');
        }

        return outputString;
    }

    public PageReference backToStartPage() {
        String url = '/apex/cc_POC_DataLoader';

        PageReference pr = new PageReference(url);
        return pr;
    }

    private void clearErrors() {
        hasError = false;
        errorCounter = 0;
        errorMap = new Map<Integer, List<String>>();
        errorList = new Set<String>();
    }

    private final String PROCESS_NAME = 'CC_Product_Image_Clone';

    /*
        This only works when remote sites have been created.
     */
    /*
    public Boolean doesMediaProcessFlowExist() {
        String auth = 'Bearer ' + UserInfo.getSessionId();
        String query = 'SELECT DeveloperName, ActiveVersionId FROM FlowDefinition where DeveloperName = \'' + PROCESS_NAME + '\'';
        String endpoint = URL.getSalesforceBaseUrl().toExternalForm() +
                '/services/data/v41.0/tooling/query/?q=' +
                EncodingUtil.urlEncode(query, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setHeader('Authorization', auth);
        request.setEndpoint(endpoint);
        request.setMethod('GET');

        HttpResponse response = new Http().send(request);
        system.debug(response.getBody());

        String body = response.getBody();

        Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(body);

        Integer size = (Integer)responseMap.get('size');

        if(size == 1) {
            return true;
        }
        else {
            return false;
        }


    }
    */

    public Boolean doesMediaProcessFlowExist() {
        Boolean flowExists = false;
        try {
            Flow.Interview.createInterview(PROCESS_NAME, new Map<String, Object>());
            flowExists = true;
        }
        catch(TypeException e) {}

        return flowExists;
    }

    public Map<String, Category> createCategoryBranchMap() {

        System.debug('createCategoryBranchMap() begin');

        /*
            Build a map of all categories by parent category Id.
            The Map key is the parent category Id.
            Unfortunately, all categories are included.
            I don't have a way to just get the categories that descend from the Root Category Id selected for the current Storefront.
            (Categories don't have a Storefront value.)
         */

        List<ccrz__E_Category__c> allCategoryList = [SELECT Id, Name, ccrz__CategoryID__c, ccrz__Sequence__c, ccrz__ParentCategory__c FROM ccrz__E_Category__c WHERE ccrz__ParentCategory__c != NULL];

        for(ccrz__E_Category__c ccCategory : allCategoryList) {

            List<Id> childCatList = null;

            if(parentCategoryMap.containsKey(ccCategory.ccrz__ParentCategory__c)) {
                childCatList = parentCategoryMap.get(ccCategory.ccrz__ParentCategory__c);

            }
            else {
                childCatList = new List<Id>();
            }

            childCatList.add(ccCategory.Id);
            parentCategoryMap.put(ccCategory.ccrz__ParentCategory__c, childCatList);
        }

        Set<Id> childCategoryIds = new Set<Id>();

        childCategoryIds.add(selectedRootCategoryObjId);

        getChildCategories(childCategoryIds, categoryMap, parentCategoryMap);

        // Create the branch for each category
        for(Id catId : categoryMap.keySet()) {
            Category category = categoryMap.get(catId);

            if(category.parentId != null) {
                category.branch = buildCategoryBranch ('/' + category.name, category.parentId, categoryMap);
            }
        }

        for(Id catId : categoryMap.keySet()) {
            Category category = categoryMap.get(catId);

            categoryBranchMap.put(category.branch, category);

        }

        System.debug('categoryBranchMap: ' + categoryBranchMap);

        System.debug('createCategoryBranchMap() exit');

        return categoryBranchMap;

    }

    /*
        Recursively add all child categories to the current category.
     */
    public void getChildCategories(Set<Id> categoryIds, Map<Id, Category> categoryMap, Map<Id, List<Id>> parentCategoryMap) {

        List<ccrz__E_Category__c> categories = [SELECT Id, Name, ccrz__ParentCategory__c FROM ccrz__E_Category__c WHERE ccrz__ParentCategory__c IN :categoryIds];

        Set<Id> childCategoryIds = new Set<Id>();

        for(ccrz__E_Category__c cat : categories) {

            //System.debug('processing category: ' + cat.Name);

            Category childCategory = new Category();
            childCategory.Id = cat.Id;
            childCategory.parentId = cat.ccrz__ParentCategory__c;
            childCategory.name = cat.Name;

            // Add the current category to the Map
            categoryMap.put(cat.Id, childCategory);

            // See if the current category has any children
            if(parentCategoryMap.containsKey(childCategory.Id)) {
                List<Id> childCatIds = parentCategoryMap.get(childCategory.Id);
                if(childCatIds.size() > 0) {
                    childCategoryIds.add(childCategory.Id);
                }
            }

        }

        if(childCategoryIds.size() > 0) {
            getChildCategories(childCategoryIds, categoryMap, parentCategoryMap);
        }

    }

    /*
        Recursively create the category branch (ex: /Tires/Goodyear/Passenger)
     */
    public String buildCategoryBranch (String branch, Id categoryId, Map<Id, Category> categoryMap) {

        //System.debug('branch: ' + branch);

        String newBranch = '';

        if(categoryId != null && categoryMap.containsKey(categoryId)) {
            Category category = categoryMap.get(categoryId);
            newBranch = '/' + category.name + branch;

            if(category.parentId != null) {
                newBranch = buildCategoryBranch(newBranch, category.parentId, categoryMap);
            }
            else {
                newBranch = branch;
            }

        }
        else {
            newBranch = branch;
        }

        //System.debug('returning: ' + newBranch);

        return newBranch;

    }

    public class Category {
        public Id Id {get; set;}
        public Id parentId {get; set;}
        public String name {get; set;}
        public String branch {get; set;}

    }

    public static String getGuid() {
        Blob b = Crypto.generateAesKey(128);
        String h = EncodingUtil.convertToHex(b);
        String guid = h.substring(0,8)+ '-' + h.substring(8,12) + '-' + h.substring(12,16) + '-' + h.substring(16,20) + '-' + h.substring(20);

        return guid;
    }

    /*
        Update the category maps after new ccCategory objects have been created.

        This is done to save on SOQL queries after each level of categories have been inserted.
     */
    private void updateCategoryMap(List<ccrz__E_Category__c>  objectsAdd) {

        // Add all of the new categories to the catgoryMap
        for(ccrz__E_Category__c cat : objectsAdd) {

            Category childCategory = new Category();
            childCategory.Id = cat.Id;
            childCategory.parentId = cat.ccrz__ParentCategory__c;
            childCategory.name = cat.Name;

            // Add the current category to the Map
            categoryMap.put(cat.Id, childCategory);

        }

        // Create the branch for each category
        for(Id catId : categoryMap.keySet()) {
            Category category = categoryMap.get(catId);

            if(category.parentId != null && category.branch == null) {
                category.branch = buildCategoryBranch ('/' + category.name, category.parentId, categoryMap);
            }
        }

        // Update Map of category branches

        for(Id catId : categoryMap.keySet()) {
            Category category = categoryMap.get(catId);

            categoryBranchMap.put(category.branch, category);

        }

        System.debug('categoryBranchMap: ' + categoryBranchMap);

    }

}
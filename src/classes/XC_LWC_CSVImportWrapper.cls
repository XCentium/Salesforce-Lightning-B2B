/**
 * @FileName: XC_LWC_CSVImportWrapper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/15/2020         Created
 *-----------------------------------------------------------  
 */
public with sharing class XC_LWC_CSVImportWrapper {
    private String csvContents;
    private Map<String,Product2> productBySku;
    private List<String> csvLines;

    public Map<String,String> items;

    public XC_LWC_CSVImportWrapper(String csvContents) {
        this.csvContents = csvContents;
        this.items = new Map<String,String>();

        getCSVLines();
        getProductBySku();
        setItemMap();
    }

    private void getCSVLines() {
        csvLines = csvContents.split('\n');
        csvLines.remove(0);
    }

    private void getProductBySku() {
        Set<String> productSkus = new Set<String>();

        for (String line : csvLines) {
            List<String> rowData = line.split(',');

            productSkus.add(rowData[0]);
        }

        List<Product2> products = [SELECT Id, StockKeepingUnit FROM Product2 WHERE StockKeepingUnit IN :productSkus];

        this.productBySku = (Map<String,Product2>) JSON.deserialize(
                XC_Util_Apex.convertListToMap((List<SObject>) products, 'StockKeepingUnit', false),
                Map<String,Product2>.class
        );
    }
    
    private void setItemMap() {
        for (String line : csvLines) {
            List<String> rowData = line.split(',');

            Product2 product = productBySku.get(rowData[0]);

            items.put(product.Id, rowData[1].deleteWhitespace());
        }
    }
}
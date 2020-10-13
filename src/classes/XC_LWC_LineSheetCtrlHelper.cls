/*
 * @FileName: XC_LWC_LineSheetCtrlHelper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/21/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_LineSheetCtrlHelper {

    public static String getTemplateOptions() {
        return JSON.serialize(
                XC_Util_Apex.getFieldPicklistValues(
                        'XC_Line_Sheet__c',
                        'XC_Template__c',
                        true
                )
        );
    }

    public static String getLineSheets() {
        List<XC_Line_Sheet__c> lineSheets = [SELECT Id, Name, XC_Contact__r.Name FROM XC_Line_Sheet__c ORDER BY Name];

        List<XC_LWC_LineSheetWrappers.LineSheetWrapper> wrappers = new List<XC_LWC_LineSheetWrappers.LineSheetWrapper>();

        for (XC_Line_Sheet__c lineSheet : lineSheets) {
            XC_LWC_LineSheetWrappers.LineSheetWrapper wrapper = new XC_LWC_LineSheetWrappers.LineSheetWrapper();
            wrapper.id = lineSheet.Id;
            wrapper.name = lineSheet.Name;
            wrapper.contactId = lineSheet.XC_Contact__c;
            wrapper.contactName = lineSheet.XC_Contact__r.Name;

            wrappers.add(wrapper);
        }

        return JSON.serialize(wrappers);
    }

    public static String getContactLineSheets() {
        List<XC_Line_Sheet__c> lineSheets = [
                SELECT Id, Name, XC_Contact__r.Name
                FROM XC_Line_Sheet__c
                WHERE XC_Contact__c = :XC_Util_Query.currentUser.ContactId
                ORDER BY Name
        ];

        List<XC_LWC_LineSheetWrappers.LineSheetWrapper> wrappers = new List<XC_LWC_LineSheetWrappers.LineSheetWrapper>();

        for (XC_Line_Sheet__c lineSheet : lineSheets) {
            XC_LWC_LineSheetWrappers.LineSheetWrapper wrapper = new XC_LWC_LineSheetWrappers.LineSheetWrapper();
            wrapper.id = lineSheet.Id;
            wrapper.name = lineSheet.Name;
            wrapper.contactId = lineSheet.XC_Contact__c;
            wrapper.contactName = lineSheet.XC_Contact__r.Name;

            wrappers.add(wrapper);
        }

        return JSON.serialize(wrappers);
    }

    public static String getLineSheet(String lineSheetId) {
        XC_LWC_LineSheetWrappers.LineSheetWrapper wrapper;

        XC_Line_Sheet__c lineSheet = [
                SELECT Id, Name, XC_Template__c, XC_Contact__c, XC_Contact__r.Name, Header_Image_URL__c, Header_Text__c,
                        Line_Sheet_Text__c, Footer_Image_URL__c, Footer_Text__c,
                        (SELECT Id, XC_Product__c, XC_Sort_Order__c
                        FROM Line_Sheet_Items__r
                        ORDER BY XC_Sort_Order__c ASC)
                FROM XC_Line_Sheet__c
                WHERE Id = :lineSheetId
        ];

        wrapper = new XC_LWC_LineSheetWrappers.LineSheetWrapper(lineSheet);
        wrapper.lineSheetItems = getLineSheetItems(lineSheet.Line_Sheet_Items__r, lineSheet.XC_Contact__c);

        return JSON.serialize(wrapper);
    }

    public static String getItem(String productId, String contactId) {
        List<XC_Line_Sheet_Item__c> itemList = new List<XC_Line_Sheet_Item__c>{
                new XC_Line_Sheet_Item__c(XC_Product__c = productId, XC_Sort_Order__c = 0)
        };

        return JSON.serialize(getLineSheetItems(itemList, contactId)[0]);
    }

    private static List<XC_LWC_LineSheetWrappers.LineSheetItemWrapper> getLineSheetItems(
            List<XC_Line_Sheet_Item__c> items,
            String contactId)
    {
        Map<String, XC_LWC_LineSheetWrappers.LineSheetItemWrapper> itemMap =
                new Map<String, XC_LWC_LineSheetWrappers.LineSheetItemWrapper>();

        Id accountId = [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId;

        if (items != null && !items.isEmpty()) {
            for (XC_Line_Sheet_Item__c item : items) {
                XC_LWC_ProductWrappers.ProductDetails productWrapper = XC_LWC_ProductCtrl.getProduct(
                        item.XC_Product__c,
                        accountId
                );

                itemMap.put(item.XC_Product__c, new XC_LWC_LineSheetWrappers.LineSheetItemWrapper(item, productWrapper));
            }
        }

        return itemMap.values();
    }

    public static String saveLineSheet(String wrapperJSON) {
        XC_LWC_LineSheetWrappers.LineSheetWrapper wrapper = (XC_LWC_LineSheetWrappers.LineSheetWrapper)
                JSON.deserialize(wrapperJSON, XC_LWC_LineSheetWrappers.LineSheetWrapper.class);

        XC_Line_Sheet__c lineSheet = new XC_Line_Sheet__c(
                XC_Template__c = checkNull(wrapper.template),
                XC_Contact__c = checkNull(wrapper.contactId),
                Header_Text__c = checkNull(wrapper.headerText),
                Header_Image_URL__c = checkNull(wrapper.headerImageUrl),
                Line_Sheet_Text__c = checkNull(wrapper.lineSheetText),
                Footer_Text__c = checkNull(wrapper.footerText),
                Footer_Image_URL__c = checkNull(wrapper.footerImageUrl)
        );

        if (String.isNotBlank(wrapper.id)) {
            lineSheet.Id = wrapper.id;
        }

        upsert lineSheet;

        Map<Id, XC_Line_Sheet_Item__c> lineSheetItemsToDelete = new Map<Id, XC_Line_Sheet_Item__c>([
                SELECT Id
                FROM XC_Line_Sheet_Item__c
                WHERE XC_Line_Sheet__c = :lineSheet.Id
        ]);

        List<XC_Line_Sheet_Item__c> lineSheetItemsToUpsert = new List<XC_Line_Sheet_Item__c>();

        for (XC_LWC_LineSheetWrappers.LineSheetItemWrapper itemWrapper : wrapper.lineSheetItems) {
            XC_Line_Sheet_Item__c item = new XC_Line_Sheet_Item__c(
                    XC_Line_Sheet__c = lineSheet.Id,
                    XC_Product__c = itemWrapper.productId,
                    XC_Sort_Order__c = itemWrapper.sortOrder
            );

            if (String.isNotBlank(itemWrapper.id)) {
                if (lineSheetItemsToDelete.containsKey(itemWrapper.id)) {
                    lineSheetItemsToDelete.remove(itemWrapper.id);
                }

                item.Id = itemWrapper.id;
            }

            lineSheetItemsToUpsert.add(item);
        }

        upsert lineSheetItemsToUpsert;
        delete lineSheetItemsToDelete.values();

        return lineSheet.Id;
    }

    public static void deleteLineSheet(String lineSheetId) {
        delete new XC_Line_Sheet__c(Id = lineSheetId);
    }

    private static String checkNull(String value) {
        return value != null ? value : '';
    }
}
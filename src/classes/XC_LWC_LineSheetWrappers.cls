/*
 * @FileName: XC_LWC_LineSheetWrappers
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/21/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_LineSheetWrappers {

    public class LineSheetWrapper {
        public String id;
        public String name;
        public String template;
        public String contactId;
        public String contactName;
        public String headerImageUrl;
        public String headerText;
        public String lineSheetText;
        public String footerImageUrl;
        public String footerText;
        public List<LineSheetItemWrapper> lineSheetItems;

        public LineSheetWrapper() {}

        public LineSheetWrapper(XC_Line_Sheet__c lineSheet) {
            this.id = lineSheet.Id;
            this.name = lineSheet.Name;
            this.template = lineSheet.XC_Template__c;
            this.contactId = lineSheet.XC_Contact__c;
            this.contactName = lineSheet.XC_Contact__r.Name;
            this.headerImageUrl = lineSheet.Header_Image_URL__c;
            this.headerText = lineSheet.Header_Text__c;
            this.lineSheetText = lineSheet.Line_Sheet_Text__c;
            this.footerImageUrl = lineSheet.Footer_Image_URL__c;
            this.footerText = lineSheet.Footer_Text__c;
        }
    }

    public class LineSheetItemWrapper {
        public String id;
        public Integer sortOrder;
        public String productId;
        public String productName;
        public String sku;
        public String imgURL;
        public String altText;

        public LineSheetItemWrapper(XC_Line_Sheet_Item__c item, XC_LWC_ProductWrappers.ProductDetails productWrapper) {
            Map<String,Object> fields = (Map<String,Object>) productWrapper.productDetail.fields;
            ConnectApi.ProductMedia imageDetails = productWrapper.productDetail.defaultImage;

            this.id = item.Id;
            this.sortOrder = Integer.valueOf(item.XC_Sort_Order__c);
            this.productId = item.XC_Product__c;
            this.productName = (String) fields.get('Name');
            this.sku = (String) fields.get('StockKeepingUnit');
            this.imgURL = imageDetails.url;
            this.altText = imageDetails.alternateText;
        }
    }
}
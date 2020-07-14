/**
 * @FileName: XC_LWC_MenuWrapper
 * @Description:
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       6/18/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_MenuWrapper {
    private String menuName;
    private List<Menu_Item__c> menuData;
    private Map<String, ProductCategory> categoriesByName;
    public List<MenuItem> menuItems;

    public XC_LWC_MenuWrapper(String menuName) {
        this.menuName = menuName;
        this.menuItems = new List<MenuItem>();

        fetchMenuItems();
        getCategories();

        this.menuItems = createItemWrappers(this.menuData);
    }

    private void fetchMenuItems() {
        this.menuData = [
                SELECT Id, Name, Publicly_Available__c, Display_Type__c, Type__c, Category_Name__c,
                    Community_Page_Name__c, External_URL__c, Menu_Column__c,
                    (SELECT Id, Name, Publicly_Available__c, Display_Type__c, Type__c, Category_Name__c,
                    Community_Page_Name__c, External_URL__c, Menu_Column__c
                    FROM Menu_Items__r
                    ORDER BY Sequence__c ASC NULLS LAST)
                FROM Menu_Item__c
                WHERE Menu__r.Name = :menuName
                ORDER BY Sequence__c ASC NULLS LAST
        ];
    }

    private void getCategories() {
        Set<String> categoryNames = new Set<String>();

        for (Menu_Item__c item : this.menuData) {
            if (item.Type__c == 'Category' ) {
                categoryNames.add(item.Category_Name__c);
            }

            for (Menu_Item__c childItem : item.Menu_Items__r) {
                if (childItem.Type__c == 'Category') {
                    categoryNames.add(childItem.Category_Name__c);
                }
            }
        }

        List<ProductCategory> categories = [
                SELECT Id, Name, ParentCategory.Name
                FROM ProductCategory
                WHERE Name IN :categoryNames
        ];

        this.categoriesByName = (Map<String, ProductCategory>) JSON.deserialize(
                XC_Util_Apex.convertListToMap(categories, 'Name', false),
                Map<String, ProductCategory>.class
        );
    }

    private List<MenuItem> createItemWrappers(List<Menu_Item__c> menuData) {
        List<MenuItem> menuItems = new List<MenuItem>();

        for (Menu_Item__c item : menuData) {
            //String url = constructUrl(item);

            String recordId = item.Type__c == 'Category' ? categoriesByName.get(item.Category_Name__c).Id : null;

            MenuItem itemWrapper = new MenuItem(item, recordId);

            menuItems.add(itemWrapper);

            if (item.Menu_Items__r.isEmpty()) continue;

            itemWrapper.hasChildItems = true;
            itemWrapper.childItems = createItemWrappers(item.Menu_Items__r);

            if (item.Display_Type__c == 'Mega Menu') {
                Map<String, MegaMenuColumn> megaMenuMap = new Map<String, MegaMenuColumn>();

                for (MenuItem childItem : itemWrapper.childItems) {
                    MegaMenuColumn column = megaMenuMap.get(childItem.menuColumn);

                    if (column == null) {
                        column = new MegaMenuColumn();
                        column.label = childItem.menuColumn;
                        column.childItems = new List<MenuItem>();
                    }

                    column.childItems.add(childItem);

                    megaMenuMap.put(childItem.menuColumn, column);
                }

                for (MegaMenuColumn column : megaMenuMap.values()) {
                    itemWrapper.megaMenuColumns.add(column);
                }
            }
        }

        return menuItems;
    }

//    private String constructUrl(Menu_Item__c item) {
//        String url;
//
//        switch on item.Type__c {
//            when 'External URL' {
//                url = item.External_URL__c;
//            }
//            when 'Category' {
//                ProductCategory category = categoriesByName.get(item.Category_Name__c);
//
//                url = 'category/';
//
//                if (String.isNotBlank(category.ParentCategoryId)) {
//                    url += category.ParentCategory.Name.toLowerCase() + '/';
//                }
//
//                url += + category.Name.toLowerCase() + '/' + category.Id;
//            }
//            when 'Community Page' {
//                String pageName = item.Community_Page_Name__c.replace(' ', '-').toLowerCase();
//
//                if (pageName == 'home') {
//                    url = 'albatrossgolf/s/';
//                }
//                else {
//                    url = 'albatrossgolf/s/comm-' + pageName;
//                }
//
//            }
//        }
//
//        return url;
//    }

    public class MenuItem {
        @AuraEnabled public String label;
        @AuraEnabled public String type;
        @AuraEnabled public Boolean megaMenu;
        @AuraEnabled public String menuColumn;
        @AuraEnabled public String recordId;
        @AuraEnabled public String objectApiName;
        @AuraEnabled public String pageName;
        @AuraEnabled public List<MenuItem> childItems;
        @AuraEnabled public List<MegaMenuColumn> megaMenuColumns;
        @AuraEnabled public Boolean hasChildItems;

        private MenuItem(Menu_Item__c item, String recordId) {
            // Shared Attributes
            this.label = item.Name;
            this.type = 'comm__namedPage';
            this.recordId = recordId;
            this.objectApiName = 'ProductCategory';
            this.pageName = String.isNotBlank(item.Community_Page_Name__c) ? item.Community_Page_Name__c.replace(' ', '_') : '';

            // Parent Attributes
            this.megaMenu = item.Display_Type__c == 'Mega Menu' ? true : false;
            this.childItems = new List<MenuItem>();
            this.megaMenuColumns = new List<MegaMenuColumn>();
            this.hasChildItems = false;

            // Child Attributes
            this.menuColumn = item.Menu_Column__c;
        }
    }

    public class MegaMenuColumn {
        @AuraEnabled public String label;
        @AuraEnabled public List<MenuItem> childItems;
    }
}
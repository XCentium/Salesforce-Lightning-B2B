/*
   @Author: EDL Resource
   @Updated By: Accenture,
   @Name:ckz_bean_OrderBuilderMap
   @CreateDate: 11/11/2014
   @Description:ckz_bean_OrderBuilderMap
   @Version: 1.0
 */

/* Bean class for order builder */
global with sharing class ckz_bean_OrderBuilderMap implements Comparable {
    /* Fields for bean class */
    public String sfid { get; set; }
    public ckz_bean_OrderItem uniqueOrderItem { set; get; }
    public List<Integer> quantities { set; get; }


    /* created enum variable that will  decide the base of sorting.*/
    public enum SORT_BY {
        ByArticleCode, ByTradeMark, ByUnitOfMeasure
    }
    public static SORT_BY sortBy = SORT_BY.ByTradeMark;
    public static boolean ascOrder = true;   // boolean varialble to decide sort order.

    /*Default Contructor*/
    public ckz_bean_OrderBuilderMap() {
    }

    /*Parameterized Contructor*/
    public ckz_bean_OrderBuilderMap(ckz_bean_OrderItem uniqueOrderItem, List<Integer> quantities) {
        this.uniqueOrderItem = uniqueOrderItem;
        this.quantities = quantities;

    }

    /* Over-riding compareto function to compare the elements for sorting.*/
    global Integer compareTo(Object other) {
        ckz_bean_OrderBuilderMap obm = (ckz_bean_OrderBuilderMap) other;

        if (ascOrder) {
            if (sortBy == SORT_BY.ByArticleCode) {
                Integer thssku = Integer.ValueOf(this.uniqueOrderItem.productSKU);
                Integer obmsku = Integer.ValueOf(obm.uniqueOrderItem.productSKU);
                if (thssku == obmsku) {
                    return 0;
                } else if (thssku > obmsku) {
                    return 1;
                } else {
                    return -1;
                }
            } else if (sortBy == SORT_BY.ByTradeMark) {
                if (this.uniqueOrderItem.tradeMark == null) {
                    return -1;
                } else if (obm.uniqueOrderItem.tradeMark == null) {
                    return 1;
                } else {
                    return this.uniqueOrderItem.tradeMark.compareTo(obm.uniqueOrderItem.tradeMark);
                }
            } else {
                if (this.uniqueOrderItem.unitOfMeasureQuantity == null) {
                    return -1;
                } else if (obm.uniqueOrderItem.unitOfMeasureQuantity == null) {
                    return 1;
                } else {
                    return this.uniqueOrderItem.unitOfMeasureQuantity.compareTo(obm.uniqueOrderItem.unitOfMeasureQuantity);
                }
            }
        } else {
            if (sortBy == SORT_BY.ByArticleCode) {
                Integer thssku = Integer.ValueOf(this.uniqueOrderItem.productSKU);
                Integer obmsku = Integer.ValueOf(obm.uniqueOrderItem.productSKU);
                if (thssku == obmsku) {
                    return 0;
                } else if (thssku > obmsku) {
                    return -1;
                } else {
                    return 1;
                }
            } else if (sortBy == SORT_BY.ByTradeMark) {
                if (this.uniqueOrderItem.tradeMark == null) {
                    return 1;
                } else if (obm.uniqueOrderItem.tradeMark == null) {
                    return -1;
                } else {
                    return (this.uniqueOrderItem.tradeMark.compareTo(obm.uniqueOrderItem.tradeMark)) * -1;
                }
            } else {
                if (this.uniqueOrderItem.unitOfMeasureQuantity == null) {
                    return 1;
                } else if (obm.uniqueOrderItem.unitOfMeasureQuantity == null) {
                    return -1;
                } else {
                    return (this.uniqueOrderItem.unitOfMeasureQuantity.compareTo(obm.uniqueOrderItem.unitOfMeasureQuantity)) * -1;
                }
            }
        }

    }

}
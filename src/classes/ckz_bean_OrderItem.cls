/*
   @Updated By: Accenture,
   @Name:cc_ccr_bean_OrderBuilderMap
   @CreateDate: 11/11/2014
   @Description:cc_ccr_bean_OrderBuilderMap
   @Version: 1.0
 */

/* Bean class for order items */
global with sharing class ckz_bean_OrderItem {
    public String sfid { get; set; }
    public String productId { get; set; }
    public String productName { get; set; }
    public String productSKU { get; set; }
    public String prodSalesMethod { get; set; }
    public String unitOfMeasureQuantity { get; set; }
    public Integer quantityPerUnit { get; set; }
    public string inventory { get; set; }
    public Integer quantity { get; set; }
    public Integer quantityInCart { get; set; }
    public Date productEndDate { get; set; }
    public Boolean bolQty { get; set; }
    public Boolean productblocked { get; set; }
    public ckz_bean_MediaWrapper mediaWrapper { get; set; }
    public String unitOfMeasure { get; set; }
    public String tradeMark { get; set; }
    public string userLocale { get; set; }
    public string brand { get; set; }
    public string category { get; set; }


    /* Default constructor for ckz_bean_OrderItem */
    public ckz_bean_OrderItem() {
    }

    /* Parametreized constructor for ckz_bean_OrderItem */
    public ckz_bean_OrderItem(String productId,
            String productNameP,
            String productSKUP,
            String unitOfMeasureQuantityP,
            Integer quantityPerUnit,
            string inventory,
            Integer quantityP,
            Integer quantityInCartP,
            ckz_bean_MediaWrapper mediaWrapper, String unitOfMeasure,
            String tradeMark, Date productEndDate, Boolean bolQty, string userLocale, Boolean productblocked) {
        this.productId = productId;
        this.productName = productNameP;
        this.productSKU = productSKUP;
        this.unitOfMeasureQuantity = unitOfMeasureQuantityP;
        this.quantityPerUnit = quantityPerUnit;
        this.inventory = inventory;
        this.quantity = quantityP;
        this.quantityInCart = quantityInCartP;
        this.mediaWrapper = mediaWrapper;
        this.tradeMark = tradeMark;
        this.unitOfMeasure = unitOfMeasure;
        this.productEndDate = productEndDate;
        this.bolQty = bolQty;
        this.userLocale = userLocale;
        this.productblocked = productblocked;

    }
    public ckz_bean_OrderItem(String productId,
            String productNameP,
            String productSKUP,
            String unitOfMeasureQuantityP,
            Integer quantityPerUnit,
            string inventory,
            Integer quantityP,
            Integer quantityInCartP,
            ckz_bean_MediaWrapper mediaWrapper, String unitOfMeasure,
            String tradeMark, Date productEndDate, Boolean bolQty, string userLocale, Boolean productblocked,
            String brand, String category) {
        this.productId = productId;
        this.productName = productNameP;
        this.productSKU = productSKUP;
        this.unitOfMeasureQuantity = unitOfMeasureQuantityP;
        this.quantityPerUnit = quantityPerUnit;
        this.inventory = inventory;
        this.quantity = quantityP;
        this.quantityInCart = quantityInCartP;
        this.mediaWrapper = mediaWrapper;
        this.tradeMark = tradeMark;
        this.unitOfMeasure = unitOfMeasure;
        this.productEndDate = productEndDate;
        this.bolQty = bolQty;
        this.userLocale = userLocale;
        this.productblocked = productblocked;
        this.brand = brand;
        this.category = category;


    }

}
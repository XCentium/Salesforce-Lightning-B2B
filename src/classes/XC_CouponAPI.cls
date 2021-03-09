/*******************************************************************************************
* @Name         XC_CouponAPI
* @Author       Brian Zigarovich <brian.zigarovich@xcentium.com>
* @Date         01/06/2021
* @Group        Coupon
* @Description  Coupon API logic.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Brian           01/06/2020          Initial Creation                    
*******************************************************************************************/
public with sharing class XC_CouponAPI {

    /**
     * Promo prefix
     */
    private static final String PROMO_PREFIX = 'PROMO:';

    /**
     * Coupon exception.
     */
    public class XC_CouponException extends Exception {}

    /**
     * Cart record
     */
    private WebCart mCart;

    /**************************************************************************************
    * @Description  Constructor
    * @Param        cartId - the cart record Id
    * @Return       The constructed object
    * @Example
    **************************************************************************************/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public XC_CouponAPI(String cartId) {
        this.mCart = [
            SELECT Id, WebStore.Name, XC_Coupon__c, XC_Coupon__r.XC_CouponCode__c,
                XC_Coupon__r.XC_CouponName__c, TotalProductAmount, TotalProductCount,
                TotalListAmount
            FROM WebCart
            WHERE Id = :cartId
        ];
    }

    /**************************************************************************************
    * @Description  Gets the applied coupon details
    * @Param        
    * @Return       applied coupon details
    * @Example
    **************************************************************************************/
    public Map<String, Object> getCouponDetails() {
        System.debug(this.mCart);
        Boolean hasCoupon = null != this.mCart.XC_Coupon__c;
        return new Map<String, Object>{
            'hasCoupon' => hasCoupon,
            'code' => hasCoupon ? this.mCart.XC_Coupon__r.XC_CouponCode__c : null,
            'name' => hasCoupon ? this.mCart.XC_Coupon__r.XC_CouponName__c : null
        };
    }

    /**************************************************************************************
    * @Description  Applies the coupon to the cart.
    * @Param        code - the coupon code
    * @Return       true if coupon was applied; throws error if not applied
    * @Example
    **************************************************************************************/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Map<String, Object> addCoupon(String code) {
        try {
            XC_Coupon__c coupon =
                lookupCoupon(null != code ? code : this.mCart.XC_Coupon__r.XC_CouponCode__c);

            // Perform validation
            checkDateRange(coupon);
            checkMaxUsage(coupon);
            //checkCurrencyCode(coupon);
            checkMinAmount(coupon);

            // Perform DML (if here, validation passed)
            this.mCart.XC_Coupon__c = coupon.Id;
            update this.mCart;

            return new Map<String, Object>{
                'success' => true,
                'code' => coupon.XC_CouponCode__c,
                'name' => coupon.XC_CouponName__c
            };
        } catch (Exception e) {
            this.mCart.XC_Coupon__c = null;
            this.mCart.XC_TotalDiscount__c = 0;
            update this.mCart;
            throw e;
        }
    }

    /**************************************************************************************
    * @Description  Applies the coupon discounts to the cart.
    * @Param        
    * @Return       true if coupon was applied; throws error if not applied
    * @Example
    **************************************************************************************/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Map<String, Object> applyDiscounts() {

        try {
            XC_Coupon__c coupon = lookupCoupon(this.mCart.XC_Coupon__r.XC_CouponCode__c);

            // Determine the type
            switch on (coupon.XC_DiscountType__c) {
                when 'Absolute' {
                    this.mCart.XC_TotalDiscount__c = coupon.XC_DiscountAmount__c;
                }
                when 'Percentage' {
                    this.mCart.XC_TotalDiscount__c =
                        this.mCart.TotalProductAmount * (coupon.XC_DiscountAmount__c / 100.00);
                }
                when 'Price' {
                    // not supported
                }
            }
            update this.mCart;

            // Adds coupon item
            addCouponItem(this.mCart.XC_Coupon__r.XC_CouponCode__c,
                this.mCart.XC_TotalDiscount__c);
        } catch (Exception e) {
            this.mCart.XC_TotalDiscount__c = 0;
            update this.mCart;
        }

        return new Map<String, Object>{
            'totalListAmount' => this.mCart.TotalListAmount,
            'totalProductAmount' => this.mCart.TotalProductAmount,
            'totalDiscount' => this.mCart.XC_TotalDiscount__c
        };
    }

    /**************************************************************************************
    * @Description  Removes the coupon from the cart.
    * @Param        
    * @Return       true if coupon was removed; throws error if not removed
    * @Example
    **************************************************************************************/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public Map<String, Object> removeCoupon() {
        Boolean success;
        try {
            // Perform DML
            this.mCart.XC_Coupon__c = null;
            update this.mCart;

            delete [
                SELECT Id
                FROM CartItem
                WHERE CartId = :this.mCart.Id AND
                    XC_CartCouponId__c = :(PROMO_PREFIX + this.mCart.Id)
                LIMIT 1
            ];

            success = true;
        } catch (Exception e) {
            success = false;
        }

        return new Map<String, Object>{
            'success' => true
        };
    }

    /**************************************************************************************
    * @Description  Adds coupon cart item
    * @Param        code   - the coupon code
    *               amount - the coupon amount
    * @Return       void
    * @Example
    **************************************************************************************/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private void addCouponItem(String code, Decimal amount) {
        Product2 prod = [
            SELECT Id, Name, ProductCode
            FROM Product2
            WHERE ProductCode = :code AND IsActive = true
        ];

        Decimal negativeAmount = -1 * amount;
        CartItem tmp = [
            SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :this.mCart.Id LIMIT 1
        ];
        CartItem ci = new CartItem(
            Name = prod.Name,
            CartId = this.mCart.Id,
            CartDeliveryGroupId = tmp.CartDeliveryGroupId,
            Product2Id = prod.Id,
            Type = 'Charge',
            Sku = prod.ProductCode,
            Quantity = 1,
            ListPrice = negativeAmount,
            UnitAdjustmentAmount = 0.0,
            UnitAdjustedPrice = 0.0,
            TotalListPrice = negativeAmount,
            TotalLineAmount = negativeAmount,
            AdjustmentAmount = 0.0,
            AdjustmentTaxAmount = 0.0,
            TotalPrice = negativeAmount,
            XC_CartCouponId__c = PROMO_PREFIX + this.mCart.Id,
            XC_IsCoupon__c = true
        );
        upsert ci XC_CartCouponId__c;
    }

    /**************************************************************************************
    * @Description  Looks up coupon.
    * @Param        code - the coupon code
    * @Return       the coupon record
    * @Example
    **************************************************************************************/
    @SuppressWarnings('PMD.ApexCRUDViolation')
    private XC_Coupon__c lookupCoupon(String code) {
        try {
            return [
                SELECT Id, XC_RuleType__c, XC_StartDate__c, XC_EndDate__c,
                    XC_DiscountAmount__c, XC_DiscountType__c, XC_CouponType__c,
                    XC_TotalUsed__c, XC_MaxUse__c, XC_CurrencyISOCode__c,
                    XC_CartTotalAmount__c, XC_CouponName__c, XC_CouponCode__c
                FROM XC_Coupon__c
                WHERE XC_CouponCode__c = :code AND
                    XC_Enabled__c = true
                LIMIT 1
            ];
        } catch (Exception e) {
            throw new XC_CouponException('Invalid Code');
        }
    }

    /**************************************************************************************
    * @Description  Check coupon start and end dates.
    * @Param        coupon - the coupon to check
    * @Return       true if the coupon passes the validity check; otherwise throw error
    * @Example
    **************************************************************************************/
    @TestVisible
    private Boolean checkDateRange(XC_Coupon__c coupon) {
        Date today = Date.today();

        if (today >= coupon.XC_StartDate__c && today <= coupon.XC_EndDate__c) {
            return true;
        } else {
            throw new XC_CouponException('Invalid Date Range');
        }
    }

    /**************************************************************************************
    * @Description  Check coupon max usage.
    * @Param        coupon - the coupon to check
    * @Return       true if the coupon passes the validity check; otherwise throw error
    * @Example
    **************************************************************************************/
    @TestVisible
    private Boolean checkMaxUsage(XC_Coupon__c coupon) {
        if (coupon.XC_TotalUsed__c < coupon.XC_MaxUse__c) {
            return true;
        } else {
            throw new XC_CouponException('Exceed Max Usage');
        }
    }

    /**************************************************************************************
    * @Description  Check coupon min amount.
    * @Param        coupon - the coupon to check
    * @Return       true if the coupon passes the validity check; otherwise throw error
    * @Example
    **************************************************************************************/
    @TestVisible
    private Boolean checkMinAmount(XC_Coupon__c coupon) {
        Decimal minAmount = coupon.XC_CartTotalAmount__c;

        if (null == minAmount || this.mCart.TotalProductAmount >= minAmount) {
            return true;
        } else {
            throw new XC_CouponException('Minimum not met for that coupon');
        }
    }

    /**************************************************************************************
    * @Description  Check coupon min quantity.
    * @Param        coupon - the coupon to check
    * @Return       true if the coupon passes the validity check; otherwise throw error
    * @Example
    **************************************************************************************/
    @TestVisible
    private Boolean checkMinQuantity(XC_Coupon__c coupon) {
        Decimal minQuanitty = coupon.XC_MinQty__c;

        if (null == minQuanitty || this.mCart.TotalProductCount >= minQuanitty) {
            return true;
        } else {
            throw new XC_CouponException('Minimum quantity not met');
        }
    }

    /**************************************************************************************
    * @Description  Applies coupon to cart
    * @Param        inputData - the input parameters
    *                   cartId - the cart ID
    *                   code   - the coupon code
    * @Return       true if coupon was added; error message if failed to add
    * @Example
    **************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> addPromo(Map<String, Object> inputData) {
        XC_CouponAPI api = new XC_CouponAPI((String)inputData.get('cartId'));
        return api.addCoupon((String)inputData.get('code'));
    }

    /**************************************************************************************
    * @Description  Applies coupon to cart
    * @Param        inputData - the input parameters
    *                   cartId - the cart ID
    *                   code   - the coupon code
    * @Return       true if coupon was added; error message if failed to add
    * @Example
    **************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> removePromo(Map<String, Object> inputData) {
        XC_CouponAPI api = new XC_CouponAPI((String)inputData.get('cartId'));
        return api.removeCoupon();
    }

    /**************************************************************************************
    * @Description  Gets coupon details
    * @Param        inputData - the input parameters
    *                   cartId - the cart ID
    * @Return       the coupon details
    * @Example
    **************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> getCoupon(Map<String, Object> inputData) {
        XC_CouponAPI api = new XC_CouponAPI((String)inputData.get('cartId'));
        return api.getCouponDetails();
    }

    /**************************************************************************************
    * @Description  Calculates discounts on carts
    * @Param        inputData - the input parameters
    *                   cartId - the cart ID
    * @Return       the cart amounts
    * @Example
    **************************************************************************************/
    @AuraEnabled
    public static Map<String, Object> calculateDiscount(Map<String, Object> inputData) {
        XC_CouponAPI api = new XC_CouponAPI((String)inputData.get('cartId'));
        return api.applyDiscounts();
    }
}
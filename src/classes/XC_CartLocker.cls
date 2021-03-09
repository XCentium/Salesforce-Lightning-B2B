/*******************************************************************************************
* @Name         XC_CartLocker
* @Author       Brian Zigarovich <brian.zigarovich@xcentium.com>
* @Date         01/24/2021
* @Group        Checkout Flow
* @Description  Unlocks cart.
*******************************************************************************************/
/* MODIFICATION LOG
* Version          Developer          Date               Description
*-------------------------------------------------------------------------------------------
*  1.0              Brian           01/24/2021          Initial Creation                    
*******************************************************************************************/
public with sharing class XC_CartLocker {

    /**************************************************************************************
    * @Description  Unlocks the cart
    * @Param        activeCartOrId - the cart ID
    * @Return
    * @Example
    **************************************************************************************/
    @AuraEnabled
    @SuppressWarnings('PMD.ApexCRUDViolation')
    public static void unlockCart(String activeCartOrId) {
        CartCheckoutSession ccs = [
            SELECT Id, WebCartId, OrderId
            FROM CartCheckoutSession
            WHERE WebCartId = :activeCartOrId
        ];
        try { update new WebCart(Id=ccs.WebCartId, Status='Active'); } catch (Exception e) {}
        try { delete new Order(Id=ccs.OrderId); } catch (Exception e) {}
        try { delete ccs; } catch (Exception e) {}
    }

    /**************************************************************************************
    * @Description  Unlocks the cart
    * @Param
    * @Return
    * @Example
    **************************************************************************************/
    @AuraEnabled
    @SuppressWarnings('PMD.ApexCRUDViolation,PMD.EmptyCatchBlock')
    public static void unlockCart2() {
        try {
            unlockCart([
                SELECT Id
                FROM WebCart
                WHERE OwnerId = :UserInfo.getUserId() AND
                    Status = 'Checkout'
                LIMIT 1
            ].Id);
        } catch (Exception e) {

        }
    }
}
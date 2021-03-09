/**
 * Created by brandon.rogers on 11/29/18.
 */

global with sharing class ckz_ctrl_RewardsPointsCheckout {
    global Boolean pointsEnabled { get; set; }
    global Decimal pointsApplied { get; set; }
    global Decimal pointsBalance { get; set; }
    global Boolean showPointsDollarValue { get; set; }
    global Decimal pointsDollarValue { get; set; }
    global Decimal postPointsSubtotal { get; set; }

    global ckz_ctrl_RewardsPointsCheckout() {
        ccrz.ccLog.log('ckz_ctrl_RewardsPointsCheckout');
        pointsEnabled = false;
        pointsApplied = 0;
        pointsBalance = 0;
        String cartId = ApexPages.currentPage().getParameters().get('cartID');
        String orderId = ApexPages.currentPage().getParameters().get('o');

        ccrz.ccLog.log('ckz_ctrl_RewardsPointsCheckout', 'orderId = ' + orderId);

        // 2018-12-05  msobczak: if we're at the order confirmation page, we won't have a cartID.
        if (String.isBlank(cartId)) {

            if(!String.isBlank(orderId)) {
                List <ccrz__E_Order__c> orderList = [Select Id, Name, ccrz__OriginatedCart__r.ccrz__EncryptedId__c from ccrz__E_Order__c where ccrz__EncryptedId__c = :orderId];

                if(orderList.size() > 0) {
                    ccrz__E_Order__c order = orderList.get(0);

                    cartId = order.ccrz__OriginatedCart__r.ccrz__EncryptedId__c;
                }
            }
        }

        ccrz.ccLog.log('ckz_ctrl_RewardsPointsCheckout', 'cartId = ' + cartId);

        if (String.isBlank(cartId)) {
            return;
        }

        ccrz__E_Cart__c cart = null;

        List<ccrz__E_Cart__c> cartList = [
                Select c.ccrz__SubtotalAmount__c,
                        c.ccrz__AdjustmentAmount__c,
                        c.ccrz__EncryptedId__c,
                        c.ccrz__Account__c,
                        c.Reward_Points_Applied__c,
                        c.Name
                From ccrz__E_Cart__c c
                Where c.ccrz__EncryptedId__c = :cartId
        ];

        if(cartList.size() > 0) {
            cart = cartList.get(0);
        }

        if(cart.Reward_Points_Applied__c == null || cart.Reward_Points_Applied__c == 0) {
            return;
        }

        ccrz.ccLog.log('ckz_ctrl_RewardsPointsCheckout:cart: ' + cart);

        if (cart.ccrz__Account__c != null) {
            Account theAccount = [
                    Select a.Id, ckz_B2B_Reward_Points_Balance__c, ckz_B2B_Reward_Points_Earned_Multiplier__c, ckz_B2B_Reward_Points_Cost_Multiplier__c, ckz_B2B_Reward_Points_Enabled__c
                    From Account a
                    Where a.Id = :cart.ccrz__Account__c
            ];
            ccrz.ccLog.log('ckz_ctrl_RewardsPointsCheckout:theAccount: ' + theAccount);

            if (theAccount != null) {

                ccrz.ccLog.log('ckz_ctrl_RewardsPointsCheckout:arp: ' + theAccount);

                if (theAccount.ckz_B2B_Reward_Points_Enabled__c) {
                    pointsEnabled = true;
                    pointsApplied = cart.Reward_Points_Applied__c;
                    pointsBalance = theAccount.ckz_B2B_Reward_Points_Balance__c - pointsApplied;
                    pointsDollarValue = cart.ccrz__AdjustmentAmount__c != null ? (cart.ccrz__AdjustmentAmount__c * -1) : 0;
                    showPointsDollarValue = pointsDollarValue > 0;
                    postPointsSubtotal = cart.ccrz__SubtotalAmount__c - pointsDollarValue;
                }
            }
        }

    }
}
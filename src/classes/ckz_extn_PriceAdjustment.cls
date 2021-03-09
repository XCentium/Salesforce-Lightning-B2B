global with sharing class ckz_extn_PriceAdjustment extends ccrz.cc_api_PriceAdjustment {

    private final List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

    global override Map<String, Object> computePricingCart(Map<String, Object> inputData) {

        System.debug('ckz_extn_PriceAdjustment - begin computePricingCart');

        try {

            ccrz.cc_bean_CartSummary cartBean = (ccrz.cc_bean_CartSummary) inputData.get(ccrz.cc_api_CartExtension.PARAM_CARTBEAN);

            //Query cart and account for points info
            ccrz__E_Cart__c cart = [
                    Select c.ccrz__AdjustmentAmount__c, c.ccrz__EncryptedId__c, c.ccrz__Account__c, c.Reward_Points_Applied__c, c.Name, c.ccrz__Storefront__c
                    From ccrz__E_Cart__c c
                    Where c.ccrz__EncryptedId__c = :cartBean.encryptedId
            ][0];
            Account theAccount = [
                    Select a.Id, ckz_B2B_Reward_Points_Balance__c, ckz_B2B_Reward_Points_Earned_Multiplier__c, ckz_B2B_Reward_Points_Cost_Multiplier__c, ckz_B2B_Reward_Points_Enabled__c
                    From Account a
                    Where a.Id = :cart.ccrz__Account__c
            ];

            // See if the storefront uses Reward Points
            ckz_CheckConfigSetting.ConfigSettingRequest request = new ckz_CheckConfigSetting.ConfigSettingRequest();
            request.storefront = cart.ccrz__Storefront__c;
            request.configSetting = 'c.rewardpts';
            request.externallySafe = true;
            request.page = 'all';

            ckz_CheckConfigSetting.ConfigSettingResponse response = ckz_CheckConfigSetting.checkConfigSetting(request);

            String configValue = response.configValue;

            if(configValue != 'TRUE') {
                System.debug('Reward points not enabled for Storefront: ' + cart.ccrz__Storefront__c);
                throw new CustomException ('Bypassing Reward Points calculations');
            }

            if(cart.Reward_Points_Applied__c == null || cart.Reward_Points_Applied__c == 0) {
                throw new CustomException ('Bypassing Reward Points calculations');
            }

            //Check for rewards program enabled, apply discount
            if (theAccount != null) {

                Decimal pointsBalance = theAccount.ckz_B2B_Reward_Points_Balance__c;  System.debug('pointsBalance: ' + pointsBalance);
                Decimal earnedMultiplier = theAccount.ckz_B2B_Reward_Points_Earned_Multiplier__c;  System.debug('earnedMultiplier: ' + earnedMultiplier);
                Decimal costMultiplier = theAccount.ckz_B2B_Reward_Points_Cost_Multiplier__c;  System.debug('costMultiplier: ' + costMultiplier);
                Boolean enabled = theAccount.ckz_B2B_Reward_Points_Enabled__c;  System.debug('enabled: ' + enabled);

                // If the Account hasn't been setup for reward points at all, need to handle that appropriately.
                if(enabled == false || pointsBalance == null || earnedMultiplier == null) {
                    System.debug('Reward points not configured for account: ' + theAccount.Name);
                    throw new CustomException ('Bypassing Reward Points calculations');
                }

                if (cart.Reward_Points_Applied__c > 0 && enabled) {
                    Decimal discountAmount = cart.Reward_Points_Applied__c * costMultiplier;  System.debug('discountAmount: ' + discountAmount);
                    cartBean.adjustment = -1 * discountAmount;  System.debug('cartBean.adjustment: ' + cartBean.adjustment);
                    inputData.put(ccrz.cc_api_CartExtension.PARAM_CARTBEAN, cartBean);
                    System.debug('Set cart price adjustment to : ' + cartBean.adjustment);
                    //It should be sufficient to set adjustment on the cartBean object, however that is not persisted (OOTB bug)
                    //So, set it manually on the cart SFDC object
                    cart.ccrz__AdjustmentAmount__c = cartBean.adjustment;
                    update cart;
                }
            }
        } catch (Exception e) {

        } finally {
            return inputData;
        }
        return inputData;
    }

    global override Map<String, Object> computePricingReview(Map<String, Object> inputData) {
        return computePricingCart(inputData);
    }

    public class CustomException extends Exception {}
}
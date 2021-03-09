global class ckzPOCLogicCartPrice extends ccrz.ccLogicCartPrice {

    global virtual override Map<String, Object> applyPricing(Map<String, Object> inputData) {

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'begin applyPricing');

        // invoke out-of-box pricing to prevent duplicating work
        super.applyPricing(inputData);

        ccrz__E_Cart__c cartObj = (ccrz__E_Cart__c) inputData.get('cartToUpdate');

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'cartObj: ' + cartObj);

        // Need to get this version of the cart because cartToUpdate does not contain any fields.
        ccrz__E_Cart__c cartPriceObj = (ccrz__E_Cart__c) inputData.get('cartToPrice');

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'cartPriceObj: ' + cartPriceObj);

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'storefront: ' + cartPriceObj.ccrz__Storefront__c);

        // REWARD POINTS LOGIC
        try {
            Account theAccount = [
                    SELECT a.Id, ckz_B2B_Reward_Points_Balance__c, ckz_B2B_Reward_Points_Earned_Multiplier__c, ckz_B2B_Reward_Points_Cost_Multiplier__c, ckz_B2B_Reward_Points_Enabled__c
                    FROM Account a
                    WHERE a.Id = :cartPriceObj.ccrz__Account__c
            ];

            // See if the storefront uses Reward Points
            ckz_CheckConfigSetting.ConfigSettingRequest request = new ckz_CheckConfigSetting.ConfigSettingRequest();
            request.storefront = cartPriceObj.ccrz__Storefront__c;
            request.configSetting = 'c.rewardpts';
            request.externallySafe = true;
            request.page = 'all';

            ckz_CheckConfigSetting.ConfigSettingResponse response = ckz_CheckConfigSetting.checkConfigSetting(request);

            String configValue = response.configValue;

            ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'configValue: ' + configValue);

            if (configValue != 'TRUE') {
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'Reward points not enabled for Storefront: ' + cartPriceObj.ccrz__Storefront__c);
                throw new CustomException ('Bypassing Reward Points calculations');
            }

            if (cartPriceObj.Reward_Points_Applied__c == null || cartPriceObj.Reward_Points_Applied__c == 0) {
                throw new CustomException ('Bypassing Reward Points calculations');
            }

            //Check for rewards program enabled, apply discount
            if (theAccount != null) {

                Decimal pointsBalance = theAccount.ckz_B2B_Reward_Points_Balance__c;
                Decimal earnedMultiplier = theAccount.ckz_B2B_Reward_Points_Earned_Multiplier__c;
                Decimal costMultiplier = theAccount.ckz_B2B_Reward_Points_Cost_Multiplier__c;
                Boolean enabled = theAccount.ckz_B2B_Reward_Points_Enabled__c;

                ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'pointsBalance: ' + pointsBalance);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'earnedMultiplier: ' + earnedMultiplier);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'costMultiplier: ' + costMultiplier);
                ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'enabled: ' + enabled);

                // If the Account hasn't been setup for reward points at all, need to handle that appropriately.
                if (enabled == false || pointsBalance == null || earnedMultiplier == null) {
                    ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'Reward points not configured for account: ' + theAccount.Name);
                    throw new CustomException ('Bypassing Reward Points calculations');
                }

                if (cartPriceObj.Reward_Points_Applied__c > 0 && enabled) {
                    Decimal discountAmount = cartPriceObj.Reward_Points_Applied__c * costMultiplier;

                    ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'discountAmount: ' + discountAmount);

                    Decimal adjustment = -1 * discountAmount;
                    ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'adjustment: ' + adjustment);

                    cartObj.ccrz__AdjustmentAmount__c = -1 * discountAmount;

                    ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'cart.ccrz__AdjustmentAmount__c: ' + cartObj.ccrz__AdjustmentAmount__c);

                    //update cartObj;

                }

            }
        } catch (Exception e) {
            ccrz.ccLog.log('ckzPOCLogicCartPrice', 'Exception: ' + e.getMessage());

            ccrz.ccLog.log(LoggingLevel.ERROR, 'ckzPOCLogicCartPrice', 'Line number: ' + e.getLineNumber());
        }

        ccrz.ccLog.log(LoggingLevel.DEBUG, 'ckzPOCLogicCartPrice', 'exit applyPricing');
        return inputData;

    }

    public class CustomException extends Exception {
    }

}
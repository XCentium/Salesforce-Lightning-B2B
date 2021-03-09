/**
 * Created by brandon.rogers on 11/28/18.
 */

global with sharing class ckz_ctrl_RewardsPoints {
    global static String blank {
        get {
            return '';
        }
        private set;
    }
    global Boolean pointsEnabled { get; set; }
    global Decimal pointsApplied { get; set; }
    global Decimal pointsBalance { get; set; }
    global Boolean showPointsDollarValue { get; set; }
    global Decimal pointsDollarValue { get; set; }
    global Decimal postPointsSubtotal { get; set; }

    global ckz_ctrl_RewardsPoints() {
        pointsEnabled = false;
        pointsApplied = 0;
        pointsBalance = 0;
        String cartId = ApexPages.currentPage().getParameters().get('cartId');
        if (String.isBlank(cartId))
            cartId = ApexPages.currentPage().getParameters().get('cartID');
        if (!String.isBlank(cartId)) {
            ccrz__E_Cart__c cart = [
                    Select  c.ccrz__SubtotalAmount__c,
                            c.ccrz__AdjustmentAmount__c,
                            c.ccrz__EncryptedId__c,
                            c.ccrz__Account__c,
                            c.Reward_Points_Applied__c,
                            c.Name
                    From ccrz__E_Cart__c c
                    Where c.ccrz__EncryptedId__c = :cartId
            ];

            if (cart.ccrz__Account__c != null) {
                Account theAccount = [
                        Select  Id,
                                ckz_B2B_Reward_Points_Balance__c,
                                ckz_B2B_Reward_Points_Earned_Multiplier__c,
                                ckz_B2B_Reward_Points_Cost_Multiplier__c,
                                ckz_B2B_Reward_Points_Enabled__c
                        From Account
                        Where Id = :cart.ccrz__Account__c
                ];

                if (theAccount != null) {
                    if (theAccount.ckz_B2B_Reward_Points_Enabled__c) {
                        pointsEnabled = true;
                        pointsApplied = cart.Reward_Points_Applied__c == null ? 0 : cart.Reward_Points_Applied__c;
                        pointsBalance = theAccount.ckz_B2B_Reward_Points_Balance__c - pointsApplied;
                        //Have to calculate in real time because pricing adjustment hook hasn't fired
                        //pointsDollarValue = cart.ccrz__AdjustmentAmount__c != null ? (cart.ccrz__AdjustmentAmount__c * -1) : 0;
                        pointsDollarValue = (pointsApplied * theAccount.ckz_B2B_Reward_Points_Cost_Multiplier__c).setScale(2);
                        showPointsDollarValue = pointsDollarValue > 0;
                        postPointsSubtotal = (cart.ccrz__SubtotalAmount__c - pointsDollarValue).setScale(2);
                    }
                }
            }
        }
    }

    @RemoteAction
    global static ccrz.cc_RemoteActionResult applyPoints(final ccrz.cc_RemoteActionContext ctx, final String cartId, String pointsEnteredStr) {
        ccrz.cc_CallContext.initRemoteContext(ctx);
        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();

        List<ccrz.cc_bean_Message> retMessages = new List<ccrz.cc_bean_Message>();

        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', 'In applyPoints');
        res.success = false;
        try {

            Map<String, String> pageLabelMap = new Map<String, String>();

            Set<String> pageLabelSet = new Set<String> {'RewardPointsErrorMsg_InvalidAmount1', 'RewardPointsErrorMsg_InvalidAmountNeg'};

            Map<String, Object> inputData = new Map<String, Object>{
                    ccrz.ccApiI18N.PAGE_LABEL_NAMES => pageLabelSet
                    , ccrz.ccAPI.API_VERSION => ccrz.ccAPI.CURRENT_VERSION
                    , ccrz.ccApiI18N.STORE_NAME => ctx.storefront
                    ,ccrz.ccApiI18N.USE_CACHE => True

            };


            Map<String, Object> outputData = ccrz.ccApiI18N.fetchPageLabels(inputData);

            Boolean wasSuccessful = (Boolean) outputData.get(ccrz.ccApi.SUCCESS);

            System.debug('wasSuccessful: ' + wasSuccessful);

            if (outputData.get(ccrz.ccApiI18N.PAGE_LABELS) != null) {

                pageLabelMap = (Map<String, String>) outputData.get(ccrz.ccApiI18N.PAGE_LABELS);
            }

            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', 'L1');
            Decimal pointsToApply = Decimal.valueOf(pointsEnteredStr);

            if (pointsToApply >= 0) {

                ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', 'L2');
                ccrz__E_Cart__c cart = [
                        Select  c.ccrz__AdjustmentAmount__c,
                                c.ccrz__EncryptedId__c,
                                c.ccrz__Account__c,
                                c.Reward_Points_Applied__c,
                                c.Name
                        From ccrz__E_Cart__c c
                        Where c.Id = :cartId
                ];

                if (cart.ccrz__Account__c != null) {

                    ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', 'L3');
                    Account theAccount = [
                            Select  a.Id,
                                    ckz_B2B_Reward_Points_Balance__c,
                                    ckz_B2B_Reward_Points_Earned_Multiplier__c,
                                    ckz_B2B_Reward_Points_Cost_Multiplier__c,
                                    ckz_B2B_Reward_Points_Enabled__c
                            From Account a
                            Where a.Id = :cart.ccrz__Account__c
                    ];

                    if (theAccount != null) {

                        ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', 'L4');

                        if (theAccount.ckz_B2B_Reward_Points_Enabled__c && pointsToApply <= theAccount.ckz_B2B_Reward_Points_Balance__c) {
                            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', 'L5');
                            cart.Reward_Points_Applied__c = pointsToApply;
                            update cart;
                            res.success = true;

//                            String messageText = pageLabelMap.get('RewardPointsAppliedMsg');
//                            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
//                            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
//                            msg.classToAppend = 'messagingSection-Info';
//                            retMessages.add(msg);

                        } else {
                            // Error handling - if they enter more points than they have
                            //String messageText = 'You have entered more points than you currently have available';
                            String messageText = pageLabelMap.get('RewardPointsErrorMsg_InvalidAmount1');
                            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
                            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                            msg.classToAppend = 'messagingSection-Error';
                            retMessages.add(msg);
                        }
                    }
                }
            }
//            else if (pointsToApply == 0) {
//                //String messageText = 'You have entered zero, which is an invalid number of reward points to claim';
//                String messageText = pageLabelMap.get('RewardPointsErrorMsg_InvalidAmountZero');
//                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
//                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
//                msg.classToAppend = 'messagingSection-Error';
//                retMessages.add(msg);
//            }
            else {
                // Error handling - if they enter a negative number

                //String messageText = 'You have entered a negative reward points number';
                String messageText = pageLabelMap.get('RewardPointsErrorMsg_InvalidAmountNeg');
                ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
                msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
                msg.classToAppend = 'messagingSection-Error';
                retMessages.add(msg);
            }
        } catch (Exception e) {
            // Error handling - invalid number or SOQL error
            ccrz.ccLog.log(System.LoggingLevel.DEBUG, 'DEBUG ---', e.getMessage());

            String messageText = e.getMessage();
            ccrz.cc_bean_Message msg = new ccrz.cc_bean_Message(messageText, ccrz.cc_bean_Message.MessageSeverity.ERROR);
            msg.type = ccrz.cc_bean_Message.MessageType.CUSTOM;
            msg.classToAppend = 'messagingSection-Error';
            retMessages.add(msg);

        } finally {

            res.messages.addAll(retMessages);

            ccrz.ccLog.close(res);

        }
        return res;
    }
}
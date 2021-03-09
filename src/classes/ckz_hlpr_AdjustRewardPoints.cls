public without sharing class ckz_hlpr_AdjustRewardPoints {

    // Enable for testing purposes
    public static boolean sendEmailDebug = false;

    public static void adjustRewardPoints(Id orderId) {

        System.debug('ckz_hlpr_AdjustRewardPoints - begin adjustRewardPoints');

        String emailBody = '';

        ccrz__E_Order__c theOrder = [
                Select o.Id, o.Reward_Points_Processed__c, o.ccrz__OrderStatus__c, o.ccrz__AdjustmentAmount__c, o.ccrz__TotalAmount__c, o.ccrz__OriginatedCart__c, o.ccrz__Storefront__c, ccrz__SubtotalAmount__c, ccrz__Account__c, Points_Applied__c, Points_Earned__c
                From ccrz__E_Order__c o
                Where o.Id = :orderId
        ];

        System.debug('checking to see if Reward Points is enabled');

        // See if the storefront uses Reward Points
        ckz_CheckConfigSetting.ConfigSettingRequest request = new ckz_CheckConfigSetting.ConfigSettingRequest();
        request.storefront = theOrder.ccrz__Storefront__c;
        request.configSetting = 'c.rewardpts';
        request.externallySafe = true;
        request.page = 'all';

        ckz_CheckConfigSetting.ConfigSettingResponse response = ckz_CheckConfigSetting.checkConfigSetting(request);

        String configValue = response.configValue;

        if(configValue != 'TRUE') {
            System.debug('Reward points not enabled for Storefront: ' + theOrder.ccrz__Storefront__c);
            return;
        }
        else {
            System.debug('Reward points is enabled for Storefront: ' + theOrder.ccrz__Storefront__c);
        }

        System.debug('ccrz__OrderStatus__c = ' + theOrder.ccrz__OrderStatus__c);
        System.debug('ccrz__TotalAmount__c = ' + theOrder.ccrz__TotalAmount__c);
        System.debug('ccrz__SubtotalAmount__c = ' + theOrder.ccrz__SubtotalAmount__c);
        System.debug('ccrz__AdjustmentAmount__c = ' + theOrder.ccrz__AdjustmentAmount__c);
        System.debug('Reward_Points_Processed__c = ' + theOrder.Reward_Points_Processed__c);

        emailBody += 'order status = ' + theOrder.ccrz__OrderStatus__c + '<br/>';
        emailBody += 'order total amount = ' + theOrder.ccrz__TotalAmount__c + '<br/>';
        emailBody += 'order subtotal amount = ' + theOrder.ccrz__SubtotalAmount__c + '<br/>';
        emailBody += 'order adjustment amount = ' + theOrder.ccrz__AdjustmentAmount__c + '<br/>';
        emailBody += 'reward points processed = ' + theOrder.Reward_Points_Processed__c + '<br/>';

        // If reward points have already been processed, exit here.
        if(theOrder.Reward_Points_Processed__c == true) {
            emailBody += 'check 1 ' + '<br/>';
            sendEmailMsg(emailBody);
            return;
        }

        if(theOrder.ccrz__OrderStatus__c == null) {
            sendEmailMsg(emailBody);
            return;
        }

        // theOrder.ccrz__OrderStatus__c != null &&
        if(theOrder.ccrz__OrderStatus__c.equalsIgnoreCase('Order Submitted') == false) {
            emailBody += 'check 2 ' + '<br/>';
            theOrder.Reward_Points_Processed__c = true;
            update theOrder;
            sendEmailMsg(emailBody);
            return;
        }

        Account theAccount = [
                Select a.Id, a.Name, ckz_B2B_Reward_Points_Balance__c, ckz_B2B_Reward_Points_Earned_Multiplier__c, ckz_B2B_Reward_Points_Cost_Multiplier__c, ckz_B2B_Reward_Points_Enabled__c
                From Account a
                Where a.Id = :theOrder.ccrz__Account__c
        ];

        if (theAccount != null) {

            Decimal pointsBalance = theAccount.ckz_B2B_Reward_Points_Balance__c;  emailBody += 'current account points balance: ' + pointsBalance + '<br/>';
            Decimal earnedMultiplier = theAccount.ckz_B2B_Reward_Points_Earned_Multiplier__c;  emailBody += 'account reward points earned multiplier: ' + earnedMultiplier + '<br/>';
            Boolean enabled = theAccount.ckz_B2B_Reward_Points_Enabled__c;  emailBody += 'account reward points enabled: ' + enabled + '<br/>';

            // If the Account hasn't been setup for reward points at all, need to handle that appropriately.
            if(enabled == false || pointsBalance == null || earnedMultiplier == null) {
                System.debug('Reward points not configured for account: ' + theAccount.Name);
                return;
            }

            Decimal netPoints = 0;
            ccrz__E_Cart__c cart = [
                    Select c.ccrz__AdjustmentAmount__c, c.ccrz__EncryptedId__c, c.ccrz__Account__c, c.Reward_Points_Applied__c, c.Name
                    From ccrz__E_Cart__c c
                    Where c.Id = :theOrder.ccrz__OriginatedCart__c
            ];

            if (cart.Reward_Points_Applied__c > 0) {
                netPoints -= cart.Reward_Points_Applied__c;  emailBody += ' reward points applied to order: ' + netPoints + '<br/>';
            }

            // the dollar value of the points applied in the cart
            Decimal adjustmentAmount = theOrder.ccrz__AdjustmentAmount__c != null ? (theOrder.ccrz__AdjustmentAmount__c * -1) : 0;  emailBody += 'order adjustment amount (abs value): ' + adjustmentAmount + '<br/>';

            Decimal postPointsSubtotal = theOrder.ccrz__SubtotalAmount__c - adjustmentAmount;  emailBody += 'order reward $$$: ' + postPointsSubtotal + '<br/>';

            Decimal pointsEarned = (postPointsSubtotal * earnedMultiplier);  emailBody += 'order reward points earned: ' + pointsEarned + '<br/>';

            Decimal pointsEarnedRnd = pointsEarned.setScale(0);  emailBody += 'order reward points earned (rounded): ' + pointsEarnedRnd + '<br/>';

            netPoints += pointsEarned;  emailBody += ' actual order reward points earned: ' + netPoints + '<br/>';
            pointsBalance += netPoints;  emailBody += 'new account points balance: ' + pointsBalance + '<br/>';

            theAccount.ckz_B2B_Reward_Points_Balance__c = pointsBalance;

            if (pointsBalance < 0) {
                Decimal causeException = 1 / 0;
            } else {
                theOrder.Points_Applied__c = cart.Reward_Points_Applied__c;
                theOrder.Points_Earned__c = pointsEarnedRnd;
                theOrder.Reward_Points_Processed__c = true;

                update theAccount;

                sendEmailMsg(emailBody);

                // This causes the trigger to fire again
                update theOrder;


            }
        }

    }

    private static void sendEmailMsg(String emailBody) {

        if(sendEmailDebug == false) {
            return;
        }

        List<Messaging.SingleEmailMessage> mails =
                new List<Messaging.SingleEmailMessage>();

        Messaging.SingleEmailMessage mail =
                new Messaging.SingleEmailMessage();

        List<String> sendTo = new List<String>();
        sendTo.add('msobczak@salesforce.com');
        mail.setToAddresses(sendTo);

        // Step 3: Set who the email is sent from
        mail.setReplyTo('msobczak@salesforce.com');
        mail.setSenderDisplayName('Michael Sobczak');

        mail.setSubject('Reward Points account update log');

        mail.setHtmlBody(emailBody);

        mails.add(mail);

        Messaging.sendEmail(mails);
    }
}
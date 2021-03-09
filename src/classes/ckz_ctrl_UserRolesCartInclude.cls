global with sharing class ckz_ctrl_UserRolesCartInclude {

    @RemoteAction
    global static ccrz.cc_RemoteActionResult createCaseBudgetOverride(final ccrz.cc_RemoteActionContext ctx) {
        ccrz.cc_CallContext.initRemoteContext(ctx);

        ccrz.cc_RemoteActionResult res = new ccrz.cc_RemoteActionResult();
        res.success = false;
        try {

            List<String> cartidlist = new List<String>{};
            cartidlist.add(ctx.currentCartId);


            Map<String, Object> cartApiFetchResponse = ccrz.ccApiCart.fetch(new Map<String,Object>{
                    ccrz.ccApi.API_VERSION => ccrz.ccApi.CURRENT_VERSION,
                    ccrz.ccApiCart.CART_ENCIDLIST => cartidlist,
                    ccrz.ccApi.SIZING=>new Map<String, Object>{
                            ccrz.ccApiCart.ENTITYNAME => new Map<String, Object>{
                                    ccrz.ccAPI.SZ_SKIPTRZ=>true
                            }
                    }
            });

            List<ccrz__E_Cart__c> cartRes = (List<ccrz__E_Cart__c>)cartApiFetchResponse.get(ccrz.ccApiCart.CART_OBJLIST);

            ccrz__E_Cart__c theCart = null;

            if(cartRes.get(0) != null)
            {
                theCart = (ccrz__E_Cart__c)cartRes.get(0);
                Case newRequest = new Case();

                // General Fields
                newRequest.Origin = 'Web';
                newRequest.Reason = 'Budget Limit';
                newRequest.Type = 'Cart';
                newRequest.Subject = 'Budget override request for ' + ccrz.cc_CallContext.effAccount.Name;
                newRequest.ckz_Source_Cart__c = theCart.Id;
                newRequest.ContactId = ccrz.cc_CallContext.currUser.ContactId;
                newRequest.AccountId = ccrz.cc_CallContext.effAccountId;

                newRequest.ckz_Budget_Approval_Requested__c = True;
                newRequest.ckz_Budget_Approval_Status__c = 'Submitted';

                insert newRequest;

                theCart.Budget_Approval_Requested__c = TRUE;
                update theCart;
            }

            res.success = true;
        } catch (Exception e) {
            res.data = e;
            System.debug(System.LoggingLevel.ERROR, e.getMessage());
            System.debug(System.LoggingLevel.ERROR, e.getStackTraceString());
        }
        return res;
    }

}
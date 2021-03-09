/**
 * Created by brandon.rogers on 9/6/18.
 */

global with sharing class ckz_ctrl_ContractSelector {
    public String grid { get; private set; }
    global String communityURL { get; set; }


    global ckz_ctrl_ContractSelector() {
        getCommunityURL();
        ccrz.ccLog.log('ckz_ctrl_ContractSelector');
        grid = ccrz.cc_CallContext.priceGroupId;
    }

    global void getCommunityURL(){
        ccrz.ccLog.log('ckz_ctrl_Header_Pro:getCommunityURL');
        
        //Get current community ID
        String ntwrkId = Network.getNetworkId();
        
        Network currentCommunity= [SELECT Name, UrlPathPrefix FROM Network where id=:ntwrkId];
        communityURL = currentCommunity.UrlPathPrefix;
		ccrz.ccLog.log('ckz_ctrl_Header_Pro:getCommunityURL:communityURL: ' + communityURL);
    }
    @RemoteAction
    global static ccrz.cc_RemoteActionResult fetchPriceGroupsForUserAccount(ccrz.cc_RemoteActionContext ctx) {
        ccrz.ccLog.log(LoggingLevel.DEBUG, 'M:E', 'fetchPriceGroupsForUser');
        ccrz.cc_RemoteActionResult response = new ccrz.cc_RemoteActionResult();
        response.success = false;
        response.inputContext = ctx;

        System.debug('currAccountId: ' + ccrz.cc_CallContext.currAccountId);
        System.debug('ctx.effAccountId: ' + ctx.effAccountId);
        System.debug('currPageParameters: ' + ccrz.cc_CallContext.currPageParameters);
        System.debug('isRemoteCall: ' + ccrz.cc_CallContext.isRemoteCall);

        Map<String, Object> dataMap = new Map<String, Object>();

        try {
            String effectiveAccountId = '';

            if(ctx.effAccountId != null && ctx.effAccountId != '') {
                effectiveAccountId = ctx.effAccountId;
            }
            else {
                effectiveAccountId = ccrz.cc_CallContext.effAccountId;
            }

            System.debug('effectiveAccountId: ' + effectiveAccountId);

            ccrz.cc_CallContext.initRemoteContext(ctx);

            List<ContractPriceData> contractPriceGroupList = new List<ContractPriceData>();

            for (ccrz__E_PriceGroupAccount__c priceGroupAccount : ckz_util_Common.fetchPriceGroupAccounts(effectiveAccountId)) {
                ContractPriceData contractPriceData = new ContractPriceData();
                contractPriceData.priceGroupId = priceGroupAccount.ccrz__PriceGroup__c;
                contractPriceData.priceGroupName = priceGroupAccount.ccrz__PriceGroup__r.ccrz__GroupName__c;

                contractPriceGroupList.add(contractPriceData);
            }
            dataMap.put('contractPriceGroups', contractPriceGroupList);
            response.data = dataMap;
            response.success = true;
        } catch (Exception ex) {
            ccrz.ccLog.log('ckz_ctrl_ContractSelector:fetchPriceGroupsForUserAccount:responseFalse');
            response.success = false;
            ccrz.ccLog.log(LoggingLevel.ERROR, 'message', ex.getMessage());
        } finally {
            ccrz.ccLog.log(System.LoggingLevel.INFO, 'M:X', 'fetchPriceGroupsForUser');
            ccrz.ccLog.close(response);
        }

        ccrz.ccLog.log('ckz_ctrl_ContractSelector:fetchPriceGroupsForUserAccount:response: ' + response);
        return response;
    }


    public with sharing class ContractPriceData {
        public String priceGroupId { get; set; }
        public String priceGroupName { get; set; }
    }

}
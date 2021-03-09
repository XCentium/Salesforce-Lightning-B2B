trigger ckz_trg_AdjustRewardPoints on ccrz__E_Order__c (after update) {
    if(!System.isBatch()) return;
    private static boolean run = true;

    if(Trigger.isAfter && Trigger.isUpdate) {

        System.debug('ckz_trg_AdjustRewardPoints - after update');

        if(runOnce()) {

            for (ccrz__E_Order__c theOrder : Trigger.New) {
                ckz_hlpr_AdjustRewardPoints.adjustRewardPoints(theOrder.Id);
            }

            System.debug('short circuit recursive call');
            return;
        }


    }

    public static boolean runOnce() {
        if(run){
            run = false;
            return true;
        }
        else {
            return run;
        }
    }

}
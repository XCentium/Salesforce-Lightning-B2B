public class UnlockRecords {
    @InvocableMethod
    public static void UnlockLeads(List<Id> leadIds) {
        try {
            Lead[] myleads = [Select Id from Lead where Id IN :leadIds];
            List<Approval.UnlockResult> ur = Approval.unlock(myleads, false);
            for (Approval.UnlockResult lr : ur) {
                if (lr.isSuccess()) {
                    System.debug('Unlocked lead ' + lr.getId());
                } else {
                    System.debug('Failed to unlock lead ' + lr.getId());
                    for(Database.Error err : lr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('Account fields that affected this error: ' + err.getFields());
                    }
                }
            }
        } catch (Exception e) {
            System.debug(e);
        }
    }
}
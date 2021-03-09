public class contactOppsRelatedListCtrl {
    
    public List<Opportunity> opps {get;set;}
    
    public contactOppsRelatedListCtrl(ApexPages.standardController std) {
        system.debug(std.getId());

        List<User> curr_user = [SELECT Id, Name FROM User WHERE ContactId = :std.getId()];
        opps = userOps(curr_user);
    }
    
    private List<Opportunity> userOps(List<User> u) {
        return (u != null && !u.isEmpty()) ? [SELECT Id, Name, AccountId, Account.Name, Amount, OwnerId, Owner.Name, CloseDate FROM Opportunity WHERE OwnerId = :u[0].Id] : new List<Opportunity>();
    }
}
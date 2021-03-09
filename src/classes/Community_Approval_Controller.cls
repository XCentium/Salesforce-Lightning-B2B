public class Community_Approval_Controller {
    public List<ProcessInstance> myApprovals {get;set;}
  
    public Community_Approval_Controller(){
        myApprovals = [Select p.TargetObject.Id, p.TargetObjectId, p.TargetObject.Name, p.Status, p.LastModifiedDate, p.Id, p.CreatedBy.Id, p.CreatedById 
                       From ProcessInstance p
                       Where p.CreatedBy.Id =: UserInfo.getUserID()
                       Order By p.LastModifiedDate Desc Limit 5];
    }
}
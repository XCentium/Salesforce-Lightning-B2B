trigger completeFirstResponseCaseComment on CaseComment (after insert) {
    
    // Cannot be a portal user
    if (UserInfo.getUserType() == 'Standard'){
        DateTime completionDate = System.now();
        List<Id> caseIds = new List<Id>();
        for (CaseComment cc : Trigger.new){
            // Only public comments qualify
            if(cc.IsPublished == true)
                caseIds.add(cc.ParentId);
        }
        if (caseIds.isEmpty() == false){
            List<Case> caseList = [Select c.Id, c.ContactId, c.Contact.Email,
                                          c.OwnerId, c.Status, c.EntitlementId,
                                          c.SlaStartDate, c.SlaExitDate
                                   From Case c where c.Id IN :caseIds];
            if (caseList.isEmpty() == false){
                List<Id> updateCases = new List<Id>();
                for (Case caseObj:caseList) {
                    // consider an outbound email to the contact on the case a valid first response
                    if ((caseObj.EntitlementId != null)&&
                        (caseObj.SlaStartDate <= completionDate)&&(caseObj.SlaStartDate != null)&&
                        (caseObj.SlaExitDate == null))
                        updateCases.add(caseObj.Id);
                }
                if(updateCases.isEmpty() == false)
                    milestoneUtils.completeMilestone(updateCases, 'First Response', completionDate);
            }
        }
    }
}
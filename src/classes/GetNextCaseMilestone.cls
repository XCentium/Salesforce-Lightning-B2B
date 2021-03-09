public with sharing class GetNextCaseMilestone {
    // Controller for VF page to display Milestones on the Case
    private final CaseMilestone oCaseMilestone;
    private final Case oCase;
    private final String caseID;
    private Double timeUntilTarget;
    public String headerText {get;set;}
    public String targetDateText {get;set;}
    public String imageName {get;set;}
    public String caseMilestoneID {get;set;}
    public String milestoneName {get;set;}
    public String contextUserTargetDate {get;set;}
    public String contextUserTargetTime {get;set;}
    public Integer timeRemainingSec {get;set;}
    public Integer timeRemainingMins {get;set;}
    public Integer timeRemainingHrs {get;set;}
    public String milestoneStatusText {get;set;}
    
    public GetNextCaseMilestone(ApexPages.StandardController stdController) {
        this.oCase = (Case)stdController.getRecord();
        caseID = oCase.Id;
        timeRemainingMins = 0;
        milestoneName = '';
        headerText = '';
        targetDateText = '';
        imageName = '';
        if (caseID > ''){
            for(CaseMilestone oCaseMilestone : [Select  Id, CaseId, MilestoneType.Name, TargetResponseInMins, TargetResponseInHrs,
                                        TargetResponseInDays, TargetDate, CompletionDate, ElapsedTimeInMins, ElapsedTimeInHrs,
                                        ElapsedTimeInDays, IsViolated, IsCompleted
                                        From CaseMilestone
                                        Where CaseId = :caseID And CompletionDate = null Order By TargetDate ASC limit 1]){
                                            
                headerText = 'Due: ';
                if(oCaseMilestone.IsViolated)
                    imageName = 'error24.png';
                else
                    imageName = 'confirm32.png';
                milestoneName = oCaseMilestone.MilestoneType.Name;
                caseMilestoneID = oCaseMilestone.Id;
                contextUserTargetDate = oCaseMilestone.TargetDate.format('MMM d');
                contextUserTargetTime = oCaseMilestone.TargetDate.format('h:mm a');
                targetDateText = contextUserTargetDate + ' at ' + contextUserTargetTime;
                if(oCaseMilestone.IsViolated==true)
                    milestoneStatusText = 'Past Due';
                else{
                    timeUntilTarget = Double.ValueOf(oCaseMilestone.TargetDate.getTime() - system.now().getTime());
                    Integer timeLeft = timeUntilTarget.intValue();
                    timeRemainingSec = math.mod((timeLeft/1000),60);
                    timeRemainingMins = math.mod((timeLeft/(1000*60)),60);
                    timeRemainingHrs = (((timeLeft)/(1000*60))/60);
                    milestoneStatusText = timeRemainingHrs + ' hr ' + timeRemainingMins + ' min';
                }
            }
        }
    }
    public CaseMilestone getCaseMilestone() {
        return oCaseMilestone;
    }
    private CaseMilestone cm{
        get { return getCaseMilestone(); }
        set;
    }
    // test methods
    static testMethod void testGetNextCaseMilestone() {
        List<CaseMilestone> listCM = [Select CaseId From CaseMilestone limit 10];
        for (CaseMilestone cm:listCM){
            ApexPages.currentPage().getParameters().put('Id',cm.CaseId);
            ApexPages.StandardController con = new ApexPages.StandardController(new Case());
            GetNextCaseMilestone ext = new GetNextCaseMilestone(con);
            ext.getCaseMilestone();
        }
        System.debug('TESTS ENDED');
    }
}
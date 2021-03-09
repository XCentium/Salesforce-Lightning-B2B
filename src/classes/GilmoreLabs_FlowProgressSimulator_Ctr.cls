public class GilmoreLabs_FlowProgressSimulator_Ctr 
{
    @AuraEnabled
    public static Integer updateProgress(Integer currentProgress, Integer speed) 
    {
        //Change to do actual things if not running simulation
        return currentProgress + speed;
    }
}
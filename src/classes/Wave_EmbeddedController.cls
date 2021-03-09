public class Wave_EmbeddedController {
    
        private Map<String, Id> waveMap;

    public Wave_EmbeddedController() {
        
        waveMap = new Map<String, Id>(); 
		for(Lens l : [SELECT Id,DeveloperName FROM Lens])
        {
            waveMap.put(l.DeveloperName, l.Id);
        }
        	
       
    }
    
    public Id getSalesWaveManagerDashboard()
    {
        return waveMap.get('Manager_Overview3');
    }
    public Id getSalesWaveRepDashboard()
    {
        return waveMap.get('Sales_Rep_Overview3');
    }
    

    

}
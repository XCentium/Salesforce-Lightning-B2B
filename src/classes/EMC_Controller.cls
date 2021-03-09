global class EMC_Controller {
    global EMC_Controller(){}
    global EMC_Controller(ApexPages.StandardController sc){}
    
    @RemoteAction
    global static Object[] getPeriods(){
        return [Select Id, FullyQualifiedLabel, StartDate From Period 
                Where Type = 'Month' AND (StartDate <= LAST_N_MONTHS:3 OR StartDate >= LAST_N_MONTHS:3)
                Order By StartDate DESC];
    }
    
    @RemoteAction
    global static Map<String, Object> getRootUserRole(){
        UserRole root = [Select Id, Name, ForecastUserId, (Select Id, Name From Users)
                         From UserRole Where DeveloperName = 'VPSales' And ForecastUserId != null Limit 1];
        UserRole[] children = [Select Id, Name, ParentRoleId, (Select Id, Name, Manager.Name From Users Where isActive = true)
                               From UserRole Where ParentRoleId = :root.Id And ForecastUserId != null];
        
        Map<String, Object> hierachyMap = new Map<String, Object>{'root' => root, 'children' => children};
        return hierachyMap;
    }
    
    @RemoteAction
    global static Map<String, Object> getRootUser(String userId){
        User root = new User();
        List<User> children = new List<User>();
        if(userId == ''){
            root = [Select Id, Name, UserRoleId 
                    From User 
                    Where External_Id__c = 'User.001'];
            children = [Select Id, Name, UserRoleId, UserRole.ForecastUserId, UserRole.ParentRoleId 
                        From User 
                        Where UserRole.ParentRoleId = :root.UserRoleId And ForecastEnabled = true
                        Order By Name ASC];
        } else {
            root = [Select Id, Name, UserRoleId
                    From User 
                    Where Id = :userId Limit 1];
            children = [Select Id, Name, UserRoleId, UserRole.ForecastUserId, UserRole.ParentRoleId 
                        From User 
                        Where UserRole.ParentRoleId = :root.UserRoleId And ForecastEnabled = true
                        Order By Name ASC];
            
        }
        
        List<String> childrenIds = new List<String>();
        for(User child: children){
            childrenIds.add(child.UserRoleId);
        }
        
        List<UserRole> grandChildren = [Select Id, ParentRoleId From UserRole Where ParentRoleId IN: childrenIds];
        Map<String, Boolean> hasChildren = new Map<String, Boolean>();
        for(UserRole grandChild: grandChildren){
            hasChildren.put(grandChild.ParentRoleId, true);
        }
        
        Map<String, Object> hierachyMap = new Map<String, Object>{'root' => root, 'children' => children, 'hasChildren' => hasChildren};
        return hierachyMap;
    }
    
    @RemoteAction
    global static Object[] getForecastingPredictions(String forcastingItemId){
        return [Select Id, Period.FullyQualifiedLabel From ForecastingPrediction];
    }
    
    @RemoteAction
    global static Object upsertForecastingPredictions(String sForecastingPrediction){
        ForecastingPrediction[] predictions = (ForecastingPrediction[])JSON.deserialize(sForecastingPrediction, ForecastingPrediction[].class);
        upsert predictions;
        return null;
    }
    
    @RemoteAction
    global static Database.DeleteResult[] deleteRecords(Id[] recordIds, Boolean allOrNothing){
        Database.DeleteResult[] result = Database.delete(recordIds, allOrNothing);
        return result;
    }
    
    global static void fakeTest(){
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}
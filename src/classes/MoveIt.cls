public class MoveIt {
    
    @InvocableMethod
    public static list<string> MoveIt (list<Inputs> myInputList) {
        point oldlocation = new point(myInputList[0].inoldlat,myInputList[0].inoldlong);
        point newlocation = new point(myInputList[0].innewlat,myInputList[0].innewlong);
        id tid = myInputList[0].interritoryID;       
        list<string> resultsstring = new list<string>();  
        list<integer> successCodes = new list<integer>();
        resultsstring.add('success');
        
FSLDemoTools_BatchUpdateLocation batch = new FSLDemoTools_BatchUpdateLocation('ServiceTerritoryMember',tid,oldLocation,newlocation); 
Database.executeBatch(batch);          

        return resultsstring;
        
        }
        
        
    public class Inputs {        
        @InvocableVariable
        public string interritoryID;
        @InvocableVariable
        public double inoldlat;
        @InvocableVariable
        public double inoldlong;  
        @InvocableVariable
        public double innewlat;
        @InvocableVariable
        public double innewlong;          
        }
}
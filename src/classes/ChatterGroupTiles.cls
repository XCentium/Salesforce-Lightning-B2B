public class ChatterGroupTiles {
	@auraEnabled 
    public static List<CollaborationGroup> getGroups(String filter,Boolean publiconly){
        String nid=System.Network.getNetworkId();
        String query='SELECT Id,Name,FullPhotoUrl FROM CollaborationGroup WHERE NetworkId=:nid AND IsArchived=false ';
        if(!String.isEmpty(filter))query=query+'AND Description LIKE \'%'+String.escapeSingleQuotes(filter)+'%\' ';
        if(publiconly)query=query+'AND CollaborationType=\'Public\''; 
        List<sObject> tiles=Database.query(query);
        return tiles;
    }
}
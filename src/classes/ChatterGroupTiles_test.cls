@isTest
public class ChatterGroupTiles_test {
    
    @isTest
    static void Test_getGroups()
    {
        // Insert a chatter group
        CollaborationGroup cg=New CollaborationGroup(Name='Test CG',CollaborationType='Private',description='featured');
        insert cg;
        
        test.starttest();
        List <CollaborationGroup> retourPonlyNotFiltered=ChatterGroupTiles.getGroups('',true);
        List <CollaborationGroup> retourAllNotFiltered=ChatterGroupTiles.getGroups('',false);
        List <CollaborationGroup> retourAllFiltered=ChatterGroupTiles.getGroups('featured',false);
        List <CollaborationGroup> retourPonlyFiltered=ChatterGroupTiles.getGroups('featured',true);
        test.stoptest();
        System.AssertEquals(retourPonlyNotFiltered.isEmpty(),true);
        System.AssertEquals(retourAllNotFiltered[0].Name,'Test CG');
        System.AssertEquals(retourAllFiltered[0].Name,'Test CG');
         System.AssertEquals(retourPonlyFiltered.isEmpty(),true);
        
    }

}
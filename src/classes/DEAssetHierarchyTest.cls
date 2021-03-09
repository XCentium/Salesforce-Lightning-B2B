@isTest
public class DEAssetHierarchyTest {
	 static testMethod void testAssetHierarchy() {
    // Instanciate Page
  
    DEAssetHierarchyTestData.createTestHierarchy();

    Asset topAsset = [Select id, name from Asset where name = 'HierarchyTest0' LIMIT 1];
    Asset middleAsset = [Select id, parentID, name from Asset where name = 'HierarchyTest4' LIMIT 1];
    Asset bottomAsset = [Select id, parentID, name from Asset where name = 'HierarchyTest9' LIMIT 1];
    Asset[] AssetList = [Select id, parentID, name from Asset where name like 'HierarchyTest%'];

    test.startTest();
    
    System.debug('DEBUG: AssetList size: '+AssetList.size());
  
    PageReference DEAssetHierarchyVF = Page.DEAssetHierarchyVF;
    Test.setCurrentPage(DEAssetHierarchyVF);
    ApexPages.currentPage().getParameters().put('id', topAsset.id);
  
    // Instanciate Controller
    DEAssetHierarchyCTRL controller = new DEAssetHierarchyCTRL();
    
    // Call Methodes for top Asset
    controller.setcurrentId(null);
    DEAssetHierarchyCTRL.ObjectStructureMap[] smt1 = new DEAssetHierarchyCTRL.ObjectStructureMap[]{};
    smt1 = controller.getObjectStructure();
    System.Assert(smt1.size()>0, 'Test failed at Top Asset, no Id');

    controller.setcurrentId(String.valueOf(topAsset.id));
    DEAssetHierarchyCTRL.ObjectStructureMap[] smt2 = new DEAssetHierarchyCTRL.ObjectStructureMap[]{};
    smt2 = controller.getObjectStructure();
    System.Assert(smt2.size()>0, 'Test failed at Top Asset, with Id: '+smt2.size());

    //Call ObjectStructureMap methodes
    smt2[0].setnodeId('1234567890');
    smt2[0].setlevelFlag(true);
    smt2[0].setlcloseFlag(false);
    smt2[0].setnodeType('parent');
    smt2[0].setcurrentNode(false);
    smt2[0].setAsset(topAsset);
    String nodeId = smt2[0].getnodeId();
    Boolean[] levelFlag = smt2[0].getlevelFlag();
    Boolean[] closeFlag = smt2[0].getcloseFlag();
    String nodeType = smt2[0].getnodeType();
    Boolean currentName = smt2[0].getcurrentNode();
    Asset smbAsset = smt2[0].getAsset();


    // Call Methodes for middle Asset
    controller.setcurrentId(String.valueOf(middleAsset.id));
    DEAssetHierarchyCTRL.ObjectStructureMap[] smm = new DEAssetHierarchyCTRL.ObjectStructureMap[]{};
    smm = controller.getObjectStructure();
    System.Assert(smm.size()>0, 'Test failed at middle Asset');

    // Call Methodes for bottom Asset
    controller.setcurrentId(String.valueOf(bottomAsset.id));
    DEAssetHierarchyCTRL.ObjectStructureMap[] smb = new DEAssetHierarchyCTRL.ObjectStructureMap[]{};
    smb = controller.getObjectStructure();
    System.Assert(smb.size()>0, 'Test failed at top Asset');
    
    test.stopTest();
  }
}
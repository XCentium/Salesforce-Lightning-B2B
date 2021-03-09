public class DEAssetHierarchyTestData {
	public static void createTestHierarchy() {
    // Create Assets with Hierarchy
  
    // Create Top Level Assets
    Account acc1  = new Account(name = 'acc1');
    insert acc1;
        
    Asset[] subAssets = new Asset[]{};
    Asset[] assetList = new Asset[]{};
    Asset[] subAssetsSideTree = new Asset[]{};
    Asset[] subAssetsList = new Asset[]{};
    
    
    String assetName = 'HierarchyTest';
    
    Asset parentAsset = new Asset(name=assetName+'0',AccountId = acc1.Id);
    Asset subTreeParent  = new Asset(AccountId = acc1.Id);
    Asset subTreeSideParent  = new Asset(AccountId = acc1.Id);


    insert parentAsset;
    parentAsset = [select id, name from asset where name='HierarchyTest0'];
    Id parentID = parentAsset.id;
    System.Assert(parentID != null, 'Parent Id not found');
    
    // Create sub assets
  
    for (Integer i=0;i<10;i++){
      subAssets.add(new Asset(name=assetName+i,AccountId = acc1.Id));  
    }
    
    insert subAssets;
    
    assetList = [Select id, parentID, AccountId , name from asset where name like 'HierarchyTest%' ORDER BY Name];
        
    for (Integer x=0;x<assetList.size();x++){
      if (assetList[x].name != 'HierarchyTest0'){
        assetList[x].parentID = parentID;
        assetList[x].AccountId = acc1.Id;
        parentID=assetList[x].Id;  
      }
    }
    
    update assetList;
    
    subTreeParent = [Select id, parentID, name, AccountId from asset where name = 'HierarchyTest4'];
    parentID=subTreeParent.Id;

    for (Integer y=0;y<10;y++){
      subAssetsSideTree.add(new Asset(name=assetName+'4.'+y,AccountId = acc1.Id));  
    }

    insert subAssetsSideTree;
    
    subAssetsList = [Select id, parentID, name, AccountId from asset where name like 'HierarchyTest4%'];

    for (Integer z=1;z<subAssetsList.size();z++){
      subAssetsList[z].parentID = parentID;
      subAssetsList[z].AccountId = acc1.Id;
      parentID=assetList[z].Id;  
    }
    
    update subAssetsList;
    
  }
}
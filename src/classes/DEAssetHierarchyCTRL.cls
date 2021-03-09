public class DEAssetHierarchyCTRL {
// To adapt this to anouther Object simply search for "Change" to go to the places 
// where the sObject and query must be changed

    //Wrapper class
    public class ObjectStructureMap {

        public String nodeId;
        public Boolean[] levelFlag = new Boolean[]{};
        public Boolean[] closeFlag = new Boolean[]{};
        public String nodeType;
        public Boolean currentNode;
        //
        // Change this to your sObject
        //
        public Asset asset;
        //
        
        public String getnodeId() { return nodeId; }
        public Boolean[] getlevelFlag() { return levelFlag; }
        public Boolean[] getcloseFlag() { return closeFlag; }
        public String getnodeType() { return nodeType; }
        public Boolean getcurrentNode() { return currentNode; }
        //
        // Change this to your sObject
        //
        public Asset getasset() { return asset; }
        //
        
        public void setnodeId( String n ) { this.nodeId = n; }
        public void setlevelFlag( Boolean l ) { this.levelFlag.add(l); }
        public void setlcloseFlag( Boolean l ) { this.closeFlag.add(l); }
        public void setnodeType( String nt ) { this.nodeType = nt; }
        public void setcurrentNode( Boolean cn ) { this.currentNode = cn; }
        //
        // Change this to your sObject
        //
        public void setasset( Asset a ) { this.asset = a; }
        //
        
        //
        // Change the parameters to your sObject
        //
        public ObjectStructureMap(String nodeId, Boolean[] levelFlag,Boolean[] closeFlag , String nodeType, Boolean lastNode, Boolean currentNode, Asset a){
            this.nodeId = nodeId;
            this.levelFlag = levelFlag; 
            this.closeFlag = closeFlag;
            this.nodeType = nodeType;
            this.currentNode = currentNode;
            //
            // Change this to your sObject  
            //
            this.asset = a;
            //
        }
    }

    // Declare variables
    // 
    public String currentId;
    public List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
    public Map<String, ObjectStructureMap> masm = new Map<String, ObjectStructureMap>{};
    public List<Integer> maxLevel = new List<Integer>{};
    
        
    // Allow page to set the current ID
    //
    public void setcurrentId(String cid) {
        currentId = cid;
        System.debug('cid ' + cid);
    }

    // Return ObjectStructureMap to page
    //
    public List<ObjectStructureMap> getObjectStructure(){
        asm.clear();
        if (currentId == null) {
            currentId = System.currentPageReference().getParameters().get('id');
            System.debug('currentId ' + currentId);
        }
        System.assertNotEquals(currentId,null,'sObject ID must be provided');
        asm = formatObjectStructure(CurrentId);
        System.debug('asm ' + asm);
        return asm;
    }

    // Query Account from top down to build the ObjectStructureMap
    //
    public ObjectStructureMap[] formatObjectStructure(String currentId){
        System.debug('hello ');
    
        List<ObjectStructureMap> asm = new List<ObjectStructureMap>{};
        masm.clear();
        System.debug('masm ' + masm);
        //
        // Change below
        //
        List<Asset> al = new List<Asset>{};
            System.debug('al ' + al);
        //
        List<ID> currentParent = new List<ID>{};
        Map<ID, String> nodeList = new Map<ID, String>{};
        List<String> nodeSortList = new List<String>{};
        List<Boolean> levelFlag = new List<Boolean>{};
        List<Boolean> closeFlag = new List<Boolean>{};
        String nodeId = '0';
        String nodeType = 'child';
        Integer count = 0;
        Integer level = 0;
        Boolean endOfStructure = false;
        
        // Find highest level obejct in the structure
        //
        currentParent.add(GetTopElement(currentId));

        // Loop though all children
        while (!endOfStructure ){

      if(level==0){
          //
          // Change below
          //        
          al = [SELECT a.ParentId, a.Name, a.Id, a.Status, a.InstallDate, a.Product2.Name, a.Contact.Name FROM Asset a WHERE a.id IN :CurrentParent ORDER BY a.Name];
          System.debug('get children is top' + al);
          //
          
      }
      else {
          //
          // Change below
          //        
          al = [SELECT a.ParentId, a.Name, a.Id, a.Status, a.InstallDate, a.Product2.Name, a.Contact.Name FROM Asset a WHERE a.ParentID IN :CurrentParent ORDER BY a.Name];
          System.debug('get children not top' + al);
          //
      }

            if(al.size() == 0){
                endOfStructure = true;
                System.debug('al size zero ');
            }
            else {
                 System.debug('al size not zero ');
                currentParent.clear();
                for (Integer i = 0 ; i < al.size(); i++){
                    //
                    // Change below
                    //
                    Asset a = al[i];
                    //
                    if (level > 0){
                        nodeId=NodeList.get(a.ParentId)+'.'+String.valueOf(i);
                    }
                    else {
                        nodeId=String.valueOf(i);
                    }
                    masm.put( NodeID, new ObjectStructureMap(nodeID,levelFlag,closeFlag,nodeType,false,false,a));
                    currentParent.add(a.id);
                    nodeList.put(a.id,nodeId);
                    nodeSortList.add(nodeId);
                }
                maxLevel.add(level);                
                level++;
            }
            
        }
        
        // Account structure must now be formatted
        //
        
        NodeSortList.sort();
        for (Integer i = 0; i < NodeSortList.size();i++){
            List<String> pnl = new List<String> {};
            List<String> cnl = new List<String> {};
            List<String> nnl = new List<String> {};
            
            if (i > 0){
                String pn = NodeSortList[i-1];
                pnl = pn.split('\\.',-1);
            }

            String cn = NodeSortList[i];
            cnl = cn.split('\\.',-1);

            if (i < NodeSortList.size()-1){
                String nn = NodeSortList[i+1];
                nnl = nn.split('\\.',-1);
            }
            ObjectStructureMap tasm = masm.get(cn);
            if (cnl.size() < nnl.size()){
                //Parent
                if (isLastNode(cnl)){
                    tasm.nodeType='parent_end';
                }
                else {
                    tasm.nodeType='parent';
                }
            }
            else if (cnl.size() > nnl.size()){
                tasm.nodeType='child_end';
                tasm.closeFlag=setcloseFlag(cnl, nnl, tasm.nodeType);
            }
            else {
                tasm.nodeType='child';
            }
            tasm.levelFlag = setlevelFlag(cnl, tasm.nodeType); 
            //
            // Change below
            //
            if (tasm.asset.id == currentId) {
                tasm.currentNode=true;
            }
            //
            asm.add(tasm);
        }
        asm[0].nodeType='start';
        asm[asm.size()-1].nodeType='end';
        
        return asm;
    }
    
    // Determin parent elements relationship to current element
    //
    public List<Boolean> setlevelFlag(List<String> nodeElements, String nodeType){
        System.debug('set level flag');
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode = '';
        String workNode = '';
        Integer cn = 0;
            for(Integer i = 0; i < nodeElements.size()-1;i++){
                cn = Integer.valueOf(nodeElements[i]);
                cn++;
                searchNode=workNode + String.valueOf(cn);
                workNode=workNode + nodeElements[i] + '.';
                if (masm.containsKey(searchNode)){
                    flagList.add(true);
                }
                else {
                    flagList.add(false);
                }
            }
        return flagList;
    }
    
    // Determin if the element is a closing element
    //
    public List<Boolean> setcloseFlag(List<String> cnl, List<String> nnl, String nodeType){
        System.debug('set close flag');
        List<Boolean> flagList = new List<Boolean>{};
        String searchNode = '';
        String workNode = '';
        Integer cn = 0;
        for(Integer i = nnl.size(); i < cnl.size();i++){
                    flagList.add(true);
        }
        return flagList;
    }

    // Determin if Element is the bottom node
    //    
    public Boolean isLastNode(List<String> nodeElements){
        System.debug('is last');
        String searchNode = '';
        Integer cn = 0;
        for(Integer i = 0; i < nodeElements.size();i++){
            if (i == nodeElements.size()-1){
                cn = Integer.valueOf(nodeElements[i]);
                cn++;
                searchNode=searchNode + String.valueOf(cn);
            }
            else {
                searchNode=searchNode + nodeElements[i] + '.';
            }
        }
        if (masm.containsKey(searchNode)){
            return false;
        }
        else{
            return true;
        }
    }

    // Find the tom most element in Heirarchy
    //    
    public String GetTopElement(String objId) {
        System.debug('get top');
        Boolean top = false;
        while (!top) {
            //
            // Change below
            //
            Asset a = [Select a.id, a.ParentId From Asset a where a.id = :objId LIMIT 2];
            //
            
            if (a.ParentID != null) {
                objId = a.ParentID;
            }
            else {
                top=true;
            }
        }
        return objId ;
    }
}
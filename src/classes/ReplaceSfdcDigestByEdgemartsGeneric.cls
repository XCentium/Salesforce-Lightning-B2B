public with sharing class ReplaceSfdcDigestByEdgemartsGeneric implements ReplaceSfdcDigestByEdgemarts {
    
    public ReplaceSfdcDigestByEdgemartsGeneric() {

    }

    public Map<String, Object> doReplacement(Map<String, Object> dataflowDefinitionObject, List<WaveApplicationEdgemart> edgemartsConfigurations){
        Map<String, String> digestNodes = new Map<String, String>();
        Map<String, String> replaceNodesMap = new Map<String, String>();
        List<String> lstObjectNamesToHandle = new List<String>();

        for (WaveApplicationEdgemart wae : edgemartsConfigurations) {
            lstObjectNamesToHandle.add(wae.objectName);
        }

        // With this for loop we search which are the sfdcDigest nodes and from which object they extract
        for (String nodeName : dataflowDefinitionObject.keySet()) {
            Map<String, Object> node = (Map<String, Object>)dataflowDefinitionObject.get(nodeName);
            // If parameters exist
            if(node.containsKey('action')) {
                String action = (String)node.get('action');
                if (action.equals('sfdcDigest')) {
                    if(node.containsKey('parameters')) {
                        Map<String, Object> nodeParams = (Map<String, Object>)node.get('parameters');
                        String objName = (String)nodeParams.get('object');
                        if (lstObjectNamesToHandle.contains(objName)) {
                            if(digestNodes.containsKey(objName)){
                                throw new WaveConfiguratorException('Cannot edit dataflow because cannot replace sfdcDigest by edgemart transformation. ' + objName + ' object is being extracted more than once in the dataflow.');
                            }
                            digestNodes.put(objName, nodeName);
                        }                        
                    }
                }
            }
        }

        for (WaveApplicationEdgemart wae : edgemartsConfigurations) {
            
            // Add each edgemart node
            String nodeJson = '{"action": "edgemart","parameters": { "alias": "' + wae.edgemartDeveloperName + '" }}';
            Object o = JSON.deserializeUntyped(nodeJson);
            dataflowDefinitionObject.put(wae.edgemartNodeNameInDataflow, o);
            replaceNodesMap.put(digestNodes.get(wae.objectName), wae.edgemartNodeNameInDataflow);
        }

        // Key: Node Name
        // Value: List of node names that depend on the node named by Key 
        Map<String, List<String>> dependencyMap = new Map<String, List<String>>();
        for (String tdn : digestNodes.values()) {
            dependencyMap.put(tdn, new List<String>());
        }

        // With this for loop we search which nodes are dependent of our sfdcDigests
        for (String nodeName : dataflowDefinitionObject.keySet()) {
            Map<String, Object> node = (Map<String, Object>)dataflowDefinitionObject.get(nodeName);
            // If parameters exist
            if(node.containsKey('action')) {
                
                String action = (String)node.get('action');
                
                // We don't want root type transformations, those without source transformation/s
                if (!(action.equals('sfdcDigest') || action.equals('digest') || action.equals('edgemart'))) {
                    if(node.containsKey('parameters')) {
                        Map<String, Object> nodeParams = (Map<String, Object>)node.get('parameters');
                        switch on action {
                            when 'append' {
                                List<Object> sources = (List<Object>)nodeParams.get('sources');
                                for (Object sourceTransfObj: sources) {
                                    String sourceTransf = (String) sourceTransfObj;
                                    if (digestNodes.values().contains(sourceTransf)) {
                                        dependencyMap.get(sourceTransf).add(nodeName);
                                    }
                                }
                            }
                            when 'augment', 'update' {
                                String left = (String)nodeParams.get('left');
                                String right = (String)nodeParams.get('right');
                                
                                if (digestNodes.values().contains(left)) {
                                    dependencyMap.get(left).add(nodeName);
                                }

                                if (digestNodes.values().contains(right)) {
                                    dependencyMap.get(right).add(nodeName);
                                }
                            }
                            when else {
                                String source = (String)nodeParams.get('source');
                                if (digestNodes.values().contains(source)) {
                                    dependencyMap.get(source).add(nodeName);
                                }
                            }
                        }
                    }
                }
            }
        }
        
        for (String s: dependencyMap.keySet()) {
            List<String> ls = dependencyMap.get(s);
            System.debug('Transformations that depend of: ' + s);
            System.debug(ls);
        }

        for (String nodeName : digestNodes.values()) {
            
            List<String> nodesToEdit = dependencyMap.get(nodeName);
            
            for (String nodeToEditName: nodesToEdit) {
                Map<String, Object> nodeToEdit = (Map<String, Object>)dataflowDefinitionObject.get(nodeToEditName);
                String action = (String)nodeToEdit.get('action');
                Map<String, Object> nodeParams = (Map<String, Object>)nodeToEdit.get('parameters');
                switch on action {
                    when 'append' {
                        List<Object> sources = (List<Object>)nodeParams.get('sources');
                        sources.remove(sources.indexOf(nodeName));
                        sources.add(replaceNodesMap.get(nodeName));                        
                    }
                    when 'augment', 'update' {
                        String left = (String)nodeParams.get('left');
                        String right = (String)nodeParams.get('right');
                        
                        if (left.equals(nodeName)) {
                            nodeParams.put('left', replaceNodesMap.get(nodeName));
                        }

                        if (right.equals(nodeName)) {
                            nodeParams.put('right', replaceNodesMap.get(nodeName));
                        }
                    }
                    when else {
                        String source = (String)nodeParams.get('source');
                        if (source.equals(nodeName)) {
                            nodeParams.put('source', replaceNodesMap.get(nodeName));
                        }
                    }
                }
            }
        }

        return dataflowDefinitionObject;
    }
}
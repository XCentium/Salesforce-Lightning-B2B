public with sharing class ReplaceSfdcDigestByEdgemartsDirect implements ReplaceSfdcDigestByEdgemarts {
    
    public ReplaceSfdcDigestByEdgemartsDirect() {

    }

    public Map<String, Object> doReplacement(Map<String, Object> dataflowDefinitionObject, List<WaveApplicationEdgemart> edgemartsConfigurations){
        
        // Key: Node Name
        // Value: List of node names that depend on the node named by Key 
        Map<String, List<String>> dependencyMap = new Map<String, List<String>>();
        Map<String, String> replaceNodesMap = new Map<String, String>();
        List<String> lstDigestsToReplace = new List<String>();
        
        // sfdcDigest nodes that will be replaced by edgemarts and dependent of those
        for (WaveApplicationEdgemart wae : edgemartsConfigurations) {
            lstDigestsToReplace.add(wae.edgemartNodeNameToReplaceInDataflow);
            dependencyMap.put(wae.edgemartNodeNameToReplaceInDataflow, new List<String>());

            // Add each edgemart node
            String nodeJson = '{"action": "edgemart","parameters": { "alias": "' + wae.edgemartDeveloperName + '" }}';
            Object o = JSON.deserializeUntyped(nodeJson);
            dataflowDefinitionObject.put(wae.edgemartNodeNameInDataflow, o);
            replaceNodesMap.put(wae.edgemartNodeNameToReplaceInDataflow, wae.edgemartNodeNameInDataflow);
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
                                    if (lstDigestsToReplace.contains(sourceTransf)) {
                                        dependencyMap.get(sourceTransf).add(nodeName);
                                    }
                                }
                            }
                            when 'augment', 'update' {
                                String left = (String)nodeParams.get('left');
                                String right = (String)nodeParams.get('right');
                                
                                if (lstDigestsToReplace.contains(left)) {
                                    dependencyMap.get(left).add(nodeName);
                                }

                                if (lstDigestsToReplace.contains(right)) {
                                    dependencyMap.get(right).add(nodeName);
                                }
                            }
                            when else {
                                String source = (String)nodeParams.get('source');
                                if (lstDigestsToReplace.contains(source)) {
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

        for (String nodeName : lstDigestsToReplace) {
            
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

        // Finally we remove all the nodes that were replaced
        for (String nodeName : lstDigestsToReplace) {
            dataflowDefinitionObject.remove(nodeName);
        }

        return dataflowDefinitionObject;
    }
}
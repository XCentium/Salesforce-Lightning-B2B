public interface ReplaceSfdcDigestByEdgemarts {
    Map<String, Object> doReplacement(Map<String, Object> dataflowDefinitionObject, List<WaveApplicationEdgemart> edgemartsConfigurations);
}
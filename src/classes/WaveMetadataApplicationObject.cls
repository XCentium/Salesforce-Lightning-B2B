public class WaveMetadataApplicationObject {
	public String name;
	public String url;
	public Integer additionalDataFiles;
    public String externalIdPrefix;
	public String metadataUrl;
	public List<String> dateFieldsToShift;
	public List<String> stdFieldsForPermissionSet;
	public List<WaveMetadataApplicationObject> children;
	public List<WaveMetadataApplicationObjectRelation> relations;
	public List<WaveRecordTypeItem> recordTypes;
}
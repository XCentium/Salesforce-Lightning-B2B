public class WaveApplicationObject {
	public String name {get; set;}
	public String url {get; set;}
	public Integer currentDataIndex {get; set;}
	public Integer additionalDataFiles {get; set;}
	public Integer recordsToProcess {get; set;}
	public List<WaveApplicationObjectRelation> relations { get; set; }
	public List<WaveApplicationObjectField> fields { get; set; }
	public Map<Integer, String> fieldPositions { get; set; }
	public List<String> stdFieldsForPermissionSet { get; set; }

	public WaveApplicationObject(){
		this.currentDataIndex = 0;
		this.additionalDataFiles = 0;
	}
}
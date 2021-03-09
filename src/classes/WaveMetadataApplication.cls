public virtual class WaveMetadataApplication {
	public String appName;
	public String appType;
	public String appDescription;
	public String dataflowLocation;
	public String userProfilePicturesUrl;
	public List<WaveMetadataApplicationObject> objects;
	public TimeShiftSettings timeShift;
	public List<WaveMetadataApplicationEdgemart> edgemarts;
	public List<WaveMetadataApplicationActionField> actionFieldOverrides;
	public List<WaveMetadataApplicationDataset> datasets;
	public List<WaveMetadataApplicationDashboard> dashboards;
	public WaveMetadataApplicationImage referencedImages;
	public WaveMetadataApplicationDataflow dataflow;
}
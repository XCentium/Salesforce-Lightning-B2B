public with sharing class ChronosBot_JSON2Apex {

	public List<TimeSlots> timeSlots;

	public class TimeSlots {
		public DateTime endTime;
		public DateTime startTime;
		public String territoryId;
	}
	
	public static ChronosBot_JSON2Apex parse(String json) {
		return (ChronosBot_JSON2Apex) System.JSON.deserialize(json, ChronosBot_JSON2Apex.class);
	}
}
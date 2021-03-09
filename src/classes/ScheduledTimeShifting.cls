global class ScheduledTimeShifting implements Schedulable{
	private String url;
    
    global ScheduledTimeShifting(String url){
        this.url = url;
    }
    
	global void execute(SchedulableContext sc) {
		System.enqueueJob(new CheckTimeShiftingQueue(true, this.url));
	}
	
}
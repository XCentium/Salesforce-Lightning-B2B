@isTest(SeeAllData=true)
public class MyTopicsControllerTest {
	
    public static testmethod  void doStuff(){
    	MyTopicsController.getTopicsWithFollowers('audiophiles');
        MyTopicsController.hasFollowers('audiophiles');
    }
}
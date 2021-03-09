/**
* wrapper class for saving order informations to show to pages/components
* 
*
* @author  Neeraj Yadav
* @version 1.0
*/
public class SCCOrderWrapper {
		
	@AuraEnabled public String name			{get; set;}
	@AuraEnabled public String value		{get; set;}
		
	public SCCOrderWrapper(String name, String value) {

		this.name		= name;
		this.value		= value;

	}

}
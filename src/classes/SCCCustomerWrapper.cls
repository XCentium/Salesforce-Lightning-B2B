public class SCCCustomerWrapper {
		
	@AuraEnabled public String name			{get; set;}
	@AuraEnabled public String value		{get; set;}
	public Map<String, String> genderMap = new Map<String, String>{	'1'=>'Male', 
																	'2'=>'Female'};		
	public SCCCustomerWrapper(String name, String value) {

		this.name = name;
		if(this.name == 'Gender') {
			if(genderMap.containsKey(value)) {
				this.value = genderMap.get(value);
			} else {
				this.value 		= '';
			}
		} else {
			this.value		= value;
		}

	}

}
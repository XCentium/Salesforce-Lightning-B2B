public with sharing class iPhonePageClass {
	public StaticResource backgroundId {get;set;}

	public iPhonePageClass() {
		backgroundId =  [Select Id FROM StaticResource WHERE Name = 'iphonebackground' Limit 1];

	}
}
public with sharing class MockarooHelperFactory {
	
	public static IMockarooHelper getIMockarooHelper(){
		//return new MockarooHelper();
		return new WaveCsvDataRetriever();
	}
}
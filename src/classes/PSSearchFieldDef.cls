public with sharing class PSSearchFieldDef
{
  public String fieldLabel {get;set;}
  public String fieldName {get;set;}
  public String fieldType {get; set;}   // values: MAPLIST, UNIQUE
  public String obj {get; set;}
  public Boolean wildcard {get; set;}
  public Map<String, String> mapList {get; set;}
  public List<String> keyList {get; set;}

  public PSSearchFieldDef()
  {
     mapList = new Map<String, String>();
     keyList = new List<String>();
     wildcard = false;
  }

  public void addKeyValue(String key, String value)
  {
  	 keyList.add(key);
  	 mapList.put(key, value);
  }

  public static PSField parseFieldDef(String fieldDefStr)
  {
  	 PSSearchFieldDef sfd = (PSSearchFieldDef)JSON.deserialize(fieldDefStr, PSSearchFieldDef.class);

  	 if ((sfd.keyList == null) && (sfd.mapList != null))
  	 {
        sfd.keyList = new List<String>(sfd.mapList.keySet());
  	 }

  	 PSField fld = new PSField();
  	 if (sfd.fieldType == 'MAPLIST')
  	 {
  	 	fld.ftype = 'picklist';
  	 	fld.label = sfd.fieldLabel;
  	 	fld.name = sfd.fieldName;
  	 	fld.wildcard = sfd.wildcard;

  	 	for (String key : sfd.keyList)
  	 	{
  	 		fld.addOption(key, sfd.mapList.get(key));
  	 	}
  	 }

  	 return fld;
  }

  public static void test()
  {
  	PSSearchFieldDef sfd = new PSSearchFieldDef();
  	sfd.fieldName = 'TestField__c';
  	sfd.fieldLabel = 'Test Field';
  	sfd.fieldType = 'MAPLIST';
  	sfd.obj = 'TestTable__c';
  	sfd.wildcard = true;
  	sfd.addKeyValue('Key1', 'K1');
  	sfd.addKeyValue('Key2', 'K2');

    String tmpStr = JSON.serializePretty(sfd);
  	System.debug(tmpStr);

  	PSField fld = PSSearchFieldDef.parseFieldDef(tmpStr);
  	System.debug(JSON.serializePretty(fld));
  }

}
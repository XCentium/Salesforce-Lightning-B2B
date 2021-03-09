@isTest(SeeAllData=true)
public class openCTIHelperApexTest {
	public static testMethod void doTest() {
		Account myAcc = [SELECT Id, Name FROM Account ORDER BY Name ASC LIMIT 1];

		Contact con = new Contact();
		con.AccountId = myAcc.Id;
		con.LastName = 'myLastName';
		con.FirstName = 'myFirstName';
		insert con;

		openCTIHelperApex helper = new openCTIHelperApex();

		Contact myContact = openCTIHelperApex.getContactViaId(con.Id);

		openCTIHelperApex.createMyConfig('ContactName', 'AccountName', myContact.Id, myAcc.Id, 'CEO', '5555555', true, true);
	}
}
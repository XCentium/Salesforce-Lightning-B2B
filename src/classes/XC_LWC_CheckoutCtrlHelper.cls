/**
 * @FileName: XC_LWC_CheckoutCtrlHelper
 * @Description: Helper methods for the lightning storefront checkout controller
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       9/8/2020         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_LWC_CheckoutCtrlHelper {

    public static List<ContactPointAddress> getContactPointAddresses() {
        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :u.ContactId];

        return [
                SELECT Id, Street, City, State, PostalCode, Country
                FROM ContactPointAddress
                WHERE ParentId = :c.AccountId
                AND AddressType = 'Shipping'
        ];
    }

    public static ContactPointAddress createContactPointAddress(String addressJSON) {
        XC_LWC_CheckoutWrappers.AddressWrapper wrapper = (XC_LWC_CheckoutWrappers.AddressWrapper)
                JSON.deserialize(addressJSON, XC_LWC_CheckoutWrappers.AddressWrapper.class);

        User u = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        Contact c = [SELECT Id, AccountId FROM Contact WHERE Id = :u.ContactId];

        ContactPointAddress address = new ContactPointAddress(
                Name = wrapper.name,
                Street = wrapper.street,
                City = wrapper.city,
                State = wrapper.state,
                PostalCode = wrapper.postalCode,
                Country = wrapper.country,
                ParentId = c.AccountId,
                AddressType = 'Shipping',
                IsDefault = false
        );

        insert address;

        return address;
    }
}
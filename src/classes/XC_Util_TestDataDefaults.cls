/**
 * @FileName: XC_Util_TestDataDefaults
 * @Description: Field defaults for constructing test data by object type
 * @Author: Graeme Ward
 * @ModificationLog:
 *-----------------------------------------------------------
 * Author            Date            Modification
 * Graeme Ward       11/1/2019         Created
 *-----------------------------------------------------------  
 */
public inherited sharing class XC_Util_TestDataDefaults {

    // Use the FieldDefaults interface to set up values you want to default in for all objects.
    public interface FieldDefaults {
        Map<String, Object> getFieldDefaults();
    }

    // Fields that must be incremented (ie. unique) when creating lists of sobjects
    public static Map<String, List<String>> incrementFieldMap = new Map<String, List<String>> {
            'Account' => new List<String>{'Name'},
            'Contact' => new List<String>{'LastName', 'Email'},
            'Case' => new List<String>{'Subject'},
            'User' => new List<String>{'LastName'},
            'OperatingHours' => new List<String>{'Name'},
            'ServiceTerritory' => new List<String>{'Name'},
            'Product2' => new List<String>{'Name'}
    };

    /*
     * ===============================
     * STANDARD OBJECT DEFAULT CLASSES
     * ===============================
     */

    public class AccountDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString(),
                    'Phone' => XC_Util_Apex.generateRandomPhoneNumber(),
                    'BillingStreet' => XC_Util_Apex.generateRandomString(),
                    'BillingCity' => XC_Util_Apex.generateRandomString(),
                    'BillingState' => XC_Util_Apex.generateRandomString(2),
                    'BillingPostalCode' => 'A1A1A1',
                    'BillingCountry' => XC_Util_Apex.generateRandomString(),
                    'ShippingStreet' => XC_Util_Apex.generateRandomString(),
                    'ShippingCity' => XC_Util_Apex.generateRandomString(),
                    'ShippingState' => XC_Util_Apex.generateRandomString(2),
                    'ShippingPostalCode' => 'A1A1A1',
                    'ShippingCountry' => XC_Util_Apex.generateRandomString()
            };
        }
    }

    public class ContactDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'FirstName' => XC_Util_Apex.generateRandomString(),
                    'LastName' => XC_Util_Apex.generateRandomString(),
                    'Email' => XC_Util_Apex.generateRandomEmail()
            };
        }
    }

    public class OpportunityDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'Name' => XC_Util_Apex.generateRandomString(),
                    'CloseDate' => System.today().addDays(30),
                    'Amount' => 0.0,
                    'Type' => 'Retention',
                    'LeadSource' => 'Call In'
            };
        }
    }

    public class OpportunityContactRoleDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{};
        }
    }

    public class OpportunityLineItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{
                    'UnitPrice' => 1.0,
                    'Quantity' => 1
            };
        }
    }

    public class OrderDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'EffectiveDate' => Date.today(),
                    'Pricebook2Id' => Test.getStandardPricebookId()
            };
        }
    }

    public class OrderItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'UnitPrice' => 1.0,
                    'Quantity' => 1
            };
        }
    }

    public class PermissionSetAssignmentDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object>{

            };
        }
    }

    public class PricebookEntryDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Pricebook2Id' => Test.getStandardPricebookId(),
                    'UnitPrice' => 1.0,
                    'IsActive' => true
            };
        }
    }

    public class Product2Defaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'Name' => XC_Util_Apex.generateRandomString(),
                    'IsActive' => true
            };
        }
    }


    public class UserDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
                    'LastName' => XC_Util_Apex.generateRandomString(5),
                    'Alias' => XC_Util_Apex.generateRandomString(4),
                    'Email' => XC_Util_Apex.generateRandomEmail(),
                    'UserName' => System.now().millisecond() + '@cj.com',
                    'TimeZoneSidKey' => 'America/Los_Angeles',
                    'LocaleSidKey' => 'en_US',
                    'EmailEncodingKey' => 'ISO-8859-1',
                    'LanguageLocaleKey' => 'en_US',
                    'Employee_Number__c' => XC_Util_Apex.generateRandomString(25)
            };
        }
    }

    public class WorkOrderDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
            };
        }
    }

    public class WorkOrderLineItemDefaults implements FieldDefaults {
        public Map<String, Object> getFieldDefaults() {
            return new Map<String, Object> {
            };
        }
    }

    /*
     * ===============================
     * CUSTOM OBJECT DEFAULT CLASSES
     * ===============================
     */


    /*
     * ===============================
     * CUSTOM SETTING DEFAULT CLASSES
     * ===============================
     */
}
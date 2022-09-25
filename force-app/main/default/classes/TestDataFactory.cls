@IsTest
public class TestDataFactory {

    public static final Id DEFAULT_CONTACT_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
    public static final Id DEFAULT_DEAL_TYPE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName().get('Sale').getRecordTypeId();

    public static Log__c createLog() {
        Log__c log = new Log__c(Type__c = 'Undefined', Message__c = 'Undefined');

        insert log;
        return log;
    }

    public static Log__c createLog(String type, String message) {
        Log__c log = new Log__c(Type__c = type, Message__c = message);

        insert log;
        return log;
    }

    public static List<Log__c> createLogs(Integer count, String type, String message) {
        List<Log__c> logs = new List<Log__c>(count);
        for (Integer i = 0; i < count; i++) {
            logs[i] = new Log__c(Type__c = type, Message__c = message);
        }

        insert logs;
        return logs;
    }

    public static Contact createContact(String firstName, String lastName) {
        Contact contact = new Contact(FirstName = firstName, LastName = lastName);
        insert contact;
        return contact;
    }

    public static Contact createContact(String firstName, String lastName, String phone, String email) {
        Contact contact = new Contact(FirstName = firstName, LastName = lastName, Phone = phone, Email = email, RecordTypeId = DEFAULT_CONTACT_TYPE);

        insert contact;
        return contact;
    }

    public static List<Contact> createContacts(Integer count) {
        List<Contact> contacts = new List<Contact>(count);
        for (Integer i = 0; i < count; i++) {
            contacts[i] = new Contact(FirstName = 'test', LastName = 'contact' + i, Email = 'test_contact' + i + '@gmail.com');
        }

        insert contacts;
        return contacts;
    }    
    
    public static Deal__c createDeal(Contact salesman, Contact buyer, Property__c property) {
        Deal__c deal = new Deal__c(Salesman__c = salesman.Id, Buyer__c = buyer.Id, Property_for_sale__c = property.Id, Status__c = 'Open', RecordTypeId = DEFAULT_DEAL_TYPE);

        insert deal;
        return deal;
    }

    public static List<Deal__c> createDeals(Integer count, Contact salesman, Contact buyer, Property__c property) {
        List<Deal__c> deals = new List<Deal__c>(count);
        for (Integer i = 0; i < count; i++) {
            deals[i] = new Deal__c(Salesman__c = salesman.Id, Buyer__c = buyer.Id, Property_for_sale__c = property.Id, Status__c = 'Open', RecordTypeId = DEFAULT_DEAL_TYPE);
        }

        insert deals;
        return deals;
    }

    public static Property__c createProperty(Contact propertyOwner, Decimal sellingPrice, Decimal rentalPrice, String address) {
        Property__c p = new Property__c(Property_Owner__c = propertyOwner.Id, Selling_price__c = sellingPrice, Rental_price_per_month__c = rentalPrice, Address__c = address);

        insert p;
        return p;
    }

    public static List<Property__c> createProperties(Integer count, Contact propertyOwner) {
        List<Property__c> properties = new List<Property__c>(count);
        for (Integer i = 0; i < count; i++) {
            properties[i] = new Property__c(Property_Owner__c = propertyOwner.Id, Selling_price__c = count * i * (count + i), 
                                                Rental_price_per_month__c = count * i * (count - i + 1), Address__c = 'Super address # ' + i);
        }

        insert properties;
        return properties;
    }    

    public User CreateUser()
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];           
        User user = new User(LastName = 'TestUser', Alias = 'stestuser', Email ='testemail@testorg.com', Username ='TestUser@testorg.com',
                                EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', LocaleSidKey ='en_US', ProfileId = profile.Id,
                                TimeZoneSidKey = 'America/Los_Angeles');
         
        insert user;                        
        return user;
    }
    
    public User CreateUser(string userType)
    {
        Profile profile = [SELECT Id FROM Profile WHERE Name = :userType];
        User user = new User(LastName = 'TestUser', Alias = 'stestuser', Email ='testemail@testorg.com', Username ='TestUser@testorg.com',
                                EmailEncodingKey ='UTF-8', LanguageLocaleKey ='en_US', LocaleSidKey ='en_US', ProfileId = profile.Id,
                                TimeZoneSidKey = 'America/Los_Angeles');
        insert user; 
        return user;
    }
}
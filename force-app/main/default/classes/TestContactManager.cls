@isTest
public with sharing class TestContactManager {

    static final Id BROKER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Broker').getRecordTypeId();
    static final Id PROP_OWNER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Property Owner').getRecordTypeId();
    static final String FIELDS = 'Id, FirstName, LastName, Phone, Email, RecordTypeId';

    @testSetup 
    static void setup() 
    {          
        Contact cont1 = new Contact();
        cont1.FirstName = 'Test Contact';
        cont1.LastName = 'Broker 1';
        cont1.RecordTypeId = BROKER_TYPE;
        cont1.phone = '+375393837363';
        cont1.email = 'test_contact@setuped.brok';
        insert cont1;

        Contact cont2 = new Contact();
        cont2.FirstName = 'Test Contact';
        cont2.LastName = 'Owner 1';
        cont2.RecordTypeId = PROP_OWNER_TYPE;
        cont2.phone = '+375494847464';
        cont2.email = 'test_contact@setuped.prop';
        insert cont2;
    }

    @isTest static void testGetContactsByIds(){
        List<Id> contactsIds = new List<Id>();
        for (Contact con : [SELECT Id FROM Contact WHERE FirstName = 'Test Contact']) {
            contactsIds.add(con.Id);
        }
        List<Contact> resultList = ContactManager.getContactsByIds(contactsIds, FIELDS);
        System.assertEquals(contactsIds.size(), resultList.size());
    }

    @isTest static void testGetContactsByRecordTypes(){
        List<Contact> brokersContacts = [SELECT Id FROM Contact WHERE LastName = 'Broker 1'];
        List<String> recordTypesList = new List<String>();
        recordTypesList.add('Broker');

        List<Contact> resultList = ContactManager.getContactsByRecordTypes(recordTypesList, FIELDS);
        System.assertEquals(brokersContacts.size(), resultList.size());
    }

    @isTest static void testCreateContact(){
        ContactManager.ContactWrapper wrap = new ContactManager.ContactWrapper();
        wrap.firstName = 'Test Contact';
        wrap.lastName = 'Created';
        wrap.recordTypeId = PROP_OWNER_TYPE;
        wrap.phone = '+375292827262';
        wrap.email = 'test_contact@created.prop';

        Contact resultCon = ContactManager.createContact(wrap, true);
        Contact resultDBCon = [SELECT RecordTypeId FROM Contact WHERE LastName = 'Created'];
        System.assertEquals(PROP_OWNER_TYPE, resultCon.RecordTypeId);
        System.assertEquals(PROP_OWNER_TYPE, resultDBCon.RecordTypeId);
    }

    @isTest static void testUpdateContactById(){
        Contact conForUpdate = Database.query('SELECT ' + FIELDS + 
                                                ' FROM Contact WHERE FirstName = \'Test Contact\' LIMIT 1');
        ContactManager.ContactWrapper wrap = new ContactManager.ContactWrapper();
        wrap.id = conForUpdate.Id;
        wrap.firstName = conForUpdate.FirstName;
        wrap.lastName = 'Updated';
        wrap.recordTypeId = conForUpdate.RecordTypeId;

        Contact resultCon = ContactManager.updateContactById(wrap, true);
        Contact resultDBCon = [SELECT LastName FROM Contact WHERE Id = :conForUpdate.Id];
        System.assertEquals(wrap.lastName, resultCon.LastName);
        System.assertEquals(wrap.lastName, resultDBCon.LastName);
    }

    @isTest static void testDeleteContactsByEmails(){
        List<String> emailsList = new List<String>();
        emailsList.add('test_contact@setuped.prop');

        ContactManager.deleteContactsByEmails(emailsList);
        List<Contact> resultDBCon = [SELECT Id FROM Contact WHERE Email = 'test_contact@setuped.prop'];
        System.assertEquals(0, resultDBCon.size());
    }
}

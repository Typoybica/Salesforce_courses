@isTest
public with sharing class TestPropertyManager {

    static final Id PROP_OWNER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName()
                                                    .get('Property Owner').getRecordTypeId();
    
    static final String FIELDS = 'Id, Address__c, Property_Owner__c, Rental_price_per_month__c' +
                                    ', Selling_price__c, RecordTypeId';

    @testSetup 
    static void setup() 
    {       
        Contact owner1 = new Contact();
        owner1.FirstName = 'Test Contact';
        owner1.LastName = 'Owner 1';
        owner1.RecordTypeId = PROP_OWNER_TYPE;
        owner1.phone = '+375494847464';
        owner1.email = 'test_prop1@setuped.con';
        insert owner1;

        Contact owner2 = new Contact();
        owner2.FirstName = 'Test Contact';
        owner2.LastName = 'Owner 2';
        owner2.RecordTypeId = PROP_OWNER_TYPE;
        owner2.phone = '+375595857565';
        owner2.email = 'test_prop2@setuped.con';
        insert owner2;

        Property__c prop1 = new Property__c();
        prop1.Address__c = 'Prop address 1';
        prop1.Property_Owner__c = owner1.Id;
        prop1.Rental_price_per_month__c = 400;
        prop1.Selling_price__c = 5000;
        insert prop1;

        Property__c prop2 = new Property__c();
        prop2.Address__c = 'Prop address 2';
        prop2.Property_Owner__c = owner2.Id;
        prop2.Rental_price_per_month__c = 600;
        prop2.Selling_price__c = 10000;
        insert prop2;        
    }

    @isTest static void testGetPropertiesByIds(){
        List<Id> propertiesIds = new List<Id>();
        for (Property__c prop : [SELECT Id FROM Property__c]) {
            propertiesIds.add(prop.Id);
        }
        List<Property__c> resultList = PropertyManager.getPropertiesByIds(propertiesIds, FIELDS);
        System.assertEquals(propertiesIds.size(), resultList.size());
    }

    @isTest static void testGetPropertiesByAddresses(){
        List<Property__c> propertiesIds = [SELECT Id FROM Property__c WHERE Address__c = 'Prop address 1'];
        List<String> addressesList = new List<String>();
        addressesList.add('Prop address 1');

        List<Property__c> resultList = PropertyManager.getPropertiesByAddresses(addressesList, FIELDS);
        System.assertEquals(propertiesIds.size(), resultList.size());
    }

    @isTest static void testGetPropertiesByOwners(){
        List<Id> ownersIds = new List<Id>();
        for (Contact con : [SELECT Id FROM Contact WHERE LastName = 'Owner 2']) {
            ownersIds.add(con.Id);
        }
        List<Property__c> relatedDeals = PropertyManager.getPropertiesByOwners(ownersIds, FIELDS);
        System.assertEquals(ownersIds.get(0), relatedDeals.get(0).Property_Owner__c);
    }

    @isTest static void testCreateProperty(){
        List<Contact> owners = [SELECT Id FROM Contact WHERE RecordTypeId = :PROP_OWNER_TYPE];
        PropertyManager.PropertyWrapper wrap = new PropertyManager.PropertyWrapper();
        wrap.address = 'Kakoito address 1';
        wrap.propertyOwner = owners.get(0).Id;
        wrap.rentalPrice = 200;
        wrap.sellingPrice = 5000;

        Property__c resultProperty = PropertyManager.createProperty(wrap, true);
        Property__c resultDBProperty = [SELECT Property_Owner__c FROM Property__c WHERE Id = :resultProperty.Id];
        System.assertEquals(owners.get(0).Id, resultProperty.Property_Owner__c);
        System.assertEquals(owners.get(0).Id, resultDBProperty.Property_Owner__c);
    }

    @isTest static void testUpdatePropertyById(){
        Property__c propertyForUpdate = Database.query('SELECT ' + FIELDS + 
                                                ' FROM Property__c WHERE Rental_price_per_month__c = 400 LIMIT 1');
        PropertyManager.PropertyWrapper wrap = new PropertyManager.PropertyWrapper();
        wrap.id = propertyForUpdate.Id;
        wrap.address = 'Another address';
        wrap.propertyOwner = propertyForUpdate.Property_Owner__c;
        wrap.rentalPrice = propertyForUpdate.Rental_price_per_month__c;
        wrap.sellingPrice = propertyForUpdate.Selling_price__c;

        Property__c resultProperty = PropertyManager.updatePropertyById(wrap, true);
        Property__c resultDBProperty = [SELECT Address__c FROM Property__c WHERE Id = :resultProperty.Id];
        System.assertEquals('Another address', resultProperty.Address__c);
        System.assertEquals('Another address', resultDBProperty.Address__c);
    }

    @isTest static void testDeletePropertiesByAddresses(){
        List<String> addressesList = new List<String>();
        addressesList.add('Prop address 1');

        PropertyManager.deletePropertiesByAddresses(addressesList);
        List<Property__c> resultDBProperties = [SELECT Id FROM Property__c WHERE Address__c = 'Prop address 1'];
        System.assertEquals(0, resultDBProperties.size());
    }

    @isTest static void testDeletePropertiesByOwnersIds(){
        Contact owner = [SELECT Id FROM Contact WHERE LastName = 'Owner 2' LIMIT 1];
        List<Id> ownersIds = new List<Id>();
        ownersIds.add(owner.Id);

        PropertyManager.deletePropertiesByOwnersIds(ownersIds);
        List<Property__c> resultDBProperties = [SELECT Id FROM Property__c WHERE Property_Owner__c = :owner.Id];
        System.assertEquals(0, resultDBProperties.size());
    }
}

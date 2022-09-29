@isTest
public with sharing class TestDealManager {

    static final Id BROKER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName()
                                                        .get('Broker').getRecordTypeId();
    static final Id PROP_OWNER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName()
                                                        .get('Property Owner').getRecordTypeId();
    
    static final Id LEASE_TYPE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName()
                                                        .get('Lease').getRecordTypeId();
    static final Id SALE_TYPE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName()
                                                        .get('Sale').getRecordTypeId();

    static final String DEFAULT_STATUS = 'Open';

    static final String FIELDS = 'Id, Buyer__c, Property_for_sale__c, Salesman__c, Status__c' 
                                + ', RecordTypeId, Rental_start_date__c, Rental_end_date__c';
    
    @testSetup 
    static void setup() 
    {          
        Contact broker = new Contact();
        broker.FirstName = 'Test Contact';
        broker.LastName = 'Broker 1';
        broker.RecordTypeId = BROKER_TYPE;
        broker.phone = '+375393837363';
        broker.email = 'test_broker1@setuped.con';
        insert broker;

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

        Deal__c lease1 = new Deal__c();
        lease1.Buyer__c = owner2.Id;
        lease1.Property_for_sale__c = prop1.Id;
        lease1.Salesman__c = owner1.Id;
        lease1.Status__c = DEFAULT_STATUS;
        lease1.RecordTypeId = LEASE_TYPE;
        lease1.Rental_start_date__c = Date.newInstance(2022, 7, 20);
        lease1.Rental_end_date__c = Date.newInstance(2022, 9, 20);
        insert lease1;

        Deal__c sale1 = new Deal__c();
        sale1.Buyer__c = owner1.Id;
        sale1.Property_for_sale__c = prop2.Id;
        sale1.Salesman__c = owner2.Id;
        sale1.Status__c = DEFAULT_STATUS;
        sale1.RecordTypeId = SALE_TYPE;
        insert sale1;

        Deal__c sale2 = new Deal__c();
        sale2.Buyer__c = owner1.Id;
        sale2.Property_for_sale__c = prop2.Id;
        sale2.Salesman__c = owner2.Id;
        sale2.Status__c = 'Closed';
        sale2.RecordTypeId = SALE_TYPE;
        insert sale2;
    }

    @isTest static void testGetDealsByIds(){
        List<Id> dealsIds = new List<Id>();
        for (Deal__c deal : [SELECT Id FROM Deal__c]) {
            dealsIds.add(deal.Id);
        }
        List<Deal__c> resultList = DealManager.getDealsByIds(dealsIds, FIELDS);
        System.assertEquals(dealsIds.size(), resultList.size());
    }

    @isTest static void testGetDealsBySalesmans(){
        List<Id> ownersIds = new List<Id>();
        for (Contact con : [SELECT Id FROM Contact WHERE LastName = 'Owner 2']) {
            ownersIds.add(con.Id);
        }
        List<Deal__c> relatedDeals = DealManager.getDealsBySalesmans(ownersIds, FIELDS);
        System.assertEquals(SALE_TYPE, relatedDeals.get(0).RecordTypeId);
    }

    @isTest static void testGetDealsByBuyers(){
        List<Id> ownersIds = new List<Id>();
        for (Contact con : [SELECT Id FROM Contact WHERE LastName = 'Owner 2']) {
            ownersIds.add(con.Id);
        }
        List<Deal__c> relatedDeals = DealManager.getDealsByBuyers(ownersIds, FIELDS);
        System.assertEquals(LEASE_TYPE, relatedDeals.get(0).RecordTypeId);
    }

    @isTest static void testGetDealsByStatuses(){
        List<Deal__c> dealsIds = [SELECT Id FROM Deal__c WHERE Status__c = :DEFAULT_STATUS];
        List<String> statusesList = new List<String>();
        statusesList.add(DEFAULT_STATUS);

        List<Deal__c> resultList = DealManager.getDealsByStatuses(statusesList, FIELDS);
        System.assertEquals(dealsIds.size(), resultList.size());
    }

    @isTest static void testCreateDeal(){
        List<Contact> owners = [SELECT Id FROM Contact WHERE RecordTypeId = :PROP_OWNER_TYPE];
        List<Property__c> props = [SELECT Id FROM Property__c];
        DealManager.DealWrapper wrap = new DealManager.DealWrapper();
        wrap.buyer = owners.get(1).Id;
        wrap.propertyForSale = props.get(0).Id;
        wrap.salesman = owners.get(0).Id;
        wrap.status = DEFAULT_STATUS;
        wrap.recordTypeId = LEASE_TYPE;
        wrap.leaseStartDate = Date.newInstance(2022, 5, 10);
        wrap.leaseEndDate = Date.newInstance(2022, 7, 20);

        Deal__c resultDeal = DealManager.createDeal(wrap, true);
        Deal__c resultDBDeal = [SELECT RecordTypeId FROM Deal__c WHERE Id = :resultDeal.Id];
        System.assertEquals(LEASE_TYPE, resultDeal.RecordTypeId);
        System.assertEquals(LEASE_TYPE, resultDBDeal.RecordTypeId);
    }

    @isTest static void testUpdateDealsById(){
        Deal__c dealForUpdate = Database.query('SELECT ' + FIELDS + 
                                                ' FROM Deal__c WHERE RecordTypeId = :SALE_TYPE LIMIT 1');
        DealManager.DealWrapper wrap = new DealManager.DealWrapper();
        wrap.id = dealForUpdate.Id;
        wrap.buyer = dealForUpdate.Buyer__c;
        wrap.propertyForSale = dealForUpdate.Property_for_sale__c;
        wrap.salesman = dealForUpdate.Salesman__c;
        wrap.status = dealForUpdate.Status__c;
        wrap.recordTypeId = LEASE_TYPE;
        wrap.leaseStartDate = Date.newInstance(2022, 5, 10);
        wrap.leaseEndDate = Date.newInstance(2022, 7, 20);

        Deal__c resultDeal = DealManager.updateDealsById(wrap, true);
        Deal__c resultDBDeal = [SELECT RecordTypeId FROM Deal__c WHERE Id = :resultDeal.Id];
        System.assertEquals(LEASE_TYPE, resultDeal.RecordTypeId);
        System.assertEquals(LEASE_TYPE, resultDBDeal.RecordTypeId);
    }

    @isTest static void testDeleteDealsByStatuses(){
        List<String> statusesList = new List<String>();
        statusesList.add('Closed');

        DealManager.deleteDealsByStatuses(statusesList);
        List<Deal__c> resultDBDeal = [SELECT Id FROM Deal__c WHERE Status__c = 'Closed'];
        System.assertEquals(0, resultDBDeal.size());
    }
}

@isTest
public with sharing class TestBrokerDealPercentageManager {
    
    static final Id BROKER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName()
                                                        .get('Broker').getRecordTypeId();
    static final Id PROP_OWNER_TYPE = Schema.SObjectType.Contact.getRecordTypeInfosByName()
                                                        .get('Property Owner').getRecordTypeId();
    
    static final Id LEASE_TYPE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName()
                                                        .get('Lease').getRecordTypeId();
    static final Id SALE_TYPE = Schema.SObjectType.Deal__c.getRecordTypeInfosByName()
                                                        .get('Sale').getRecordTypeId();

    static final String DEFAULT_STATUS = 'Open';

    static final String FIELDS = 'Id, Deal__c, Broker_percent__c, Broker__c';

    @testSetup 
    static void setup() 
    {          
        Contact broker1 = new Contact();
        broker1.FirstName = 'Test Contact';
        broker1.LastName = 'Broker 1';
        broker1.RecordTypeId = BROKER_TYPE;
        broker1.phone = '+375393837363';
        broker1.email = 'test_broker1@setuped.con';
        insert broker1;

        Contact broker2 = new Contact();
        broker2.FirstName = 'Test Contact';
        broker2.LastName = 'Broker 2';
        broker2.RecordTypeId = BROKER_TYPE;
        broker2.phone = '+375494847464';
        broker2.email = 'test_broker2@setuped.con';
        insert broker2;

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

        Broker_Deal_Percentage__c bdPercent1 = new Broker_Deal_Percentage__c();
        bdPercent1.Broker__c = broker1.Id;
        bdPercent1.Deal__c = lease1.Id;
        bdPercent1.Broker_percent__c = 5;
        insert bdPercent1;

        Broker_Deal_Percentage__c bdPercent2 = new Broker_Deal_Percentage__c();
        bdPercent2.Broker__c = broker2.Id;
        bdPercent2.Deal__c = sale1.Id;
        bdPercent2.Broker_percent__c = 10;
        insert bdPercent2;
    }

    @isTest static void testGetBrokerDealPercentageByIds(){
        List<Id> bdPercentsIds = new List<Id>();
        for (Broker_Deal_Percentage__c bdPercent : [SELECT Id FROM Broker_Deal_Percentage__c]) {
            bdPercentsIds.add(bdPercent.Id);
        }
        List<Broker_Deal_Percentage__c> resultList = BrokerDealPercentageManager.getBrokerDealPercentageByIds(bdPercentsIds, FIELDS);
        System.assertEquals(bdPercentsIds.size(), resultList.size());
    }

    @isTest static void testGetBrokerDealPercentageByBrokers(){
        List<Id> brokersIds = new List<Id>();
        for (Contact con : [SELECT Id FROM Contact WHERE LastName = 'Broker 2']) {
            brokersIds.add(con.Id);
        }
        List<Broker_Deal_Percentage__c> relatedDeals = BrokerDealPercentageManager.getBrokerDealPercentageByBrokers(brokersIds, FIELDS);
        System.assertEquals(10, relatedDeals.get(0).Broker_percent__c);
    }

    @isTest static void testGetBrokerDealPercentageByDeals(){
        List<Id> dealsIds = new List<Id>();
        for (Deal__c con : [SELECT Id FROM Deal__c WHERE RecordTypeId = :SALE_TYPE]) {
            dealsIds.add(con.Id);
        }
        List<Broker_Deal_Percentage__c> relatedBrDPerc = BrokerDealPercentageManager.getBrokerDealPercentageByDeals(dealsIds, FIELDS);
        System.assertEquals(10, relatedBrDPerc.get(0).Broker_percent__c);
    }
    
    @isTest static void testCreateBrokerDealPercent(){
        Contact broker = [SELECT Id FROM Contact WHERE RecordTypeId = :BROKER_TYPE LIMIT 1];
        Deal__c deal = [SELECT Id FROM Deal__c LIMIT 1];
        BrokerDealPercentageManager.BrokerDealPercentageWrapper wrap = new BrokerDealPercentageManager.BrokerDealPercentageWrapper();
        wrap.dealId = deal.Id;
        wrap.brokerDealPercent = 20;
        wrap.brokerId = broker.Id;

        Broker_Deal_Percentage__c resultBrDPerc = BrokerDealPercentageManager.createBrokerDealPercent(wrap, true);
        Broker_Deal_Percentage__c resultDBBrDPerc = [SELECT Broker_percent__c FROM Broker_Deal_Percentage__c WHERE Id = :resultBrDPerc.Id];
        System.assertEquals(20, resultBrDPerc.Broker_percent__c);
        System.assertEquals(20, resultDBBrDPerc.Broker_percent__c);
    }

    @isTest static void testUpdateBrokerDealPercentageById(){
        Broker_Deal_Percentage__c bdPercForUpdate = Database.query('SELECT ' + FIELDS + 
                                                ' FROM Broker_Deal_Percentage__c WHERE Broker_percent__c = 5 LIMIT 1');
        BrokerDealPercentageManager.BrokerDealPercentageWrapper wrap = new BrokerDealPercentageManager.BrokerDealPercentageWrapper();
        wrap.id = bdPercForUpdate.Id;
        wrap.brokerDealPercent = 20;

        Broker_Deal_Percentage__c resultBrDPerc = BrokerDealPercentageManager.updateBrokerDealPercentageById(wrap, true);
        Broker_Deal_Percentage__c resultDBBrDPerc = [SELECT Broker_percent__c FROM Broker_Deal_Percentage__c WHERE Id = :resultBrDPerc.Id];
        System.assertEquals(20, resultBrDPerc.Broker_percent__c);
        System.assertEquals(20, resultDBBrDPerc.Broker_percent__c);
    }

    @isTest static void testDeleteBrokerDealPercentageByBrokers(){
        Contact broker = [SELECT Id FROM Contact WHERE LastName = 'Broker 2' LIMIT 1];
        List<Id> brokersIds = new List<Id>();
        brokersIds.add(broker.Id);

        BrokerDealPercentageManager.deleteBrokerDealPercentageByBrokers(brokersIds);
        List<Broker_Deal_Percentage__c> resultDBProperties = [SELECT Id FROM Broker_Deal_Percentage__c WHERE Broker__c = :broker.Id];
        System.assertEquals(0, resultDBProperties.size());
    }
}

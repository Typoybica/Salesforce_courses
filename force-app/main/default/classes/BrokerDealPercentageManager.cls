public inherited sharing class BrokerDealPercentageManager {

    public class BrokerDealPercentageWrapper {
        public Id id {get; set;}
        public Id brokerId {get; set;}
        public Id dealId {get; set;}
        public Decimal brokerDealPercent {get; set;}
    }
    
    public static List<Broker_Deal_Percentage__c> getBrokerDealPercentageByIds(List<Id> ids, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Broker_Deal_Percentage__c WHERE Id IN :ids');
    }
    
    public static List<Broker_Deal_Percentage__c> getBrokerDealPercentageByBrokers(List<Id> brokers, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Broker_Deal_Percentage__c WHERE Broker__c IN :brokers');
    }
    
    public static List<Broker_Deal_Percentage__c> getBrokerDealPercentageByDeals(List<Id> deals, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Broker_Deal_Percentage__c WHERE Deal__c IN :deals');
    }

    public static Broker_Deal_Percentage__c createBrokerDealPercent(BrokerDealPercentageWrapper wrapper, Boolean serialize) {
        Broker_Deal_Percentage__c brokerDealPercent = new Broker_Deal_Percentage__c();
        brokerDealPercent.Deal__c = wrapper.dealId;
        brokerDealPercent.Broker_percent__c = wrapper.brokerDealPercent;
        brokerDealPercent.Broker__c = wrapper.brokerId;

        if (serialize) insert brokerDealPercent;

        return brokerDealPercent;
    }

    public static Broker_Deal_Percentage__c updateBrokerDealPercentageById(BrokerDealPercentageWrapper wrapper, Boolean serialize) {
        Broker_Deal_Percentage__c brokerDealPercentage = [SELECT Broker__c, Deal__c, Broker_percent__c FROM Broker_Deal_Percentage__c WHERE Id = :wrapper.id];
        brokerDealPercentage.Broker__c = wrapper.brokerId;
        brokerDealPercentage.Deal__c = wrapper.dealId;
        brokerDealPercentage.Broker_percent__c = wrapper.brokerDealPercent;

        if (serialize) update brokerDealPercentage;

        return brokerDealPercentage;
    }

    public static void deleteBrokerDealPercentageByBrokers(List<Id> brokers) {
        delete [SELECT Id FROM Broker_Deal_Percentage__c WHERE Broker__c IN :brokers];
    }
}

public inherited sharing class LogManager {

    public static final String DEFAULT_TYPE = 'Undefined';
    
    public static List<Log__c> getLogsByIds(List<Id> ids, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Log__c WHERE Id IN :ids');
    }
    
    public static List<Log__c> getLogsByTypes(List<String> types, String fields) {
        return Database.query('SELECT ' + fields + ' FROM Log__c WHERE Type__c IN :types');
    }
    
    public static Log__c createLog(String type, String message, Boolean serialize) {
        Log__c log = new Log__c();
        log.Type__c = String.isBlank(type) ? DEFAULT_TYPE : type;
        log.Message__c = message;

        if (serialize) insert log;

        return log;
    }

    public static Log__c updateLogById(Id id, String type, String message, Boolean serialize) {
        Log__c logToUpdate = [SELECT Type__c, Message__c FROM Log__c WHERE Id = :id];
        
        logToUpdate.Type__c = type;
        logToUpdate.Message__c = message;
        
        if (serialize) update logToUpdate;

        return logToUpdate;
    }

    public static void deleteLogsByTypes(List<String> types) {
        delete [SELECT id FROM Log__c WHERE Type__c IN :types];
    }
}
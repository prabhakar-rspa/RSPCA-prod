public class WOAHenController {
    @AuraEnabled
    public static WOAHens__c getWOAHens(String recordId){
        // Get the Map of Schema of WOAHens__c SObject
        Map<String, Schema.SObjectField> fieldMap = WOAHens__c.sObjectType.getDescribe().fields.getMap();
                
        // Get all of the fields on the object
        Set<String> setFieldNames = fieldMap.keySet();
        list<String> lstFieldNames = new List<String>(setFieldNames);
                
        // Dynamic Query String.
        List<WOAHens__c> hensList = Database.query('SELECT ' + String.join(lstFieldNames, ',') + ' FROM WOAHens__c WHERE WOA__c =:recordId');

        WOAHens__c henWoa = new WOAHens__c(WOA__c = recordId);
        if(!hensList.isEmpty()){
            henWoa = hensList[0];
        }
        return henWoa;

    }

    @AuraEnabled
    public static void saveWOAHens(WOAHens__c woaHen){        
        if(woaHen != null){
            WOAHens__c woaHenRecord = woaHen;
            if(woaHenRecord.Id == null){
                insert woaHenRecord;
            }else{
                update woaHenRecord;
            }
        }
    }
}
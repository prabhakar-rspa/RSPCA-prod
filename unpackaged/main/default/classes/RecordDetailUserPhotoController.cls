public without sharing class RecordDetailUserPhotoController {

    @AuraEnabled
    public static User fetchUserDetail(Id recordId, String userLookUpFieldName){
        User u;
        Schema.SObjectType sobjectType = recordId.getSObjectType();
        String sobjectName = sobjectType.getDescribe().getName();
        SObject record = Database.query('SELECT Id, ' + userLookUpFieldName + ' FROM ' + sobjectName + ' WHERE Id = :recordId');
        if(record != null){
            String userId = (String)record.get(userLookUpFieldName);
            if(userId != null){
                u = [SELECT Id, Name, SmallPhotoUrl, FullPhotoUrl, Email, MobilePhone FROM User WHERE Id = :userId];
            }
        }
        return u;
    }
}
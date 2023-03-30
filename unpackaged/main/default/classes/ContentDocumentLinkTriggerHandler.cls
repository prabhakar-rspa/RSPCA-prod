public with sharing class ContentDocumentLinkTriggerHandler {
    public static void onAfterInsert(list<ContentDocumentLink> lstCntLinks) {
        String strObjPrefix;
        Set<Id> setCntDocIds = new set<Id>();
        set<Id> setChecklistQuestionIds = new set<Id>();
        map<Id, Checklist_Template_Standard__c> mapChecklistQuestion;
        
        for(ContentDocumentLink clIterator : lstCntLinks) {
            strObjPrefix = String.valueOf(clIterator.LinkedEntityId).substring(0, 3);
            if(strObjPrefix == Checklist_Template_Standard__c.sObjectType.getDescribe().getKeyPrefix()) {
                setCntDocIds.add(clIterator.ContentDocumentId);
                setChecklistQuestionIds.add(clIterator.LinkedEntityId);
            }
        }
        
        if(!setCntDocIds.isEmpty()) {
            if(!setChecklistQuestionIds.isEmpty()) {
                mapChecklistQuestion = new map<Id, Checklist_Template_Standard__c>([SELECT Id, ContentVersion_URL__c FROM Checklist_Template_Standard__c WHERE Id IN :setChecklistQuestionIds]);
            }
        }
        
        // Get content document object for current set of files
        //Map<Id, ContentDocument> mapContentDocuments = new Map<Id, ContentDocument>([SELECT Id, Title, FileExtension FROM ContentDocument WHERE Id IN :setCntDocIds]);
        
        System.debug('mapChecklistQuestion => ' + mapChecklistQuestion);

        // Get the content version for the content documents
        Map<Id, ContentVersion> mapContentVersion = new Map<Id, ContentVersion>();
        for(ContentVersion cv : [SELECT Id, ContentDocumentId, FileType, IsLatest, VersionData FROM ContentVersion WHERE ContentDocumentId IN:setCntDocIds AND IsLatest = true]){
            mapContentVersion.put(cv.ContentDocumentId, cv);
        }

        System.debug('mapContentVersion => ' + mapContentVersion);
        List<Checklist_Template_Standard__c> checklistQuestions = new List<Checklist_Template_Standard__c>();
        
        Decimal apiVersion = 52.0;
        for(ContentDocumentLink cdlIterator : lstCntLinks) {
            if(mapContentVersion.containsKey(cdlIterator.ContentDocumentId)){
                ContentVersion conVer = mapContentVersion.get(cdlIterator.ContentDocumentId);
                System.debug('conVer => ' + conVer);
                List<String> allowedFileTypes = new List<String>{'PNG', 'JPG', 'JPEG'};
                if(allowedFileTypes.contains(conVer.FileType)){
                    System.debug('conVer.FileType => ' + conVer.FileType);
                    if(mapChecklistQuestion.containsKey(cdlIterator.LinkedEntityId)){
                        Checklist_Template_Standard__c chQ = mapChecklistQuestion.get(cdlIterator.LinkedEntityId);
                        System.debug('chQ => ' + chQ);
                        String versionDataURL = '/services/data/v'+ apiVersion + '/sobjects/ContentVersion/' + conVer.Id +'/VersionData' ;
                        chQ.ContentVersion_URL__c = versionDataURL;
                        checklistQuestions.add(chQ);
                    }
                }else{
                    System.debug('File type not valid for image.');
                }
            }
            
            
           
        }
        if(!checklistQuestions.isEmpty()) {
            update checklistQuestions;
        }
        
    }
}
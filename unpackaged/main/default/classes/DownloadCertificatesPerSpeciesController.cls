public with sharing class DownloadCertificatesPerSpeciesController {
    // current record of from the current page
    public Account currentRecord{get;set;}
   
    // Certificate URL's with currentRecord.Id passed to it
    public String supplyChainCertificateURL{get;set;}
    public String troutCertificateURL{get;set;}
    public String sciCertificate{get;set;}
    public List<Unit__c> supplyChainCertificateList{get;set;}
    public List<Unit__c> troutCertificateList{get;set;}
    public List<Unit__c> sciCertificateList{get;set;}

    // Checking whether the account has the relevant units for certificates
    public Boolean hasSupplyChainCertificate{get;set;}
    public Boolean hasTroutCertificate{get;set;}
    public Boolean hasSCICertificate{get;set;}
    public Boolean hideSpinner{get;set;}
	public String imageURL{get;set;}
     public String pdfName{get;set;}

    public DownloadCertificatesPerSpeciesController(ApexPages.StandardController controller) {
       Set<String> businessToHandleAnimalsList = new Set<String>{
           'Hatchery',
           'Haulier',
           'Abattoir',
           'Catching'
       };

        hideSpinner = false;
        currentRecord = [SELECT Id, Name, Membership_Number__c FROM Account WHERE Id = :controller.getRecord().Id];
        supplyChainCertificateList = new List<Unit__c>();
        sciCertificateList = new List<Unit__c>();
        troutCertificateList = new List<Unit__c>();
        // Generating the URL's for the certificates
        supplyChainCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SupplyChainCertificateSpecies'+'?id='+currentRecord.Id+'&' ;
        troutCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/TroutCertificate'+'?id='+currentRecord.Id +'&';
        sciCertificate = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SCICertificateSpecies'+'?id='+currentRecord.Id +'&';


        // Checking if member has Supply Chain certificate
        Map<String,Unit__c> unitsMap = new Map<String,Unit__c>();
        List<Unit__c> supplyChainList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c,Description__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c = 'Supply Chain'];
        if(supplyChainList.size() > 0){
           for(Unit__c unit:supplyChainList){
               if(!unitsMap.containsKey(unit.Animals__c)){
                   unitsMap.put(unit.Animals__c,unit);
               }
           }
            hasSupplyChainCertificate = true;
            supplyChainCertificateList = unitsMap.values();
        }else{
            hasSupplyChainCertificate = false;
        }


        // Checking if member has trout certificate
        Set<String> businessSetTrout = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer'
        };
        unitsMap = new Map<String,Unit__c>();
        List<Unit__c> troutList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c,Description__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSetTrout AND Animals__c = 'Trout'];
        if(troutList.size() > 0){
            hasTroutCertificate = true;
            for(Unit__c unit:troutList){
               if(!unitsMap.containsKey(unit.Animals__c)){
                   unitsMap.put(unit.Animals__c,unit);
               }
           }
            troutCertificateList = unitsMap.values();
        }else{
            hasTroutCertificate = false;
        }

        // Checking if member has NSF UKAS certificate
        Set<String> businessSetNSFUKAS = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer',
            'Cleaner Fish',
            'Catching'
        };
        unitsMap = new Map<String,Unit__c>();
        //List<Unit__c> sciList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSetNSFUKAS AND Animals__c != 'Trout'];
        List<Unit__c> sciList = [SELECT Id, Name,Animals_List__c, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c,Description__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSetNSFUKAS];
        if(sciList.size() > 0){
            hasSCICertificate = true;
            for(Unit__c unit:sciList){
               if(businessToHandleAnimalsList.contains(unit.Business__c)){
                   if(unit.Animals_List__c != null){
                       List<String> animals = unit.Animals_List__c.split(';');
                       for(String animal:animals){
                           if(!unitsMap.containsKey(animal)){
                               
                               unitsMap.put(animal,new Unit__c(Animals__c = animal));
                           }
                       }
                   }
               }else{
                   if(!unitsMap.containsKey(unit.Animals__c)){
                       unitsMap.put(unit.Animals__c,unit);
                   }
               }
           }
           system.debug('unitsMap::::'+unitsMap);
            sciCertificateList = unitsMap.values();
        }else{
            hasSCICertificate = false;
        }
        hideSpinner = true;
    }
    public PageReference attachPDF(){
        if(imageURL != null){
         	PageReference reportPage = new PageReference(imageURL);
            Blob reportPdf;
            try {
                reportPdf = reportPage.getContentAsPDF();
            }
            catch (Exception e) {
                reportPdf = Blob.valueOf(e.getMessage());
            }
            
            ContentVersion cv = new ContentVersion();
            cv.VersionData = reportPdf;
            cv.Title = pdfName;
            cv.PathOnClient = pdfName;
            cv.Description = pdfName;
            cv.isMajorVersion = true;
            insert cv;
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id =: cv.Id].ContentDocumentId;
            cdl.LinkedEntityId = currentRecord.Id;
            cdl.ShareType = 'V';
            insert cdl;   
        }
        return null;
    }
 
}
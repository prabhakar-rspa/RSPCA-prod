public with sharing class DownloadCertificatesController {
    
    // current record of from the current page
    public Account currentRecord{get;set;}
    
    // Certificate URL's with currentRecord.Id passed to it
    public String supplyChainCertificateURL{get;set;}
    public String troutCertificateURL{get;set;}
    public String sciCertificate{get;set;}

    // Checking whether the account has the relevant units for certificates
    public Boolean hasSupplyChainCertificate{get;set;}
    public Boolean hasTroutCertificate{get;set;}
    public Boolean hasSCICertificate{get;set;}




    public DownloadCertificatesController(ApexPages.StandardController controller) {
        currentRecord = [SELECT Id, Name, Membership_Number__c FROM Account WHERE Id = :controller.getRecord().Id];

        // Generating the URL's for the certificates
        supplyChainCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SupplyChainCertificate'+'?id='+currentRecord.Id ;
        troutCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/TroutCertificate'+'?id='+currentRecord.Id ;
        sciCertificate = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SCICertificate'+'?id='+currentRecord.Id ;


        // Checking if member has Supply Chain certificate
        List<Unit__c> supplyChainList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c = 'Supply Chain'];
        if(supplyChainList.size() > 0){
            hasSupplyChainCertificate = true;
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
        List<Unit__c> troutList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSetTrout AND Animals__c = 'Trout'];
        if(troutList.size() > 0){
            hasTroutCertificate = true;
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

        //List<Unit__c> sciList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSetNSFUKAS AND Animals__c != 'Trout'];
        List<Unit__c> sciList = [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c =:currentRecord.Id AND Status__c = 'Certified' AND Business__c IN:businessSetNSFUKAS];
        if(sciList.size() > 0){
            hasSCICertificate = true;
        }else{
            hasSCICertificate = false;
        }
    }
    
}
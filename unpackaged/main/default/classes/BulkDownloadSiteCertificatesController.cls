public with sharing class BulkDownloadSiteCertificatesController {
    public Account currentRecord{get;set;}
    public List<SiteCertificate> siteCertificateList{get;set;}
    public Boolean hasSiteCertificates{get;set;}
    public Boolean showSpinner{get;set;}
    public String imageURL{get;set;}
     public String pdfName{get;set;}
    public BulkDownloadSiteCertificatesController(ApexPages.StandardController controller) {
        showSpinner = true;
        currentRecord = [SELECT Id, Name, Membership_Number__c FROM Account WHERE Id = :controller.getRecord().Id];

        List<Account> sites = [SELECT Id, Name, Membership_Number__c FROM Account WHERE ParentId = :currentRecord.Id];
        Map<Id,Map<String,Unit>> supplyChainMap = new Map<Id,Map<String,Unit>>();
        for(Unit__c u : [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c IN :sites AND Status__c = 'Certified' AND Business__c = 'Supply Chain']){
            Unit unitIns = new Unit();
            unitIns.species = u.Animals__c;
            unitIns.accountId = u.Account__c;
            unitIns.supplyChainCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SupplyChainCertificateSpecies'+'?id='+u.Account__c+'&species=' ;
            if(supplyChainMap.containsKey(u.Account__c)){
                Map<String,Unit> unitmap = supplyChainMap.get(u.Account__c);
                unitmap.put(u.Animals__c,unitIns);
                supplyChainMap.put(u.Account__c, unitmap);
            }else{
                supplyChainMap.put(u.Account__c, new Map<String,Unit> {u.Animals__c=>unitIns});
            }
        }

        // Map list of trout units to site ids
        /*Map<Id,List<Unit__C>> troutMap = new Map<Id,List<Unit__C>>();
        Set<String> businessSetTrout = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer'
        };
        for(Unit__c u : [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c IN :siteids AND Status__c = 'Certified' AND Business__c IN:businessSetTrout AND Animals__c = 'Trout']){
            if(troutMap.containsKey(u.Account__c)){
                List<Unit__c> unitList = troutMap.get(u.Account__c);
                unitlist.add(u);
                troutMap.put(u.Account__c, unitList);
            }else{
                troutMap.put(u.Account__c, new List<Unit__c> {u});
            }
        }*/

        // Map list of nsf ukas units to site ids
        Map<Id,Map<String,Unit>> nsfUKASMap = new Map<Id,Map<String,Unit>>();
        Set<String> businessSetNSFUKAS = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer',
            'Cleaner Fish',
            'Catching'
        };
        for(Unit__c u : [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c IN :sites AND Status__c = 'Certified' AND Business__c IN:businessSetNSFUKAS]){
            Unit unitIns = new Unit();
            unitIns.species = u.Animals__c;
            unitIns.accountId = u.Account__c;
            unitIns.nsfUkasCertificateUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SCICertificateSpecies'+'?id='+u.Account__c+'&species='+u.Animals__c ;

            if(nsfUKASMap.containsKey(u.Account__c)){
                Map<String,Unit> unitmap = nsfUKASMap.get(u.Account__c);
                unitmap.put(u.Animals__c,unitIns);
                nsfUKASMap.put(u.Account__c, unitmap);
            }else{
                nsfUKASMap.put(u.Account__c, new Map<String,Unit> {u.Animals__c=>unitIns});
            }
        }

        siteCertificateList = new List<SiteCertificate>();
        for(Account a : sites){
            SiteCertificate sc = new SiteCertificate();
            sc.siteRecordId = a.Id;
            sc.siteName = a.Name;
            sc.membershipNumber = a.Membership_Number__c;
            sc.supplyChainCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SupplyChainCertificate'+'?id='+a.Id;
            sc.troutCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/TroutCertificate'+'?id='+a.Id;
            sc.nsfUkasCertificate = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SCICertificate_V2'+'?id='+a.Id;
            sc.hasSupplyChainCertificate = false; // false by default
            sc.hasTroutCertificate = false; // false by default
            sc.hasNSFUKASCertificate = false; // false by default
            
            Map<String,Unit> unitCertificateMap = new Map<String,Unit>();

            if(supplyChainMap.containsKey(a.Id)){
                List<Unit> supplyChainList = supplyChainMap.get(a.Id).values();
                if(supplyChainList != null && supplyChainList.size() > 0){
                    sc.hasSupplyChainCertificate = true;
                    for(Unit u:supplyChainList){
                        u.hasSupplyChainCertificate = true;
                        u.hasNSFUKASCertificate = false;
                        u.species = 'Supply Chain';
                        unitCertificateMap.put(u.species,u);
                    }
                }
                
            }
            
            if(nsfUKASMap.containsKey(a.Id)){
                List<Unit> nsfUKASList = nsfUKASMap.get(a.Id).values();
                if(nsfUKASList != null && nsfUKASList.size() > 0){
                    sc.hasNSFUKASCertificate = true;
                    for(Unit u:nsfUKASList){
                        if(unitCertificateMap.containsKey(u.species)){
                            Unit unitIns = unitCertificateMap.get(u.species);
                            unitIns.hasSupplyChainCertificate = false;
                            unitIns.nsfUkasCertificateUrl = u.nsfUkasCertificateUrl;
                            unitCertificateMap.put(u.species,unitIns);
                        }else{
                            u.hasNSFUKASCertificate = true;
                            unitCertificateMap.put(u.species,u);
                        }
                    }
                }
            }
            if(unitCertificateMap != null && unitCertificateMap.size()>0){
                sc.hasUnitCertificates = true;
                sc.unitCertificates = unitCertificateMap.values();
            }else{
                sc.hasUnitCertificates = false;
                sc.unitCertificates = New List<Unit>();
            }
            
            siteCertificateList.add(sc);
            
        }

        if(siteCertificateList.size() > 0){
            hasSiteCertificates = true;
        }else{
            hasSiteCertificates = false;
        }
        showSpinner = false;
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
    public class SiteCertificate{
        public String siteRecordId{get;set;} // Site Id
        public String siteName{get;set;} 
        public String membershipNumber{get;set;} 
        public String supplyChainCertificateURL{get;set;} 
        public String troutCertificateURL{get;set;} 
        public String nsfUkasCertificate{get;set;} 
        public Boolean hasSupplyChainCertificate{get;set;} 
        public Boolean hasTroutCertificate{get;set;} 
        public Boolean hasNSFUKASCertificate{get;set;} 
        public Boolean hasUnitCertificates{get;set;}
        public List<Unit> unitCertificates{get;set;}
    }
    public class Unit{
        public String species{get;set;}
        public String accountId{get;set;}
        public Unit__c unit{get;set;}
        public String supplyChainCertificateURL{get;set;}
        public String nsfUkasCertificateUrl{get;set;}
        public Boolean hasSupplyChainCertificate{get;set;} 
        public Boolean hasNSFUKASCertificate{get;set;} 
    }
}
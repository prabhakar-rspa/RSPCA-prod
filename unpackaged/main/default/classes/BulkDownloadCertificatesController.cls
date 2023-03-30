public class BulkDownloadCertificatesController {
    // current record of from the current page
    public Account currentRecord{get;set;}

    // List of site certificate records
    public List<SiteCertificate> siteCertificateList{get;set;}

    // Indicates if there are any site certificate records
    public Boolean hasSiteCertificates{get;set;}

    public BulkDownloadCertificatesController(ApexPages.StandardController controller) {
        // Head office record
        currentRecord = [SELECT Id, Name, Membership_Number__c FROM Account WHERE Id = :controller.getRecord().Id];

        // Sites for the head office
        List<Account> sites = [SELECT Id, Name, Membership_Number__c FROM Account WHERE ParentId = :currentRecord.Id];

        // Assign site ids to set
        Set<Id> siteids = new Set<Id>();
        for(Account a :sites){
            siteids.add(a.Id);
        }
        /*********************************************************************************************************************** */
        //Unit lists to site mapping

        // Map list of supply chain units to site ids
        Map<Id,List<Unit__C>> supplyChainMap = new Map<Id,List<Unit__C>>();
        for(Unit__c u : [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c IN :siteids AND Status__c = 'Certified' AND Business__c = 'Supply Chain']){
            if(supplyChainMap.containsKey(u.Account__c)){
                List<Unit__c> unitList = supplyChainMap.get(u.Account__c);
                unitlist.add(u);
                supplyChainMap.put(u.Account__c, unitList);
            }else{
                supplyChainMap.put(u.Account__c, new List<Unit__c> {u});
            }
        }

        // Map list of trout units to site ids
        Map<Id,List<Unit__C>> troutMap = new Map<Id,List<Unit__C>>();
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
        }

        // Map list of nsf ukas units to site ids
        Map<Id,List<Unit__C>> nsfUKASMap = new Map<Id,List<Unit__C>>();
        Set<String> businessSetNSFUKAS = new Set<String>{
            'Hatchery',
            'Haulier',
            'Abattoir',
            'Producer',
            'Cleaner Fish',
            'Catching'
        };
        for(Unit__c u : [SELECT Id, Name, Account__c, Business__c, Animals__c, Production__c, Rearing_System__c, Status__c FROM Unit__c WHERE Account__c IN :siteids AND Status__c = 'Certified' AND Business__c IN:businessSetNSFUKAS]){
            if(nsfUKASMap.containsKey(u.Account__c)){
                List<Unit__c> unitList = nsfUKASMap.get(u.Account__c);
                unitlist.add(u);
                nsfUKASMap.put(u.Account__c, unitList);
            }else{
                nsfUKASMap.put(u.Account__c, new List<Unit__c> {u});
            }
        }

        /*********************************************************************************************************************** */
        // iterate through the list of sites and create site certificate records
        siteCertificateList = new List<SiteCertificate>();
        for(Account a : sites){
            SiteCertificate sc = new SiteCertificate();
            sc.siteRecordId = a.Id;
            sc.siteName = a.Name;
            sc.membershipNumber = a.Membership_Number__c;
            sc.supplyChainCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SupplyChainCertificate'+'?id='+a.Id;
            sc.troutCertificateURL = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/TroutCertificate'+'?id='+a.Id;
            sc.nsfUkasCertificate = System.URL.getSalesforceBaseUrl().toExternalForm() + '/apex/SCICertificate'+'?id='+a.Id;
            sc.hasSupplyChainCertificate = false; // false by default
            sc.hasTroutCertificate = false; // false by default
            sc.hasNSFUKASCertificate = false; // false by default
            
            // Check if the site has these units in order to generate certificates
            if(supplyChainMap.containsKey(a.Id)){
                List<Unit__c> supplyChainList = supplyChainMap.get(a.Id);
                if(supplyChainList != null){
                    if(supplyChainList.size() > 0){
                        sc.hasSupplyChainCertificate = true;
                    }
                }
                
            }
            if(troutMap.containsKey(a.Id)){
                List<Unit__c> troutList = troutMap.get(a.Id);
                if(troutList != null){
                    if(troutList.size() > 0){
                        sc.hasTroutCertificate = true;
                    }
                }
            }
            if(nsfUKASMap.containsKey(a.Id)){
                List<Unit__c> nsfUKASList = nsfUKASMap.get(a.Id);
                if(nsfUKASList != null){
                    if(nsfUKASList.size() > 0){
                        sc.hasNSFUKASCertificate = true;
                    }
                }
            }
            siteCertificateList.add(sc);
            
        }

        if(siteCertificateList.size() > 0){
            hasSiteCertificates = true;
        }else{
            hasSiteCertificates = false;
        }

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
    }
}
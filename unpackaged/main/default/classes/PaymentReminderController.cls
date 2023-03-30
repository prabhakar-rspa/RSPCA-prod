public class PaymentReminderController {
    
    public Id accountId{get;set;}
    public Id bulkRenewalId{get;set;}
    public Id userId{get;set;}
    public Id applicationId{get;set;}
    public Date evidenceReminderDate{get;set;}

    /** Getting Head Office details **/
    public Account getHeadOffice(){
        Account HeadOffice = [SELECT Id, Name, Primary_Contact_Full_Name__c, Primary_Contact__c FROM Account WHERE Id =: accountId];
        return HeadOffice;
    }

    /** Getting Site Applications created 2 days ago for the Head Office **/
    public List<Application__c> getSiteApplications(){
        List<Application__c> SiteApplications = [SELECT Id, Name, Site_Name__c, Membership_Number__c FROM Application__c WHERE Head_Office__c =: accountId AND (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal') AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal') AND Paid__c = false AND CreatedDate = N_DAYS_AGO:2 AND Total_Amount_Inc_VAT__c > 0];
        return SiteApplications;
    }

    /** Getting Unpaid Site Applications created 4 days ago for the Head Office - Final Payment Reminder **/
    public List<Application__c> getFinalSiteApplications(){
        List<Application__c> FinalSiteApplications = [SELECT Id, Name, Site_Name__c, Membership_Number__c FROM Application__c WHERE Head_Office__c =: accountId AND (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal') AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal') AND Paid__c = false AND CreatedDate = N_DAYS_AGO:4 AND Total_Amount_Inc_VAT__c > 0];
        return FinalSiteApplications;
    }

    /** Getting Site Certificates for the Applications in Certificate stage **/
    public List<Application__c> getSiteCertificates(){
        List<Application__c> SiteCertificates = [SELECT Id, Name, Site_Name__c, Membership_Number__c FROM Application__c WHERE Head_Office__c =: accountId AND Certificate_Email_Sent__c = false AND (Stage__c = 'Certification' OR Renewal_Stage__c = 'Certification') AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal')];
        return SiteCertificates;
    }

    /** Getting  bulk renewal details **/
    public Bulk_Renewal__c getBulkRenewal(){
        Bulk_Renewal__c BulkRenewal = [SELECT Id, Name, Applicant_Full_Name__c, Invoice_Date__c, Payment_Reference__c, Payment_Due_Date__c,
                                       Total_Amount_Inc_VAT__c, Head_Office__r.Name, Head_Office__r.BillingStreet,
                                       Head_Office__r.BillingCity, Head_Office__r.BillingState, Head_Office__r.BillingCountry,
                                       Head_Office__r.BillingPostalCode, Sage_Invoice__r.Invoice_Number__c, PO_Number__c FROM Bulk_Renewal__c WHERE Id =: bulkRenewalId];
        return BulkRenewal;
    }

    /** Getting Renewal Applications linked with the Bulk Renewal record **/
    public List<Application__c> getRenewalApplications(){
        List<Application__c> RenewalApplications = [SELECT Id, Name, Site_Name__c, Membership_Number__c, Amount_Ex_VAT__c, 
                                                    VAT__c, Total_Amount_Inc_VAT__c FROM Application__c 
                                                    WHERE Bulk_Renewal__c =: bulkRenewalId];
        return RenewalApplications;
    }

    /** Getting Paid Applications for the Head Office - Confirming Payment **/
    public List<Application__c> getPymntCnfrmApplications(){
        List<Application__c> PymntCnfrmApplications = [SELECT Id, Name, Site_Name__c, Membership_Number__c, Date_of_Payment__c, Payment_Method__c, 
                                                       Amount_Ex_VAT__c, Total_Amount_Inc_VAT__c, VAT__c, Payment_Reference__c
                                                       FROM Application__c 
                                                       WHERE Head_Office__c =: accountId AND Paid__c = true 
                                                       AND (RecordType.Name = 'Applications' OR RecordType.Name = 'Renewal')];
        return PymntCnfrmApplications;
    }

    /** Getting Sites expiring in 6 weeks for the Head Office - 6 Week Renewal Reminder **/
    public List<Account> getRenewalReminderSites(){
        Date reminderDate = Date.today();
        x6WeekRenewalReminderTestDate__c testDateSetting = x6WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
            reminderDate = testDateSetting.Test_Date__c;
        }
        Set<String> siteIds = new Set<String>();
        List<Renewal_Price_Report__c> renewalSites = [SELECT Id, Site__c FROM Renewal_Price_Report__c 
                                                            WHERE Site__r.Renewal_Reminder_Ready__c = true 
                                                            AND Site__r.ParentId =:accountId 
                                                            AND Site__r.Status__c ='Member'];
        for(Renewal_Price_Report__c rpr : renewalSites){
            siteIds.add(rpr.Site__c);
        }

        List<Account> RenewalReminderSites = [SELECT Id, Name, Membership_Number__c FROM Account 
                                              WHERE Id IN:siteIds];
                                  
        return RenewalReminderSites;
    }

    /** Getting Sites expiring in 2 weeks for the Head Office - 2 Week Renewal Reminder **/
    public List<Account> getTwoWeekRenewalReminderSites(){
        Date reminderDate = Date.today();
        x2WeekRenewalReminderTestDate__c testDateSetting = x2WeekRenewalReminderTestDate__c.getOrgDefaults();
        if(testDateSetting.Use_Test_Date_Data__c == true && testDateSetting.Test_Date__c != null){
            reminderDate = testDateSetting.Test_Date__c;
        }
        Set<String> siteIds = new Set<String>();
        List<Renewal_Price_Report__c> renewalSites = [SELECT Id, Site__c FROM Renewal_Price_Report__c 
                                                            WHERE Site__r.Renewal_Reminder_Ready__c = true 
                                                            AND Site__r.ParentId =:accountId 
                                                            AND Site__r.Status__c ='Member'];
        for(Renewal_Price_Report__c rpr : renewalSites){
            siteIds.add(rpr.Site__c);
        }
        List<Account> TwoWeekRenewalReminderSites = [SELECT Id, Name, Membership_Number__c FROM Account 
                                                     WHERE Id IN:siteIds];
        return TwoWeekRenewalReminderSites;
    }

    /** Getting Sites expiring today for the Head Office - Renew Date Lapsed **/
    public List<Account> getRenewLapsedSites(){
        List<Account> RenewLapsedSites = [SELECT Id, Name, Membership_Number__c FROM Account 
                                          WHERE ParentId =: accountId AND 
                                          Membership_Expiry_Date__c = Today];
        return RenewLapsedSites;
    }

    /** Getting Applications expired 8 weeks ago for the Head Office - Membership Cancelled **/
    public List<Account> getMembershipCancelledSites(){
        List<Account> MembershipCancelledSites = [SELECT Id, Name, Membership_Number__c FROM Account 
                                                  WHERE ParentId =: accountId AND 
                                                  Membership_Expiry_Date__c = LAST_N_WEEKS:8];
        return MembershipCancelledSites;
    }

    /** Getting the Final Payment Reminder Image Url. **/
    public String getStrPymUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Final_Payment_Reminder_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String StrPymUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('StrPymUrl '+StrPymUrl);
        return StrPymUrl;
    }

    /** Getting the Payment Reminder Image Url. **/
    public String getStrPymRemUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Payment_Reminder_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String StrPymRemUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('StrPymRemUrl '+StrPymRemUrl);
        return StrPymRemUrl;
    }

    /** Getting the Your Certificates Image Url. **/
    public String getStrCertUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Your_Certificates_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String StrCertUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('StrCertUrl '+StrCertUrl);
        return StrCertUrl;
    }

    /** Getting the Invoice Image Url. **/
    public String getStrInvoiceUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Invoice_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String StrInvoiceUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('StrInvoiceUrl '+StrInvoiceUrl);
        return StrInvoiceUrl;
    }

    /** Getting the Community Invite Image Url. **/
    public String getCommunityInviteUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Comm_In_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String CommunityInviteUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('CommunityInviteUrl '+CommunityInviteUrl);
        return CommunityInviteUrl;
    }

    /** Getting the Assesment Complete Image Url. **/
    public String getAssessmentCompleteUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Assess_Con_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String AssessmentCompleteUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('AssessmentCompleteUrl '+AssessmentCompleteUrl);
        return AssessmentCompleteUrl;
    }

    /** Getting the Six week Renewal Reminder Image Url. **/
    public String getSixWeekUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Renewal_Invite_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String SixWeekUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('SixWeekUrl '+SixWeekUrl);
        return SixWeekUrl;
    }

    /** Getting the Two week Renewal Reminder Image Url. **/
    public String getTwoWeekUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_FRReminder_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String TwoWeekUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('TwoWeekUrl '+TwoWeekUrl);
        return TwoWeekUrl;
    }

    /** Getting the Renew Date Lapsed Image Url. **/
    public String getRenewLapsedUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Lapsed_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String RenewLapsedUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('RenewLapsedUrl '+RenewLapsedUrl);
        return RenewLapsedUrl;
    }

    /** Getting the Membership Cancelled Image Url. **/
    public String getMembershipCancelledUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Cancelled_Not_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String MembershipCancelledUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('MembershipCancelledUrl '+MembershipCancelledUrl);
        return MembershipCancelledUrl;
    }

    /** Getting the Payment Confirmed Image Url. **/
    public String getPymntCnfmUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Headers_Payment_Confirmation_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String PymntCnfmUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('PymntCnfmUrl '+PymntCnfmUrl);
        return PymntCnfmUrl;
    }

    /** Getting the Extension Granted Image Url. **/
    public String getExtensionGrantedUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'RSPCA_Assured_Email_Header_EG_png'];
        String strOrgId = UserInfo.getOrganizationId();
        String ExtensionGrantedUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('ExtensionGrantedUrl '+ExtensionGrantedUrl);
        return ExtensionGrantedUrl;
    }

    /** Getting the Evidence Reminder Image Url. **/
    public String getEvidenceReminderUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'EvidenceReminder'];
        String strOrgId = UserInfo.getOrganizationId();
        String EvidenceReminderUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('EvidenceReminderUrl '+EvidenceReminderUrl);
        return EvidenceReminderUrl;
    }

    /** Getting the Final Evidence Reminder Image Url. **/
    public String getFinalEvidenceReminderUrl(){
        List<Document> lstDocument = [SELECT Id FROM Document WHERE DeveloperName = 'FinalEvidenceReminder'];
        String strOrgId = UserInfo.getOrganizationId();
        String FinalEvidenceReminderUrl = System.URL.getSalesforceBaseUrl().toExternalForm() + 
                            '/servlet/servlet.ImageServer?id='+lstDocument[0].Id +
                            '&oid=' + strOrgId;
        System.debug('FinalEvidenceReminderUrl '+FinalEvidenceReminderUrl);
        return FinalEvidenceReminderUrl;
    }

    /** Getting the Community Name. **/
    public String getCommunityName(){
        List<Network> networkList = [SELECT Id, Name FROM Network LIMIT 1];
        String CommunityName = networkList.get(0).Name;
        return CommunityName;
    }

    /** Getting the Community Login Url. **/
    public String getCommunityUrl(){
        List<Network> networkList = [SELECT Id, Name FROM Network LIMIT 1];
        String CommunityUrl = Network.getLoginUrl(networkList.get(0).Id);
        return CommunityUrl;
    }

    /** Getting the Community User Details **/
    public User getCommunityUser(){
        User CommunityUser = [SELECT Id, FirstName, LastName, UserName FROM User WHERE Id =: userId];
        return CommunityUser;
    }

    /** Getting Assessment Complete application **/
    public Application__c getApplication(){
        Application__c Application = new Application__c();
        List<Application__c> appList = [SELECT Id, Name, Contact_Name__c, Membership_Number__c, Site_Name__c, Assessment_Approved_By_Assessor__r.Name, Assessor__r.Name, Assessment_Date__c,
                                        Assessment_Deadline__c, Evidence_Deadline__c, Applicant_Contact__r.Name FROM Application__c WHERE Id =: applicationId];
        Application = appList.get(0);
        return Application;
    }

    /** Getting Extension Granted application **/
    public Application__c getExtensionApplication(){
        Application__c ExtensionApplication = new Application__c();
        List<Application__c> appList = [SELECT Id, Name, Contact_Name__c, Membership_Number__c, Site_Name__c, Extension_Deadline__c, Extension_Granted_On__c, Applicant_Contact__r.Name FROM Application__c WHERE Id =: applicationId];
        ExtensionApplication = appList.get(0);
        return ExtensionApplication;
    }

    /** Getting Evidence Reminder application **/
    public Application__c getEvidenceReminderApplication(){
        Application__c EvidenceReminderApplication = new Application__c();
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Site_Name__c, Extension_Deadline__c, Evidence_Deadline__c, Applicant_Contact__r.Name FROM Application__c WHERE Id =: applicationId];
        EvidenceReminderApplication = appList.get(0);
        if(EvidenceReminderApplication.Extension_Deadline__c != null){
            evidenceReminderDate = EvidenceReminderApplication.Extension_Deadline__c;
        }else{
            evidenceReminderDate = EvidenceReminderApplication.Evidence_Deadline__c;
        }
        return EvidenceReminderApplication;
    }

}
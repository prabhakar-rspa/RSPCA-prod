@isTest
public class BulkRenewalInvoiceControllerTest {
    @testSetup
    static void loadData(){
        Account act = TestDataFactory.createHeadOfficeAccount();
        Contact cnt = TestDataFactory.createContact(act.Id);
        act.Primary_Contact__c = cnt.Id;
        update act;
        Account site = TestDataFactory.createSiteAccount(act.Id);
        Id recordTypeId = Schema.SObjectType.Application__c.getRecordTypeInfosByName().get('Applications').getRecordTypeId();
        Application__c app = TestDataFactory.createApplication(recordTypeId, act.Id, act.Id, cnt.Id, true); 
        Bulk_Renewal__c  bulk_renewal = TestDataFactory.createBulkRenewal(cnt.Id,act.Id,true);
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Assess_Con_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Comm_In_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Renewal_Invite_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_FRReminder_png');
        TestDataFactory.createDocument('EvidenceReminder');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Final_Payment_Reminder_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Payment_Reminder_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Your_Certificates_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Invoice_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Lapsed_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Cancelled_Not_png');
        TestDataFactory.createDocument('RSPCA_Assured_Headers_Payment_Confirmation_png');
        TestDataFactory.createDocument('RSPCA_Assured_Email_Header_EG_png');
        TestDataFactory.createDocument('FinalEvidenceReminder');
    }
    @isTest
    static void testMethod1(){
        Bulk_Renewal__c  bulk_renewal = [SELECT Id,Head_Office__c FROM Bulk_Renewal__c limit 1];
        Application__c app = [SELECT Id FROM Application__c limit 1];
        ApexPages.currentPage().getParameters().put('id',bulk_renewal.Id);
        ApexPages.StandardController controller = new ApexPages.StandardController(bulk_renewal);
        BulkRenewalInvoiceController brCntrlStnd = new BulkRenewalInvoiceController(controller);
        brCntrlStnd.bulkRenewalId = bulk_renewal.Id;
        brCntrlStnd.userId = userinfo.getUserId();
        brCntrlStnd.applicationId = app.Id;
        brCntrlStnd.accountId = bulk_renewal.Head_Office__c;
        brCntrlStnd.getApplication();
        brCntrlStnd.getAssessmentCompleteUrl();
        brCntrlStnd.getBulkRenewal();
        brCntrlStnd.getCommunityInviteUrl();
        brCntrlStnd.getCommunityName();
        brCntrlStnd.getCommunityUser();
        brCntrlStnd.getEvidenceReminderApplication();
        brCntrlStnd.getEvidenceReminderUrl();
        brCntrlStnd.getExtensionApplication();
        brCntrlStnd.getFinalSiteApplications();
        brCntrlStnd.getMembershipCancelledSites();
        brCntrlStnd.getMembershipCancelledUrl();
        brCntrlStnd.getPymntCnfmUrl();
        brCntrlStnd.getPymntCnfrmApplications();
        brCntrlStnd.getRenewalApplications();
        brCntrlStnd.getRenewalReminderSites();
        brCntrlStnd.getRenewLapsedSites();
        brCntrlStnd.getSiteApplications();
        brCntrlStnd.getSiteCertificates();
        brCntrlStnd.getSixWeekUrl();
        brCntrlStnd.getStrCertUrl();
        brCntrlStnd.getStrInvoiceUrl();
        brCntrlStnd.getStrPymRemUrl();
        brCntrlStnd.getStrPymUrl();
        brCntrlStnd.getTwoWeekRenewalReminderSites();
        brCntrlStnd.getTwoWeekUrl();
        brCntrlStnd.getRenewLapsedUrl();
        brCntrlStnd.getExtensionGrantedUrl();
        brCntrlStnd.getFinalEvidenceReminderUrl();
        brCntrlStnd.getCommunityUrl();
        Account headOffice = brCntrlStnd.getHeadOffice();
        system.assert(headOffice.Name == 'Test Head Office');
    }
}
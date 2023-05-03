@isTest
public class PaymentReminderControllerTest {
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
        PaymentReminderController paymentCntrlStnd = new PaymentReminderController(controller);
        PaymentReminderController paymentCntrl = new PaymentReminderController();
        paymentCntrl.accountId = bulk_renewal.Head_Office__c;
        paymentCntrl.applicationId = app.Id;
        paymentCntrl.userId = userInfo.getUserId();
        Account headOffice = paymentCntrl.getHeadOffice();
        system.assert(headOffice.Name == 'Test Head Office');
        app = paymentCntrl.getApplication();
        system.assert(app != null);
        String AssessmentCompleteUrl = paymentCntrl.getAssessmentCompleteUrl();
        system.assert(String.isNotBlank(AssessmentCompleteUrl));
        paymentCntrl.getBulkRenewal();
        String CommunityInviteUrl = paymentCntrl.getCommunityInviteUrl();
        system.assert(String.isNotBlank(CommunityInviteUrl));
        paymentCntrl.getCommunityName();
        String CommunityUrl = paymentCntrl.getCommunityUrl();
        system.assert(String.isNotBlank(CommunityUrl));
        paymentCntrl.getCommunityUser();
        paymentCntrl.getEvidenceReminderApplication();
        String EvidenceReminderUrl = paymentCntrl.getEvidenceReminderUrl();
        paymentCntrl.getFinalSiteApplications();
        paymentCntrl.getMembershipCancelledSites();
        String TwoWeekUrl = paymentCntrl.getTwoWeekUrl();
        paymentCntrl.getTwoWeekRenewalReminderSites();
        String StrPymUrl = paymentCntrl.getStrPymUrl();
        String StrInvoiceUrl = paymentCntrl.getStrInvoiceUrl();
        String StrCertUrl = paymentCntrl.getStrCertUrl();
        String SixWeekUrl = paymentCntrl.getSixWeekUrl();
        paymentCntrl.getSiteCertificates();
        paymentCntrl.getSiteApplications();
        paymentCntrl.getRenewLapsedUrl();
        paymentCntrl.getMembershipCancelledUrl();
        paymentCntrl.getPymntCnfmUrl();
        paymentCntrl.getExtensionGrantedUrl();
        paymentCntrl.getFinalEvidenceReminderUrl();
        paymentCntrl.getCommunityName();
        paymentCntrl.getExtensionApplication();
        paymentCntrl.getRenewLapsedSites();
        paymentCntrl.getRenewalReminderSites();
        List<Application__c> PymntCnfrmApplications = paymentCntrl.getPymntCnfrmApplications();
        system.assert(PymntCnfrmApplications.size() == 0);
        String StrPymRemUrl = paymentCntrl.getStrPymRemUrl();
        system.assert(String.isNotBlank(StrPymRemUrl));
        List<Application__c> RenewalApplications = paymentCntrl.getRenewalApplications();
        system.assert(RenewalApplications.size() == 0);
    }
}
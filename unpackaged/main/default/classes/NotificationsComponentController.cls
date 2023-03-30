public class NotificationsComponentController {
    // Get the base URL.
    public String sfdcBaseURL{get;set;}

    // True if lists below return data
    // for Membership Services
    public Boolean hasEnquires{get;set;}
    public Boolean hasApplications{get;set;}
    public Boolean hasPaidApplications{get;set;}
    public Boolean hasExpiringApplications{get;set;}
    public Boolean hasAllocations{get;set;}
    public Boolean hasRejections{get;set;}
    public Boolean hasApprovalsOffice{get;set;}
    public Boolean hasCertifications{get;set;}
    public Boolean hasDerogationExceptions{get;set;}
    
    // for Accounts
    public Boolean hasPaidCardApplications{get;set;}
    public Boolean hasPendingBacsChequeApplications{get;set;}

    // for NSF
    public boolean hasApprovalsNSF{get;set;}
    public boolean hasSuspensionsPendingApproval{get;set;}

    // for Assessors
    public Id assessorId{get;set;}
    public Boolean hasAssessorAllocations{get;set;}
    public Boolean hasAssessmentBookingsPending{get;set;}
    public Boolean hasAssessmentReportsPending{get;set;}
    public Boolean hasAssessorApprovalsPending{get;set;}

    public NotificationsComponentController(){
        sfdcBaseURL = URL.getSalesforceBaseUrl().toExternalForm();
    }
    // Get List of Enquires
    public List<Lead> getEnquires(){
        List<Lead> leadList = [SELECT Id, Name, Company, Company_Industry__c, CreatedDate, IsConverted FROM Lead WHERE IsConverted = false];
        if(leadList.size() > 0){
            hasEnquires = true;
        }
        return leadList;
    }

    // Get list of Applications
    public List<Application__c> getApplications(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, CreatedDate FROM Application__c WHERE Paid__c = false AND ((RecordType.Name = 'Applications' AND Stage__c = 'Application') OR (RecordType.Name = 'Renewal' AND Renewal_Stage__c = 'Renewal'))];
        if(appList.size() > 0){
            hasApplications = true;
        }
        return appList;
    }

    // Get List of Paid Applications
    public List<Application__c> getPaidApplications(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Payment_Method__c, Date_of_Payment__c FROM Application__c WHERE Paid__c = true AND ((RecordType.Name = 'Applications' AND Stage__c = 'Application') OR (RecordType.Name = 'Renewal' AND Renewal_Stage__c = 'Renewal'))];
        if(appList.size() > 0){
            hasPaidApplications = true;
        }
        return appList;
    }

    // Get List of Paid Card Applications
    public List<Application__c> getPaidCardApplications(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Payment_Method__c, Date_of_Payment__c FROM Application__c WHERE Paid__c = true AND Payment_Method__c = 'Card' AND (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal')];
        if(appList.size() > 0){
            hasPaidCardApplications = true;
        }
        return appList;
    }

    // Get List of Paid BACS/Cheque Applications
    public List<Application__c> getPendingBacsChequeApplications(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Payment_Method__c, Date_of_Payment__c, CreatedDate FROM Application__c WHERE Paid__c = false AND (Payment_Method__c = 'BACS' OR Payment_Method__c = 'Cheque') AND (Stage__c = 'Application' OR Renewal_Stage__c = 'Renewal')];
        if(appList.size() > 0){
            hasPendingBacsChequeApplications = true;
        }
        return appList;
    }

    // Get List of Allocation Applications
    public List<Application__c> getAllocationApplications(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c  FROM Application__c WHERE Stage__c = 'Allocation' OR Renewal_Stage__c = 'Allocation'];
        if(appList.size() > 0){
            hasAllocations = true;
        }
        return appList;
    }

    // Get List of Assessor Allocation Applications
    public List<Application__c> getAssessorAllocations(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Assessor__c, Assessment_Deadline__c  FROM Application__c WHERE (Stage__c = 'Allocation' OR Renewal_Stage__c = 'Allocation') AND Assessor__c = :assessorId AND Allocation_Status__c = 'Pending'];
        if(appList.size() > 0){
            hasAssessorAllocations = true;
        }
        return appList;
    }

    // Get List of Applications where Assessor allocation status is accepted and Assessment Date is blank
    public List<Application__c> getAssessmentBookingsPending(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Assessor__c, Assessment_Deadline__c, Assessment_Date__c  FROM Application__c WHERE (Stage__c = 'Assessment' OR Renewal_Stage__c = 'Assessment') AND Assessor__c = :assessorId AND Allocation_Status__c = 'Accepted' AND Assessment_Date__c = null];
        if(appList.size() > 0){
            hasAssessmentBookingsPending = true;
        }
        return appList;
    }

    // Get List of Applications where Assessor allocation status is accepted and Assessment Date is booked and Assessment Report is blank
    public List<Application__c> getAssessmentReportsPending(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Assessor__c, Assessment_Deadline__c, Assessment_Date__c, Evidence_Deadline__c  FROM Application__c WHERE (Stage__c = 'Assessment' OR Renewal_Stage__c = 'Assessment') AND Assessor__c = :assessorId AND Allocation_Status__c = 'Accepted' AND Assessment_Date__c != null AND Assessment_Report__c = null];
        if(appList.size() > 0){
            hasAssessmentReportsPending = true;
        }
        return appList;
    }

    // Get List of Applications for Assessor where approvals are pending
    public List<Application__c> getAssessorApprovalsPending(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Assessor__c, Assessment_Deadline__c, Assessment_Date__c, Evidence_Deadline__c  FROM Application__c WHERE (Stage__c = 'Compliance' OR Renewal_Stage__c = 'Compliance') AND Assessor__c = :assessorId AND (Assessment_Approved_By_Assessor__c = null  OR Evidence_Approved_By_Assessor__c = null)];
        if(appList.size() > 0){
            hasAssessorApprovalsPending = true;
        }
        return appList;
    }

    // Get List of Rejected Application
    public List<Application__c> getRejectionApplications(){
        Datetime last72Hours = Datetime.now().addHours(-72);
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Membership_Expiry_Date__c   FROM Application__c WHERE Reject__c = true AND Rejection_Date__c >= :last72Hours];
        if(appList.size() > 0){
            hasRejections = true;
        }
        return appList;
    }

    // Get List of Approvals Application for office
    public List<Application__c> getApprovalApplicationsOffice(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Membership_Expiry_Date__c  FROM Application__c WHERE (Application_Approved_By_Office__c = null OR Assessment_Approved_By_Office__c = null OR Evidence_Approved_By_Office__c = null) AND (Stage__c = 'Compliance' OR Renewal_Stage__c = 'Compliance')];
        if(appList.size() > 0){
            hasApprovalsOffice = true;
        }
        return appList;
    }

    // get list of Approvals Application for NSF

    // Get List of Approvals Application
    public List<Application__c> getApprovalApplicationsNSF(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Membership_Expiry_Date__c  FROM Application__c WHERE (Application_Approved_By_Certifier__c = null OR Assessment_Approved_By_Certifier__c = null OR Evidence_Approved_By_Certifier__c = null) AND (Stage__c = 'Compliance' OR Renewal_Stage__c = 'Compliance')];
        if(appList.size() > 0){
            hasApprovalsNSF = true;
        }
        return appList;
    }

    // Get List of Certified Application
    public List<Application__c> getCertifiedApplications(){
        List<Application__c> appList = [SELECT Id, Name, Membership_Number__c, Applicant_Full_Name__c, Site_Name__c, Site__r.Company_Industry__c, Site__r.County__c, Membership_Expiry_Date__c  FROM Application__c WHERE Stage__c = 'Certification' OR Renewal_Stage__c = 'Certification'];
        if(appList.size() > 0){
            hasCertifications = true;
        }
        return appList;
    }

    public List<Derogation_Exception__c> getDerogationExceptions(){
        List<Derogation_Exception__c> DerogationExceptions = [SELECT Id, Name, Derogation_Exception__c, Site__r.Name, Stage__c, Standard_number__c, Start_Date__c FROM Derogation_Exception__c WHERE Granted_by__c = null AND Granted_Date__c = null];
        if(DerogationExceptions.size() > 0){
            hasDerogationExceptions = true;
        }
        return DerogationExceptions;
    }

    // Get list of Suspensions on Account Pending Approval
    public List<Account> getSuspensionsPendingApproval(){
        List<Account> accList = [SELECT Id, Name, Membership_Number__c, Date_Requested_For_Suspension__c, Reason_for_Suspension__c, Administrator__r.Name, Approved__c FROM Account WHERE RecordType.DeveloperName = 'Site' AND Request_for_Suspension__c = true AND Administrator__c != null AND Approved__c = 'Pending'];
        if(accList.size() > 0){
            hasCertifications = true;
        }
        return accList;
    }



}
@isTest
public class ContentDocumentLinkTriggerHandlerTest {

    @testSetup static void setup() {
        // Create Checklist Template Standard
        FObject ctsFobject = new FObject('Checklist_Template_Standard__c', 1);
        ctsFobject.insertRecords(true);
    }

    @isTest
    static void insertImageTest(){
        // Get checklist template standard
        List<Checklist_Template_Standard__c> ctsList = [SELECT Id, Checklist_Template__c, Checklist_Template_Section__c, Checklist_Template_Subsection__c, ContentVersion_URL__c FROM Checklist_Template_Standard__c];

        Test.startTest();
        // Insert content version of the image
        ContentVersion contentVersion = new ContentVersion(
            Title = 'TestImage',
            PathOnClient = 'TestImage.jpg',
            VersionData = Blob.valueOf('Test Content'),
            IsMajorVersion = true
        );
        insert contentVersion;
        
        // Get content document
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink for checklist template standard record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = ctsList[0].id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        Test.stopTest();
    }
}
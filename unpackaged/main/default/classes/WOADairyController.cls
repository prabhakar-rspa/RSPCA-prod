public class WOADairyController {
  @AuraEnabled
  public static WOADairy__c getWOADairy(String recordId) {
    // Get the Map of Schema of WOADairy__c SObject
    Map<String, Schema.SObjectField> fieldMap = WOADairy__c.sObjectType.getDescribe()
      .fields.getMap();

    // Get all of the fields on the object
    Set<String> setFieldNames = fieldMap.keySet();
    list<String> lstFieldNames = new List<String>(setFieldNames);

    // Dynamic Query String.
    List<WOADairy__c> dairyList = Database.query(
      'SELECT ' +
      String.join(lstFieldNames, ',') +
      ' FROM WOADairy__c WHERE WOA__c =:recordId'
    );

    WOADairy__c dairyWoa = new WOADairy__c(WOA__c = recordId);
    if (!dairyList.isEmpty()) {
      dairyWoa = dairyList[0];
    }
    return dairyWoa;
  }

  @AuraEnabled
  public static void saveWOADairy(
    WOADairy__c woaDairy,
    String cowHousing,
    List<String> deletedCHRecords,
    String mobilityScoring,
    List<String> deletedMSRecords,
    String lamenessPrevalence
  ) {
    if (woaDairy != null) {
      WOADairy__c woaDairyRecord = woaDairy;
      if (woaDairyRecord.Id == null) {
        insert woaDairyRecord;
      } else {
        update woaDairyRecord;
      }
      List<Cows_Housing__c> cowHousingList = (List<Cows_Housing__c>) JSON.deserialize(
        cowHousing,
        List<Cows_Housing__c>.class
      );
      if (cowHousingList != null && cowHousingList.size() > 0) {
        for (Cows_Housing__c ch : cowHousingList) {
          ch.WOADairy__c = woaDairyRecord.Id;
        }
        upsert cowHousingList;
      }
      if (deletedCHRecords != null && deletedCHRecords.size() > 0) {
        cowHousingList = new List<Cows_Housing__c>();
        for (String deletedId : deletedCHRecords) {
          Cows_Housing__c ch = new Cows_Housing__c(Id = deletedId);
          cowHousingList.add(ch);
        }
        delete cowHousingList;
      }
      List<Mobility_Scoring__c> mobilityScoringList = (List<Mobility_Scoring__c>) JSON.deserialize(
        mobilityScoring,
        List<Mobility_Scoring__c>.class
      );
      if (mobilityScoringList != null && mobilityScoringList.size() > 0) {
        for (Mobility_Scoring__c ms : mobilityScoringList) {
          ms.WOADairy__c = woaDairyRecord.Id;
        }
        upsert mobilityScoringList;
      }
      if (deletedMSRecords != null && deletedMSRecords.size() > 0) {
        mobilityScoringList = new List<Mobility_Scoring__c>();
        for (String deletedId : deletedMSRecords) {
          Mobility_Scoring__c ms = new Mobility_Scoring__c(Id = deletedId);
          mobilityScoringList.add(ms);
        }
        delete mobilityScoringList;
      }
      List<Lameness_Prevalence__c> Lameness_PrevalenceRecords = (List<Lameness_Prevalence__c>) JSON.deserialize(
        lamenessPrevalence,
        List<Lameness_Prevalence__c>.class
      );
      if (
        Lameness_PrevalenceRecords != null &&
        Lameness_PrevalenceRecords.size() > 0
      ) {
        for (Lameness_Prevalence__c lp : Lameness_PrevalenceRecords) {
          lp.WOADairy__c = woaDairyRecord.Id;
        }
        upsert Lameness_PrevalenceRecords;
      }
    }
  }
  @AuraEnabled
  public static string getCowHousing(String woaDairyId, String recordTypeName) {
    try {
      List<Cows_Housing__c> cowHousingList = [
        SELECT
          Id,
          Housing_Type__c,
          Base__c,
          Base_Other_Text__c,
          Bedding__c,
          Bedding_Other_Text__c
        FROM Cows_Housing__c
        WHERE
          WOADairy__c = :woaDairyId
          AND RecordType.DeveloperName = :recordTypeName
      ];
      return JSON.serialize(cowHousingList);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static string getMobilityScoring(String woaDairyId) {
    try {
      List<Mobility_Scoring__c> mobilityScoring = [
        SELECT
          Id,
          How_often__c,
          How_often_Other_Text__c,
          RoMS__c,
          Which_cows_Other_Text__c,
          Which_cows__c,
          Who_scores__c,
          Who_scores_Other_Text__c
        FROM Mobility_Scoring__c
        WHERE WOADairy__c = :woaDairyId
      ];
      return JSON.serialize(mobilityScoring);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
  @AuraEnabled
  public static string getLamenessPrevalence(String woaDairyId) {
    try {
      List<Lameness_Prevalence__c> lamenessPrevalence = [
        SELECT
          Id,
          Percentage_Of_Score_2_cows__c,
          Percentage_Of_Score_3_cows__c,
          Date_of_scoring__c,
          No_Of_Score_2_cows__c,
          No_Of_Score_3_cows__c,
          Total_no_cows_scored__c
        FROM Lameness_Prevalence__c
        WHERE WOADairy__c = :woaDairyId
      ];
      return JSON.serialize(lamenessPrevalence);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}
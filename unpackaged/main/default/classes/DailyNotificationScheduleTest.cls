@isTest
public class DailyNotificationScheduleTest {
    @isTest
    static void runBatchTest(){
        test.startTest();
        DailyNotificationSchedule obj = new DailyNotificationSchedule();
        Database.executeBatch(obj);
        test.stopTest();

    }
}
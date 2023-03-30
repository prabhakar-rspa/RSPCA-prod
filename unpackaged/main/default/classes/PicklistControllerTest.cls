@isTest
public class PicklistControllerTest {
    @isTest
    public static void PicklistControllerTest() {
        List<String> industry = PicklistController.getPickListValuesIntoList('Account', 'Industry');
    }
}
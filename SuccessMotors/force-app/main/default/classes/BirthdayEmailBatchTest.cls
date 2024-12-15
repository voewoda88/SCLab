@isTest
public class BirthdayEmailBatchTest {
	@testSetup
    static void setup() {        
        List<Contact> contacts = new List<Contact> {
           new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', Birthdate = Date.today().addDays(1)),
           new Contact(FirstName = 'Jane', LastName = 'Doe', Email = 'jane.doe@example.com', Birthdate = Date.today().addDays(-1)),
           new Contact(FirstName = 'Alice', LastName = 'Smith', Email = 'alice.smith@example.com'),
           new Contact(FirstName = 'Misha', LastName = 'Pupkin', Email = 'pupkin@example.com', Birthdate = Date.today())
       	};
            
        insert contacts;
    }
    
    @isTest
    static void testBirthdayEmailBatch() {
        Test.startTest();
        BirthdayEmailBatch batch = new BirthdayEmailBatch();
        Database.executeBatch(batch, 200);
        Test.stopTest();
        
        Integer emailInvocations = Limits.getEmailInvocations();
        System.assertEquals(0, emailInvocations);
    }
}
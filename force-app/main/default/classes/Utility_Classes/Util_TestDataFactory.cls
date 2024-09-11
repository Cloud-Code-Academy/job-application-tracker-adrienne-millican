/**
 * @description       :
 * @author            : admillican08@gmail.com
 * @group             :
 * @last modified on  : 09-11-2024
 * @last modified by  : admillican08@gmail.com
 **/

/*IMPORTANT: Remember to apply the "Rule Exempt" permission set before running Apex tests so
as not to be hindered by validation rules. If testing should not set off flows or triggers,
apply the "Flow Exempt" and "Trigger Exempt" permission sets as needed.*/

@isTest
public without sharing class Util_TestDataFactory {
  public static User testApplicant {
    get {
      if (testApplicant == null) {
        testApplicant = [
          SELECT Id, Name, Username, Email, IsActive, ProfileId
          FROM User
          WHERE Alias = 'jappl'
          WITH SYSTEM_MODE
          LIMIT 1
        ];
      }
      return testApplicant;
    }
    set;
  }

  public static List<Account> createTestAccounts(
    Integer numAccts,
    Boolean doInsert
  ) {
    List<Account> newAccts = new List<Account>();
    String[] stateAbbrevLst = new List<String>{
      'NJ',
      'ME',
      'IL',
      'MT',
      'ID',
      'HI',
      'MD',
      'KS',
      'IN',
      'SC',
      'IA',
      'CA',
      'OR',
      'MN',
      'NM',
      'WA',
      'NY',
      'ND',
      'CO',
      'VA',
      'FL',
      'WV',
      'PR',
      'LA',
      'KY',
      'UT',
      'MO',
      'WI',
      'SD',
      'MA',
      'NV',
      'NE',
      'PA',
      'GU',
      'DE',
      'MI',
      'NC',
      'RI',
      'AK',
      'AZ',
      'OK',
      'MS',
      'AL',
      'TN',
      'GA',
      'NH',
      'OH',
      'CT',
      'VT',
      'WY',
      'AR',
      'TX'
    };
    String[] cityLst = new List<String>{
      'Hamilton',
      'Saco',
      'Elgin',
      'Miles City',
      'Lewiston',
      'Kailua',
      'Rockville',
      'Lawrence',
      'Carmel',
      'Charleston',
      'Ames',
      'San Jose',
      'Gresham',
      'Duluth',
      'Albuquerque',
      'Seattle',
      'Syracuse',
      'Jamestown',
      'Lakewood',
      'Roanoke',
      'Pembroke Pines',
      'Parkersburg',
      'San Juan',
      'Kenner',
      'Georgetown',
      'Taylorsville',
      'St. Charles',
      'Green Bay',
      'Aberdeen',
      'Lynn',
      'Sparks',
      'North Platte',
      'Bethlehem',
      'Santa Rita',
      'Dover',
      'Dearborn',
      'Raleigh',
      'Cranston',
      'Palmer',
      'Chandler',
      'Edmond',
      'Southaven',
      'Birmingham',
      'Murfreesboro',
      'Savannah',
      'Rochester',
      'Youngstown',
      'Bridgeport',
      'Montpelier',
      'Sheridan'
    };

    for (Integer k = 0; k < stateAbbrevLst.size(); k++) {
      Integer index = math.mod(k, stateAbbrevLst.size());
      Integer randomNumber = Utils_RandomGenerator.genRandIntLessThan(1000);
      String acctName =
        Utils_RandomGenerator.generateCompanyName() +
        ' ' +
        randomNumber;
      Account acct = new Account(
        Name = acctName,
        BillingCity = cityLst[index],
        BillingState = stateAbbrevLst[index],
        BillingCountry = 'US',
        BillingPostalCode = Utils_RandomGenerator.generateRandomNumberString(5),
        OwnerId = UserInfo.getUserId()
      );
      newAccts.add(acct);
    }

    if (doInsert) {
      insert newAccts;
    }
    return newAccts;
  }

  public static Contact createSingleTestContact(
    String acctId,
    String fname,
    String lname,
    Boolean doInsert
  ) {
    Account acct = [
      SELECT
        Id,
        OwnerId,
        Email_Domain__c,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry
      FROM Account
      WHERE Id = :acctId
      WITH SYSTEM_MODE
      LIMIT 1
    ];
    String emailDom = acct.Email_Domain__c ?? 'emaildomain.com';
    Contact testContact = new Contact(
      AccountId = acctId,
      FirstName = fname,
      LastName = lname,
      Email = fname + '.' + lname + '@' + emailDom,
      MailingCity = acct.BillingCity,
      MailingState = acct.BillingState,
      MailingPostalCode = acct.BillingPostalCode,
      MailingCountry = acct.BillingCountry
    );
    if (doInsert) {
      insert testContact;
    }
    return testContact;
  }

  public static List<Contact> createTestContacts(
    List<Account> acctLst,
    Integer numContactsPerAcct,
    Boolean doInsert
  ) {
    // Query accounts based on input list
    Map<Id, Account> acctMap = new Map<Id, Account>(
      [
        SELECT
          Id,
          OwnerId,
          BillingStreet,
          BillingCity,
          BillingState,
          BillingPostalCode,
          BillingCountry,
          Email_Domain__c
        FROM Account
        WHERE Id IN :acctLst
        WITH SYSTEM_MODE
      ]
    );

    // Allow duplicates (if needed)
    Database.DMLOptions allowDupes = new Database.DMLOptions();
    allowDupes.DuplicateRuleHeader.AllowSave = true;

    // Titles list for contact creation
    String[] titleLst = new List<String>{
      'Technical Lead',
      'Regional Manager',
      'Team Lead',
      'Manager',
      'Senior Manager',
      'Vice President',
      'Senior Director',
      'Project Manager',
      'Recruiter',
      'Supervisor',
      'Chief Operations Officer',
      'Lead Solutions Designer',
      'Implementation Executive',
      'Identity Officer',
      'Data Designer',
      'Security Specialist',
      'Quality Agent',
      'Research Director',
      'Team Associate',
      'Quality Assurance Technician'
    };

    // Initialize list to store new contacts
    List<Contact> newContacts = new List<Contact>();

    // Create contacts for each account
    for (Account acct : acctMap.values()) {
      for (Integer i = 0; i < numContactsPerAcct; i++) {
        // Randomly select a title
        Integer randomTitle = Utils_RandomGenerator.genRandIntLessThan(20);
        String title = titleLst[randomTitle];

        // Generate random first and last names
        String fname = Utils_RandomGenerator.generatePersonName('first');
        String lname = Utils_RandomGenerator.generatePersonName('last');
        String emailDom = acct.Email_Domain__c ?? 'emaildomain.com';
        // Create contact
        Contact contct = new Contact(
          Firstname = fname,
          Lastname = lname,
          AccountId = acct.Id,
          Email = fname + '.' + lname + '@' + emailDom,
          OwnerId = acct.OwnerId,
          Title = title,
          MailingStreet = acct.BillingStreet,
          MailingCity = acct.BillingCity,
          MailingState = acct.BillingState,
          MailingPostalCode = acct.BillingPostalCode,
          MailingCountry = acct.BillingCountry
        );
        newContacts.add(contct);
      }
    }

    // Optionally insert contacts
    if (doInsert && !newContacts.isEmpty()) {
      Database.insert(newContacts, allowDupes);
    }

    return newContacts;
  }

  public static User createSingleTestUser(
    Id profileId,
    Id roleId,
    String fname,
    String lname,
    Boolean doInsert
  ) {
    Integer randomNumber = Utils_RandomGenerator.genRandIntLessThan(1000);
    User testUser = new User(
      FirstName = fname,
      LastName = lname,
      Email = fname + '.' + lname + '@jtracker.org',
      Username = fname + '.' + lname + randomNumber + '@jtracker.org',
      TimeZoneSidKey = 'America/Denver',
      LocaleSidKey = 'en_US',
      EmailEncodingKey = 'ISO-8859-1',
      LanguageLocaleKey = 'en_US',
      ProfileId = profileId,
      UserRoleId = roleId
    );
    if (doInsert) {
      insert testUser;
    }
    return testUser;
  }
}

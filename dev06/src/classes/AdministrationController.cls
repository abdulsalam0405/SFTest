public with sharing class AdministrationController {
    public Boolean bAdministration{get;set;} 
    public String ProfileName {get;set;} 
    
    public String ConfigarationPage {get; set;}
    public String ImportDataPage {get;set;}
    public String SecurityMatrixPage {get;set;}  
    public String LinkAccountPage {get;set;}
    public String UnlinkAccountPage {get;set;} 
      
    public AdministrationController() {

        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
            }
        }
        //Get Security Level Settings
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);
        
        ConfigarationPage = 'Configurationlist';
        LinkAccountPage = 'LinkAccount';
        UnlinkAccountPage = 'UnlinkAccount';
        ImportDataPage = 'ImportData';
        SecurityMatrixPage= 'SecurityMatrix';
        
    }
}
global with sharing class AddressController 
{
    //public Account act {get;set;}
    //public Ship_To__c shipTo {get;set;}
    public string ERPSytemName {get;set;}
    //public GUMU_App_Setting__c GUMU_App_Setting{get;set;}
    //public ERP_Config__c ERPConfig {get;set;}
    public String ProfileName {get;set;}
    public Boolean bAdministration{get;set;}
     
    public AddressController(ApexPages.StandardController controller) 
    {
        
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
            }
        }
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);
        
        string AccountID = ApexPages.currentPage().getParameters().get('AccountId');        
        string shipToId = ApexPages.currentPage().getParameters().get('id');
        
        Account act;
        string IntegrationKey ='';
        if(string.isNotBlank(AccountID))
            IntegrationKey = [select Integration_Key__c from Account where ID =:AccountID].Integration_Key__c ;
        else
            IntegrationKey = [select Account_Id__r.Integration_Key__c from Ship_To__c where ID =:shipToId].Account_Id__r.Integration_Key__c;
        
        if(string.isNotBlank(IntegrationKey))
            ERPSytemName = [select ERP_System__c from ERP_Config__c where Id =:IntegrationKey].ERP_System__c;
        else
            ERPSytemName = [select ERP_System__c from GUMU_App_Setting__c limit 1].ERP_System__c;
    }
    
    //Get Address Page
    public String getAddressPage()
    {
       string AddressPageName ='';
       if(string.isNotBlank(ERPSytemName))
       {
           if(ERPSytemName== 'SageERPX3')
           {
                AddressPageName = 'AddressSageX3';        
           }
           else if(ERPSytemName== 'Sage100ERP')
           {
                AddressPageName = 'AddressSage100'; 
           }
           else if(ERPSytemName== 'Sage300ERP')
           {
                AddressPageName = 'AddressSage300'; 
           }
           else
           {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'ERP system not found.'));
           }  
       }
       //AddressPageName = 'AddressSageX3'; 
       return AddressPageName ;
      
    }
       
}
global with sharing class PromoteCustomerController {

    public Account act {get;set;}
    public string ERPSytemName {get;set;}
   // public GUMU_App_Setting__c GUMU_App_Setting{get;set;}
    //public ERP_Config__c ERPConfig {get;set;}
    public String ProfileName {get;set;} 
    public Boolean bShowPromoteCustomer{get;set;}
    
     public PromoteCustomerController(ApexPages.StandardController controller) 
     {
        this.act=(Account)controller.getRecord();
        string PromoteCustomer='PromoteCustomerSage100' ;
        
        string AccountId = ApexPages.currentPage().getParameters().get('id');
        
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible())
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
        } 
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bShowPromoteCustomer = Boolean.valueOf(SM.Promote_Customer__c);
        system.debug('bShowPromoteCustomer '+bShowPromoteCustomer);
        system.debug('IntegrationKey  '+this.act.Integration_Key__c );
        
        if(this.act.Integration_Key__c != null)
        {
            list<ERP_Config__c> ERPConfiglist = [select ERP_System__c from ERP_Config__c where Id =:this.act.Integration_Key__c];
            if(ERPConfiglist.size()>0)
                ERPSytemName = ERPConfiglist[0].ERP_System__c;
            else
            {               
                ERPSytemName = [select ERP_System__c from GUMU_App_Setting__c limit 1].ERP_System__c ;
            }
        }
        else
            ERPSytemName = [select ERP_System__c from GUMU_App_Setting__c limit 1].ERP_System__c ;

     }
    //Get promote customer Page
    public String getPromoteCustomer()
    {        
    	system.debug('ERPSytemName '+ERPSytemName);
           string PromoteCustomer ='';
           if(string.isNotBlank(ERPSytemName))
           {
               if(ERPSytemName== 'SageERPX3')
                    PromoteCustomer = 'PromoteCustomerX3';        
               else if(ERPSytemName== 'Sage100ERP')
                    PromoteCustomer = 'PromoteCustomerSage100'; 
               else if(ERPSytemName== 'Sage300ERP')
                    PromoteCustomer = 'PromoteCustomerSage300'; 
               else
                    ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'ERP system not found.'));
           }
           system.debug('PromoteCustomer'+PromoteCustomer);
           return PromoteCustomer ;
    }  
}
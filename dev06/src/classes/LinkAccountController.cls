//
global with sharing class LinkAccountController
{
    public list<Account> Accounts {get;set;}
    public String ConfigId{get;set;}
    public String FirstName{get;set;}
    public String LastName{get;set;}
    public String ConfigObjectPrefix {get;set;}
    public String SalesObjectPrefix {get;set;} 
    public list<Account> lstAccounts {get;set;}
    public list<Account> Mappings {get;set;} 
    public String Criteria {get;set;}
    public String FromAccount {get;set;}
    public String ToAccount {get;set;}
    public String NameSpace {get;set;}

    //pagination information
    public Integer PAGE_SIZE{get;set;}
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public Boolean bAdministration{get;set;} 
    public String ProfileName {get;set;} 

    public Integer OffsetSize {get;set;}
    public Integer QueryLimit {get;set;}
    public Integer CountTotalRecords{get;set;}

    public List<Schema.FieldSetMember> FieldMembers {get;set;}
    public Double TableWidth{get;set;}
    public Double colWidth{get;set;}

    public String DefaulIntegrationID{get;set;}
    public String DefaulIntegrationName{get;set;}
    private static final string className='LinkAccountController';

    public List<Helper.Customer> CustomerList{get;set;}

    // Constructor
    public LinkAccountController() 
    {
        try
        {  
            OffsetSize = 0;
            PAGE_SIZE = 10;
            QueryLimit = PAGE_SIZE;
            if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
            {
                // Check if the user has read access on the Profile.name
                if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                    ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                }
            }

            NameSpace=Utility.FetchNameSpace();

            Security_Matrix__c SM = Security_Matrix__c.getInstance();
            bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);

            ConfigObjectPrefix =Utility.getSobjectKeyPrefix(NameSpace+'ERP_Config__c');
            ConfigId='';
            Mappings=new list<Account>();

            //init variable
            this.Mappings = new list<Account>();

            //set initial page
            this.page = 1;
            this.PAGE_SIZE = 10;

            FieldMembers = getFields();

            colWidth = 14;

            if(FieldMembers.size()*14 > 100)
                TableWidth = FieldMembers.size()*14;
            else      
                TableWidth = 100;

            // Assign Default Integration
            List<ERP_Config__c> lstERPConfig = [select Id, Name from ERP_Config__c where Default__c =true limit 1] ; 
             

            DefaulIntegrationID = '';
            DefaulIntegrationName = '';
            if(lstERPConfig.size() > 0)
            {
                DefaulIntegrationID = lstERPConfig[0].Id;
                DefaulIntegrationName = lstERPConfig[0].Name;
            }
        }
        catch(Exception ex)
        {
            //GUMUException exc= new GUMUException(className,'LinkAccountController',ex);
            CustomException exc= new CustomException(ClassName,'LinkAccountController',ex,true);
        }
    }

    // Get Matching Criteria option values.
    public List<SelectOption> getItems() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','--None--'));       
        options.add(new SelectOption('Name','Customer Name'));
        return options;
    }

    //Advance to next page
    public void doNext()
    {
        try
        {
            OffsetSize += QueryLimit;
            this.page++;
            GetUnlinkAccounts();   
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'doNext',ex,true);
        }       
    }

    //Get Fields from the Field Set
    public List<Schema.FieldSetMember> getFields() {
        return SObjectType.Account.FieldSets.Link_Customer_FS.getFields();
    }


    //Advance to previous page
    public void doPrevious()
    {
        try
        {
            OffsetSize -= QueryLimit;
            this.page--;
            GetUnlinkAccounts();
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'doPrevious',ex,true);
        }    
    }

    //Returns whether the previous page exists
    public Boolean getHasPrevious()
    {
        if (OffsetSize==0)
        {
            return false;
        }
        else 
            return true;
    }

    //Returns whether the next page exists
    public Boolean getHasNext()
    {
        if(OffsetSize + QueryLimit < CountTotalRecords)
        {
            return true;
        }
        else 
        {
            return false;
        }
    }

    //Create Unlink account list   
    private void CreateUnlinkAccountList()
    {
        try
        {
            Mappings=new list<Account>();        
            Mappings = Accounts;
            //calculate total pages
            this.totalRecords = this.CountTotalRecords;
            Decimal pages = Decimal.valueOf(this.CountTotalRecords);
            pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);
            QueryLimit = PAGE_SIZE; 
            //adjust start index e.g. 1, 11, 21, 31
            this.startIdx++;
            //adjust end index
            if(this.endIdx>this.totalRecords){
                this.endIdx = this.totalRecords;
            }
            
             if(this.totalRecords == 0)
            {
                this.totalPages=1;
                this.totalPages=0;
                this.startIdx=0;
                this.endIdx=0;
            }   
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'CreateUnlinkAccountList',ex,true);
        }         
    } 

    //Get Unlinked Accounts
    public PageReference GetUnlinkAccounts() 
    {
    //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'GetUnlinkAccounts'));
        try
        {
            if(Apexpages.hasMessages())
                Apexpages.getMessages().clear();       
            this.page = page;   
            this.PAGE_SIZE=PAGE_SIZE;
            this.startIdx = (this.page-1)*PAGE_SIZE;
            this.endIdx = this.page*PAGE_SIZE;
            this.totalRecords = 0;
            QueryLimit = PAGE_SIZE; 
            Accounts=new list<Account>();
            if(ConfigId.length()>15)
            {
                ConfigId=ConfigId.substring(0,15);
            } 

            // Check if the user has read access on the Acccount fields
            if (!Schema.sObjectType.Account.fields.Id.isAccessible() 
                    || !Schema.sObjectType.Account.fields.Name.isAccessible() || !Schema.sObjectType.Account.fields.BillingCity.isAccessible()
                    || !Schema.sObjectType.Account.fields.BillingCountry.isAccessible() || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isAccessible()
                    || !Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isAccessible() || !Schema.sObjectType.Account.fields.BillingState.isAccessible()){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                        'Insufficient access to Fields'));
                return null;
            }
            String query= '';

            query = 'SELECT Count() FROM ACCOUNT WHERE (ERP_Customer_Number__c = \'\' OR ERP_Customer_Number__c = null) and ERP_Company_Code__c = \'\'';

            if(String.isNotBlank(FromAccount))
                query+=' and Name >= \''+ String.escapeSingleQuotes(FromAccount) +'\''; 

            if(String.isNotBlank(ToAccount))
                query+=' and (Name < \''+ String.escapeSingleQuotes(ToAccount) +'\' or Name like \''+ String.escapeSingleQuotes(ToAccount) +'%\')';

            CountTotalRecords = Database.CountQuery(query);   

            // Main Query
            query='SELECT ';

            for(Schema.FieldSetMember f : this.getFields()) {
                query += f.getFieldPath() + ', ';
            }

            query+= 'Id FROM ACCOUNT WHERE (ERP_Customer_Number__c = \'\' OR ERP_Customer_Number__c = null) and ERP_Company_Code__c = \'\'';

            if(String.isNotBlank(FromAccount))
                query+=' and Name >= \''+ String.escapeSingleQuotes(FromAccount) +'\''; 

            if(String.isNotBlank(ToAccount))
                query+=' and (Name < \''+ String.escapeSingleQuotes(ToAccount) +'\' or Name like \''+ String.escapeSingleQuotes(ToAccount) +'%\')';

            query+=' ORDER BY Name limit '+ QueryLimit +' offset '+ OffsetSize +'';
            
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'query'+query));

            Accounts=Database.Query(query);
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Accounts'+Accounts));

            CreateUnlinkAccountList();
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'GetUnlinkAccounts',ex,true);
        }         
        return null;                            
    }

    //Save Linked Customer
    @RemoteAction
    public static Boolean SaveLinkCustomer(list<map<string,string>> lstAccounts)
    {
        //system.debug('lstAccounts '+lstAccounts);
        String CompanyCode='';
        Boolean bFirst=true;
        string IntegrationKey = '';
        Utility.bRunTrigger = false;
        try
        { 
            //check Account field level security 
            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable() 
                    || !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()
                    || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable())
            {
                return false;
            }

            if (!Schema.sObjectType.Ship_To__c.fields.Integration_Key__c.isUpdateable())
            {
                return false;
            }

            if (!Schema.sObjectType.Ship_To__c.fields.Integration_Key__c.isAccessible()){
                return false;
            }

            if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isAccessible() 
                    || !Schema.sObjectType.Account.fields.Integration_Key__c.isAccessible()
                    || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isAccessible())
            {
                return false;
            }


            list<Account> AccountsToBeUpserted=new list<Account>();
            List<Ship_To__c> ShipToList = new list<Ship_To__c>();
            Set<Id> records = new Set<Id>();

            for(map<string,string> iAccount : lstAccounts)
            {
                Account oAcc = new Account();

                if(bFirst)
                {
                    ERP_Config__c cfg=[Select Id, ERP_Company_Code__c From ERP_Config__c WHERE Id= : iAccount.get('IntegrationKey') LIMIT 1 ];
                    CompanyCode=cfg.ERP_Company_Code__c;
                    bFirst=false;
                }
                oAcc.Id = iAccount.get('AccountKey');
                oAcc.ERP_Customer_Number__c = iAccount.get('LinkedCustomer');
                oAcc.Integration_Key__c = iAccount.get('IntegrationKey');
                oAcc.ERP_Company_Code__c=CompanyCode;

                AccountsToBeUpserted.add(oAcc);

                IntegrationKey = iAccount.get('IntegrationKey');
                records.add(iAccount.get('AccountKey'));
            }

            List<Ship_To__c> lstShipTo = [SELECT Id, Integration_Key__c
                                          FROM Ship_To__c 
                                          WHERE Account_Id__c IN :records];

            // Link Ship To Records
            for(Ship_To__c shipto : lstShipTo)
            {
                Ship_To__c SH = new Ship_To__c();
                SH.Id = shipto.Id;
                SH.Integration_Key__c = IntegrationKey;

                ShipToList.add(SH);
            }

            if(AccountsToBeUpserted.size() > 0)
                upsert AccountsToBeUpserted;

            if(ShipToList.size() > 0)
                update ShipToList;

            Utility.bRunTrigger = true;
            return true;
        }
        catch(Exception ex)
        {
            //GUMUException exc= new GUMUException(className,'SaveLinkCustomer',ex);
            CustomException exc= new CustomException(ClassName,'SaveLinkCustomer',ex,true);
            Utility.bRunTrigger = true;
            return false;
        }
    }

    //Get ERP Customer List Based on Integration key, Matching Criteria and Matching Criteria Value.
    public string strCustomerList{get;set;}
    public pageReference CustomerList()
    { 

        
        string MatchingCriteriaValue = ApexPages.currentPage().getParameters().get('MatchingCriteriaValue');
        string MatchingCriteriaOpt  = ApexPages.currentPage().getParameters().get('MatchingCriteriaOpt');
        string IntegrationKey = ApexPages.currentPage().getParameters().get('ConfigId');
        string MatchingCriteria = ApexPages.currentPage().getParameters().get('MatchingCriteria');
        
        ERP_Config__c ERPConfig = new ERP_Config__c();
        string ERPSystemName='';
        if(string.isNotBlank(IntegrationKey))
        {
            ERPConfig = [select ERP_System__c from ERP_Config__c where Id =:IntegrationKey limit 1] ;
            ERPSystemName = ERPConfig.ERP_System__c;
        }
        
        
        
        List<Helper.Customer> lstCustomer = New List<Helper.Customer>();
        Helper.Customer oCustomer;

        baseIntegrationFramework integrationFramework = IntegrationFactory.getIntegrationFramework(IntegrationKey);

        map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
        map<string,list<string>> parameter = new map<string,list<string>>();
        list<string> listParams=new list<string> ();

        listParams.add(MatchingCriteriaValue);

        if(MatchingCriteriaOpt == 'EqualTo')
            parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
        else
            parameter.put(string.valueOf(Helper.Operator.LIKE_CALUSE),listParams);

        //fieldParameters.put(integrationFramework.GetFieldForAutoMatch(),parameter);  

        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        
        
        Helper.GUMU_Response resGUMU_Response;// = new Helper.GUMU_Response();
        
        if (Test.isRunningTest())
            return null;
               
        if(ERPSystemName == 'SageERPX3')
        {
            fieldParameters.put(integrationFramework.GetFieldForAutoMatch(),parameter);  
            AttribParams=Utility.getAttribParameters('1' , '200' , IntegrationKey, 'CustomerList', '' , Helper.MappingPurpose.DISPLAY);
            resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
            system.debug('resGUMU_Response1 '+resGUMU_Response);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'resGUMU_Response '+resGUMU_Response ));
        }
        else if(ERPSystemName == 'Sage300ERP')
        {
            fieldParameters.put(integrationFramework.GetFieldForAutoMatch(),parameter);  
            AttribParams=Utility.getAttribParameters('1' , '200' , IntegrationKey, 'CustomerList', '' , Helper.MappingPurpose.DISPLAY);
            resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
        }
        else
         {          
             fieldParameters.put('CustomerName',parameter);  
             AttribParams=Utility.getAttribParameters('1' , '200' , IntegrationKey, 'Sage100Customer', '' , Helper.MappingPurpose.DISPLAY);
             resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
             system.debug('getdata '+resGUMU_Response);
         }
        
        
        CustomerList = integrationFramework.GetGenericCustomers(resGUMU_Response);
        system.debug('CustomerList '+CustomerList);

        strCustomerList = jSon.serialize(CustomerList);
        system.debug('strCustomerList '+strCustomerList);
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'strCustomerList '+strCustomerList ));
                
        return null;

    }

    //Get ERP Customer List Based on Integration key, Matching Criteria and Matching Criteria Value.
    // delete this function already created pagereference
    

    //Get ERP Customer List Based on list of Account Set.
    @RemoteAction
    public static list<MatchCustomer> GetERPCustomer(list<map<string,string>> lstAccountSet)
    {
        list<MatchCustomer> lstMatchCustomer = new list<MatchCustomer>();
        MatchCustomer oMatchCustomer;
        Boolean bFlag=false;
        String sInClauseValues = '';
        String sIntegrationKey = '';
        String sMatchingCriteria = '';

        map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
        map<string,list<string>> parameter = new map<string,list<string>>();
        list<string> listParams=new list<string>();
        
        system.debug('lstAccountSet '+lstAccountSet);
        try
        {
            for(map<string,string> iMap : lstAccountSet)
            {
                sIntegrationKey     = iMap.get('IntegrationKey');
                sMatchingCriteria   = iMap.get('MatchingCriteria');       
                listParams.add(iMap.get('MatchingCriteriaValue'));
            }
            
            baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(sIntegrationKey);

            //TODO:s:Remove this after imple,meting in Clause
            /*if(lstAccountSet.size()>0)
            {
                listParams=new list<string> ();
                listParams.add(lstAccountSet[0].get('MatchingCriteriaValue'));
                system.debug('listParams '+listParams);
                listParams.add(lstAccountSet[lstAccountSet.size()-1].get('MatchingCriteriaValue'));
                parameter.put(string.valueOf(Helper.Operator.IN_CLAUSE),listParams);
                system.debug('parameter'+parameter);
                fieldParameters.put(integrationFramework.GetFieldForAutoMatch(),parameter);
                system.debug('fieldParameters '+fieldParameters);
                //fieldParameters.put('CustomerName',parameter);     
            } 
            else*/
                //TODO:s:Remove this after imple,meting in Clause
            {
                parameter.put(string.valueOf(Helper.Operator.IN_CLAUSE),listParams);
                fieldParameters.put(integrationFramework.GetFieldForAutoMatch(),parameter); 
                system.debug('fieldParameters '+fieldParameters);    
            }
            
            ERP_Config__c ERPConfig = new ERP_Config__c();
            string ERPSystemName='';
            if(string.isNotBlank(sIntegrationKey))
            {
                ERPConfig = [select ERP_System__c from ERP_Config__c where Id =:sIntegrationKey limit 1] ;
                ERPSystemName = ERPConfig.ERP_System__c;
            }

            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            
            Helper.GUMU_Response resGUMU_Response;
            if (Test.isRunningTest())
                resGUMU_Response=null; 
            else
            {
                
                if(ERPSystemName == 'SageERPX3')
                {
                    AttribParams=Utility.getAttribParameters('1' , '200' , sIntegrationKey, 'CustomerList', '' , Helper.MappingPurpose.DISPLAY);
                    list<object> obj = new list<object>();
                    obj.add('') ;
                    AttribParams.put('AccountType',obj);
                    system.debug('AttribParams '+AttribParams);
                    resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
                    system.debug('resGUMU_Response '+resGUMU_Response);
                    
                }
                else if(ERPSystemName == 'Sage300ERP')
                {
                        fieldParameters = new map<string,map<string,list<string>>> ();
                    fieldParameters.put('NAMECUST',parameter);
                    system.debug('fieldParameters '+fieldParameters);
                    AttribParams=Utility.getAttribParameters('1' , '200' , sIntegrationKey, 'CustomerList', '' , Helper.MappingPurpose.DISPLAY);
                    system.debug('AttribParams'+AttribParams);
                    resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
                    system.debug('resGUMU_Response'+resGUMU_Response);
                   
                }
                
                else
                 {
                    AttribParams=Utility.getAttribParameters('1' , '200' , sIntegrationKey, 'Sage100Customer', '' , Helper.MappingPurpose.DISPLAY);
                    resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
                    
                    system.debug('resGUMU_ResponseIMP '+resGUMU_Response);
                   
                 }
                
                    
            }
                        

            List<Helper.Customer> lstCustomer = New List<Helper.Customer>();

            if (Test.isRunningTest())
            {
                Helper.Customer cust = new Helper.Customer();
                cust.UniqueKey='ES022';
                //cust.ARDivisionNo='01';
                cust.CustomerName='ES022';
                lstCustomer.add(cust); 
            }
            else
                lstCustomer=integrationFramework.GetGenericCustomers(resGUMU_Response);

            system.debug('lstCustomer '+lstCustomer);
           // system.debug('lstAccountSet '+lstAccountSet);
            
            String sLinkCustomerName = '';
            for(map<string,string> iMap : lstAccountSet)
            {
                String sUniqueKey = '';
                String sCustomerKey = '';
                String sCustomerName = '';
                Integer Count = 0;

                for (Helper.Customer oCustomer : lstCustomer)
                {
                    sCustomerName = oCustomer.CustomerName;
                  
                    if(iMap.get('MatchingCriteriaValue') == sCustomerName)
                    {
                        sUniqueKey = oCustomer.UniqueKey ;
                        sCustomerKey = sUniqueKey;
                        sLinkCustomerName  = oCustomer.CustomerName;
                        Count++;
                        //system.debug('Count '+Count);
                        if(Count == 2)
                            break;
                    }
                }     


                if(Count > 1) 
                {
                    sCustomerKey = '';
                    sLinkCustomerName  = '';
                }           
                else if(Count == 1) 
                {
                    sCustomerKey = GetExistingLinkcustomer(sIntegrationKey,sUniqueKey);
                    //system.debug('sCustomerKey '+sCustomerKey);
                    if(sCustomerKey == '')
                        sCustomerKey = sUniqueKey;
                    else
                    {
                        sCustomerKey = '';
                        sLinkCustomerName  = '';
                    }
                }

                oMatchCustomer = new MatchCustomer();
                oMatchCustomer.AccountId = iMap.get('AccountKey');
                oMatchCustomer.CustomerNumber = sCustomerKey;
                oMatchCustomer.CustomerName = sLinkCustomerName;
                lstMatchCustomer.add(oMatchCustomer);
                //system.debug('lstMatchCustomer '+lstMatchCustomer);
            }
            system.debug('lstMatchCustomer '+lstMatchCustomer);
        }
        catch(exception ex)
        {
            CustomException exc= new CustomException(ClassName,'GetERPCustomer',ex,true);
        }
        return lstMatchCustomer; 
    }

    //Check whether Link Customer is Exists Or not.
    public string LinkId{get;set;}
    public pageReference ExistingLinkcustomer()
    {
        String IntegrationKey=ApexPages.currentPage().getParameters().get('ConfigId');
        String CustomerNumber=ApexPages.currentPage().getParameters().get('CustomerNo');
        list<Account> LinkedAccount = [SELECT ID FROM Account WHERE Integration_Key__c=:IntegrationKey AND ERP_Customer_Number__c =: CustomerNumber Limit 1];

        LinkId= '';
        if(LinkedAccount.size() > 0)
            LinkId = LinkedAccount[0].ID;

        if(LinkId !='')
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'Selected Customer is already linked to the account. Please select another customer.'));
        //return LinkID;
        return null;
    }

    //Check whether Link Customer is Exists Or not.
    @RemoteAction
    public static String GetExistingLinkcustomer(String IntegrationKey, String CustomerNumber)
    {
        system.debug('GetExistingLinkcustomer ');
        list<Account> LinkedAccount = [SELECT ID FROM Account WHERE Integration_Key__c=:IntegrationKey AND ERP_Customer_Number__c =: CustomerNumber Limit 1];

       system.debug('LinkedAccount '+LinkedAccount);
        String LinkID= '';
        if(LinkedAccount.size() > 0)
            {
                LinkID = LinkedAccount[0].ID;
                system.debug('LinkID '+LinkID);
            }

        return LinkID;
    }

    /// Wrapper Classes  ///
    public class UnlinkAccounts
    {
        //Mapping Table Id
        public string Id{get;set;}

        // Salesforce Property Members
        public string AccountNumber{get;set;}
        public string AccountName{get;set;}
        public string BillingCity{get;set;}
        public string BillingState{get;set;}
        public string BillingCountry{get;set;}

        // ERP Property Members
        public string ConfigId {get;set;}
        public string Index {get;set;}
    }


    public class MatchCustomer
    {
        // Salesforce Property Members
        public string AccountId{get;set;}
        public string CustomerNumber {get;set;}
        public string CustomerName {get;set;}
    }

    public class Customer
    {
        public string UniqueKey {get;set;}
        public string ARDivisionNo {get;set;}
        public string CustomerName {get;set;}
    } 
}
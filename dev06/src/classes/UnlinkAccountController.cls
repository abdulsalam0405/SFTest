public with sharing class UnlinkAccountController
{
    public list<Account> Accounts {get;set;}
    public String ConfigId{get;set;}
    public String ConfigObjectPrefix {get;set;}
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

    public Integer OffsetSize {get;set;}
    public Integer QueryLimit {get;set;}
    public Integer CountTotalRecords{get;set;}

    public Double colWidth{get;set;}
    public Double TableWidth{get;set;}

    public String ProfileName {get;set;} 

    public List<Schema.FieldSetMember> FieldMembers {get;set;}

    public String DefaulIntegrationID{get;set;}
    public String DefaulIntegrationName{get;set;}

    /*
     * Constructor calling with default values set.
     */ 
    public UnlinkAccountController() 
    {
        try
        {
            OffsetSize = 0;
            QueryLimit = PAGE_SIZE;

            NameSpace=Utility.FetchNameSpace();
            if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
            {
                // Check if the user has read access on the Profile.name
                if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                    ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                }
            }

            // Get Security Value and set it to the varible.
            Security_Matrix__c SM = Security_Matrix__c.getInstance();
            bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);

            // Get Object Prefix
            ConfigObjectPrefix=Utility.getSobjectKeyPrefix('GUMU_Lite__ERP_Config__c');
            ConfigId='';

            //init variable
            this.Accounts = new list<Account>();
            //set initial page
            this.page = 1;
            this.PAGE_SIZE=10;

            GetLinkedAccounts();

            FieldMembers = getFields();
            /*colWidth = 18;
            if(FieldMembers.size()*18 > 100)
            {
                TableWidth = FieldMembers.size()*18;  
            }
            else
            { 
                TableWidth = 100;
                colWidth =  (TableWidth-3)/FieldMembers.size();
            }*/
            colWidth = 12;
        
            if(FieldMembers.size()*12 + 20 + 8 + 15 > 100)
                TableWidth = FieldMembers.size()*12 + 20 + 8 + 15;
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
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'DefaulIntegrationID:'+DefaulIntegrationID));   
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('UnlinkAccountController','UnlinkAccountController',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
    }
    /*
     * Advance to next page
     */
    public void doNext()
    {
        try
        {           
            if(OffsetSize + QueryLimit > CountTotalRecords)
                return ; 
                   
            OffsetSize += QueryLimit;
            this.page++;
            GetLinkedAccounts();
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('UnlinkAccountController','doNext',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
    }

    /*
     * Get Fields from the Field Set
     */
    public List<Schema.FieldSetMember> getFields() 
    {
        return SObjectType.Account.FieldSets.Unlink_Customer_FS.getFields();
    }

    /*
     * Advance to previous page
     */
    public void doPrevious()
    { 
        try
        {
             if(OffsetSize == 0)
                return;
                
            OffsetSize -= QueryLimit;
            this.page--;
            GetLinkedAccounts();
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('UnlinkAccountController','doPrevious',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }       
    }

    /*
     * Returns whether the previous page exists
     */
    public Boolean getHasPrevious()
    {
        if(OffsetSize ==0)
        {
            return false;
        }
        else 
            return true;
    }

    /*
     * Returns whether the next page exists
     */
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

    /*
     * Get Already Linked Accounts for Listing
     */
    public PageReference GetLinkedAccounts() 
    {
        try
        {
            if(Apexpages.hasMessages())
                Apexpages.getMessages().clear();
            
            ConfigId= ApexPages.currentPage().getParameters().get('ConfigId');
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'ConfigId '+ConfigId));
                        
            this.page = page;
            this.PAGE_SIZE=PAGE_SIZE;

            //calculate range of records for capture
            this.startIdx = (this.page-1)*PAGE_SIZE;
            this.endIdx = this.page*PAGE_SIZE;
            this.totalRecords = 0;     
            QueryLimit = PAGE_SIZE; 

            // Check if the user has read access on the Acccount fields
            if (!Schema.sObjectType.Account.fields.Id.isAccessible() 
                    || !Schema.sObjectType.Account.fields.Name.isAccessible() || !Schema.sObjectType.Account.fields.BillingCity.isAccessible()
                    || !Schema.sObjectType.Account.fields.BillingCountry.isAccessible() || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isAccessible()
                    || !Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isAccessible()){

                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                        'Insufficient access to Fields'));
                return null;
            }

            String query='';
            query = 'SELECT Count() FROM ACCOUNT WHERE (ERP_Customer_Number__c != \'\' AND ERP_Customer_Number__c != null) and ERP_Company_Code__c != \'\' ';

            if(String.isNotBlank(ConfigId))
                query+=' and Integration_Key__c = \''+ String.escapeSingleQuotes(ConfigId) +'\'';

            if(String.isNotBlank(FromAccount))
                query+=' and Name >= \''+ String.escapeSingleQuotes(FromAccount) +'\''; 

            if(String.isNotBlank(ToAccount))
                query+=' and (Name < \''+ String.escapeSingleQuotes(ToAccount) +'\' or Name like \''+ String.escapeSingleQuotes(ToAccount) +'%\')';

            CountTotalRecords = Database.CountQuery(query); 
            
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'CountTotalRecords '+CountTotalRecords));
            
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'OffsetSize '+OffsetSize));
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'QueryLimit '+QueryLimit));      

            // Main Query
            query='SELECT ';

            for(Schema.FieldSetMember f : this.getFields()) {
                query += f.getFieldPath() + ', ';
            }
            query+= 'Id FROM ACCOUNT WHERE (ERP_Customer_Number__c != \'\' AND ERP_Customer_Number__c != null) and ERP_Company_Code__c != \'\' ';

            if(String.isNotBlank(ConfigId))
                query+=' and Integration_Key__c = \''+ String.escapeSingleQuotes(ConfigId) +'\'';

            if(String.isNotBlank(FromAccount))
                query+=' and Name >= \''+ String.escapeSingleQuotes(FromAccount) +'\''; 

            if(String.isNotBlank(ToAccount))
                query+=' and (Name < \''+ String.escapeSingleQuotes(ToAccount) +'\' or Name like \''+ String.escapeSingleQuotes(ToAccount) +'%\')';

            query+='ORDER BY Name limit '+ QueryLimit +' offset '+ OffsetSize +'';
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'query '+query));

            list<Account> lstAccounts=Database.Query(query);
           
            Accounts=new list<Account>();

            if(lstAccounts.size()>0)
            {
                for(Account A : lstAccounts)
                {
                    Accounts.add(A);
                    this.totalRecords++;
                }
            }

            //calculate total pages
            this.totalRecords=this.CountTotalRecords;
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,'totalRecords '+totalRecords));
            
            Decimal pages = Decimal.valueOf(this.CountTotalRecords);
            pages = pages.divide(Decimal.valueOf(PAGE_SIZE), 2);
            this.totalPages = (Integer)pages.round(System.RoundingMode.CEILING);

            //adjust start index e.g. 1, 11, 21, 31
            this.startIdx++;

            //adjust end index
            if(this.endIdx>this.totalRecords)
            {
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
            GUMUException exc= new GUMUException('UnlinkAccountController','GetLinkedAccounts',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }    
        return null;   
    }

    // Clear All Account List.
    public Pagereference ClearAll()
    {
        this.Accounts=new list<Account>();
        return null;
    }

    // Get Unlink Customers.
    @RemoteAction
    public static boolean UnlinkCustomers(list<string> Accs)
    {
       
        try
        {
            //check Account field level security 
             if (!Schema.sObjectType.Account.fields.ERP_Customer_Number__c.isUpdateable() 
                || !Schema.sObjectType.Account.fields.Integration_Key__c.isUpdateable()
                || !Schema.sObjectType.Account.fields.ERP_Company_Code__c.isUpdateable())
            {
              return false;
            }
            
            //check Contacts field level security 
            if (!Schema.sObjectType.Contact.fields.ERP_Contact_Code__c.isUpdateable())
            {
              return false;
            }
            
            if (!Schema.sObjectType.Contact.fields.ERP_Contact_Code__c.isAccessible())
            {
              return false;
            }
            
            //check ShipTo field level security 
            if (!Schema.sObjectType.Ship_To__c.fields.Integration_Key__c.isUpdateable())
            {
              return false;
            }
            if (!Schema.sObjectType.Ship_To__c.fields.Integration_Key__c.isAccessible())
            {
              return false;
            }
            
            list<Account> Acts=new list<Account>();
            List<Contact> contactList = new list<Contact>();
            List<Ship_To__c> ShipToList = new list<Ship_To__c>();

            Set<Id> records = new Set<Id>();

            for(string AccId : Accs)
            {
                Account A=new Account();
                A.Id=AccId;
                A.ERP_Customer_Number__c='';
                A.Integration_Key__c='';
                A.ERP_Company_Code__c='';
                Acts.add(A);                
                records.add(AccId);
            }

            List<Contact> lstContact = [SELECT Id, ERP_Contact_Code__c
                                        FROM Contact 
                                        WHERE AccountId IN :records];

            // Unlink Contact Records
            for(Contact cnt : lstContact)
            {
                Contact C = new Contact();
                C.Id=cnt.Id;
                C.ERP_Contact_Code__c='';
                contactList.add(C);
            }            
            List<Ship_To__c> lstShipTo = [SELECT Id, Integration_Key__c
                                          FROM Ship_To__c 
                                          WHERE Account_Id__c IN :records];

            // Unlink Ship To Records
            for(Ship_To__c shipto : lstShipTo )
            {
                Ship_To__c SH = new Ship_To__c();
                SH.Id=shipto.Id;
                SH.Integration_Key__c='';
                ShipToList.add(SH);
            }
            
            Utility.bRunTrigger =false;

            if(Acts.size() > 0)
                update Acts;

            if(contactList.size() > 0)
                update contactList;

            if(ShipToList.size() > 0)
                update ShipToList;
                
           Utility.bRunTrigger =true;

            return true;    
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('UnlinkAccountController','UnlinkCustomers',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
            return false;
        }
    }
}
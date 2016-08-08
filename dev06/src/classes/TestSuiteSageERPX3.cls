@isTest(SeeAllData=false)
private class TestSuiteSageERPX3 
{
    static testMethod void ERPAdministration() 
    {
        //-------------------ConfigurationListController------------------------- 
        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;
        
        //Create profile        
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];

        // create User
        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');
        insert testUser;

        //create record for Security_Matrix__c
        Security_Matrix__c securityMatrix = new Security_Matrix__c(); 
        securityMatrix.name = 'SM001';
        securityMatrix.GUMU_Administration__c=true;
        securityMatrix.Promote_Customer__c=true;
        securityMatrix.Promote_Order__c=true;
        securityMatrix.Update_Customer__c=true;
        securityMatrix.ERP_Details__c=true;
        insert securityMatrix;
        System.assertEquals('SM001',securityMatrix.name);
        

        //inserting data into app setting

        GUMU_App_Setting__c app = new GUMU_App_Setting__c();

        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage ERP X3';
        app.ERP_System__c='SageERPX3';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;

        

        //creating record for PasswordSetting__c

        PasswordSetting__c pass = new PasswordSetting__c();
        pass.name = 'Pass001';
        pass.Password_Key__c = '123456789012345678901234'; 
        insert pass; 

        // intialize Configurationlist controller           
        sObject sObj = Schema.getGlobalDescribe().get('GUMU_Lite__ERP_Config__c').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        ConfigurationListController ConfigList = new ConfigurationListController(StdCntlr);

        // calling PageReference ConfigDetails
        ApexPages.currentPage().getParameters().put('ConID',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','Edit');
        PageReference PageRef= ConfigList.ConfigDetails();

        ApexPages.currentPage().getParameters().put('Mode','New');
        PageRef= ConfigList.ConfigDetails();

        //calling deleteConfiguration pageRefernece method
        ApexPages.currentPage().getParameters().put('ConID',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','Delete');
        PageRef =ConfigList.deleteConfiguration();

        ConfigList.ERPSystem='';
        ConfigList.ConfigObjectPrefix='';
        
        //---------------------------------AdministrationController---------------------------
        AdministrationController Administration= new AdministrationController();

        //-------------------ConfigurationListController-------------------------End

        //-------------------ConfigurationController--------------------------------
        
        Entity__c objEmap = new Entity__c();
        objEmap.Entity_Code__c='ProspectContact123';
        objEmap.API_Method__c='YGTCUSTDTL';
        objEmap.Integration_Key__c = Config.Id;         
        insert objEmap;

        //calling FetchConfig
        Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED1';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;

        //intialize Configuration controller   

        sObj = Schema.getGlobalDescribe().get('GUMU_Lite__ERP_Config__c').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);

        ApexPages.currentPage().getParameters().put('Id',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','View');
        ConfigurationController ConfigCntlr = new ConfigurationController(StdCntlr); 

        ApexPages.currentPage().getParameters().put('Id',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','Edit');
        ConfigCntlr = new ConfigurationController(StdCntlr);

        ApexPages.currentPage().getParameters().put('Id',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','New');
        ConfigCntlr = new ConfigurationController(StdCntlr);

        //calling PageReference enableButtons
        ApexPages.currentPage().getParameters().put('Id',Config.Id);
        PageRef= ConfigCntlr.enableButtons();

        //calling getAvailableERPs methods
        list<ERP_Config__c> ERPlist = ConfigCntlr.getAvailableERPs();

        //calling getAvailableERPs methods
        ConfigCntlr.LoadParams();

        //calling getIsERPConfigSettingExist
        boolean isERPExist = ConfigCntlr.getIsERPConfigSettingExist();

        //calling RequiredComapnyParams
        ConfigCntlr.ERPSystem = Config.ERP_System__c;
        PageRef= ConfigCntlr.RequiredComapnyParams();

        //calling TestConnection
        ConfigCntlr.PageAction='Test&Save';
        ConfigCntlr.WebServiceURL=Config.Web_Service_URL__c;
        ConfigCntlr.ConfigurationInfo='{"Name":"Integration-SEED","WebServiceURL":"http://49.248.14.236:28880/adxwsvc/services/CAdxWebServiceXmlCC","IntegrationInformation":"<PARAMS><PARAM NAME=\"poolAlias\" VALUE=\"SEED\"/><PARAM NAME=\"codeUser\" VALUE=\"ADMIN\"/><PARAM NAME=\"password\" VALUE=\"\"/><PARAM NAME=\"poolId\" VALUE=\"SEED\"/><PARAM NAME=\"codeLang\" VALUE=\"ENG\"/><PARAM NAME=\"version\" VALUE=\"171\"/></PARAMS>","Inactive":false,"Default":false,"ERPSystem":"SageERPX3","CompanyCode":"SEED","Synchronization":"Both"}';

        ConfigCntlr.ConParams='["poolAlias=SEED","codeUser=ADMIN","password=","poolId=SEED","codeLang=ENG","version=171"]';
        PageRef= ConfigCntlr.TestConnection();

        ConfigurationController.configuration configuration = ConfigurationController.FetchConfig(Config.Id);

        //calling CRUDConfig method
        Map<String,String> Info=new Map<string,string>();

        Info.put('Name','Integration-SEED2');
        Info.put('WebServiceURL','https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC');
        Info.put('IntegrationInformation','<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>');
        Info.put('Inactive','false');
        Info.put('Default','true');
        Info.put('ERPSystem','SageERPX3');
        Info.put('CompanyCode','SAMINC');       
        boolean crud = ConfigCntlr.CRUDConfig(Config.Id,'Insert',Info);

        //calling GetERPName
        ConfigCntlr.IntegrationKey = Config.Id;
        PageRef= ConfigCntlr.GetERPName();

        //calling classes
        list<string> option = new list<string>();
        option.add('abc'); 
        ConfigurationController.Param PR = new ConfigurationController.Param();
        PR.ParamName = 'ABC';
        PR.ParamCode = 'ABC';
        PR.Length = 50;
        PR.Width = 50;
        PR.ParamType = 'Text';
        PR.Required = true;
        PR.Options = option;

        list<ConfigurationController.Param> PRList = new list<ConfigurationController.Param>();

        ConfigurationController.ERP erp = new ConfigurationController.ERP();
        erp.ERPName = Config.ERP_System__c;
        erp.Params = PRList;
        //calling doCancel
        PageRef= ConfigCntlr.doCancel();

        ConfigCntlr.ConfigObjectPrefix='';
        ConfigCntlr.UpdateDate=System.today();
        ConfigCntlr.NameSpace='';
        ConfigCntlr.ConfigurationId='';
        ConfigCntlr.ConfigurationInfo='';
        ConfigCntlr.isSelected=true;
        
        //-------------------ConfigurationController--------------------------------End


        //-------------------HomeSettingController------------------------------------

        HomeSettingController HomeStncntlr = new HomeSettingController();
        HomeStncntlr.AppItemMenu();
        //-------------------HomeSettingController------------------------------------  End

        //-------------------SecurityMatrixController------------------------------------

        securityMatrix = new Security_Matrix__c();
        securityMatrix.name = 'SM002';
        securityMatrix.GUMU_Administration__c=true;
        securityMatrix.Promote_Customer__c=true;
        securityMatrix.Promote_Order__c=true;
        securityMatrix.Update_Customer__c=true;
        securityMatrix.ERP_Details__c=true;
        //insert securityMatrix;

        SecurityMatrixController SecurityMatrixCnt = new SecurityMatrixController();

        PageRef=SecurityMatrixCnt.CreateRecords();

        SecurityMatrixCnt.secLevel='User';
        PageRef=SecurityMatrixCnt.CreateRecords();

        SecurityMatrixCnt.FindSecurityFields();

        list<map<string,string>> sMatrixList = new list<map<string,string>>();
        map<string,string> sMatrix = new map<string,string>();       
        sMatrix.put('ERP_Details','false');
        sMatrix.put('GUMU_Administration','false');
        sMatrix.put('Id','');
        sMatrix.put('Promote_Customer','false');
        sMatrix.put('Promote_Order','false');
        sMatrix.put('Update_Customer','false');
        sMatrix.put('OwnerId',p.Id);
        sMatrixList.add(sMatrix);

        sMatrix = new map<string,string>();       
        sMatrix.put('ERP_Details','true');
        sMatrix.put('GUMU_Administration','true');
        sMatrix.put('Id','');
        sMatrix.put('Promote_Customer','true');
        sMatrix.put('Promote_Order','true');
        sMatrix.put('Update_Customer','true');
        sMatrix.put('OwnerId',p.Id);
        sMatrixList.add(sMatrix);

        boolean issuccess =SecurityMatrixController.SaveSecurityMatrix(sMatrixList,'Profile',true);
        issuccess =SecurityMatrixController.SaveSecurityMatrix(sMatrixList,'Profile',false);

        PageRef=SecurityMatrixCnt.cancelChanges();       

        //-------------------SecurityMatrixController------------------------------------  End

        //-------------------LinkAccountController----------------------------------------

        LinkAccountController linkAccountCntlr = new LinkAccountController();
        linkAccountCntlr.getItems();
        linkAccountCntlr.doNext();
        linkAccountCntlr.getFields();
        linkAccountCntlr.doPrevious();
        linkAccountCntlr.getHasPrevious();

        PageRef=linkAccountCntlr.GetUnlinkAccounts();

        Account a = new Account();
        a.ERP_Customer_Number__c = '3GNEW';
        a.Integration_Key__c='';   
        a.ERP_Company_Code__c='SAMINC';
        a.Name = 'ES021';
        insert a;

        list<map<string,string>> lstAccounts  = new list<map<string,string>>();
        map<string,string> Accounts  = new map<string,string>();
        Accounts.put('AccountKey',a.Id);
        Accounts.put('IntegrationKey',Config.Id);
        Accounts.put('LinkedCustomer','ES021');
        lstAccounts.add(Accounts);

        a = new Account();
        a.ERP_Customer_Number__c = 'ES022';
        a.Integration_Key__c='';   
        a.ERP_Company_Code__c='SAMINC';
        a.Name = 'ES022';
        insert a;

        Contact c = new Contact();
        c.AccountId= a.Id;
        c.LastName= 'XYZ';
        insert c;

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= a.Id;
        insert objShipto;

        Accounts  = new map<string,string>();
        Accounts.put('AccountKey',a.Id);
        Accounts.put('IntegrationKey',Config.Id);
        Accounts.put('LinkedCustomer','ES022');
        lstAccounts.add(Accounts);
        issuccess=LinkAccountController.SaveLinkCustomer(lstAccounts);

        test.starttest();
        SageX3IntegrationFramework  integrationFramework = new SageX3IntegrationFramework();
        integrationFramework.GetFieldForAutoMatch();
        ApexPages.currentPage().getParameters().put('MatchingCriteriaValue','Edge Communications');
        ApexPages.currentPage().getParameters().put('MatchingCriteriaOpt','EqualTo');
        ApexPages.currentPage().getParameters().put('ConfigId',Config.Id);
        ApexPages.currentPage().getParameters().put('MatchingCriteria','fncOpenmatchingList');          
        PageRef=linkAccountCntlr.CustomerList();

        ApexPages.currentPage().getParameters().put('MatchingCriteriaValue','Edge Communications');
        ApexPages.currentPage().getParameters().put('MatchingCriteriaOpt','');
        ApexPages.currentPage().getParameters().put('ConfigId',Config.Id);
        ApexPages.currentPage().getParameters().put('MatchingCriteria','fncOpenmatchingList');
        PageRef=linkAccountCntlr.CustomerList();

        

        lstAccounts  = new list<map<string,string>>();
        Accounts  = new map<string,string>();
        Accounts.put('AccountKey',a.Id);
        Accounts.put('IntegrationKey',Config.Id);
        Accounts.put('MatchingCriteria','AC.CustomerName');
        Accounts.put('MatchingCriteriaValue','ES022');
        lstAccounts.add(Accounts);
        list<LinkAccountController.MatchCustomer>MatchCustomer =  LinkAccountController.GetERPCustomer(lstAccounts);


        ApexPages.currentPage().getParameters().put('CustomerNo','ES022');
        ApexPages.currentPage().getParameters().put('ConfigId',Config.Id);
        PageRef=linkAccountCntlr.ExistingLinkcustomer();

        String existcust =LinkAccountController.GetExistingLinkcustomer(Config.Id, 'ES022');

        linkAccountCntlr.getHasNext();

        LinkAccountController.UnlinkAccounts unlinkcust= new LinkAccountController.UnlinkAccounts();
        unlinkcust.Id = '';
        unlinkcust.AccountNumber='';
        unlinkcust.AccountName='';
        unlinkcust.BillingCity='';
        unlinkcust.BillingState='';
        unlinkcust.BillingCountry='';
        unlinkcust.ConfigId='';
        unlinkcust.Index='';

        LinkAccountController.MatchCustomer MC = new LinkAccountController.MatchCustomer();
        MC.AccountId = '';
        MC.CustomerNumber='';
        MC.CustomerName='';

        LinkAccountController.Customer cust = new LinkAccountController.Customer();
        cust.UniqueKey='';
        cust.ARDivisionNo='';
        cust.CustomerName = '';

        linkAccountCntlr.FirstName='';
        linkAccountCntlr.LastName='';
        linkAccountCntlr.SalesObjectPrefix='';
        linkAccountCntlr.lstAccounts=null;
        linkAccountCntlr.Criteria='';

        linkAccountCntlr.QueryLimit=null;
        linkAccountCntlr.getItems();
        linkAccountCntlr.doNext();
        linkAccountCntlr.getFields();
        linkAccountCntlr.doPrevious();

        linkAccountCntlr.OffsetSize=1;
        linkAccountCntlr.QueryLimit=0;
        linkAccountCntlr.getHasPrevious();
        linkAccountCntlr.getHasNext();

        linkAccountCntlr.PAGE_SIZE=null;
        linkAccountCntlr.FromAccount='Test';
        linkAccountCntlr.ToAccount='Test';
        PageRef=linkAccountCntlr.GetUnlinkAccounts();

        //-------------------LinkAccountController----------------------------------------End

        //-------------------UnlinkAccountController----------------------------------------

        UnlinkAccountController unlinkAccCntlr = new UnlinkAccountController();
        unlinkAccCntlr.doNext();
        unlinkAccCntlr.doPrevious();
        unlinkAccCntlr.getFields();
        unlinkAccCntlr.getHasPrevious();
        unlinkAccCntlr.getHasNext();

        unlinkAccCntlr.ConfigId = Config.Id;
        unlinkAccCntlr.FromAccount = 'ES021';
        unlinkAccCntlr.ToAccount ='ES022';
        PageRef=unlinkAccCntlr.GetLinkedAccounts();

        PageRef=unlinkAccCntlr.ClearAll();

        list<string> Accs = new list<string>();
        Accs.add(a.Id);     
        issuccess = UnlinkAccountController.UnlinkCustomers(Accs);

        Accs = new list<string>();
        Accs.add('ES021');    
        issuccess = UnlinkAccountController.UnlinkCustomers(Accs);

        unlinkAccCntlr.QueryLimit=null;
        unlinkAccCntlr.doPrevious();
        unlinkAccCntlr.doNext();

        unlinkAccCntlr.OffsetSize=1;
        unlinkAccCntlr.getHasPrevious();

        delete a;
        unlinkAccCntlr.totalRecords=0;
        PageRef=unlinkAccCntlr.GetLinkedAccounts();

        //unlinkAccCntlr.totalRecords=null;
        //PageRef=unlinkAccCntlr.GetLinkedAccounts();

        //-----------------------------SalesPersonMappingCntlr-------------------------------------------------


        Salesperson__c SP = new Salesperson__c();
        SP.Salesperson_Code__c = '0100';
        SP.Integration_Key__c =  Config.Id;
        SP.Salesperson_Description__c =  'Jim Kentley';
        insert SP;

        Salesperson_Mapping__c SPMapping = new Salesperson_Mapping__c();
        SPMapping.User_Id__c=testUser.Id;
        SPMapping.Salesperson_Id__c = SP.Id;
        SPMapping.Integration_Key__c = Config.Id;
        insert SPMapping;

        sObj = Schema.getGlobalDescribe().get('GUMU_Lite__Salesperson_Mapping__c').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);   
        SalesPersonMappingCntlr salesPersonMapping = new SalesPersonMappingCntlr(StdCntlr);

        salesPersonMapping.profileIds = new Map<id,profile>([SELECT Id,UserLicenseId FROM Profile where UserLicenseId  in (SELECT Id FROM UserLicense where name in('Salesforce','Salesforce Platform'))]);

        PageRef=salesPersonMapping.GetUserMapping();
        PageRef=salesPersonMapping.SearchUser();
        PageRef=salesPersonMapping.GetSalespersonCode();
        PageRef=salesPersonMapping.AutoMap();

        list<map<string,string>> lstMapping = new list<map<string,string>>();
        map<string,string> Mapping = new map<string,string>();

        Mapping.put('SalespersonId',sp.Id);
        Mapping.put('UserId',testUser.Id);
        Mapping.put('MappingId','');
        lstMapping.add(Mapping);

        SalesPersonMappingCntlr.SaveMapping(lstMapping);
        //test.stoptest();
        //test.starttest();
        SalesPersonMappingCntlr.UserMapping UM = new SalesPersonMappingCntlr.UserMapping(); 
        UM.ConfigId = Config.Id;
        UM.MappingId = SPMapping.Id;
        UM.SFEmail = 'salesforce@greytrix.com';
        UM.SFFirstName = 'Dev';
        UM.SFLastName = 'User 001';
        UM.SFUserID = 'User 001';
        UM.SFUsername = 'User 001';

        salesPersonMapping.Mappings.add(UM);


        salesPersonMapping.ConfigId=Config.Id;
        salesPersonMapping.FirstName = 'test';
        salesPersonMapping.LastName = 'test';
        PageRef=salesPersonMapping.GetUserMapping();
        PageRef=salesPersonMapping.SearchUser();
        PageRef=salesPersonMapping.AutoMap();
        test.stoptest();
    }

    static testMethod void EntitySetting() 
    {
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];

        // create User
        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');
        insert testUser;

        //create record for Security_Matrix__c
        Security_Matrix__c securityMatrix = new Security_Matrix__c(); 
        securityMatrix.name = 'SM001';
        securityMatrix.GUMU_Administration__c=true;
        insert securityMatrix;

        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c();
        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage ERP X3';
        app.ERP_System__c='SageERPX3';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;

        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SageERPX3', Config.ERP_System__c);
        

        //-------------------------------------------EntityListController-----------------------------------Start
        EntityListController entitylist = new EntityListController();

        Entity__c objEmap = new Entity__c();
        objEmap.Entity_Code__c='ProspectContact123';
        objEmap.API_Method__c='YGTCUSTDTL';
        objEmap.Integration_Key__c = Config.Id;         
        insert objEmap;

        entitylist.doNext();
        entitylist.doPrevious();
        entitylist.getHasPrevious();
        entitylist.getHasNext();
        pageReference pRef = entitylist.RedirectPage();
        pRef = entitylist.RedirectNewPage();

        ApexPages.currentPage().getParameters().put('Id',objEmap.Id);
        ApexPages.currentPage().getParameters().put('Action','Edit');
        pRef = entitylist.RedirectPage();
        pRef = entitylist.deleteRecord();

        entitylist.selectedERP = 'All';
        pRef = entitylist.GetEntityMappings();
        entitylist.OffsetSize = 2;
        entitylist.getHasPrevious();
        //-------------------------------------------EntityListController-----------------------------------End

        //-------------------------------------------EntityController-----------------------------------Start

        objEmap = new Entity__c();
        objEmap.Entity_Code__c='ProspectContact';
        objEmap.API_Method__c='YGTCUSTDTL';
        objEmap.Integration_Key__c = Config.Id;         
        insert objEmap;

        Entity_Detail__c entityDtl = new Entity_Detail__c();
        entityDtl.Name = 'Website123';
        entityDtl.Data_Type__c = 'Char';
        entityDtl.Field_APIName__c='Website123';
        entityDtl.Field_Label__c='';
        entityDtl.Values__c ='';
        entityDtl.Source_Type__c=''; 
        entityDtl.Group_Name__c ='ABC';
        entityDtl.Entity_Id__c = objEmap.Id;
       // entityDtl.External_UId__c = 'Website123-abc';
        insert entityDtl; 

        Entity_Key__c EntityKey = new Entity_Key__c();
        EntityKey.Entity_Id__c= objEmap.Id; 
        EntityKey.Key_Field__c='ABC';
        EntityKey.Key_Order__c = 1;
        EntityKey.isSyncKey__c = true;
        insert EntityKey;  

        ApexPages.currentPage().getParameters().put('Id',objEmap.Id);
        sObject sObj = Schema.getGlobalDescribe().get('GUMU_Lite__Entity__c').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        EntityController Entity = new EntityController(StdCntlr); 

        Entity.RefereshDetail();
        pRef = Entity.SaveSourceField();
        Entity.AddMaintainanceKeyRow();
        Entity.RemoveKeyRow();       
        pRef = Entity.CancelUpsert();
        pRef = Entity.EditRecord();
        pRef = Entity.deleteRecord();

        //-------------------------------------------EntityController-----------------------------------End

        //-------------------------------------------EntityMappingController-----------------------------------Start

        EntityMappingController EntityMapping = new EntityMappingController();
        EntityMapping.doNext();
        EntityMapping.doPrevious();
        EntityMapping.getHasPrevious();
        EntityMapping.getHasNext();
        pRef =EntityMapping.GetEntityMappings();
        EntityMapping.SyncNow();
        EntityMapping.getMessage();
        EntityMapping.SyncNow();
        EntityMapping.RedirectPage();
        EntityMapping.RedirectNewPage();
        EntityMapping.deleteRecord();

        objEmap = new Entity__c();
        objEmap.Entity_Code__c='ProspectContact';
        objEmap.API_Method__c='YGTCUSTDTL';
        objEmap.Integration_Key__c = Config.Id;         
        insert objEmap;

        Entity_Mapping_Header__c Entity_Mapping_Header = new Entity_Mapping_Header__c();
        //Entity_Mapping_Header.name = 'SageX3Customer';
        Entity_Mapping_Header.Source_Entity__c='YGTCUSTDTL';
        Entity_Mapping_Header.Integration_Key__c=Config.Id;
        Entity_Mapping_Header.Target_Entity__c = 'Account';
        Entity_Mapping_Header.Entity_Id__c = objEmap.Id;
        Entity_Mapping_Header.Active__c = true;
        Entity_Mapping_Header.Sync_Type__c='System';
        insert Entity_Mapping_Header;

        ApexPages.currentPage().getParameters().put('Id',Entity_Mapping_Header.Id);
        EntityMapping.deleteRecord();
        //-------------------------------------------EntityMappingController-----------------------------------End

        //-------------------------------------------ImporterMaintenanceController-----------------------------------Start
        delete Entity_Mapping_Header;
        objEmap = new Entity__c();
        objEmap.Entity_Code__c='Customer';
        objEmap.API_Method__c='YGTCUSTDTL';
        objEmap.Integration_Key__c = Config.Id;         
        insert objEmap;

        entityDtl = new Entity_Detail__c();
        entityDtl.Name = 'Website123';
        entityDtl.Data_Type__c = 'Char';
        entityDtl.Field_APIName__c='Website123';
        entityDtl.Field_Label__c='';
        entityDtl.Values__c ='';
        entityDtl.Source_Type__c=''; 
        entityDtl.Group_Name__c ='ABC';
        entityDtl.Entity_Id__c = objEmap.Id;
        //entityDtl.External_UId__c = 'Website123-abc';
        insert entityDtl; 

        Entity_Mapping_Header = new Entity_Mapping_Header__c();
        //Entity_Mapping_Header.name = 'SageX3Prospect';
        Entity_Mapping_Header.Source_Entity__c='YGTPROSDTL';
        Entity_Mapping_Header.Integration_Key__c=Config.Id;
        Entity_Mapping_Header.Target_Entity__c = 'Account';
        Entity_Mapping_Header.Entity_Id__c = objEmap.Id;
        Entity_Mapping_Header.Active__c = true;
        Entity_Mapping_Header.Sync_Type__c='System';
        Entity_Mapping_Header.Schedule_Start__c=system.today();
        Entity_Mapping_Header.Schedule_Type__c = 'Daily';
        insert Entity_Mapping_Header;

        Entity_Fields_Mapping_Detail__c EntityFieldsMappingDetail = new Entity_Fields_Mapping_Detail__c(); 
        EntityFieldsMappingDetail.Data_Type__c = 'string';
        EntityFieldsMappingDetail.Entity_Mapping_Id__c = Entity_Mapping_Header.Id;
        EntityFieldsMappingDetail.ERP_Field__c = 'BPCNUM';
        EntityFieldsMappingDetail.IsSync__c = true;
        EntityFieldsMappingDetail.Salesforce_Field__c = 'ERP_Customer_Number__c';
        EntityFieldsMappingDetail.Salesforce_Field_Label__c = 'Customer No';
        EntityFieldsMappingDetail.Default_Value__c= '';
        insert  EntityFieldsMappingDetail;

        Entity_Fields_Map_Parent__c Entity_Fields_Map_Parent = new Entity_Fields_Map_Parent__c();
        Entity_Fields_Map_Parent.Source_Field__c='ARDivisionNo';
        Entity_Fields_Map_Parent.Target_Field__c ='Account_Id__c';
        Entity_Fields_Map_Parent.Parent_Object_Name__c ='Account';
        Entity_Fields_Map_Parent.IsSync__c =false;
        Entity_Fields_Map_Parent.Order__c=1;
        Entity_Fields_Map_Parent.Entity_Fields_Map_Header_Id__c =  Entity_Mapping_Header.Id;
        insert Entity_Fields_Map_Parent;

        Entity_Sync_Filteration__c EntitySyncFilteration = new Entity_Sync_Filteration__c();
        EntitySyncFilteration.Active__c=true;
        EntitySyncFilteration.Entity_Mapping_Header_Id__c=Entity_Mapping_Header.Id;
        EntitySyncFilteration.Field__c='BPCNUM';
        EntitySyncFilteration.Operator__c='Equal';
        EntitySyncFilteration.Value__c='Na002';
        EntitySyncFilteration.IsSync__c=true;
        insert EntitySyncFilteration;

        ImporterMaintenanceController ImporterMaintenance1 = new ImporterMaintenanceController(Entity_Mapping_Header.Id,'0');

        ApexPages.currentPage().getParameters().put('Id',Entity_Mapping_Header.Id);
        //ApexPages.currentPage().getParameters().put('Action','Clone');
        sObj = Schema.getGlobalDescribe().get('GUMU_Lite__Entity_Mapping_Header__c').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        ImporterMaintenanceController ImporterMaintenance = new ImporterMaintenanceController(StdCntlr);

        ImporterMaintenance.RefereshDetail();
        pRef=ImporterMaintenance.SaveSourceField();
        pRef=ImporterMaintenance.CloneRecord();
        ImporterMaintenance.cloneExistingRecords();
        ImporterMaintenance.ImportNow();       
        ImporterMaintenance.AddFilterRow();
        ImporterMaintenance.RemoveFilterRow();
        ImporterMaintenance.AddParentRow();
        ImporterMaintenance.RemoveParentRow();
        ImporterMaintenance.getMessage();
        pRef=ImporterMaintenance.RedirectOncancel();
        pRef=ImporterMaintenance.EditMapping();
        pRef=ImporterMaintenance.clearLog();
        pRef=ImporterMaintenance.deleteRecord(); 
        SObject newsObj = ImporterMaintenance.getNewSobject('Account'); 


        ApexPages.currentPage().getParameters().put('Id',Entity_Mapping_Header.Id);
        ApexPages.currentPage().getParameters().put('Action','Clone');
        sObj = Schema.getGlobalDescribe().get('GUMU_Lite__Entity_Mapping_Header__c').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        ImporterMaintenanceController ImporterMaintenance2 = new ImporterMaintenanceController(StdCntlr);
        ImporterMaintenance2.FAILCOUNT = '';
        ImporterMaintenance2.NextRec= '';
        ImporterMaintenance2.ErrorMessage= '';
        ImporterMaintenance2.IntegrationKey   = '';

        Entity_Mapping_Header__c  Entity_Mapping_Header1 = new Entity_Mapping_Header__c();
       // Entity_Mapping_Header1.name = 'SageX3Prospect';
        Entity_Mapping_Header1.Source_Entity__c='YGTPROSDTL';
        Entity_Mapping_Header1.Integration_Key__c=Config.Id;
        Entity_Mapping_Header1.Target_Entity__c = '';
        Entity_Mapping_Header1.Entity_Id__c = objEmap.Id;
        Entity_Mapping_Header1.Active__c = true;
        Entity_Mapping_Header1.Sync_Type__c='System';
        ImporterMaintenance2.Entity_Mapping_Header = Entity_Mapping_Header1;
        ImporterMaintenance.RefereshDetail();
        pRef=ImporterMaintenance.SaveSourceField();
    }

    static testMethod void promoteCustomer_Addresses()
    {

        Profile p = [select id from profile where Name = 'System Administrator' limit 1];

        // create User
        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');
        insert testUser;

        //create record for Security_Matrix__c
        Security_Matrix__c securityMatrix = new Security_Matrix__c(); 
        securityMatrix.name = 'SM001';
        securityMatrix.Promote_Customer__c=true;
        securityMatrix.Update_Customer__c = true;
        insert securityMatrix;

        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c();
        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage ERP X3';
        app.ERP_System__c='SageERPX3';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;

        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SageERPX3',Config.ERP_System__c);

        //---------------------------------------PromoteCustomerController-------------------------Start

        Account act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';
        act.Integration_Key__c='';   
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';
        act.Integration_Key__c = Config.Id;
        insert act;

        Contact cnt = new Contact();
        cnt.AccountId= act.Id;
        cnt.LastName= 'son';
        cnt.FirstName= 'john';
        insert cnt;

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= act.Id;
        insert objShipto;

        sObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        PromoteCustomerController PromoteCustomer = new PromoteCustomerController(StdCntlr);
        PromoteCustomer.getPromoteCustomer();
        
        PromoteCustomer.ERPSytemName = 'Sage100ERP';
        PromoteCustomer.getPromoteCustomer();
        
        PromoteCustomer.ERPSytemName = 'Sage300ERP';
        PromoteCustomer.getPromoteCustomer();
        
        PromoteCustomer.ERPSytemName = 'Sage500ERP';
        PromoteCustomer.getPromoteCustomer();
        //---------------------------------------PromoteCustomerController-------------------------end

        //----------------------------------------------PromoteCustomerX3Controller---------------start

        ApexPages.currentPage().getParameters().put('Id',act.Id);
        PromoteCustomerX3Controller PromoteCustomerX3= new PromoteCustomerX3Controller(StdCntlr);
        PageReference pRef=PromoteCustomerX3.UnlinkAccount();

        Salesperson__c SP = new Salesperson__c();
        SP.Salesperson_Code__c = '0100';
        SP.Integration_Key__c =  Config.Id;
        SP.Salesperson_Description__c =  'Jim Kentley';
        insert SP;

        Salesperson_Mapping__c SPMapping = new Salesperson_Mapping__c();
        SPMapping.User_Id__c=UserInfo.getUserId();
        SPMapping.Salesperson_Id__c = SP.Id;
        SPMapping.Integration_Key__c = Config.Id;
        insert SPMapping;

        pRef=PromoteCustomerX3.AssignSalesperson();
        pRef=PromoteCustomerX3.PromoteCustomer_X3();
        string TestResponseData='<?xml version="1.0" encoding="UTF-8"?> <RESULT> <GRP ID="BPC0_1"> <FLD NAME="BCGCOD" TYPE="Char">SIT</FLD> <FLD NAME="ZBCGCOD" TYPE="Char">Intersite customers</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCSTA" TYPE="Integer">2</FLD> <FLD NAME="BPCNUM" TYPE="Char">NA011</FLD> <FLD NAME="BPCNAM" TYPE="Char">Computer Products</FLD> </GRP> <GRP ID="BPRC_1"> <FLD NAME="BPRSHO" TYPE="Char">Computer P</FLD> <FLD NAME="BPRLOG" TYPE="Char">Computer P</FLD> <LST NAME="BPRNAM" SIZE="1" TYPE="Char"> <ITM>Computer Products</ITM> </LST> <FLD MENULAB="No" MENULOCAL="1" NAME="LEGETT" TYPE="Integer">1</FLD> <FLD NAME="CRY" TYPE="Char">US</FLD> <FLD NAME="ZCRY" TYPE="Char">United States of America</FLD> <FLD NAME="LAN" TYPE="Char">ENG</FLD> <FLD NAME="ZLAN" TYPE="Char">English - American</FLD> <FLD NAME="CRN" TYPE="Char" /> <FLD NAME="NAF" TYPE="Char" /> <FLD NAME="EECNUM" TYPE="Char" /> <FLD NAME="CUR" TYPE="Char">USD</FLD> <FLD NAME="ZCUR" TYPE="Char">US Dollar</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="BPRFBDMAG" TYPE="Integer">1</FLD> </GRP> <GRP ID="BPRC_2"> <FLD MENULAB="Yes" MENULOCAL="1" NAME="BETFCY" TYPE="Integer">2</FLD> <FLD NAME="FCY" TYPE="Char">NA011</FLD> <FLD NAME="ZFCY" TYPE="Char">Computer Products</FLD> </GRP> <GRP ID="BPRC_3"> <FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCFLG" TYPE="Integer">2</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="REPFLG" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="PPTFLG" TYPE="Integer">1</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="BPSFLG" TYPE="Integer">2</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="BPRACC" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="PRVFLG" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="BPTFLG" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="DOOFLG" TYPE="Integer">1</FLD> </GRP> <GRP ID="BPAC_5"> <FLD NAME="NUMBPA" TYPE="Integer">1</FLD> <FLD NAME="IDENT" TYPE="Char">1NA011</FLD> <FLD NAME="TRTBPAB" TYPE="Char" /> </GRP> <TAB DIM="30" ID="BPAC_1" SIZE="1"> <LIN NUM="1"> <FLD NAME="CODADR" TYPE="Char">AD1</FLD> <FLD NAME="BPADES" TYPE="Char">Corporate</FLD> <FLD NAME="BPACRY" TYPE="Char">US</FLD> <FLD NAME="CRYNAM" TYPE="Char">United States of America</FLD> <FLD NAME="ADDLIG1" TYPE="Char">6511 Irvine Center Drive</FLD> <FLD NAME="ADDLIG2" TYPE="Char" /> <FLD NAME="ADDLIG3" TYPE="Char" /> <FLD NAME="POSCOD" TYPE="Char">92618</FLD> <FLD NAME="CTY" TYPE="Char">Irvine</FLD> <FLD NAME="SAT" TYPE="Char">CA</FLD> <FLD NAME="TEL1" TYPE="Char" /> <FLD NAME="TEL2" TYPE="Char" /> <FLD NAME="TEL3" TYPE="Char" /> <FLD NAME="TEL4" TYPE="Char" /> <FLD NAME="TEL5" TYPE="Char" /> <FLD NAME="WEB1" TYPE="Char" /> <FLD NAME="WEB2" TYPE="Char" /> <FLD NAME="WEB3" TYPE="Char" /> <FLD NAME="WEB4" TYPE="Char" /> <FLD NAME="WEB5" TYPE="Char" /> <FLD NAME="FCYWEB" TYPE="Char" /> <FLD NAME="EXTNUM" TYPE="Char" /> <FLD MENULAB="Yes" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer">2</FLD> <FLD NAME="FLMOD" TYPE="Integer">0</FLD> <FLD NAME="FLMODFONC" TYPE="Integer">0</FLD> </LIN> </TAB> <GRP ID="BPC1_1"> <FLD MENULAB="Class B" MENULOCAL="212" NAME="ABCCLS" TYPE="Integer">2</FLD> <FLD NAME="WORDMINAMT" TYPE="Decimal">0</FLD> <FLD NAME="XCUR" TYPE="Char">EUR</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="ORDCLE" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="LNDAUZ" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="ODL" TYPE="Integer">1</FLD> <FLD MENULAB="Allowed" MENULOCAL="414" NAME="DME" TYPE="Integer">1</FLD> <FLD MENULAB="Exclude tax" MENULOCAL="243" NAME="PRITYP" TYPE="Integer">1</FLD> </GRP> <GRP ID="BPC1_2"> <FLD MENULAB="Invoiced" MENULOCAL="402" NAME="FREINV" TYPE="Integer">1</FLD> <FLD MENULAB="One/Shipment" MENULOCAL="408" NAME="IME" TYPE="Integer">1</FLD> <FLD MENULAB="Per request" MENULOCAL="406" NAME="INVPER" TYPE="Integer">1</FLD> <FLD MENULAB="Invoice date" MENULOCAL="407" NAME="DUDCLC" TYPE="Integer">1</FLD> </GRP> <GRP ID="BPC1_3"> <FLD MENULAB="Category 1" MENULOCAL="403" NAME="COMCAT" TYPE="Integer">1</FLD> <FLD NAME="MORREP" TYPE="Char" /> </GRP> <GRP ID="BPC1_4"> <FLD MENULAB="No" MENULOCAL="1" NAME="WORDTEX" TYPE="Integer">1</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="WINVTEX" TYPE="Integer">1</FLD> </GRP> <GRP ID="BPC1_5"> <FLD MENULAB="No" MENULOCAL="1" NAME="OCNFLG" TYPE="Integer">1</FLD> <FLD NAME="TPMCOD" TYPE="Char" /> <FLD NAME="ZTPMCOD" TYPE="Char" /> </GRP> <TAB DIM="30" ID="BPC1_6" SIZE="3"> <LIN NUM="1"> <FLD NAME="INVDTA" TYPE="Integer">1</FLD> <FLD NAME="SHO" TYPE="Char">Discount %</FLD> <FLD NAME="INVDTAAMT" TYPE="Decimal">0</FLD> <FLD MENULAB="%" MENULOCAL="2227" NAME="INVDTATYP" TYPE="Integer">3</FLD> <FLD NAME="WWCUR" TYPE="Char" /> </LIN> <LIN NUM="2"> <FLD NAME="INVDTA" TYPE="Integer">2</FLD> <FLD NAME="SHO" TYPE="Char">Freight char</FLD> <FLD NAME="INVDTAAMT" TYPE="Decimal">0</FLD> <FLD MENULAB="Tax excl" MENULOCAL="2227" NAME="INVDTATYP" TYPE="Integer">1</FLD> <FLD NAME="WWCUR" TYPE="Char">USD</FLD> </LIN> <LIN NUM="3"> <FLD NAME="INVDTA" TYPE="Integer">3</FLD> <FLD NAME="SHO" TYPE="Char">Insurance</FLD> <FLD NAME="INVDTAAMT" TYPE="Decimal">0</FLD> <FLD MENULAB="Tax excl" MENULOCAL="2227" NAME="INVDTATYP" TYPE="Integer">1</FLD> <FLD NAME="WWCUR" TYPE="Char">USD</FLD> </LIN> </TAB> <GRP ID="BPC2_1"> <FLD MENULAB="Normal" MENULOCAL="401" NAME="BPCTYP" TYPE="Integer">1</FLD> <FLD NAME="BPCBPSNUM" TYPE="Char" /> <FLD MENULAB="Daily Rate" MENULOCAL="202" NAME="CHGTYP" TYPE="Integer">1</FLD> </GRP> <GRP ID="BPC2_2"> <FLD MENULAB="Check" MENULOCAL="234" NAME="OSTCTL" TYPE="Integer">1</FLD> <FLD NAME="WOSTAUZ" TYPE="Decimal">0</FLD> <FLD NAME="XCUR" TYPE="Char">EUR</FLD> <FLD NAME="XOST" TYPE="Decimal">0</FLD> <FLD NAME="WCDTISR" TYPE="Decimal">0</FLD> <FLD NAME="BPCCDTISR" TYPE="Char" /> </GRP> <GRP ID="BPC2_3"> <FLD NAME="BPCNOTE" TYPE="Char">117</FLD> </GRP> <GRP ID="BPC2_4"> <FLD NAME="BUS" TYPE="Char" /> <FLD NAME="ZBUS" TYPE="Char" /> <FLD NAME="ORIPPT" TYPE="Char" /> <FLD NAME="ZORIPPT" TYPE="Char" /> <FLD NAME="BPCSNCDAT" TYPE="Date">20150124</FLD> </GRP> <GRP ID="BPC2_5"> <FLD NAME="PITCDT" TYPE="Integer">0</FLD> <FLD NAME="PITCPT" TYPE="Integer">0</FLD> <FLD NAME="TOTPIT" TYPE="Integer">0</FLD> <FLD NAME="BPCPITDEB" TYPE="Integer">0</FLD> <FLD MENULAB="No" MENULOCAL="1" NAME="NULPIO" TYPE="Integer">1</FLD> <FLD NAME="COTCHX" TYPE="Char" /> <FLD NAME="COTPITRQD" TYPE="Integer">0</FLD> </GRP> <GRP ID="BPC2_6"> <LST NAME="TSCCOD" SIZE="3" TYPE="Char"> <ITM>400</ITM> <ITM>427</ITM> <ITM>AME</ITM> </LST> <LST NAME="ZTSCCOD" SIZE="3" TYPE="Char"> <ITM>Wholesaler</ITM> <ITM>Wholesaler</ITM> <ITM>Americas</ITM> </LST> </GRP> <GRP ID="BPC3_1"> <FLD NAME="BPCINV" TYPE="Char">NA011</FLD> <FLD NAME="BPAINV" TYPE="Char">AD1</FLD> <FLD NAME="BPCPYR" TYPE="Char">NA011</FLD> <FLD NAME="BPAPYR" TYPE="Char">AD1</FLD> <FLD NAME="FCTNUM" TYPE="Char" /> <FLD NAME="BPCGRU" TYPE="Char">NA011</FLD> <FLD NAME="BPCRSK" TYPE="Char">NA011</FLD> <FLD NAME="ACCCOD" TYPE="Char">LOCAL</FLD> <FLD NAME="ZACCCOD" TYPE="Char" /> <FLD NAME="DIA" TYPE="Char" /> <FLD NAME="ZDIA" TYPE="Char" /> </GRP> <GRP ID="BPC3_2"> <FLD NAME="VACBPR" TYPE="Char">NTX</FLD> <FLD NAME="ZVACBPR" TYPE="Char">No Tax</FLD> <FLD NAME="VATEXN" TYPE="Char" /> </GRP> <GRP ID="BPC3_3"> <FLD NAME="PTE" TYPE="Char">CH30NET</FLD> <FLD NAME="ZPTE" TYPE="Char">30 Days</FLD> <FLD NAME="J1" TYPE="Integer">0</FLD> <FLD NAME="J2" TYPE="Integer">0</FLD> <FLD NAME="J3" TYPE="Integer">0</FLD> <FLD NAME="J4" TYPE="Integer">0</FLD> <FLD NAME="J5" TYPE="Integer">0</FLD> <FLD NAME="J6" TYPE="Integer">0</FLD> <FLD NAME="UVYCOD2" TYPE="Char" /> <FLD NAME="ZUVYCOD2" TYPE="Char" /> <FLD NAME="DEP" TYPE="Char" /> <FLD NAME="ZDEP" TYPE="Char" /> <FLD NAME="PAYBAN" TYPE="Char" /> <FLD NAME="ZPAYBAN" TYPE="Char" /> <FLD NAME="GRP" TYPE="Char" /> <FLD NAME="ZGRP" TYPE="Char" /> <FLD MENULAB="No reminder" MENULOCAL="235" NAME="FUPTYP" TYPE="Integer">1</FLD> <FLD NAME="FUPMINAMT" TYPE="Decimal">0</FLD> <FLD NAME="FUPCUR" TYPE="Char">EUR</FLD> <FLD MENULAB="Per Request" MENULOCAL="404" NAME="SOIPER" TYPE="Integer">1</FLD> <FLD NAME="SEBPC" TYPE="Char">214</FLD> </GRP> <TAB DIM="20" ID="BPC3_4" SIZE="4"> <LIN NUM="1"> <FLD NAME="DIE" TYPE="Char">CCT</FLD> <FLD NAME="ZDIE" TYPE="Char">Cost Cente</FLD> <FLD NAME="CCE" TYPE="Char" /> <FLD NAME="ZCCE" TYPE="Char" /> </LIN> <LIN NUM="2"> <FLD NAME="DIE" TYPE="Char">PRJ</FLD> <FLD NAME="ZDIE" TYPE="Char">Projects</FLD> <FLD NAME="CCE" TYPE="Char" /> <FLD NAME="ZCCE" TYPE="Char" /> </LIN> <LIN NUM="3"> <FLD NAME="DIE" TYPE="Char">PRO</FLD> <FLD NAME="ZDIE" TYPE="Char">Product</FLD> <FLD NAME="CCE" TYPE="Char" /> <FLD NAME="ZCCE" TYPE="Char" /> </LIN> <LIN NUM="4"> <FLD NAME="DIE" TYPE="Char">MAR</FLD> <FLD NAME="ZDIE" TYPE="Char">Market</FLD> <FLD NAME="CCE" TYPE="Char" /> <FLD NAME="ZCCE" TYPE="Char" /> </LIN> </TAB> <TAB DIM="30" ID="BPC4_1" SIZE="1"> <LIN NUM="1"> <FLD NAME="BPAADD" TYPE="Char">AD1</FLD> <FLD NAME="BPADES" TYPE="Char">Corporate</FLD> <FLD NAME="BPDNAM0" TYPE="Char">Computer Products</FLD> <FLD NAME="BPDNAM1" TYPE="Char" /> <FLD NAME="LAN" TYPE="Char">FRA</FLD> <FLD NAME="STOFCY" TYPE="Char" /> <FLD NAME="BPCLOC" TYPE="Char" /> <FLD NAME="SCOLOC" TYPE="Char" /> <FLD NAME="RCPFCY" TYPE="Char">NA011</FLD> <FLD MENULAB="Route Code 1" MENULOCAL="409" NAME="DRN" TYPE="Integer">1</FLD> <FLD MENULAB="Normal" MENULOCAL="410" NAME="DLVPIO" TYPE="Integer">1</FLD> <FLD NAME="BPTNUM" TYPE="Char" /> <FLD NAME="MDL" TYPE="Char" /> <FLD NAME="DAYLTI" TYPE="Integer">0</FLD> <FLD NAME="EECINCRAT" TYPE="Decimal">0</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="NPRFLG" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="NDEFLG" TYPE="Integer">2</FLD> <FLD NAME="REP0" TYPE="Char" /> <FLD NAME="PREREP0" TYPE="Char" /> <FLD NAME="REP1" TYPE="Char" /> <FLD NAME="PREREP1" TYPE="Char" /> <FLD NAME="PRPTEX" TYPE="Char" /> <FLD NAME="DLVTEX" TYPE="Char" /> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY1" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY2" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY3" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY4" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY5" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY6" TYPE="Integer">2</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="UVYDAY7" TYPE="Integer">2</FLD> <FLD NAME="UVYCOD" TYPE="Char" /> <FLD NAME="EECICT" TYPE="Char" /> <FLD MENULAB="Domestic" MENULOCAL="236" NAME="EECLOC" TYPE="Integer">1</FLD> <FLD MENULAB="Yes" MENULOCAL="1" NAME="ENAFLG" TYPE="Integer">2</FLD> <FLD NAME="VACBPD" TYPE="Char" /> <FLD NAME="ICTCTY" TYPE="Char" /> <FLD NAME="SSTENTCOD" TYPE="Char" /> <FLD NAME="BPDCRY" TYPE="Char">US</FLD> <FLD NAME="BPDPOSCOD" TYPE="Char">92618</FLD> <FLD NAME="FFWNUM" TYPE="Char" /> <FLD NAME="FFWADD" TYPE="Char" /> <FLD NAME="EECNUM" TYPE="Char" /> <FLD MENULAB="Yes" MENULOCAL="1" NAME="BPDADDFLG" TYPE="Integer">2</FLD> <FLD NAME="FLMOD" TYPE="Integer">0</FLD> <FLD NAME="EXPNUM" TYPE="Integer">3</FLD> <FLD NAME="CREUSR" TYPE="Char">ERP</FLD> <FLD NAME="CREDAT" TYPE="Date">20080109</FLD> <FLD NAME="UPDUSR" TYPE="Char">ADMIN</FLD> <FLD NAME="UPDDAT" TYPE="Date">20151016</FLD> </LIN> </TAB> <GRP ID="CNTC_3"> <FLD NAME="TRTBPAB" TYPE="Char" /> <FLD NAME="IDENT" TYPE="Char">1NA011</FLD> <FLD NAME="NUMBPA" TYPE="Integer">1</FLD> </GRP> <GRP ID="ADXTEC"> <FLD NAME="WW_MODSTAMP" TYPE="Char">20151016100957</FLD> <FLD NAME="WW_MODUSER" TYPE="Char">ADMIN</FLD> </GRP> </RESULT>';      
        PromoteCustomerX3Controller.getCustomerNumber(TestResponseData);

        list<map<String,String>> ContactCodeslist = new list<map<String,String>>();
        map<String,String> ContactCodes = new map<String,String>();
        ContactCodes.put('ContactName','john son');
        ContactCodes.put('ContactCode','0111');
        ContactCodeslist.add(ContactCodes); 
        boolean updatecust= PromoteCustomerX3.UpdateCustomer(Config.Id,'SEED',act.Id,'3GNEW',ContactCodeslist,'Prospect');

        pRef=PromoteCustomerX3.GetCategoryValues();
        PromoteCustomerX3Controller.result rs = new PromoteCustomerX3Controller.result();
        rs.Error ='' ;
        rs.CustomereNumber='';
        rs.ContactCodes = null;

        PromoteCustomerX3.CategoryX3='';
        PromoteCustomerX3.CurrencyX3='';
        PromoteCustomerX3.LanguageX3='';
        PromoteCustomerX3.CustomerNoX3='';
        PromoteCustomerX3.TaxRuleX3='';
        pRef=PromoteCustomerX3.PromoteCustomer_X3();

        ContactCodeslist = new list<map<String,String>>();
        ContactCodes = new map<String,String>();
        ContactCodes.put('ContactName','abc');
        ContactCodes.put('ContactCode','0111');
        ContactCodeslist.add(ContactCodes); 
        updatecust= PromoteCustomerX3.UpdateCustomer(Config.Id,'SEED',act.Id,'3GNEW',ContactCodeslist,'Customer');

        //-------------------------------------------PromoteCustomerX3Controller--------------------------------END
        
        //-------------------------------------------AddressController--------------------------------------start
                
        ApexPages.currentPage().getParameters().put('id',objShipto.Id);
        AddressController AddressCnt1 = new AddressController(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('AccountId',act.Id);
        AddressController AddressCnt = new AddressController(StdCntlr);
        AddressCnt.getAddressPage();
        
        AddressCnt.ERPSytemName = 'Sage100ERP';
        AddressCnt.getAddressPage();
        
        AddressCnt.ERPSytemName = 'Sage300ERP';
        AddressCnt.getAddressPage();
        
        AddressCnt.ERPSytemName = 'Sage500ERP';
        AddressCnt.getAddressPage();
        
        AddressCnt.ERPSytemName = null;
        AddressCnt.getAddressPage();
        //-------------------------------------------AddressController--------------------------------------END
        
        //-------------------------------------------AddressSageX3Controller--------------------------------------start
        
        objShipTo = new Ship_To__c();
        objShipTo.isShipTo__c='Yes';
        objShipTo.Default_ShipTo__c='Yes';
        objShipTo.Warehouse_Code__c='';
        objShipTo.Telephone_No__c=''; 
        objShipTo.Telephone_Ext__c='';
        objShipTo.Tax_Schedule__c='';
        objShipTo.Ship_To_Zip_Code__c=''; 
        objShipTo.Ship_To_State__c='PA'; 
        objShipTo.Ship_To_Name__c='Corporation';
        objShipTo.Ship_To_Country_Code__c='US';
        objShipTo.Ship_To_Code__c='Corp'; 
        objShipTo.Ship_To_City__c='';
        objShipTo.Ship_To_Address3__c='boston';
        objShipTo.Ship_To_Address2__c ='street';
        objShipTo.Ship_To_Address1__c='90 Canal';
        objShipTo.IsPrimary__c='Yes';
        objShipTo.Integration_Key__c =Config.Id;
        objShipTo.Fax_No__c='';
        objShipTo.Email_Address__c='';
        objShipTo.Account_Id__c=act.Id;
            
        insert objShipTo; 
        
        ApexPages.currentPage().getParameters().put('AccountID',act.Id);
        ApexPages.currentPage().getParameters().put('id','');
        AddressSageX3Controller AddressSageX31 = new AddressSageX3Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('id',objShipto.Id);
        AddressSageX3Controller AddressSageX32 = new AddressSageX3Controller(StdCntlr);
        
        
        AddressSageX3Controller.Address  Addr = new  AddressSageX3Controller.Address();
        Addr.Ship_To_Country_Code = '';
        boolean isValid = AddressSageX32.ApexMessages(Addr);
        
        Addr = new  AddressSageX3Controller.Address();
        Addr.Ship_To_Code = '';
        isValid = AddressSageX32.ApexMessages(Addr);
        
        Addr = new  AddressSageX3Controller.Address();
        Addr.Ship_To_Zip_Code = '';
        isValid = AddressSageX32.ApexMessages(Addr);
        
        AddressSageX32.pageMode = 'New';
        Addr = new  AddressSageX3Controller.Address();
        Addr.Ship_To_Code = 'Corp';
        isValid = AddressSageX32.ApexMessages(Addr);
        
        Addr = new  AddressSageX3Controller.Address();
        Addr.Ship_To_State = '';
        isValid = AddressSageX32.ApexMessages(Addr);
        
        AddressSageX32.pageMode = 'Edit';
        Addr = new AddressSageX3Controller.Address();
        Addr.ShipToId=objShipTo.Id;
        Addr.isShipTo='Yes';
        Addr.DefaultShipTo='Yes'; 
        Addr.Warehouse_Code='';
        Addr.Telephone_No='';
        Addr.Telephone_Ext='';
        Addr.Tax_Schedule='';
        Addr.Ship_To_Zip_Code='15143';
        Addr.Ship_To_State='PA';
        Addr.Ship_To_Name='Corporation';
        Addr.Ship_To_Country_Code='US';
        Addr.Ship_To_Code='CORP';
        Addr.Ship_To_City='Sewickley';       
        Addr.Ship_To_Address3='ABC';
        Addr.Ship_To_Address2='Sewickley';
        Addr.Ship_To_Address1='136 Wexford Run Road';
        Addr.IsPrimary='Yes';
        Addr.Integration_Key=Config.Id;
        Addr.Fax_No='';
        Addr.Email_Address='';
        Addr.ERP_Customer_Number='NA002';
        Addr.ERP_Contact_Code='';
        Addr.Account_Id=act.id;
        Addr.Account_Name='Amalgate';
        Addr.Account_Type='Customer';
        pRef=AddressSageX32.saveAddresses();
        pRef=AddressSageX32.savePromoteAddresses();
        
        pRef=AddressSageX32.cancelProcess();
        //AddressSageX32.PromoteAddressToERP_X3(Addr,Config);

    }

    static testMethod void promoteOrder()
    {
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];

        // create User
        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');
        insert testUser;

        //create record for Security_Matrix__c
        Security_Matrix__c securityMatrix = new Security_Matrix__c(); 
        securityMatrix.name = 'SM001';
        securityMatrix.Promote_Customer__c=true;
        insert securityMatrix;
        System.assertEquals('SM001',securityMatrix.name);
        

        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c();
        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage ERP X3';
        app.ERP_System__c='SageERPX3';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;

        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;

        Account act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';
        act.Integration_Key__c='';   
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';
        act.Integration_Key__c = Config.Id;
        insert act;
        
        Contact cnt = new Contact();
        cnt.AccountId= act.Id;
        cnt.LastName= 'son';
        cnt.FirstName= 'john';
        insert cnt;

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= act.Id;
        objShipto.isShipTo__c ='Yes' ; 
        objShipto.IsPrimary__c ='Yes' ;
        objShipto.Default_ShipTo__c='Yes';
        insert objShipto;
        
        Salesperson__c SP = new Salesperson__c();
        SP.Salesperson_Code__c = '0100';
        SP.Integration_Key__c =  Config.Id;
        SP.Salesperson_Description__c =  'Jim Kentley';
        insert SP;

        Salesperson_Mapping__c SPMapping = new Salesperson_Mapping__c();
        SPMapping.User_Id__c=UserInfo.getUserId();
        SPMapping.Salesperson_Id__c = SP.Id;
        SPMapping.Integration_Key__c = Config.Id;
        insert SPMapping;

        //----------------------------------------------ERPOrderListController------------------------------start

        ERPOrderListController ERPOrderList1 = new ERPOrderListController();
        ERPOrderList1.selectedERP = 'All';
        pageReference pRef=ERPOrderList1.GetOrders();
        
        //Product family
        ERP_Product_Family__c Family1 =new ERP_Product_Family__c();
        Family1.ERP_Product_Family_Code__c = 'Charge';
        Family1.ERP_Product_Family_Description__c = 'Charge';
        Family1.Integration_Key__c = Config.Id;
        insert Family1;
        
        //Product 
        Product2 prod2 =new Product2();
        prod2.Name='BMS002';
        prod2.ProductCode='BMS002';
        prod2.IsActive = true;
        prod2.ERP_Product_Family_Id__c = Family1.Id;
        prod2.Description = 'Bicycle, R330, 54cm, Grey';        
        insert prod2;
        
        // price book
        Id pricebookId = Test.getStandardPricebookId();
        Pricebook2 pb =new Pricebook2();
        pb.Name= Config.ERP_System__c+' - '+ Config.ERP_Company_Code__c;
        pb.Description='Pricebook for '+Config.ERP_System__c +' - '+ Config.ERP_Company_Code__c; 
        pb.Integration_Key__c=Config.Id;
        pb.IsActive=true;
        insert pb;
        
        //Price book entry
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pricebookId;//STDPriceBook.Id;
        pbEntry.Product2Id = prod2.id;
        pbEntry.UnitPrice = 153.00;
        insert pbEntry;
        
        //Price book entry
        pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pb.Id;
        pbEntry.Product2Id = prod2.id;
        pbEntry.UnitPrice = 153.00;
        pbEntry.UseStandardPrice = true;
        insert pbEntry;
        
        //Order 
        Order objOrder = new Order();
        objOrder.Name = 'John Anderson';       
        objOrder.EffectiveDate =Date.valueof('2015-02-02');
        objOrder.status ='Draft';
        objOrder.ERP_Order_Number__c = 'ORD001';
        objOrder.Document_Type__c = 'Order';
        objOrder.ERP_Order_Total__c = 600;       
        objOrder.AccountId = act.Id;
        objOrder.Pricebook2Id=pb.Id;
        objOrder.Integration_Key__c = Config.Id;
        insert objOrder;
        
        //Order Item
        OrderItem ordItem = new OrderItem();
        ordItem.UnitPrice=100.00;
        ordItem.Quantity=1;
        ordItem.PricebookEntryId=pbEntry.Id;
        ordItem.OrderId=objOrder.Id;
        ordItem.PlusTax__c=98.00;
        ordItem.MinusTax__c=98.00;
        ordItem.TaxClass__c='NTX';
        ordItem.QOH__c=1;
        ordItem.Warehouse_Code__c='';
        ordItem.ExtensionAmt__c=100.00;
        ordItem.Discount__c=0.00;
        insert ordItem;

        ERPOrderListController ERPOrderList = new ERPOrderListController();
        ERPOrderList.doNext();
        ERPOrderList.doPrevious();
        ERPOrderList.getHasPrevious();
        ERPOrderList.getHasNext();
        pRef=ERPOrderList.GetOrders();

        ERPOrderList.OrderId = objOrder.Id;
        pRef=ERPOrderList.RedirectPage();

        ERPOrderList.totalRecords = 0;
        ERPOrderList.selectedERP = 'All';
        pRef=ERPOrderList.GetOrders();
        pRef=ERPOrderList.RedirectPage();

        ERPOrderList.OffsetSize = 1;
        ERPOrderList.getHasPrevious();

        //----------------------------------------------ERPOrderListController------------------------------End

        //----------------------------------------------SalesOrderX3Controller------------------------------start
                        
        sObject sObj = Schema.getGlobalDescribe().get('Order').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        SalesOrderX3Controller SalesOrderX31 = new SalesOrderX3Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('Id',objOrder.Id);
        
        sObj = Schema.getGlobalDescribe().get('Order').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        SalesOrderX3Controller SalesOrderX3 = new SalesOrderX3Controller(StdCntlr);
        
        list<SalesOrderX3Controller.LineItem> OrderProduct=  SalesOrderX3Controller.getOrderProduct(objOrder.Id);
        
         map<String,String> LoadAccountData =SalesOrderX3Controller.LoadAccountData(act.Id);
         String Salesperson =SalesOrderX3Controller.GetSalesperson(Config.Id);
         Ship_To__c ShipAddress =  SalesOrderX3Controller.LoadShipAddress (objShipto.Id);
         list<SalesOrderX3Controller.ResultSet> rs = SalesOrderX3Controller.getRecords('24', pb.Id, 'Charge' ,'Invoice');
         SalesOrderX3Controller.getFamilyRecords('Charge', Config.Id, 'Order');
         
         pRef=SalesOrderX3.LoadItem();
         map<String,String> CheckPBEntryExists = SalesOrderX3Controller.CheckPBEntryExists(pb.Id , 'BMS002');
         
         string JSONPrdDetails= '{"ProductCode":"BMS002","ProductId":"01u28000000tEjBAAU","Quantity":"","UOM":"","IntegrationId":"a0C28000000koi2EAA","AccountID":"'+act.Id+'","SalesSite":"NA012","ShipmentSite":"NA012","grossPrice":"","shipAddr":"","taxRule":"","Discount":"","currency":"USD"}';
         map<String,String> RealTimeProductData = SalesOrderX3Controller.RealTimeProductData (JSONPrdDetails);
         
         SalesOrderX3.JSONPrdDetails =JSONPrdDetails;
         pRef=SalesOrderX3.ReadRealTimeProductData();
         
        ApexPages.currentPage().getParameters().put('LineIndex', '0');
        ApexPages.currentPage().getParameters().put('LineOperation', 'delete');
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('mapLineDetails', '{"WarehouseCode":"000","UOM":"EACH","UnitPrice":"45.00","TaxClass":"TX","QuantityOrdered":"1.00","QOH":"-9.000000","ProductId":"01u90000006tcBfAAI","ListPrice":"45.00","ItemTypeCode":null,"ItemType":"ACC","ItemDescription":"Mirror, 18 X 14","ItemCode":"4886-18-14-3","ExtensionAmt":"45.00","minusTax":"45.00","plusTax":"45.00","DropShip":"Y","Discount":"0.00","Commissionable":"Y","Comments":"Line 1"}');
        pRef=SalesOrderX3.CRUDLineItem();
         
        ApexPages.currentPage().getParameters().put('LineIndex', '1');
        ApexPages.currentPage().getParameters().put('LineOperation', 'add');
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('mapLineDetails', '{"WarehouseCode":"000","UOM":"EACH","UnitPrice":"45.00","TaxClass":"TX","QuantityOrdered":"1.00","QOH":"-9.000000","ProductId":"01u90000006tcBfAAI","ListPrice":"45.00","ItemTypeCode":null,"ItemType":"ACC","ItemDescription":"Mirror, 18 X 14","ItemCode":"4886-18-14-3","ExtensionAmt":"45.00","minusTax":"45.00","plusTax":"45.00","DropShip":"Y","Discount":"0.00","Commissionable":"Y","Comments":"Line 1"}');
        pRef = SalesOrderX3.CRUDLineItem();
        
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('DiscountPC', '0'); 
        pRef=SalesOrderX3.RecalculateTax();
         
        ApexPages.currentPage().getParameters().put('ERPOrderNumber', 'SOH00001');
        pRef=SalesOrderX3.UpdateOrderNumber();
        
        //SalesOrderX3.JSONOrderDetails='{"WarehouseCode":"NA012","OrderDate":"2/2/2016","UOM":"UN","UnitPrice":"5.1745","TaxClass":"GST","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000aD0jAAE","plusTax":"5.43","minusTax":"5.17","ListPrice":"3.95","ItemTypeCode":null,"ItemType":"BMSOL","ItemDescription":"7 Sprockets","ItemCode":"BMS003","ExtensionAmt":"5.43","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}';
        SalesOrderX3.JSONOrderDetails='{"OrderDate":"03/09/2016","OrderType":"","OrderDescription":"AMC","AccountId":"0012800000DjqWmAAJ","Account":"Amalgamate Supply","CompanyAuthorizedById":"","CustomerAuthorizedById":"","Pricebook2Id":"01s28000004GD2TAAW","PricebookName":"SageERPX3 - SEED","Currency":"USD","ARDivisionNo":"NA002","CustomerNo":"NA002","TotalAmount":"4.65","LineTotal":4.65,"DocumentType":"Order","BillToAddress1":"New Originals Factory Best Seller 3 Corner Road","BillToAddress2":"","BillToAddress3":"","BillToCity":"Ciales","BillToState":"PR","BillToZipCode":"00638","BillToCountryCode":"US","ShipToCode":"","ShipToName":"","SalesSite":"NA012","ShipmentSite":"NA012","SalesSiteId":"a0528000002mHMqAAM","ShipmentSiteId":"a0528000002mHMqAAM","ShipToAddress1":"New Originals Factory Best Seller 3 Corner Road","ShipToAddress2":"","ShipToAddress3":"","ShipToCity":"Ciales","ShipToState":"PR","ShipToZipCode":"00638","ShipToCountryCode":"US","PrintSalesOrders":"N","PrintPickingSheets":"N","BatchFaxNo":"N","DiscountType":"-- none --","DiscountPC":0,"DiscountAmt":0,"FreightAmt":null,"DepositAmt":null,"SalesTaxAmt":null,"AmtSubTax":4.65,"AmtAddTax":4.65,"ContactName":"","UserName":""}';
        pRef=SalesOrderX3.SaveERPOrder();
         
        SalesOrderX3.OrderHeaderDetails='{"OrderDate":"03/09/2016","OrderType":"","OrderDescription":"AMC","AccountId":"0012800000DjqWmAAJ","Account":"Amalgamate Supply","CompanyAuthorizedById":"","CustomerAuthorizedById":"","Pricebook2Id":"01s28000004GD2TAAW","PricebookName":"SageERPX3 - SEED","Currency":"USD","ARDivisionNo":"NA002NA002","CustomerNo":"NA002NA002","TotalAmount":"4.65","LineTotal":4.65,"DocumentType":"Order","BillToAddress1":"New Originals Factory Best Seller 3 Corner Road","BillToAddress2":"","BillToAddress3":"","BillToCity":"Ciales","BillToState":"PR","BillToZipCode":"00638","BillToCountryCode":"US","ShipToCode":"","ShipToName":"","SalesSite":"NA012","ShipmentSite":"NA012","SalesSiteId":"a0528000002mHMqAAM","ShipmentSiteId":"a0528000002mHMqAAM","ShipToAddress1":"New Originals Factory Best Seller 3 Corner Road","ShipToAddress2":"","ShipToAddress3":"","ShipToCity":"Ciales","ShipToState":"PR","ShipToZipCode":"00638","ShipToCountryCode":"US","PrintSalesOrders":"N","PrintPickingSheets":"N","BatchFaxNo":"N","DiscountType":"-- none --","DiscountPC":0,"DiscountAmt":0,"FreightAmt":null,"DepositAmt":null,"SalesTaxAmt":null,"AmtSubTax":4.65,"AmtAddTax":4.65,"ContactName":"","UserName":""}';
        SalesOrderX3.JSONOrderDetails='[{"WarehouseCode":"NA012","UOM":"UN","UnitPrice":"4.6505","TaxClass":"NOR","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000tEjAAAU","plusTax":"4.65","minusTax":"4.65","ListPrice":"3.55","ItemTypeCode":null,"ItemType":null,"ItemDescription":"5 Sprockets","ItemCode":"BMS002","ExtensionAmt":"4.65","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}]';
        pRef=SalesOrderX3.PromoteOrder();
         
        // string OrderNumber = SalesOrderX3Controller.getOrderNumber_X3('');
         
        SalesOrderX3.JSONLineItems='[{"WarehouseCode":"NA012","UOM":"UN","UnitPrice":"4.6505","TaxClass":"NOR","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000tEjAAAU","plusTax":"4.65","minusTax":"4.65","ListPrice":"3.55","ItemTypeCode":null,"ItemType":null,"ItemDescription":"5 Sprockets","ItemCode":"BMS002","ExtensionAmt":"4.65","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}]';
        pRef=SalesOrderX3.AddMultiLineItem();
        pRef=SalesOrderX3.GetERPName();
        
        SalesOrderX3Controller.ERPOrder erpodr = new SalesOrderX3Controller.ERPOrder();
        erpodr.CustomerNo = '';
        erpodr.OrderLineItems = null;
        
        test.starttest();
        SalesOrderX3.Mode = '';
        SalesOrderX3.Synchronization ='';
        rs = SalesOrderX3Controller.getRecords('24', pb.Id, '' ,'Invoice');
        rs = SalesOrderX3Controller.getRecords('24', pb.Id, '' ,'order');
        SalesOrderX3Controller.getFamilyRecords('Charge', Config.Id, 'Invoice');
        CheckPBEntryExists = SalesOrderX3Controller.CheckPBEntryExists(pb.Id , 'BMS003');
        test.stoptest();
    }
    
    static testMethod void ReadWriteXML()
    {
        //////ReadAndWriteXML Start//////
        ReadAndWriteXML readandwrite = new ReadAndWriteXML();   
        ReadAndWriteXML.XmlNode objXmlNode  =new ReadAndWriteXML.XmlNode();

        string xmlString = '<Households><Household isPrimary="False" MailFlag="False" ID="4265447-PR"><Address1>33080 THUNDERBIRD DR</Address1><Address2>M G Road</Address2><Address3></Address3><City>HAYES</City><State>KANSAS</State><Country>UNITED STATES OF AMERICA</Country><Zip>00000-0000</Zip></Household><Household isPrimary="False" MailFlag="False" ID="4265447-S1"><Address1>test</Address1><Address2>test</Address2><Address3>test</Address3><City>test</City><State>test</State><Country>test</Country><Zip>test</Zip></Household><Household isPrimary="True" MailFlag="False" ID="4265447-S2"><Address1>fdsfds</Address1><Address2>fdsfdsf</Address2><Address3>fdsf</Address3><City>fdsfds</City><State>Florida</State><Country>fdsfds</Country><Zip>fdsfds</Zip></Household></Households>';
        objXmlNode = ReadAndWriteXML.ParseXmlString(xmlString);

        ReadAndWriteXML.XmlNode AddNode = new ReadAndWriteXML.XmlNode();
        AddNode.NodeName = 'Household';
        AddNode.Attributes.put('isPrimary','false');
        AddNode.Attributes.put('MailFlag','false');
        AddNode.Attributes.put('ID','4265447-S4');

        ReadAndWriteXML.XmlNode Add1 = new ReadAndWriteXML.XmlNode();
        Add1.NodeName = 'Address1';
        Add1.NodeValue = '1'; 
        AddNode.ChildXmlNodes.add(Add1);

        ReadAndWriteXML.XmlNode Add2 = new ReadAndWriteXML.XmlNode();
        Add2.NodeName = 'Address2';
        Add2.NodeValue = '2'; 
        AddNode.ChildXmlNodes.add(Add2);

        ReadAndWriteXML.XmlNode Add3 = new ReadAndWriteXML.XmlNode();
        Add3.NodeName = 'Address3';
        Add3.NodeValue = '3'; 
        AddNode.ChildXmlNodes.add(Add3);

        ReadAndWriteXML.XmlNode City = new ReadAndWriteXML.XmlNode();
        City.NodeName = 'City';
        City.NodeValue = 'HAYES'; 
        AddNode.ChildXmlNodes.add(City);
        System.assertEquals('HAYES',City.NodeValue);
        

        ReadAndWriteXML.XmlNode State = new ReadAndWriteXML.XmlNode();
        State.NodeName = 'State';
        State.NodeValue = 'KANSAS'; 
        AddNode.ChildXmlNodes.add(State);

        ReadAndWriteXML.XmlNode Country = new ReadAndWriteXML.XmlNode();
        Country.NodeName = 'Country';
        Country.NodeValue = 'UNITED STATES OF AMERICA'; 
        AddNode.ChildXmlNodes.add(Country);

        ReadAndWriteXML.XmlNode Zip = new ReadAndWriteXML.XmlNode();
        Zip.NodeName = 'Zip';
        Zip.NodeValue = '00000-0000'; 
        AddNode.ChildXmlNodes.add(Zip);

        xmlString = ReadAndWriteXML.AddOneNode(xmlString, AddNode);

        xmlString = ReadAndWriteXML.DeleteOneNode(xmlString, '4265447-S4', 'ID');

        objXmlNode = ReadAndWriteXML.ParseXmlString(xmlString);
        AddNode = ReadAndWriteXML.GetOneNode(objXmlNode, '4265447-S2', 'ID');
        AddNode = ReadAndWriteXML.GetOneNode(objXmlNode, '4265447-S2', 'ID');
        List<ReadAndWriteXML.XmlNode> lstXmlNode = AddNode.ChildXmlNodes;

        for(ReadAndWriteXML.XmlNode curXmlNode:lstXmlNode)
        {
            if(curXmlNode.NodeName == 'Address1')  
            {
                curXmlNode.NodeValue = 'Addr_1';
                break;
            }    
        }


        xmlString = ReadAndWriteXML.GenerateXmlString(objXmlNode);
        
        objXmlNode = ReadAndWriteXML.ParseXmlString(null);
        xmlString = ReadAndWriteXML.GenerateXmlString(null);
        xmlString = ReadAndWriteXML.AddOneNode(null, null);
        AddNode = ReadAndWriteXML.GetOneNode(null, '4265447-S2', 'ID');
        
        list<ReadAndWriteXML.XmlNode> xmlNodeLst = new list<ReadAndWriteXML.XmlNode>();
        xmlNodeLst = ReadAndWriteXML.getXmlNode()  ;
        xmlString = ReadAndWriteXML.DeleteOneNode(null, '4265447-S4', null);

    }
    
    static testMethod void IntegrationFrameworkBase()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SageERPX3', Config.ERP_System__c);
        
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 300',ERP_System__c='SageERPX3'
                    ,Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
        Standard_Setting__c addr = new Standard_Setting__c();
        addr.Name = 'addr1';
        addr.Address_Code_1__c = 'AD01';
        addr.Address_Code_2__c = 'AD02';        
        insert addr;
        
        Data_Page__c dataPage = new Data_Page__c();
        dataPage.Description__c='Customer';
        dataPage.ERP_System__c='SageERPX3';
        dataPage.Name__c='Customer'; 
        dataPage.Name ='Customer';
        dataPage.Type__c ='DEtail';
        dataPage.ERP_Function__c='YGTCUSTDTL';
        insert dataPage;
        
        //-------------------------------------------------SageX3IntegrationFramework----------------------------Start
        
        BaseIntegrationFramework SageX3Integration = new SageX3IntegrationFramework();
        
        map<String,String> PromotionFields = new map<String,String>();
        PromotionFields.put('CustomerNoX3','MN001');
        PromotionFields.put('Category','US');
        PromotionFields.put('Currency','USD');
        PromotionFields.put('Language','ENG');
        PromotionFields.put('Tax_rule','NTX');
        PromotionFields.put('Terms_Code','CASG');
        PromotionFields.put('SalesPersonX3','NA002');
        
        Account act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';   
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';
        act.Integration_Key__c = Config.Id;
        act.BillingStreet = '90 street\n boston \n US';
        act.BillingCountry='USA';
        act.BillingPostalCode='1234';
        act.BillingCity='Boston';
        act.BillingState='MA';
        act.ShippingStreet='90 street canal \n abc hdhahdh  adhahdhahd';
        act.ShippingCity='Boston';
        act.ShippingState='MA';
        act.ShippingPostalCode='123';
        act.ShippingCountry='MA';
        act.Website='www.johnsen.com';
        act.Type = 'Customer';
        insert act;
        list<account> acnt = new list<account>(); 
        acnt.add(act);
        
        Contact cnt = new Contact();
        cnt.AccountId= act.Id;
        cnt.LastName= 'son';
        cnt.FirstName= 'john';
        insert cnt;
        
        list<Contact> ContactList = new list<Contact>();
        ContactList.add(cnt);

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= act.Id;
        objShipto.isShipTo__c ='Yes' ; 
        objShipto.IsPrimary__c ='Yes' ;
        objShipto.Default_ShipTo__c='Yes';
        objShipto.Ship_To_Country_Code__c = 'US';
        insert objShipto;
        list<Ship_To__c> shipToList = new list<Ship_To__c>();
        shipToList.add(objShipto);
        
        map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
        SFObjectLists.put('Accounts',acnt);
        SFObjectLists.put('Contacts',ContactList);
        SFObjectLists.put('Addresses',shipToList);
        
        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        list<object>  AttribParam= new list<object>();
        AttribParams=Utility.getAttribParameters('', '' , config.Id, 'Customer', '' , Helper.MappingPurpose.POST); 
               
        AttribParam= new list<object>();
        AttribParam.add('YGTCUSTDTL');
        AttribParams.put('ERPFuncName',AttribParam);
        AttribParam= new list<object>();
        AttribParam.add('171');
        AttribParams.put('Version',AttribParam);
        
        Helper.GUMU_Response resGUMU_Response =SageX3Integration.PostData(Config.Id,'Customer',SFObjectLists, PromotionFields,AttribParams);
        
        act = new Account();
        act.ERP_Customer_Number__c = '3GPros';
        act.ERP_Company_Code__c='SAMINC';
        act.Name = '3GPros';
        act.Type = 'Prospect';
        act.Integration_Key__c = Config.Id;
        act.BillingStreet = '90 street\n boston';
        act.BillingCountry='USA';
        act.BillingPostalCode='1234';
        act.BillingCity='Boston';
        act.BillingState='MA';
        act.ShippingStreet='90 street canal \n abc hdhahdh\n Boston';
        act.ShippingCity='Boston';
        act.ShippingState='MA';
        act.ShippingPostalCode='123';
        act.ShippingCountry='MA';
        act.Website='www.johnsen.com';
        insert act;
        acnt = new list<account>(); 
        acnt.add(act);
        
        shipToList = new list<Ship_To__c>();
        
        
        SFObjectLists = new map<string,list<object>> ();
        SFObjectLists.put('Accounts',acnt);
        SFObjectLists.put('Contacts',ContactList);        
        SFObjectLists.put('Addresses',shipToList);
        
        resGUMU_Response =SageX3Integration.PostData(Config.Id,'Prospect',SFObjectLists, PromotionFields,AttribParams);
        
        /////--------------------GetData
        
        AttribParams=new map<string,list<object>> ();        
        AttribParam= new list<object>();        
        AttribParam.add('BMS002');
        AttribParams.put('ProductCode',AttribParam);

        AttribParam= new list<object>();      
        AttribParam.add('1');
        AttribParams.put('Quantity',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('0');
        AttribParams.put('discount',AttribParam);

        AttribParam= new list<object>();      
        AttribParam.add('EACH');            
        AttribParams.put('UOM',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('NA012');
        AttribParams.put('salesite',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('NA012');
        AttribParams.put('shipSite',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('0.00');
        AttribParams.put('grossPrice',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('NTX');
        AttribParams.put('taxRule',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('USD');
        AttribParams.put('Currency',AttribParam);

        AttribParam= new list<object>();
        Helper.MappingPurpose mappingType =Helper.MappingPurpose.ACTION;
        AttribParam.add(mappingType);
        AttribParams.put('MappingPurpose',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('');
        AttribParams.put('SourceEntity',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('0');
        AttribParams.put('startIndex',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('0');
        AttribParams.put('count',AttribParam);

        AttribParam= new list<object>();
        AttribParam.add('SOH4_1');
        AttribParams.put('include',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('171');
        AttribParams.put('Version',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add(Config.Id);
        AttribParams.put('IntegrationId',AttribParam);
        
        map<string,map<string,list<string>>> Params = new map<string,map<string,list<string>>>(); 
        resGUMU_Response =  SageX3Integration.getData(Params,AttribParams);
        
        AttribParams=new map<string,list<object>> ();        
        AttribParam= new list<object>();        
        AttribParam.add('Customer');
        AttribParams.put('SourceEntity',AttribParam);
        
        AttribParam= new list<object>();
        mappingType =Helper.MappingPurpose.POST;
        AttribParam.add(mappingType);
        AttribParams.put('MappingPurpose',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add(Config.Id);
        AttribParams.put('IntegrationId',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('YGTCUSTDTL');
        AttribParams.put('ERPFuncName',AttribParam); 
        resGUMU_Response =  SageX3Integration.getData(Params,AttribParams);
        

        AttribParam= new list<object>();
        mappingType =Helper.MappingPurpose.MODIFY;
        AttribParam.add(mappingType);
        AttribParams.put('MappingPurpose',AttribParam);
        resGUMU_Response =  SageX3Integration.getData(Params,AttribParams);
        
        

        AttribParam= new list<object>();
        AttribParam.add('Prospect');
        AttribParams.put('AccountType',AttribParam);
        
        AttribParam= new list<object>();
        mappingType =Helper.MappingPurpose.DISPLAY;
        AttribParam.add(mappingType);
        AttribParams.put('MappingPurpose',AttribParam);
        resGUMU_Response =  SageX3Integration.getData(Params,AttribParams);
        
        
        map<string,map<string,list<string>>> PrepareFieldParam=SageX3Integration.PrepareFieldParam('NA002', 'NA002');
        PrepareFieldParam=SageX3Integration.PrepareFieldParam('01/01/2016', '');
        
        list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
        map<string,string>ERPDataMap = new map<string,string>();
        ERPDataMap.put('BPCNUM','NA002');
        ERPDataMap.put('BPCTYP','2');
        ERPDataMap.put('BPCNAM','AMALGATE');        
        ERPDataMapList.add(ERPDataMap);
        
        Helper.GUMU_Response pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.ERPDataMap = ERPDataMapList;
        list<Helper.Customer> GetGenericCustomers =SageX3Integration.GetGenericCustomers(pGUMU_Response);
        
        //---------------------------------------------------BaseIntegrationFramework---------------------Start
        BaseIntegrationFramework BaseIntegration = new BaseIntegrationFramework();
        resGUMU_Response= BaseIntegration.PostData(Config.Id,'Prospect',SFObjectLists, PromotionFields,AttribParams);   
        PrepareFieldParam=BaseIntegration.PrepareFieldParam('01/01/2016', '');
        BaseIntegration.GetFieldForAutoMatch();
        GetGenericCustomers =BaseIntegration.GetGenericCustomers(pGUMU_Response);
        list<Ship_To__c> Addresses =BaseIntegration.GetAddresses(Config.Id,'Customer',pGUMU_Response);
        list<Contact> Cnts =BaseIntegration.GetContacts(Config.Id,'Customer',pGUMU_Response);
        BaseIntegration.InsertOrUpdatePBEntries(null,true);
        resGUMU_Response= BaseIntegration.ReadSchema('','');
        
        
        //-----------------------------------------------IntegrationFactory-----------------------------------------
        IntegrationFactory Factory = new IntegrationFactory();
        IntegrationFactory.getERPProvider();            
    }
    
    static testMethod void CustomerERPDetaitls()
    {
        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;
        
        Profile p = [select id from profile where Name = 'System Administrator' limit 1];

        // create User
        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');
        insert testUser;

        //create record for Security_Matrix__c
        Security_Matrix__c securityMatrix = new Security_Matrix__c(); 
        securityMatrix.name = 'SM001';
        securityMatrix.ERP_Details__c=true;
        insert securityMatrix;
       System.assertEquals('SM001',securityMatrix.name);

        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c();
        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage ERP X3';
        app.ERP_System__c='SageERPX3';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;

        

        Account act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';
        act.Integration_Key__c='';   
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';
        act.Integration_Key__c = Config.Id;
        insert act;
        
        Data_Page__c dataPage = new Data_Page__c();
        dataPage.Description__c='';
        dataPage.Create_Tab__c=true;
        dataPage.Default__c = true;
        dataPage.ERP_System__c='SageERPX3';
        dataPage.Name__c ='Sales_Order_Details';       
        dataPage.Type__c ='List';
        dataPage.Filter_Field__c='BPCNUM';
        insert dataPage;
        
        //---------------------------------------------------------AccountInfoController-------------------------------
        ApexPages.currentPage().getParameters().put('Id',act.Id);
        sObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        AccountInfoController AccountInfo = new AccountInfoController(StdCntlr);
        
        Component.Apex.OutputPanel InquiryLinks=AccountInfo.GetInquiryLinks();
        AccountInfo.ShowDefaultPage();
        AccountInfo.getCustomerEnquiries('customer') ;
        AccountInfo.updatePagesize();
        AccountInfo.displayStatus();
        AccountInfo.navigateNext();
        AccountInfo.navigatePrevious();
        AccountInfo.RefreshList();
        AccountInfo.ShowDataPage();
        AccountInfo.displayDetail();
        AccountInfo.BackToParent();
        //AccountInfo.displayDetail();
        
        //---------------------------------------------------------AccountTriggerHelper-----------------------------STArT
        act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';     
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';
        act.Integration_Key__c = Config.Id;
        act.BillingStreet = '90 street \n canal';
        act.ShippingStreet = '90 street \n canal';
        act.Sync_To_ERP__c = true;
        insert act;
        
        Ship_To__c objShipto = new Ship_To__c();
        objShipTo.Ship_To_Code__c='Corp12'; 
        objShipto.Account_Id__c= act.Id;
        objShipto.Account_Id__c= act.Id;
        objShipto.isShipTo__c ='Yes' ; 
        objShipto.IsPrimary__c ='Yes' ;
        objShipto.Default_ShipTo__c='No';
        objShipto.Telephone_No__c = '9594055880';
        objShipto.Ship_To_Zip_Code__c= '1234';
        objShipto.Ship_To_State__c= 'CA';
        objShipto.Ship_To_Country_Code__c= 'US';  
        objShipto.Ship_To_City__c= 'boston';
        objShipto.Ship_To_Address3__c= 'boston'; 
        objShipto.Ship_To_Address2__c= 'canal';
        objShipto.Ship_To_Address1__c= '90 street';
        objShipto.Fax_No__c= '9594055880';
        objShipto.Email_Address__c= 'john@gmail.com';
        insert objShipto;
        
        act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';          
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'mandy Newrwal';
        act.Integration_Key__c = Config.Id;
        act.BillingStreet = '90 street \n canal\n boston';
        act.ShippingStreet = '90 street \n canal\n boston';
        act.Sync_To_ERP__c = true;
        insert act;
        
        objShipto = new Ship_To__c();
        objShipto.Account_Id__c= act.Id;
        objShipto.isShipTo__c ='Yes' ; 
        objShipto.IsPrimary__c ='No' ;
        objShipto.Default_ShipTo__c='Yes';
        insert objShipto;
        
        delete objShipto;
        
        Standard_Setting__c addr = new Standard_Setting__c();
        addr.Name = 'addr1';
        addr.Address_Code_1__c = 'AD01';
        addr.Address_Code_2__c = 'AD02';
        insert addr;
        
        act = new Account();
        act.ERP_Customer_Number__c = '3GNEW123';           
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'mandy Newrwal123';
        act.Integration_Key__c = Config.Id;
        act.BillingStreet = '90 street ';
        act.ShippingStreet = '90 street';
        act.Sync_To_ERP__c = true;
        insert act;
        list<account> actList = new list<account>();
        string accountlist = String.valueOf(actList);
        AccountTriggerHelper AccountTrigger = new AccountTriggerHelper();
        AccountTriggerHelper.UpdateERPCustomer_X3(act, Config);
        //AccountTriggerHelper.UpdateERPCustomer(accountlist);
        
        
    }
    static testMethod void GTLookup()
    {
        /////GTLookup/////
    
        //Pagereference Page = new PageReference('https://c.ap2.visual.force.com/apex/Lookup?obj=001&fldsrch1=Name&fldsrch2=ERP_Customer_Number__c&fldshow1=ERP_Company_Code__c&fldshow2=ERP_Customer_Number__c&fldshow3=Name&txt=Account&groupbyfield1=&groupbyfield2=&wherefield1=ERP_Company_Code__c&wherefieldvalue1=blank&wherecompareop1=notequal&wherefield2=&wherefieldvalue2=&wherecompareop2=&wherefield3=undefined&wherefieldvalue3=undefined&wherecompareop3=undefined&frm=frmPromote');
        Pagereference Page = new PageReference('https://gumu-lite.ap2.visual.force.com/apex/Lookup?obj=001&fldsrch1=Name&fldsrch2=GUMU_Lite__ERP_Customer_Number__c&fldshow1=GUMU_Lite__ERP_Company_Code__c&fldshow2=Name&fldshow3=Name&txt=Account&groupbyfield1=&groupbyfield2=&wherefield1=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue1=SEED&wherecompareop1=equal&wherefield2=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue2=SEED&wherecompareop2=equal&wherefield3=Integration_Key__c&wherefieldvalue3=a0O28000000mOoBEAU&wherecompareop3=in&frm=frmPromote');
        Test.setCurrentPage(Page);
        LookupController objGTLookup = new LookupController(); 
    
        objGTLookup.getFieldsToShowTag();
        objGTLookup.getFormTag();
        objGTLookup.getTextBox();
        objGTLookup.search();
        objGTLookup.performSearch('Account');
        
        
        Page = new PageReference('https://gumu-lite.ap2.visual.force.com/apex/Lookup?obj=001&fldsrch1=Name&fldsrch2=GUMU_Lite__ERP_Customer_Number__c&fldshow1=GUMU_Lite__ERP_Company_Code__c&fldshow2=Name&fldshow3=Name&txt=Account&groupbyfield1=&groupbyfield2=&wherefield1=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue1=SEED&wherecompareop1=in&wherefield2=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue2=SEED&wherecompareop2=in&wherefield3=Integration_Key__c&wherefieldvalue3=a0O28000000mOoBEAU&wherecompareop3=in&frm=frmPromote');
        Test.setCurrentPage(Page);
        String test1='https://gumu-lite.ap2.visual.force.com';
        System.assertEquals('https://gumu-lite.ap2.visual.force.com',test1);
        
        objGTLookup = new LookupController();
        objGTLookup.performSearch('Account');
        
        Page = new PageReference('https://gumu-lite.ap2.visual.force.com/apex/Lookup?obj=001&fldsrch1=Name&fldsrch2=GUMU_Lite__ERP_Customer_Number__c&fldshow1=GUMU_Lite__ERP_Company_Code__c&fldshow2=Name&fldshow3=Name&txt=Account&groupbyfield1=&groupbyfield2=&wherefield1=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue1=SEED&wherecompareop1=notequal&wherefield2=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue2=SEED&wherecompareop2=notequal&wherefield3=Integration_Key__c&wherefieldvalue3=a0O28000000mOoBEAU&wherecompareop3=notequal&frm=frmPromote');
        Test.setCurrentPage(Page);
        objGTLookup = new LookupController();
        objGTLookup.performSearch('Account');
        
        Page = new PageReference('https://gumu-lite.ap2.visual.force.com/apex/Lookup?obj=001&fldsrch1=Name&fldsrch2=GUMU_Lite__ERP_Customer_Number__c&fldshow1=GUMU_Lite__ERP_Company_Code__c&fldshow2=Name&fldshow3=Name&txt=Account&groupbyfield1=&groupbyfield2=&wherefield1=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue1=SEED&wherecompareop1=notequal&wherefield2=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue2=SEED&wherecompareop2=notequal&wherefield3=Integration_Key__c&wherefieldvalue3=a0O28000000mOoBEAU&wherecompareop3=equal&frm=frmPromote');
        Test.setCurrentPage(Page);
        objGTLookup = new LookupController();
        objGTLookup.performSearch('Account');
        
        Page = new PageReference('https://c.ap1.visual.force.com/apex/CustomLookup?obj=01u&fldsrch1=ProductCode&fldsrch2=StandardPrice&fldshow1=IsActive&fldshow2=UnitPrice&fldshow3=&txt=Integration&groupbyfield1=&groupbyfield2=&wherefield1=&wherefieldvalue1=&wherecompareop1=&wherefield2=&wherefieldvalue2=&wherecompareop2=&frm=frmImport');
        Test.setCurrentPage(Page);
        objGTLookup = new LookupController();
        objGTLookup.performSearch('PricebookEntry');
        
        Page = new PageReference('https://gumu-lite.ap2.visual.force.com/apex/Lookup?obj=001&fldsrch1=Name&fldsrch2=&fldshow1=GUMU_Lite__ERP_Company_Code__c&fldshow2=Name&fldshow3=Name&txt=Account&groupbyfield1=&groupbyfield2=&wherefield1=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue1=SEED&wherecompareop1=notequal&wherefield2=GUMU_Lite__ERP_Company_Code__c&wherefieldvalue2=SEED&wherecompareop2=notequal&wherefield3=Integration_Key__c&wherefieldvalue3=a0O28000000mOoBEAU&wherecompareop3=equal&frm=frmPromote');
        Test.setCurrentPage(Page);
        objGTLookup = new LookupController();
        objGTLookup.performSearch('Account');
    
        objGTLookup.runSearch(); 
    
        /////LookupController End/////
    }
    static testMethod void PostInstallScript()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'SageERPX3';
        Config.Name = 'Integration-SEED';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SEED';
        Config.Default__c=true;
        insert Config;
        
        System.assertEquals('Integration-SEED',Config.Name);
        
        InstallScriptSageX3 ScriptSageX3 = new InstallScriptSageX3(Config.Id);
        
        /*Entity__c objEmap = new Entity__c();
        objEmap.Entity_Code__c='Customer';
        objEmap.API_Method__c='YGTCUSTDTL';
        objEmap.Integration_Key__c = Config.Id;         
        insert objEmap;*/
        
        Entity_Mapping_Header__c Entity_Mapping_Header = new Entity_Mapping_Header__c();
        //Entity_Mapping_Header.name = 'SageX3Customer';
        Entity_Mapping_Header.Source_Entity__c='Integration-SEED-ImportProspect';
        Entity_Mapping_Header.Integration_Key__c=Config.Id;
        Entity_Mapping_Header.Target_Entity__c = 'Account';
        Entity_Mapping_Header.Entity_Id__c = null;
        Entity_Mapping_Header.Active__c = true;
        Entity_Mapping_Header.Sync_Type__c='System';
        insert Entity_Mapping_Header;
        
         ApexPages.currentPage().getParameters().put('Id',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','View');
        
        sObject sObj = Schema.getGlobalDescribe().get('GUMU_Lite__ERP_Config__c').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        ConfigurationController ConfigCntlr = new ConfigurationController(StdCntlr);
        
        ConfigCntlr.ImportDatastep =1;
        pageReference PageRef= ConfigCntlr.CreatePostInstallData();
        
        ConfigCntlr.ImportDatastep =15;
        PageRef= ConfigCntlr.CreatePostInstallData();
        
        ConfigCntlr.updateDataPageEntitySage(Config.Id,'SageX3ERP',Config.Name);
        
    }

}
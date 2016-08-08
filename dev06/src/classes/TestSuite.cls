@isTest(SeeAllData=true)
private class TestSuite 
{
    static testMethod void runTestCases()
    { 

        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC1';
        Config.Web_Service_URL__c = 'http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>'; 
        Config.Synchronization__c='Both';
        insert Config;

        system.assertEquals('Sage 300 ERP - SAMINC1', config.Name);

        GUMU_App_Setting__c delApp =[select Id from GUMU_App_Setting__c limit 1];
        delete delApp;
        GUMU_App_Setting__c app = new GUMU_App_Setting__c();

        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage 300 ERP';
        app.ERP_System__c='Sage300ERP';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;

        ///////SecurityMatrixCntlr/////
        Map<String, Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe();

        Profile p = [select id
                     from profile
                     where Name = 'System Administrator'
                     limit 1]; 

        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');

        insert testUser;

        SecurityMatrixController SM=new SecurityMatrixController();

        list<map<string,string>> lstMatrix=new list<map<String,String>>();

        map<String,String> UserMapping =new Map<string,string>();

        //UserMapping.put('OwnerId',testUser.Id);
        UserMapping.put('OwnerId',testUser.profileId);
        UserMapping.put('GUMU_Administration','false');
        UserMapping.put('ERP_Details','true');
        UserMapping.put('Promote_Customer','false');
        UserMapping.put('Promote_Order','false');

        lstMatrix.add(UserMapping);

        SM.secLevel = 'User';
        SM.FindSecurityFields();
        SM.CreateRecords();

        SecurityMatrixController.SaveSecurityMatrix(lstMatrix,'User',false);
        SecurityMatrixController.SaveSecurityMatrix(lstMatrix,'Profile',true);        
        SecurityMatrixController.SaveSecurityMatrix(lstMatrix,'Profile',false);

        /////GTLookup/////

        Pagereference Page = new PageReference('https://c.ap1.visual.force.com/apex/CustomLookup?obj=001&fldsrch1=Name&fldsrch2=AccountNumber&fldshow1=Site&fldshow2=&fldshow3=&txt=Integration&groupbyfield1=&groupbyfield2=&wherefield1=&wherefieldvalue1=&wherecompareop1=&wherefield2=&wherefieldvalue2=&wherecompareop2=&frm=frmImport');

        Test.setCurrentPage(Page);
        LookupController objGTLookup = new LookupController(); 

        objGTLookup.search();
        objGTLookup.Fieldtoshow2 = 'ABC';
        objGTLookup.Fieldtoshow3 = 'XYZ';
        objGTLookup.SearchFieldLabel4 ='Sales';
        objGTLookup.SearchFieldLabel5 ='SalesOrder';
        objGTLookup.runSearch();
        Pagereference pr= new PageReference('https://c.ap1.visual.force.com/apex/LookupController?obj=01u&fldsrch1=ProductCode&fldsrch2=Product_Desciption__c&fldshow1=ERP_Product_Family_Code__c&fldshow2=&fldshow3=&txt=Product&groupbyfield1=&groupbyfield2=&wherefield1=Pricebook2Id&wherefieldvalue1=01s90000006SVvCAAW&wherecompareop1=equal&wherefield2=ERP_Product_Family_Code__c&wherefieldvalue2=FGMSN&wherecompareop2=equal&wherefield3=ERP_Product_Family_Code__c&wherefieldvalue3=FGMSN&wherecompareop3=in&frm=frmPromote');

        Test.setCurrentPage(pr);
        objGTLookup = new LookupController();

        objGTLookup.getFieldsToShowTag();
        objGTLookup.getFormTag();
        objGTLookup.getTextBox();
        objGTLookup.search();
        objGTLookup.performSearch('ab');
        Page = new PageReference('https://c.ap1.visual.force.com/apex/CustomLookup?obj=01u&fldsrch1=ProductCode&fldsrch2=StandardPrice&fldshow1=IsActive&fldshow2=UnitPrice&fldshow3=&txt=Integration&groupbyfield1=&groupbyfield2=&wherefield1=&wherefieldvalue1=&wherecompareop1=&wherefield2=&wherefieldvalue2=&wherecompareop2=&frm=frmImport');
        objGTLookup.performSearch('ab');

        Page = new PageReference('https://c.ap1.visual.force.com/apex/LookupController?obj=01u&fldsrch1=ProductCode&fldsrch2=Product_Desciption__c&fldshow1=ERP_Product_Family_Code__c&fldshow2=&fldshow3=&txt=Product&groupbyfield1=&groupbyfield2=&wherefield1=Pricebook2Id&wherefieldvalue1=01s90000006SVvCAAW&wherecompareop1=equal&wherefield2=ERP_Product_Family_Code__c&wherefieldvalue2=FGMSN&wherecompareop2=equal&wherefield3=undefined&wherefieldvalue3=undefined&wherecompareop3=undefined&frm=frmPromote');
        objGTLookup.performSearch('Product');

        Page = new PageReference('https://c.ap1.visual.force.com/apex/LookupController?obj=01u&fldsrch1=ProductCode&fldsrch2=Product_Desciption__c&fldshow1=ERP_Product_Family_Code__c&fldshow2=&fldshow3=&txt=Product&groupbyfield1=&groupbyfield2=&wherefield1=Pricebook2Id&wherefieldvalue1=01s90000006SVvCAAW&wherecompareop1=equal&wherefield2=ERP_Product_Family_Code__c&wherefieldvalue2=FGMSN&wherecompareop2=equal&wherefield3=ERP_Product_Family_Code__c&wherefieldvalue3=FGMSN&wherecompareop3=notequal&frm=frmPromote');
        objGTLookup.performSearch('Product');

        Page = new PageReference('https://c.ap1.visual.force.com/apex/LookupController?obj=01u&fldsrch1=ProductCode&fldsrch2=Product_Desciption__c&fldshow1=ERP_Product_Family_Code__c&fldshow2=&fldshow3=&txt=Product&groupbyfield1=&groupbyfield2=&wherefield1=Pricebook2Id&wherefieldvalue1=01s90000006SVvCAAW&wherecompareop1=equal&wherefield2=ERP_Product_Family_Code__c&wherefieldvalue2=FGMSN&wherecompareop2=equal&wherefield3=ERP_Product_Family_Code__c&wherefieldvalue3=FGMSN&wherecompareop3=in&frm=frmPromote');
        objGTLookup.performSearch('Product');

        objGTLookup.runSearch(); 

        /////LookupController End/////

        /////Unlink Customer////
        Account a = new Account();
        a.ERP_Customer_Number__c = '3GNEW';
        a.Integration_Key__c='';   
        a.ERP_Company_Code__c='SAMINC';
        a.Name = 'ABC';
        insert a;

        Contact c = new Contact();
        c.AccountId= a.Id;
        c.LastName= 'XYZ';
        insert c;

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= a.Id;
        insert objShipto;


        UnlinkAccountController UNC = new UnlinkAccountController();
        list<String> lstAct = new list<String>();
        lstAct.add(a.Id);

        list<Account> actLst=new list<Account>();
        Set<Id> newRecord= new Set<Id>();
        UNC.PAGE_SIZE = 1;

        UNC.doNext();
        UNC.doPrevious();
        UNC.getHasPrevious();
        UNC.getHasNext();

        UnlinkAccountController.UnlinkCustomers(lstAct);   

        Ship_To__c sTo= new Ship_To__c();

        UNC.GetLinkedAccounts();
        UNC.ClearAll();

        /////Unlink Customer End////

        ////////////ReadAndWriteXML/////////////////////

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
        list<ReadAndWriteXML.XmlNode> xmlNodeLst = new list<ReadAndWriteXML.XmlNode>();
        xmlNodeLst = ReadAndWriteXML.getXmlNode()  ;

        //////Utility/////////////
        Utility Utl = new Utility(); 
        XMLString = Utility.getResourceContent('ParamConfig');
        XMLString = Utility.getResourceContent('ParamConfig12');
        Utility.FetchNameSpace();
        string strObjPref = Utility.getSobjectKeyPrefix('Account');
        strObjPref = Utility.getSobjectKeyPrefix('Account123');
        //string strObjname = Utility.getSobjectName('null');
        string strObjname = Utility.getSobjectName('001');

        Map<String,String> formatCon =  Utility.FormatConnectionPairs('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>');
        formatCon =  Utility.FormatConnectionPairs('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" ><PARAMNAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>');

        list<Utility.ERP> lstLoadParams=Utility.LoadParams();
        String response='';
        ReadAndWriteXML.XmlNode prepareRcrd1; 

        //need to remove commnets
        map<string,list<object>> AttribParameters  = Utility.getAttribParameters('1', '200', Config.Id, 'Customer','', Helper.MappingPurpose.DISPLAY);  
        AttribParameters  = Utility.getAttribParameters('1', '200', Config.Id, 'Customer','', Helper.MappingPurpose.DISPLAY);
        AttribParameters  = Utility.getAttribParameters('', '200', Config.Id, 'Customer','', Helper.MappingPurpose.DISPLAY);
        AttribParameters  = Utility.getAttribParameters('1', '0', Config.Id, 'Customer','Include', Helper.MappingPurpose.DISPLAY);

        string EndPoint='http://49.248.14.235:28880/adxwsvc/services/CAdxWebServiceXmlCC';
        string request='<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wss="http://www.adonix.com/WSS"><soapenv:Header/><soapenv:Body><wss:run soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><callContext xsi:type="wss:CAdxCallContext"><codeLang xsi:type="xsd:string">ENG</codeLang><codeUser xsi:type="xsd:string">ADMIN</codeUser><password xsi:type="xsd:string">admin</password><poolAlias xsi:type="xsd:string">NATRAINV6</poolAlias></callContext><publicName xsi:type="xsd:string">YGTSOLST</publicName><inputXml xsi:type="xsd:string"><![CDATA[<?xml version="1.0" encoding="UTF-8"?> <PARAM> <TAB ID="AX_PAR"> <LIN NUM="1"> <FLD NAME="AXPARCOD">$REC_MAX</FLD> <FLD NAME="AXPARVAL">10</FLD> </LIN> <LIN NUM="2"> <FLD NAME="AXPARCOD">$REC_STARTAT</FLD> <FLD NAME="AXPARVAL">1</FLD> </LIN> <LIN NUM="3"> <FLD NAME="AXPARCOD">$TOTAL_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="4"> <FLD NAME="AXPARCOD">$RET_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="5"> <FLD NAME="AXPARCOD">$HAS_NEXT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> </TAB><TAB ID="AX_WHR" ><LIN NUM="1" ><FLD NAME="AXWHRLFTBRK" >0</FLD><FLD NAME="AXWHRCOD" >BPCORD</FLD><FLD NAME="AXWHROPE" >2</FLD><FLD NAME="AXWHRCODVAL" >C2201</FLD><FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN><LIN NUM="1" ><FLD NAME="AXWHRLFTBRK" >0</FLD><FLD NAME="AXWHRCOD" >ORDSTA</FLD><FLD NAME="AXWHROPE" >2</FLD><FLD NAME="AXWHRCODVAL" >1</FLD><FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB> </PARAM> ]]></inputXml></wss:run></soapenv:Body></soapenv:Envelope>';
        Utility.httpRequest(EndPoint, request);
        map<string ,string> mapFormatERPInfo =Utility.FormatERPInfo('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','<PARAM NAME="Username"  VALUE="ADMIN" />','<PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>');
        mapFormatERPInfo =Utility.FormatERPInfo('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','NAME');
        mapFormatERPInfo =Utility.FormatERPInfo('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','NAME','+');
        mapFormatERPInfo =Utility.FormatERPInfo('PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','</PARAMS></PARAM NAME="CompanyCode"  VALUE="SAMINC" />','');

        string strdate = Utility.dateFormat('2015-01-01');
        strdate = Utility.dateFormat('201');

        string strEncrypt = Utility.Encrypt('sfadmin123');
        strEncrypt = Utility.Encrypt('XIx+5GgjZ8EmAWMQz2eG0hdJvnESyEnQh02qJjW40Es=');        
        string strDecrypt = Utility.Decrypt('sfadmin123');

        Helper.GUMU_Response pGUMU_Response = new Helper.GUMU_Response();
        
        pGUMU_Response.statusCode='200';
        pGUMU_Response.statusMessage='abc';
        pGUMU_Response.TotalRecord='10';

        Utility.ImportResult  ImportResults =Utility.setERPResponse(pGUMU_Response,'1','20');
        ImportResults =Utility.setERPResponse(pGUMU_Response,'','20');
        ImportResults =Utility.setERPResponse(pGUMU_Response,'1','0');

        pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.statusCode='1';
        pGUMU_Response.statusMessage='abc';
        ImportResults =Utility.setERPResponse(pGUMU_Response,'1','20');

        Utility.Result rs = new Utility.Result();
        rs.InqList='';
        Utility.Dropdown dp = new Utility.Dropdown();
        dp.Code='';
        dp.Description='';

        //////Utility End/////////////

        ///Linked customer
        LinkAccountController linkcust = new LinkAccountController();
        linkcust.FirstName='';
        linkcust.LastName='';
        linkcust.SalesObjectPrefix='';
        //linkcust.lstAccounts='';
        linkcust.Criteria='';

        linkcust.getItems(); 
        linkcust.doNext();
        linkcust.getFields();
        linkcust.doPrevious();
        boolean hasprev = linkcust.getHasPrevious();
        boolean hasNext =linkcust.getHasNext();
        PageReference umPage =linkcust.GetUnlinkAccounts() ;

        list<map<string,string>> lstCustMapping =new list<map<string,string>>();

        map<string,string> mapLinkCust = new map<string,string>();
        mapLinkCust.put('AccountKey',a.Id);
        mapLinkCust.put('AccountNumber','');
        mapLinkCust.put('IntegrationKey',Config.Id);
        mapLinkCust.put('LinkedCustomer','Test - 02');
        lstCustMapping.add(mapLinkCust);

        mapLinkCust = new map<string,string>();
        mapLinkCust.put('AccountKey','');
        mapLinkCust.put('AccountNumber','');
        mapLinkCust.put('IntegrationKey',Config.Id);
        mapLinkCust.put('LinkedCustomer','Test - 03');
        lstCustMapping.add(mapLinkCust);
        boolean bFirst =LinkAccountController.SaveLinkCustomer(lstCustMapping);


        //List<LinkAccountController.Customer> lstCustomersX3 = new List<LinkAccountController.Customer>();
        //lstCustomersX3 = LinkAccountController.CustomerList(Config.Id,'AC.CustomerName','Equal','a');
        //lstCustomersX3 = LinkAccountController.CustomerList(Config.Id,'AC.City','Equal','a');
        //lstCustomersX3 = LinkAccountController.CustomerList(Config.Id,'AC.State','Equal','a');
        //lstCustomersX3 = LinkAccountController.CustomerList(Config.Id,'AC.Country','Equal','a');

        //lstCustomersX3 = LinkAccountController.CustomerList(Config.Id,'AC.CustomerName','Like','a');


        list<map<string,string>> lstAccountSet = new list<map<string,string>>();

        map<string,string> oMapx; 
        oMapx = new map<string,string>();
        oMapx.put('IntegrationKey',Config.Id);
        oMapx.put('MatchingCriteria','AC.CustomerName');
        oMapx.put('MatchingCriteriaValue','C2201');
        lstAccountSet.add(oMapx);

        oMapx = new map<string,string>();
        oMapx.put('IntegrationKey',Config.Id);
        oMapx.put('MatchingCriteria','AC.CustomerName');
        oMapx.put('MatchingCriteriaValue','Ameriacan');
        lstAccountSet.add(oMapx);

        oMapx = new map<string,string>();
        oMapx.put('IntegrationKey',Config.Id);
        oMapx.put('MatchingCriteria','AC.CustomerName');
        oMapx.put('MatchingCriteriaValue','Brazil');
        lstAccountSet.add(oMapx);

        list<LinkAccountController.MatchCustomer> lstMatchCustomersX3 = new List<LinkAccountController.MatchCustomer>();
        lstMatchCustomersX3 = LinkAccountController.GetERPCustomer(lstAccountSet);

        string strExistingcust=LinkAccountController.GetExistingLinkcustomer('Config.Id','3GNEW');

        LinkAccountController.UnlinkAccounts unlacc = new LinkAccountController.UnlinkAccounts ();
        unlacc.Id='';
        unlacc.AccountNumber='';
        unlacc.AccountName='';
        unlacc.BillingCity='';
        unlacc.BillingState='';
        unlacc.BillingCountry='';
        unlacc.ConfigId ='';
        unlacc.Index ='';

        LinkAccountController.MatchCustomer matchCust = new LinkAccountController.MatchCustomer();
        matchCust.AccountId='';
        matchCust.CustomerNumber ='';
        matchCust.CustomerName ='';

        LinkAccountController.Customer Cust = new LinkAccountController.Customer();
        Cust.UniqueKey ='';
        Cust.ARDivisionNo ='';
        Cust.CustomerName='';

        //Linked customer

        //ImportDataController
        sObject sObj;
        for(string sDescribe:globalDescribe.keySet()) {
            Schema.SObjectType objType = globalDescribe.get(sDescribe);
            if(objType != null) {
                if(objType.getDescribe().getName().endsWith('ERP_Config__c'))
                {
                    sObj = objType.newSObject();
                    break;
                }
            }
        }
        ApexPages.StandardController sc = new ApexPages.StandardController(sObj);
        ImportDataController impData = new ImportDataController(sc);
        impData.IntegrationNames='';
        impData.IntegrationKey=Config.Id;
        impData.ERPSystemName='';
        impData.ERPCompanyCode='';
        impData.Synchronization='';
        impData.ERPSystem='';
        impData.UpdateDate=system.today();

        pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.statusCode='1';
        pGUMU_Response.statusMessage='abc';
        ImportResults =Utility.setERPResponse(pGUMU_Response,'1','20');

        impData.LoadParams();

        Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC2';
        Config.Web_Service_URL__c = 'http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM';
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>'; 
        Config.Synchronization__c='Both';
        insert Config;
        ImportDataController.FetchConfig(Config.Id);

        list<string> lstObjs = new list<string>(); 
        list<Account> lstAccounts = new list<Account>(); 
        a = new Account();
        a.ERP_Customer_Number__c = '3ganony';
        a.Integration_Key__c='';   
        a.ERP_Company_Code__c='SAMINC';
        a.Name = 'somanitc';
        insert a;
        lstObjs.add(a.id);
        lstAccounts.add(a);

        a = new Account();
        a.ERP_Customer_Number__c = 'sasan2';
        a.Integration_Key__c=Config.Id;   
        a.ERP_Company_Code__c='SAMINC';
        a.Name = 'sasan';
        insert a;
        lstObjs.add(a.id);
        lstAccounts.add(a);

        pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.statusCode='1';
        pGUMU_Response.statusMessage='abc';
        pGUMU_Response.responseSFData=lstAccounts;

        list<Account> objAccount=(list<Account>) pGUMU_Response.responseSFData;
        
        impData.ImportEntity = 'Customer';
        impData.ImportIntegrationKey = Config.Id;
        impData.Param1 = '01/01/2006';
        impData.Param2 = '';
        
        impData.ImportData();
        
        impData.Param1 = '1550';
        impData.Param2 = '1550';
        
        
        impData.ImportData();
        
        /*
        ImportDataController.ImportCustomers(Config.Id, 'ByDate', '01/01/2006', '', '0', '','');
        ImportDataController.ImportCustomers(':', 'ByDate', '01/01/2006', '', '0', '','');
        ImportDataController.ImportCustomers(':', 'ByDate', '01/01/', '', '0', '','');
        ImportDataController.ImportCustomers(Config.Id, 'Customer', '1550', '1550', '0', '','');
        */
        
        PageReference pageref1 = impData.GetERPName();

        //ImportDataController.ImportShipTo_Sage300(Config.Id,'Customer','','','1','20',lstObjs);
        //ImportDataController.ImportShipTo_Sage300(Config.Id,'Customer','','','','20',lstObjs);
        //ImportDataController.ImportShipTo_Sage300(Config.Id,'Customer','','','1','0',lstObjs);
        //End of ImportDataController


        //GUMUCustomerController

        Data_Page__c  dataPage = new Data_Page__c();
        dataPage.Description__c='Customer_Detail';
        dataPage.ERP_Function__c='arCustomersFinder';
        dataPage.ERP_System__c='Sage300ERP';
        dataPage.Display_Name__c='GUMUCustomerInfo'; 
        dataPage.Name='Customer';     
        dataPage.Type__c ='List';
        insert dataPage;


        ApexPages.currentPage().getParameters().put('Id',a.Id); 
        sObject sObj1 = Schema.getGlobalDescribe().get('Account').newSObject() ;

        ApexPages.StandardController sc1 = new ApexPages.StandardController(sObj1); 
        AccountInfoController gumuCust = new AccountInfoController(sc1);
        Component.Apex.PageBlock bpBlock;// =gumuCust.GetInquiryPageBlock();
        //bpBlock =gumuCust.GetCustomerDnyPage();

        Component.Apex.OutputPanel GetInquiryLinks = gumuCust.GetInquiryLinks();
        //bpBlock = gumuCust.GetInquiryLinksWithDescription();

        // End  AccountInfoController

        //Begin Sage300IntegrationFramework 
        list<string> ConnectionParameters  = new list<string>();
        ConnectionParameters.add('CompanyCode=SAMINC');
        ConnectionParameters.add('Username=ADMIN'); 
        ConnectionParameters.add('Password=ADMIN'); 

        Sage300IntegrationFramework sag300IntgrFrm = new Sage300IntegrationFramework();
        boolean isconnected=sag300IntgrFrm.TestConnection(EndPoint,ConnectionParameters);

        //{IDCUST={EQUAL=(3GNEW)}}
        list<string> CustNo  = new list<string>();
        custno.add('1200');
        map<string,list<string>> Params1 = new map<string,list<string>>();
        Params1.put('EQUAL',custno);

        map<string,map<string,list<string>>> Params = new map<string,map<string,list<string>>>();
        Params.put('IDCUST',Params1);

        list<object> objcts = new list<object>();
        objcts.add(Config.Id);
        map<string,list<object>> Attributes = new map<string,list<object>>();
        Attributes.put('IntegrationId',objcts);

        objcts = new list<object>();
        Helper.MappingPurpose  maptype = Helper.MappingPurpose.DISPLAY;
        objcts.add(maptype);
        Attributes.put('MappingPurpose',objcts); 

        objcts = new list<object>();
        objcts.add('Customer');
        Attributes.put('SourceEntity',objcts);

        objcts = new list<object>();
        objcts.add('200');
        Attributes.put('count',objcts);

        objcts = new list<object>();
        objcts.add('1');
        Attributes.put('startIndex',objcts);

        Entity_Mapping_Header__c EntityMap = new Entity_Mapping_Header__c();
        EntityMap.ERP_Function__c='arCustomersFinder';
        EntityMap.ERP_System__c='Sage300ERP';
        EntityMap.Entity_Mapping_Name__c='Accounts-Customer';
        EntityMap.Source_Entity__c='Customer';
        EntityMap.Sync_Direction__c='Two Way';
        EntityMap.Target_Entity__c='Account';
        insert EntityMap;

        EntityMap = new Entity_Mapping_Header__c();
        EntityMap.ERP_Function__c='arShiptoLocationsFinder';
        EntityMap.ERP_System__c='Sage300ERP';
        EntityMap.Entity_Mapping_Name__c='Ship To - Ship To Locations';
        EntityMap.Source_Entity__c='ShipTo';
        EntityMap.Sync_Direction__c='Two Way';
        EntityMap.Target_Entity__c='Ship_To__c';
        insert EntityMap;

        Data_Page_Section__c dataPageSec = new Data_Page_Section__c(); 
        dataPageSec.Data_Page_Id__c = dataPage.Id;
        dataPageSec.Default_Section__c = true;
        dataPageSec.ERP_System__c='Sage300ERP';
        dataPageSec.Related_List_Name__c = 'oeorderdetails';
        dataPageSec.Section_Detail_Type__c='';
        dataPageSec.Section_Name__c='Processing';
        dataPageSec.Sort_Order__c=1;
        insert dataPageSec;

        dataPage = new Data_Page__c();
        dataPage.Description__c='Customer_Detail';
        dataPage.ERP_Function__c='arCustomersFinder';
        dataPage.ERP_System__c='Sage300ERP';
        dataPage.Display_Name__c='Customer'; 
        dataPage.Name='Customer';    
        dataPage.Type__c ='Detail';
        insert dataPage;

        dataPageSec = new Data_Page_Section__c(); 
        dataPageSec.Data_Page_Id__c = dataPage.Id;
        dataPageSec.Default_Section__c = true;
        dataPageSec.ERP_System__c='Sage300ERP';
        dataPageSec.Related_List_Name__c = 'oeorderdetails';
        dataPageSec.Section_Detail_Type__c='';
        dataPageSec.Section_Name__c='Processing';
        dataPageSec.Sort_Order__c=1;
        insert dataPageSec;

        list<map<string,string>> ERPDataMapLst = new list<map<string,string>>(); 
        map<string,string> ERPDataMap = new map<string,string>();
        ERPDataMap.put('SHPVIADESC','Cross-Country Trucking Lines');
        ERPDataMapLst.add(ERPDataMap);

        ERPDataMap = new map<string,string>();
        ERPDataMap.put('FOB','In transit');
        ERPDataMapLst.add(ERPDataMap);

        ERPDataMap = new map<string,string>();
        ERPDataMap.put('CODETAXGRP','CALIF');
        ERPDataMapLst.add(ERPDataMap);


        Helper.GUMU_Response resp = new Helper.GUMU_Response();
        resp.responseERPData = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:http="http://schemas.sage.com/sdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 3GNEW</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)</id><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="3GNEW" sdata:url="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)"><IDCUST>3GNEW</IDCUST><NAMECUST>3G Homes</NAMECUST><TEXTSNAM>3G Homes</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT xsi:nil="false"/><CODECURN>USD</CODECURN><NAMECITY>BRACKNELL</NAMECITY><CODESTTE>Berkshire</CODESTTE><CODECTRY>United Kingdom</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Popes Manor</TEXTSTRE1><TEXTSTRE2>Murrell Hill Lane</TEXTSTRE2><TEXTSTRE3>Binfield</TEXTSTRE3><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>RG42 4DA</CODEPSTL><TEXTPHON1>1344897 8791</TEXTPHON1><TEXTPHON2>1344897 8701</TEXTPHON2><NAMECTAC>Clemence Stickings</NAMECTAC><PRICLIST xsi:nil="false"/><DATEINAC xsi:nil="true"/><DATELASTMN>2012-11-12</DATELASTMN><CODETERR xsi:nil="false"/><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>1344897 8791</CTACPHONE><PAYMCODE xsi:nil="false"/><AMTCRLIMT>120000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>USDTAX</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2012111222382013ADMIN___SAMINC</http:etag></entry></feed>';
        resp.statusCode='200';
        resp.statusMessage='Ok';
        resp.ERPDataMap=ERPDataMapLst;
        
        resp = sag300IntgrFrm.getMapForXML(resp,Attributes);
        map<string,map<string,list<string>>> PrepareFieldParam = sag300IntgrFrm.PrepareFieldParam('test','test2');
        Helper.GUMU_Response GumuResp =sag300IntgrFrm.getData(Params,Attributes);
        // GumuResp = sag300IntgrFrm.getMapForXML(resp);
        //GumuResp = sag300IntgrFrm.getMapForXML(resp,Attributes);
        //GumuResp = sag300IntgrFrm.getAccounts(1,'Customer',Config.Id,Params,'10','1');

        a = new Account();
        a.ERP_Customer_Number__c = '1200';
        a.Integration_Key__c=Config.Id;   
        a.ERP_Company_Code__c='SAMINC';
        a.Name = 'sasan';
        insert a;

        c = new Contact();
        c.AccountId= a.Id;
        c.LastName= 'XYZ';
        insert c;

        objShipto = new Ship_To__c();
        objShipto.Account_Id__c= a.Id;
        insert objShipto;

        list<Ship_To__c> lstShipTo =sag300IntgrFrm.GetLocations(Config,EntityMap.Id,resp.ERPDataMap);
        
        list<Contact> lstContact = sag300IntgrFrm.getContacts(Config.Id,'Contact',resp);
        list<Ship_To__c> lstSgipTo = sag300IntgrFrm.GetAddresses(Config.Id,'ShipTo',resp);
        //objAccount =sag300IntgrFrm.InsertOrUpdateCustomers(Config,EntityMap,resp.ERPDataMap);
        //list<Ship_To__c> lstShipTo =sag300IntgrFrm.InsertOrUpdateShipToLocations(Config,EntityMap,resp.ERPDataMap);
        //lstShipTo =sag300IntgrFrm.InsertOrUpdateSalesOrder(Config,EntityMap,resp.ERPDataMap);
        //list<Contact> lstContact =sag300IntgrFrm.InsertOrUpdateContacts(Config.Id,resp.ERPDataMap);
        List<Helper.Customer> lstCustomer= sag300IntgrFrm.GetGenericCustomers(resp);

        //End AccountInfoController 1200

        //BaseIntegrationFramework
        //BaseIntegrationFramework baseIngrFrm = new BaseIntegrationFramework();
        string strERPDataMapRelSection='{"oeorderdetails":[{"lotnumbers":"","serialnumbers":"","kits":"","BOMs":"","CALC_INSTRUCTIONS":"","CALC_COMMENTS":"","CALC_QTYAVAIL":"196 Ea.","CALC_ITEMNO_MISCCHARGE":"A1-103/0","COMPLETE":"3","SIMPLEPCHK":"0","DRIVENBYUI":"false","TINCLUDED5":"false","TINCLUDED4":"false","TINCLUDED3":"false","TINCLUDED2":"false","TINCLUDED1":"false","TCLASS5":"0","TCLASS4":"0","TCLASS3":"0","TCLASS2":"1","TCLASS1":"1","LASTCOST":"18.750000","AVGCOST":"20.258832","COST2":"0.000000","COST1":"0.000000","MOSTREC":"20.296944","STDCOST":"0.000000","CATEGORY":"A1","UNITPRCDEC":"2","PRPRICEBY":"1","WEIGHTUNIT":"lbs.","PRWGHTUNIT":"lbs.","PRICEUNIT":"Ea.","PRICEOVER":"false","PRICELIST":"USA","COMMINST":"true","QTYCOMMIT":"0.0000","EDCORDMISC":"0.000","INVDISC":"0.000","DISCPER":"0.00000","EXTINVMISC":"0.000","PRIUNTPRC":"59.990000","ORDUNIT":"Ea.","QTYSHPTODT":"10.0000","QTYBACKORD":"0.0000","QTYSHIPPED":"0.0000","QTYORDERED":"0.0000","LOCDESC":"Port of San Fancisco","LOCATION":"4","DESC":"Fluorescent Desk Lamp","MISCCHARGE":"","UNFMTITEM":"A11030","ITEM":"A1-103/0","LINETYPE":"1","DDTLNO":"","DETAILNUM":"1"},{"lotnumbers":"","serialnumbers":"","kits":"","BOMs":"","CALC_INSTRUCTIONS":"","CALC_COMMENTS":"","CALC_QTYAVAIL":"90 Ea.","CALC_ITEMNO_MISCCHARGE":"A1-105/0","COMPLETE":"3","SIMPLEPCHK":"0","DRIVENBYUI":"false","TINCLUDED5":"false","TINCLUDED4":"false","TINCLUDED3":"false","TINCLUDED2":"false","TINCLUDED1":"false","TCLASS5":"0","TCLASS4":"0","TCLASS3":"0","TCLASS2":"1","TCLASS1":"1","LASTCOST":"3.350000","AVGCOST":"3.626000","COST2":"0.000000","COST1":"0.000000","MOSTREC":"3.626300","STDCOST":"0.000000","CATEGORY":"A1","UNITPRCDEC":"2","PRPRICEBY":"1","WEIGHTUNIT":"lbs.","PRWGHTUNIT":"lbs.","PRICEUNIT":"Ea.","PRICEOVER":"false","PRICELIST":"USA","COMMINST":"true","QTYCOMMIT":"0.0000","EDCORDMISC":"0.000","INVDISC":"0.000","DISCPER":"0.00000","EXTINVMISC":"0.000","PRIUNTPRC":"7.100000","ORDUNIT":"Ea.","QTYSHPTODT":"5.0000","QTYBACKORD":"0.0000","QTYSHIPPED":"0.0000","QTYORDERED":"0.0000","LOCDESC":"Port of San Fancisco","LOCATION":"4","DESC":"13W Mini Fluorescent Bulb","MISCCHARGE":"","UNFMTITEM":"A11050","ITEM":"A1-105/0","LINETYPE":"1","DDTLNO":"","DETAILNUM":"2"}]}';
        map<string,list<map<string,string>>> RecordList=(map<string,list<map<string,string>>>)JSON.deserializeStrict(strERPDataMapRelSection,map<string,list<map<string,string>>>.class);

        resp = new Helper.GUMU_Response();
        resp.responseERPData = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:http="http://schemas.sage.com/sdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 3GNEW</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)</id><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="3GNEW" sdata:url="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)"><IDCUST>3GNEW</IDCUST><NAMECUST>3G Homes</NAMECUST><TEXTSNAM>3G Homes</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT xsi:nil="false"/><CODECURN>USD</CODECURN><NAMECITY>BRACKNELL</NAMECITY><CODESTTE>Berkshire</CODESTTE><CODECTRY>United Kingdom</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Popes Manor</TEXTSTRE1><TEXTSTRE2>Murrell Hill Lane</TEXTSTRE2><TEXTSTRE3>Binfield</TEXTSTRE3><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>RG42 4DA</CODEPSTL><TEXTPHON1>1344897 8791</TEXTPHON1><TEXTPHON2>1344897 8701</TEXTPHON2><NAMECTAC>Clemence Stickings</NAMECTAC><PRICLIST xsi:nil="false"/><DATEINAC xsi:nil="true"/><DATELASTMN>2012-11-12</DATELASTMN><CODETERR xsi:nil="false"/><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>1344897 8791</CTACPHONE><PAYMCODE xsi:nil="false"/><AMTCRLIMT>120000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>USDTAX</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2012111222382013ADMIN___SAMINC</http:etag></entry></feed>';
        resp.statusCode='200';
        resp.statusMessage='Ok';
        resp.ERPDataMap=ERPDataMapLst;
        resp.ERPDataMapRelSection=RecordList;
        resp.startIndex='1';
        resp.totalRecord='200';
        resp.itemPerPage='10';

        list<Utility.PageComponent> pageComp= sag300IntgrFrm.getPageComponent('Sales_Order_Details', resp);

        //End BaseIntegrationFramework


        //Helper
        Helper ohelper = new Helper(); 
        ohelper.getERP();

        list<object> lstObject = new list<object>();
        lstObject.add('A1-103/0');
        lstObject.add('A1-105/0');
        lstObject.add('True');

        list< Utility.PageComponent> lstPgComp= new list< Utility.PageComponent>();
        Utility.PageComponent pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Text';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';

        lstPgComp.add(pgComp) ;
        string strPrepareTable=Helper.prepareTable(lstPgComp);

        bpBlock=Helper.prepareFilterSection(lstPgComp, resp, 1);
        bpBlock=Helper.prepareTabPage(lstPgComp, resp, 1); 

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Section';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Date';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        strPrepareTable=Helper.prepareTable(lstPgComp);
        bpBlock=Helper.prepareFilterSection(lstPgComp, resp, 1);

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Checkbox';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        strPrepareTable=Helper.prepareTable(lstPgComp);
        bpBlock=Helper.prepareFilterSection(lstPgComp, resp, 1);

        lstObject = new list<object>();
        lstObject.add('2015-01-01');

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Date';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        bpBlock=Helper.prepareFilterSection(lstPgComp, resp, 1);


        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Section';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Grid';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);

        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Grid';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        bpBlock=Helper.prepareTabPage(lstPgComp, resp, 1);

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Checkbox';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        strPrepareTable=Helper.prepareTable(lstPgComp);
        bpBlock=Helper.prepareTabPage(lstPgComp, resp, 1);

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Date';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        strPrepareTable=Helper.prepareTable(lstPgComp);
        bpBlock=Helper.prepareTabPage(lstPgComp, resp, 1);


        lstObject = new list<object>();
        lstObject.add('**NA**');
        lstObject.add('A1-105/0');
        lstObject.add('**NA**');

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Number';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='asdasdasd';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        strPrepareTable=Helper.prepareTable(lstPgComp);
        //bpBlock=Helper.prepareTabPage(lstPgComp, resp, 1);

        lstPgComp= new list< Utility.PageComponent>();



        //END Helper           

    }

    static testMethod void runTestCases1()
    { 

        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC1';
        Config.Web_Service_URL__c = 'http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>'; 
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        insert Config;

        system.assertEquals('Sage 300 ERP - SAMINC1', config.Name);
        
        GUMU_App_Setting__c delApp =[select Id from GUMU_App_Setting__c limit 1];
        delete delApp;
        GUMU_App_Setting__c app = new GUMU_App_Setting__c();

        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage 300 ERP';
        app.ERP_System__c='Sage300ERP';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;
        

        string EndPoint='http://49.248.14.235:28880/adxwsvc/services/CAdxWebServiceXmlCC';
        //Begin Sage300IntegrationFramework 
        list<string> ConnectionParameters  = new list<string>();
        ConnectionParameters.add('CompanyCode=SAMINC');
        ConnectionParameters.add('Username=ADMIN'); 
        ConnectionParameters.add('Password=ADMIN'); 

        Sage300IntegrationFramework sag300IntgrFrm = new Sage300IntegrationFramework();
        boolean isconnected=sag300IntgrFrm.TestConnection(EndPoint,ConnectionParameters);
        
        Data_Page__c dataPage = new Data_Page__c();
        dataPage.Description__c='';
        dataPage.ERP_Function__c='oeOrders';
        dataPage.ERP_System__c='Sage300ERP';
        dataPage.Display_Name__c='Customer';  
        dataPage.Name='Customer';       
        dataPage.Type__c ='List';
        insert dataPage;
        
        //{IDCUST={EQUAL=(3GNEW)}}
        list<string> CustNo  = new list<string>();
        custno.add('1200');
        map<string,list<string>> Params1 = new map<string,list<string>>();
        Params1.put('EQUAL',custno);

        map<string,map<string,list<string>>> Params = new map<string,map<string,list<string>>>();
        Params.put('IDCUST',Params1);

        list<object> objcts = new list<object>();
        objcts.add(Config.Id);
        map<string,list<object>> Attributes = new map<string,list<object>>();
        Attributes.put('IntegrationId',objcts);

        objcts = new list<object>();
        Helper.MappingPurpose  maptype = Helper.MappingPurpose.DISPLAY;
        objcts.add(maptype);
        Attributes.put('MappingPurpose',objcts);

        objcts = new list<object>();
        objcts.add('Customer');
        Attributes.put('SourceEntity',objcts);

        objcts = new list<object>();
        objcts.add('200');
        Attributes.put('count',objcts);

        objcts = new list<object>();
        objcts.add('1');
        Attributes.put('startIndex',objcts);
  
        Helper.GUMU_Response GumuResp =sag300IntgrFrm.getData(Params,Attributes);

        CustNo  = new list<string>();
        custno.add('1200');
        Params1 = new map<string,list<string>>();
        Params1.put('RANGE',custno);

        Params = new map<string,map<string,list<string>>>();
        Params.put('IDCUST',Params1); 

        objcts = new list<object>();
        objcts.add(Helper.MappingPurpose.SYNC);
        Attributes.put('MappingPurpose',objcts);

        objcts = new list<object>();
        objcts.add('Customer');
        Attributes.put('SourceEntity',objcts);

        objcts = new list<object>();
        objcts.add('200');
        Attributes.put('count',objcts);

        objcts = new list<object>();
        objcts.add('1');
        Attributes.put('startIndex',objcts);

        GumuResp =sag300IntgrFrm.getData(Params,Attributes);


        CustNo  = new list<string>();
        custno.add('1200');
        Params1 = new map<string,list<string>>();
        Params1.put('GREATER_OR_EQUAL',custno);

        Params = new map<string,map<string,list<string>>>();
        Params.put('IDCUST',Params1);        
        GumuResp =sag300IntgrFrm.getData(Params,Attributes);


        CustNo  = new list<string>();
        custno.add('1200');
        Params1 = new map<string,list<string>>();
        Params1.put('LIKE_CALUSE',custno);

        Params = new map<string,map<string,list<string>>>();
        Params.put('IDCUST',Params1);        
        GumuResp =sag300IntgrFrm.getData(Params,Attributes);


        CustNo  = new list<string>();
        custno.add('1200');
        Params1 = new map<string,list<string>>();
        Params1.put('IN_CLAUSE',custno);

        Params = new map<string,map<string,list<string>>>();
        Params.put('IDCUST',Params1);        
        GumuResp =sag300IntgrFrm.getData(Params,Attributes);


        Entity_Mapping_Header__c EntityMap = new Entity_Mapping_Header__c();
        EntityMap.ERP_Function__c='arCustomersFinder';
        EntityMap.ERP_System__c='Sage300ERP';
        EntityMap.Entity_Mapping_Name__c='Accounts-Customer';
        EntityMap.Source_Entity__c='Customer';
        EntityMap.Sync_Direction__c='Two Way';
        EntityMap.Target_Entity__c='Account';
        insert EntityMap;

        EntityMap = new Entity_Mapping_Header__c();
        EntityMap.ERP_Function__c='arShiptoLocationsFinder';
        EntityMap.ERP_System__c='Sage300ERP';
        EntityMap.Entity_Mapping_Name__c='Ship To - Ship To Locations';
        EntityMap.Source_Entity__c='ShipTo';
        EntityMap.Sync_Direction__c='Two Way';
        EntityMap.Target_Entity__c='Ship_To__c';
        insert EntityMap;

        dataPage = new Data_Page__c();
        dataPage.Description__c='';
        dataPage.ERP_Function__c='oeOrders';
        dataPage.ERP_System__c='Sage300ERP';
        dataPage.Display_Name__c='Sales_Order_Details';   
        dataPage.Name='Customer';      
        dataPage.Type__c ='List';
        insert dataPage;

        Data_Page_Section__c dataPageSec = new Data_Page_Section__c(); 
        dataPageSec.Data_Page_Id__c = dataPage.Id;
        dataPageSec.Default_Section__c = true;
        dataPageSec.ERP_System__c='Sage300ERP';
        dataPageSec.Related_List_Name__c = 'oeorderdetails';
        dataPageSec.Section_Detail_Type__c='';
        dataPageSec.Section_Name__c='Processing';
        dataPageSec.Sort_Order__c=1;
        insert dataPageSec;

        dataPage = new Data_Page__c();
        dataPage.Description__c='Customer_Detail';
        dataPage.ERP_Function__c='arCustomersFinder';
        dataPage.ERP_System__c='Sage300ERP';
        dataPage.Display_Name__c='Customer'; 
        dataPage.Name='Customer';      
        dataPage.Type__c ='Detail';
        insert dataPage;

        dataPageSec = new Data_Page_Section__c(); 
        dataPageSec.Data_Page_Id__c = dataPage.Id;
        dataPageSec.Default_Section__c = true;
        dataPageSec.ERP_System__c='Sage300ERP';
        dataPageSec.Related_List_Name__c = 'oeorderdetails';
        dataPageSec.Section_Detail_Type__c='';
        dataPageSec.Section_Name__c='Processing';
        dataPageSec.Sort_Order__c=1;
        insert dataPageSec;

        list<map<string,string>> ERPDataMapLst = new list<map<string,string>>(); 
        map<string,string> ERPDataMap = new map<string,string>();
        ERPDataMap.put('SHPVIADESC','Cross-Country Trucking Lines');
        ERPDataMapLst.add(ERPDataMap);

        ERPDataMap = new map<string,string>();
        ERPDataMap.put('FOB','In transit');
        ERPDataMapLst.add(ERPDataMap);

        ERPDataMap = new map<string,string>();
        ERPDataMap.put('CODETAXGRP','CALIF');
        ERPDataMapLst.add(ERPDataMap);

        ERPDataMap = new map<string,string>();
        ERPDataMap.put('IDCUST','1200');
        ERPDataMapLst.add(ERPDataMap);

        Helper.GUMU_Response resp = new Helper.GUMU_Response();
        resp.responseERPData = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:http="http://schemas.sage.com/sdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 3GNEW</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)</id><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="3GNEW" sdata:url="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)"><IDCUST>3GNEW</IDCUST><NAMECUST>3G Homes</NAMECUST><TEXTSNAM>3G Homes</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT xsi:nil="false"/><CODECURN>USD</CODECURN><NAMECITY>BRACKNELL</NAMECITY><CODESTTE>Berkshire</CODESTTE><CODECTRY>United Kingdom</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Popes Manor</TEXTSTRE1><TEXTSTRE2>Murrell Hill Lane</TEXTSTRE2><TEXTSTRE3>Binfield</TEXTSTRE3><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>RG42 4DA</CODEPSTL><TEXTPHON1>1344897 8791</TEXTPHON1><TEXTPHON2>1344897 8701</TEXTPHON2><NAMECTAC>Clemence Stickings</NAMECTAC><PRICLIST xsi:nil="false"/><DATEINAC xsi:nil="true"/><DATELASTMN>2012-11-12</DATELASTMN><CODETERR xsi:nil="false"/><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>1344897 8791</CTACPHONE><PAYMCODE xsi:nil="false"/><AMTCRLIMT>120000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>USDTAX</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2012111222382013ADMIN___SAMINC</http:etag></entry></feed>';
        resp.statusCode='200';
        resp.statusMessage='Ok';
        resp.ERPDataMap=ERPDataMapLst;

        GumuResp = sag300IntgrFrm.getMapForXML(resp,Attributes);
        //GumuResp = sag300IntgrFrm.getAccounts(Helper.MappingPurpose.DISPLAY,'Customer',Config.Id,Params,'10','1');

        Account a = new Account();
        a.ERP_Customer_Number__c = '1200';
        a.Integration_Key__c=Config.Id;   
        a.ERP_Company_Code__c=Config.ERP_Company_Code__c;
        a.Name = 'sasan';
        insert a;

        Contact c = new Contact();
        c.AccountId= a.Id;
        c.LastName= 'XYZ';
        insert c;

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= a.Id;
        objShipto.ERP_Contact_Code__c='1200';
        insert objShipto;

        //GumuResp = sag300IntgrFrm.getContacts('',Config.Id,Params,'10','1');
        list<Account> objAccount =sag300IntgrFrm.GetCustomers(Config,EntityMap.Id,resp.ERPDataMap);
        //list<Ship_To__c> lstShipTo =sag300IntgrFrm.InsertOrUpdateShipToLocations(Config,EntityMap,resp.ERPDataMap);
        //lstShipTo =sag300IntgrFrm.GetSalesOrders(Config,EntityMap,resp.ERPDataMap);
        list<Contact> lstContact =sag300IntgrFrm.GetContacts(Config.Id,resp.ERPDataMap);

        //List<LinkAccountController.Customer> lstCustomer= sag300IntgrFrm.GetGenericCustomer(resp);

        //End AccountInfoController 1200

        //BaseIntegrationFramework
        //BaseIntegrationFramework baseIngrFrm = new BaseIntegrationFramework();
        string strERPDataMapRelSection='{"oeorderdetails":[{"lotnumbers":"","serialnumbers":"","kits":"","BOMs":"","CALC_INSTRUCTIONS":"","CALC_COMMENTS":"","CALC_QTYAVAIL":"196 Ea.","CALC_ITEMNO_MISCCHARGE":"A1-103/0","COMPLETE":"3","SIMPLEPCHK":"0","DRIVENBYUI":"false","TINCLUDED5":"false","TINCLUDED4":"false","TINCLUDED3":"false","TINCLUDED2":"false","TINCLUDED1":"false","TCLASS5":"0","TCLASS4":"0","TCLASS3":"0","TCLASS2":"1","TCLASS1":"1","LASTCOST":"18.750000","AVGCOST":"20.258832","COST2":"0.000000","COST1":"0.000000","MOSTREC":"20.296944","STDCOST":"0.000000","CATEGORY":"A1","UNITPRCDEC":"2","PRPRICEBY":"1","WEIGHTUNIT":"lbs.","PRWGHTUNIT":"lbs.","PRICEUNIT":"Ea.","PRICEOVER":"false","PRICELIST":"USA","COMMINST":"true","QTYCOMMIT":"0.0000","EDCORDMISC":"0.000","INVDISC":"0.000","DISCPER":"0.00000","EXTINVMISC":"0.000","PRIUNTPRC":"59.990000","ORDUNIT":"Ea.","QTYSHPTODT":"10.0000","QTYBACKORD":"0.0000","QTYSHIPPED":"0.0000","QTYORDERED":"0.0000","LOCDESC":"Port of San Fancisco","LOCATION":"4","DESC":"Fluorescent Desk Lamp","MISCCHARGE":"","UNFMTITEM":"A11030","ITEM":"A1-103/0","LINETYPE":"1","DDTLNO":"","DETAILNUM":"1"},{"lotnumbers":"","serialnumbers":"","kits":"","BOMs":"","CALC_INSTRUCTIONS":"","CALC_COMMENTS":"","CALC_QTYAVAIL":"90 Ea.","CALC_ITEMNO_MISCCHARGE":"A1-105/0","COMPLETE":"3","SIMPLEPCHK":"0","DRIVENBYUI":"false","TINCLUDED5":"false","TINCLUDED4":"false","TINCLUDED3":"false","TINCLUDED2":"false","TINCLUDED1":"false","TCLASS5":"0","TCLASS4":"0","TCLASS3":"0","TCLASS2":"1","TCLASS1":"1","LASTCOST":"3.350000","AVGCOST":"3.626000","COST2":"0.000000","COST1":"0.000000","MOSTREC":"3.626300","STDCOST":"0.000000","CATEGORY":"A1","UNITPRCDEC":"2","PRPRICEBY":"1","WEIGHTUNIT":"lbs.","PRWGHTUNIT":"lbs.","PRICEUNIT":"Ea.","PRICEOVER":"false","PRICELIST":"USA","COMMINST":"true","QTYCOMMIT":"0.0000","EDCORDMISC":"0.000","INVDISC":"0.000","DISCPER":"0.00000","EXTINVMISC":"0.000","PRIUNTPRC":"7.100000","ORDUNIT":"Ea.","QTYSHPTODT":"5.0000","QTYBACKORD":"0.0000","QTYSHIPPED":"0.0000","QTYORDERED":"0.0000","LOCDESC":"Port of San Fancisco","LOCATION":"4","DESC":"13W Mini Fluorescent Bulb","MISCCHARGE":"","UNFMTITEM":"A11050","ITEM":"A1-105/0","LINETYPE":"1","DDTLNO":"","DETAILNUM":"2"}]}';
        map<string,list<map<string,string>>> RecordList=(map<string,list<map<string,string>>>)JSON.deserializeStrict(strERPDataMapRelSection,map<string,list<map<string,string>>>.class);

        resp = new Helper.GUMU_Response();
        resp.responseERPData = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:http="http://schemas.sage.com/sdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 3GNEW</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)</id><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="3GNEW" sdata:url="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)"><IDCUST>3GNEW</IDCUST><NAMECUST>3G Homes</NAMECUST><TEXTSNAM>3G Homes</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT xsi:nil="false"/><CODECURN>USD</CODECURN><NAMECITY>BRACKNELL</NAMECITY><CODESTTE>Berkshire</CODESTTE><CODECTRY>United Kingdom</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Popes Manor</TEXTSTRE1><TEXTSTRE2>Murrell Hill Lane</TEXTSTRE2><TEXTSTRE3>Binfield</TEXTSTRE3><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>RG42 4DA</CODEPSTL><TEXTPHON1>1344897 8791</TEXTPHON1><TEXTPHON2>1344897 8701</TEXTPHON2><NAMECTAC>Clemence Stickings</NAMECTAC><PRICLIST xsi:nil="false"/><DATEINAC xsi:nil="true"/><DATELASTMN>2012-11-12</DATELASTMN><CODETERR xsi:nil="false"/><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>1344897 8791</CTACPHONE><PAYMCODE xsi:nil="false"/><AMTCRLIMT>120000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>USDTAX</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2012111222382013ADMIN___SAMINC</http:etag></entry></feed>';
        resp.statusCode='200';
        resp.statusMessage='Ok';
        resp.ERPDataMap=ERPDataMapLst;
        resp.ERPDataMapRelSection=RecordList;

        list<Utility.PageComponent> pageComp= sag300IntgrFrm.getPageComponent('Sales_Order_Details', resp);


        ////////Customer controller

        dataPage = new Data_Page__c();
        dataPage.Description__c='Customer_Detail';
        dataPage.ERP_Function__c='arCustomersFinder';
        dataPage.ERP_System__c='Sage300ERP';
        dataPage.Display_Name__c='GUMUCustomerInfo';     
        dataPage.Type__c ='List';
        insert dataPage;


        ApexPages.currentPage().getParameters().put('Id',a.Id); 
        sObject sObj1 = Schema.getGlobalDescribe().get('Account').newSObject() ;

        ApexPages.StandardController sc1 = new ApexPages.StandardController(sObj1); 
        AccountInfoController gumuCust = new AccountInfoController(sc1);
        Component.Apex.PageBlock bpBlock;// =gumuCust.GetInquiryPageBlock();
        //bpBlock =gumuCust.GetCustomerDnyPage();

        gumuCust.status='';
        gumuCust.endIndex=1;
        gumuCust.totalcount=10;
        gumuCust.ChildInquiry='';
        // gumuCust.CurrentTab='';
        gumuCust.ChildField='';
        gumuCust.ChildValue='';
        //gumuCust.bIntegrationInactive=true;
        // gumuCust.gERPSystemName='';
        //AccountInfoController.NameSpace='';
        //gumuCust.Inquiry='';
        // gumuCust.retURL='';
        // gumuCust.ParentText='';
        gumuCust.bShowParentURL=true;
        gumuCust.selectedPagesize=5;
        //gumuCust.FilterSection='';


        gumuCust.getCustomerEnquiries('Customer');
        gumuCust.DisplayStatus(); 
        gumuCust.navigateNext(); 
        gumuCust.navigatePrevious();
        //gumuCust.refreshTabs();
        gumuCust.ShowDataPage();
        gumuCust.DisplayDetail();
        gumuCust.BackToParent();
        gumuCust.BackToParent();
        gumuCust.updatePagesize();
        gumuCust.RefreshList();


        /////////ERPConfigurationCntlr start

        Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP1';
        Config.Name = 'Sage 300 ERP - SAMINC2';
        Config.Web_Service_URL__c = 'http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        insert Config;

        Profile p = [select id
                     from profile
                     where Name = 'System Administrator'
                     limit 1]; 

        String testemail = 'puser000@amamama.com';
        User testUser = new User(profileId = p.id, username = testemail, email = testemail,emailencodingkey = 'UTF-8',
                localesidkey = 'en_US',languagelocalekey = 'en_US', timezonesidkey = 'America/Los_Angeles',
                alias='cspu', lastname='Test');

        insert testUser;

        
        /// ConfigurationController /ConfigurationListController
        sObj1 = Schema.getGlobalDescribe().get('GUMU_Lite__ERP_Config__c').newSObject() ;
        sc1 = new ApexPages.StandardController(sObj1);
        
        ConfigurationListController oConfigLst = new ConfigurationListController(sc1);
        
        ApexPages.currentPage().getParameters().put('ConID',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','Edit'); 
        PageReference pRef = oConfigLst.ConfigDetails();
        
        ApexPages.currentPage().getParameters().put('ConID',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','New'); 
         pRef = oConfigLst.ConfigDetails();
        
        ApexPages.currentPage().getParameters().put('ConID',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','Delete'); 
        pRef = oConfigLst.deleteConfiguration();
        
        ///ConfigurationController
        ConfigurationController oConfig = new ConfigurationController(sc1);
        
        list<string> paramlist = new list<string>();
        paramlist.add('CompanyCode=SAMINC');
        paramlist.add('Username=ADMIN');
        paramlist.add('Password=ADMIN');
        
        oConfig.IntegrationKey=Config.Id;
        oConfig.WebServiceURL = Config.Web_Service_URL__c;
        oConfig.ConParams ='["CompanyCode=SAMINC","Username=ADMIN","Password=ADMIN"]';//paramlist;
        Component.Apex.PageBlockSection bpBlockSec;
        oConfig.ERPSystem='Sage300ERP';

        list<ERP_Config__c> getAvailERP = oConfig.getAvailableERPs();
        boolean IsERPConfigSettingExist= oConfig.getIsERPConfigSettingExist();
        oConfig.RequiredComapnyParams();
        
        ApexPages.currentPage().getParameters().put('ConID',Config.Id);
        ApexPages.currentPage().getParameters().put('Mode','New'); 
        pRef = oConfig.TestConnection();
        //isTestCon = ERPConfigurationCntlr.TestConnection_X3(EndPoint, ConnectionParameters,'');
        //isTestCon = ConfigurationController.ReadConnection_X3('');

    
        Map<String,String> Info=new Map<string,string>();

        Info.put('Name','Sage 300 ERP - SAMINC2');
        Info.put('WebServiceURL','http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac');
        Info.put('IntegrationInformation','<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>');
        Info.put('Inactive','false');
        Info.put('ERPSystem','Sage300ERP1');
        Info.put('CompanyCode','SAMINC'); 


        oConfig.CRUDConfig('','insert', Info);

        Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP1';
        Config.Name = 'Sage 300 ERP - SAMINC3';
        Config.Web_Service_URL__c = 'http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';       
        Config.Integration_Information_2__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Integration_Information_3__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        insert Config;
        
        ConfigurationController.configuration configCls = ConfigurationController.FetchConfig(Config.Id);
        
        oConfig.CRUDConfig(Config.id,'update', Info);
        oConfig.CRUDConfig(Config.id,'delete', Info);
        oConfig.IntegrationKey=Config.Id;
        PageReference pageref1 = oConfig.GetERPName();
        oConfig.ConfigObjectPrefix='';
        oConfig.NameSpace='';
        oConfig.UpdateDate=system.today();

        IntegrationFactory intFact = new IntegrationFactory();
        sag300IntgrFrm = new Sage300IntegrationFramework();
        IntegrationFactory.getERPProvider();
        IntegrationFactory.getIntegrationFramework();

        delApp =[select Id from GUMU_App_Setting__c limit 1];
        delete delApp;

        app = new GUMU_App_Setting__c();

        app.Activation_Key__c='123456789';
        app.Name = 'GUMU Sage ERP X3';
        app.ERP_System__c='SageERPX3';
        app.Expiration_Date__c=system.today();
        app.No_of_Users__c=10;
        insert app;
        sag300IntgrFrm = new Sage300IntegrationFramework();

        IntegrationFactory.getERPProvider();
        IntegrationFactory.getIntegrationFramework();
        test.starttest();
        
        delete [select Id from GUMU_App_Setting__c];
        list<Entity_Fields_Mapping_Detail__c> EntityMapHeaderDtlLst = [select Id from Entity_Fields_Mapping_Detail__c];
        delete EntityMapHeaderDtlLst;
        
        list<Entity_Mapping_Header__c> EntityMapHeaderLst = [select Id from Entity_Mapping_Header__c];
        delete EntityMapHeaderLst;
        
        list<Data_Page_Section__c> DataPageSecLst = [select Id from Data_Page_Section__c];
        delete DataPageSecLst;
        
        list<Data_Page__c> DataPageLst = [select Id from Data_Page__c]; 
        delete DataPageLst;
        
        
        PostInstallScript pstscrpt = new PostInstallScript();
        InstallContext ctx;
        pstscrpt.onInstall(ctx);
        
        //pstscrpt.loadPageData();
        //pstscrpt.loadPageDataSection();
        //pstscrpt.loadEntityMapHeader();
        //pstscrpt.loadEntityMapDetail();
        test.stoptest();  
        //AdministrationController//
        AdministrationController adminCntrl = new AdministrationController(); 


    }
}
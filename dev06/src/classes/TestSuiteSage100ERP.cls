@isTest(SeeAllData=false)
private class TestSuiteSage100ERP 
{
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
        Security_Matrix__c securityMatrix = new Security_Matrix__c(name = 'SM001',Promote_Customer__c=true); 
        insert securityMatrix;
        
        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 100',ERP_System__c='Sage100ERP',
                    Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="InstallationPath"  VALUE="C:\\Sage\\Sage 100 Advanced ERP\\MAS90\\Home\\" /><PARAM NAME="CompanyCode"  VALUE="ABX" /><PARAM NAME="Sage100Server"  VALUE="admin-PC" /><PARAM NAME="Username"  VALUE="admin" /><PARAM NAME="Password"  VALUE="Zm9'; 
        Config.Integration_Information_2__c = 'Ph93k8kOcel3L5gwrcfYJMxhg/vJv0xQEUasqKEw=" /><PARAM NAME="SQLServer"  VALUE="admin-PC" /><PARAM NAME="SQLCompanyInstance"  VALUE="ABX" /><PARAM NAME="WindowsDomain"  VALUE="Greytrixindia" /><PARAM NAME="WindowsUsername"  VALUE="admin" /><PARAM NAME="Windo';
        Config.Integration_Information_3__c = 'wsPassword"  VALUE="" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('Sage100ERP', Config.ERP_System__c);
        
    
    //---------------------------------------PromoteCustomerController-------------------------Start
    
        Account act = new Account();
        act.ERP_Customer_Number__c = 'saminic';
        act.Integration_Key__c=string.valueOf(Config.Id);   
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';      
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
        PromoteCustomerSage100Controller PromoteCustomerSage1001 = new PromoteCustomerSage100Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('id',act.Id);
        sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        PromoteCustomerSage100Controller PromoteCustomerSage100 = new PromoteCustomerSage100Controller(StdCntlr);
        
        PromoteCustomerSage100.InteKey =Config.Id;
        PageReference pRef = PromoteCustomerSage100.PromoteCustomer_100();
       // PromoteCustomerSage100Controller.getCustomerNumber('');
        
        list<map<String,String>> ContactCodeslist = new list<map<String,String>>();
        map<String,String> ContactCodes = new map<String,String>();
        ContactCodes.put('ContactName','john son');
        ContactCodes.put('ContactCode','0111');
        ContactCodeslist.add(ContactCodes);
        PromoteCustomerSage100.UpdateCustomer(Config.Id,'ABX',act.Id,'3GNEW',ContactCodeslist,'01');
        
        PromoteCustomerSage100.IntegrationKey =Config.Id;
        pRef = PromoteCustomerSage100.GetERPName();
        pRef = PromoteCustomerSage100.UnlinkAccount();
        
        PromoteCustomerSage100Controller.result rs = new PromoteCustomerSage100Controller.result();
        rs.Error ='' ;
        rs.CustomereNumber='';
        rs.ContactCodes = null;
        
        PromoteCustomerSage100.CustomerNo100 = '';
        PromoteCustomerSage100.TaxSchedule100 = '';
        PromoteCustomerSage100.SalesPerson100 = '';
        PromoteCustomerSage100.ArDivision100 = '';
        PromoteCustomerSage100.TermsCode100 = '';
        PromoteCustomerSage100.ShipMethod100 = '';
        PromoteCustomerSage100.customerNoDisable = false;
        pRef = PromoteCustomerSage100.PromoteCustomer_100();
        
        //-------------------------------------------AddressSageX3Controller--------------------------------------start
        delete objShipTo;
        
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
        AddressSage100Controller AddressSage1001 = new AddressSage100Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('id',objShipto.Id);
        AddressSage100Controller AddressSage1002 = new AddressSage100Controller(StdCntlr);
        
        
        AddressSage100Controller.Address  Addr = new  AddressSage100Controller.Address();
        Addr.Ship_To_Country_Code = '';
        boolean isValid = AddressSage1002.ApexMessages(Addr);
        
        Addr = new  AddressSage100Controller.Address();
        Addr.Ship_To_Code = '';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        Addr = new  AddressSage100Controller.Address();
        Addr.Ship_To_Zip_Code = '';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        AddressSage1002.pageMode = 'New';
        Addr = new  AddressSage100Controller.Address();
        Addr.Ship_To_Code = 'Corp';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        Addr = new  AddressSage100Controller.Address();
        Addr.Ship_To_State = '';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        AddressSage1002.pageMode = 'Edit';
        
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
        objShipTo.Ship_To_Code__c='Corp1'; 
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
        pRef=AddressSage1002.saveAddresses();
        pRef=AddressSage1002.savePromoteAddresses();
        
        Addr = new AddressSage100Controller.Address();
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
        AddressSage1002.SaveAddressToSF(Addr);
        
        pRef=AddressSage1002.cancelProcess();
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
        Security_Matrix__c securityMatrix = new Security_Matrix__c(name = 'SM001',Promote_Customer__c=true); 
        insert securityMatrix;
        
        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 100',ERP_System__c='Sage100ERP',
                    Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('Sage100ERP',Config.ERP_System__c);
        

        Account act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';       
        act.ERP_Company_Code__c='SAMINC';
        act.Name = 'saminic';
        act.Integration_Key__c = Config.Id;
        act.AR_DivisonNo__c ='01';
        insert act;
        
        Contact cnt = new Contact();
        cnt.AccountId= act.Id;
        cnt.LastName= 'son';
        cnt.FirstName= 'john';
        insert cnt;

        Ship_To__c objShipto = new Ship_To__c();
        objShipto.Account_Id__c= act.Id;
        objShipto.isShipTo__c ='Yes' ; 
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
      
        //----------------------------------------------SalesOrder100Controller------------------------------start
                        
        sObject sObj = Schema.getGlobalDescribe().get('Order').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        SalesOrder100Controller SalesOrder1001 = new SalesOrder100Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('Id',objOrder.Id);
        
        sObj = Schema.getGlobalDescribe().get('Order').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        SalesOrder100Controller SalesOrder100 = new SalesOrder100Controller(StdCntlr);
        
        list<SalesOrder100Controller.LineItem> OrderProduct=  SalesOrder100Controller.getOrderProduct(objOrder.Id);
        
         map<String,String> LoadAccountData =SalesOrder100Controller.LoadAccountData(act.Id);
         
         String Salesperson =SalesOrder100Controller.GetSalesperson(Config.Id);
         
         Ship_To__c ShipAddress =  SalesOrder100Controller.LoadShipAddress (objShipto.Id);
         
         list<SalesOrder100Controller.ResultSet> rs = SalesOrder100Controller.getRecords('24', pb.Id, 'Charge' ,'Invoice');
         SalesOrder100Controller.getFamilyRecords('Charge', Config.Id, 'Order');
         
         pRef=SalesOrder100.LoadItem();
         map<String,String> CheckPBEntryExists = SalesOrder100Controller.CheckPBEntryExists(pb.Id , 'BMS002');
         
         string JSONPrdDetails= '{"ProductCode":"BMS002","ProductId":"01u28000000tEjBAAU","Quantity":"","UOM":"","IntegrationId":"a0C28000000koi2EAA","AccountID":"'+act.Id+'","SalesSite":"NA012","ShipmentSite":"NA012","grossPrice":"","shipAddr":"","taxRule":"","Discount":"","currency":"USD"}';
        // map<String,String> RealTimeProductData = SalesOrder100Controller.RealTimeProductData (JSONPrdDetails);
         
         //SalesOrder100.JSONPrdDetails =JSONPrdDetails;
         //pRef=SalesOrder100.ReadRealTimeProductData();
         
        ApexPages.currentPage().getParameters().put('LineIndex', '0');
        ApexPages.currentPage().getParameters().put('LineOperation', 'delete');
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('mapLineDetails', '{"WarehouseCode":"000","UOM":"EACH","UnitPrice":"45.00","TaxClass":"TX","QuantityOrdered":"1.00","QOH":"-9.000000","ProductId":"01u90000006tcBfAAI","ListPrice":"45.00","ItemTypeCode":null,"ItemType":"ACC","ItemDescription":"Mirror, 18 X 14","ItemCode":"4886-18-14-3","ExtensionAmt":"45.00","minusTax":"45.00","plusTax":"45.00","DropShip":"Y","Discount":"0.00","Commissionable":"Y","Comments":"Line 1"}');
        //pRef=SalesOrder100.CRUDLineItem();
         
        ApexPages.currentPage().getParameters().put('LineIndex', '1');
        ApexPages.currentPage().getParameters().put('LineOperation', 'add');
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('mapLineDetails', '{"WarehouseCode":"000","UOM":"EACH","UnitPrice":"45.00","TaxClass":"TX","QuantityOrdered":"1.00","QOH":"-9.000000","ProductId":"01u90000006tcBfAAI","ListPrice":"45.00","ItemTypeCode":null,"ItemType":"ACC","ItemDescription":"Mirror, 18 X 14","ItemCode":"4886-18-14-3","ExtensionAmt":"45.00","minusTax":"45.00","plusTax":"45.00","DropShip":"Y","Discount":"0.00","Commissionable":"Y","Comments":"Line 1"}');
        pRef = SalesOrder100.CRUDLineItem();
        
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('DiscountPC', '0'); 
        pRef=SalesOrder100.RecalculateTax();
         
        //ApexPages.currentPage().getParameters().put('ERPOrderNumber', 'SOH00001');
        //pRef=SalesOrder100.UpdateOrderNumber();
        
        //SalesOrderX3.JSONOrderDetails='{"WarehouseCode":"NA012","OrderDate":"2/2/2016","UOM":"UN","UnitPrice":"5.1745","TaxClass":"GST","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000aD0jAAE","plusTax":"5.43","minusTax":"5.17","ListPrice":"3.95","ItemTypeCode":null,"ItemType":"BMSOL","ItemDescription":"7 Sprockets","ItemCode":"BMS003","ExtensionAmt":"5.43","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}';
        SalesOrder100.JSONOrderDetails='{"OrderType":"","OrderDescription":"","AccountId":"0012800000OFchTAAT","Account":"American Business Futures","CompanyAuthorizedById":"","CustomerAuthorizedById":"","Pricebook2Id":"01s28000006hyJLAAY","PricebookName":"Sage100ERP-ABX-Sage100","ARDivisionNo":"ABF","CustomerNo":"ABF","TotalAmount":"518.00","LineTotal":518,"DocumentType":"Order","BillToAddress1":"2131 N. 14th Street","BillToAddress2":"","BillToAddress3":"","BillToCity":"Irvine","BillToState":"CA","BillToZipCode":"92618","BillToCountryCode":"USA","ShipToCode":"","ShipToName":"","ShipToAddress1":"","ShipToAddress2":"","ShipToAddress3":"","PrintOrder":"true","PrintPickSheets":"true","BatchFax":"true","ShipToCity":"","ShipToState":"","ShipToZipCode":"","ShipToCountryCode":"","PaymentType":"CASH","PrintSalesOrders":"Y","PrintPickingSheets":"Y","BatchFaxNo":"Y","DiscountType":"-- none --","DiscountPC":null,"DiscountAmt":0,"FreightAmt":0,"DepositAmt":0,"SalesTaxAmt":0,"AmtSubTax":0,"AmtAddTax":0,"CheckNoForDeposit":"","OrderRefNo":"","ReferenceNo":"","FOB":"","ContactName":"","UserName":"","TaxSchedule":"NONTAX","TermsCode":"00","SalesPersonNo":"00","Shipvia":"UPS BLUE","WarehouseCode":"000","OrderDate":"3/10/2016"}';
        pRef=SalesOrder100.SaveERPOrder();
         
        SalesOrder100.OrderHeaderDetails='{"OrderType":"","OrderDescription":"","AccountId":"'+act.Id+'","Account":"American Business Futures","CompanyAuthorizedById":"","CustomerAuthorizedById":"","Pricebook2Id":"01s28000006hyJLAAY","PricebookName":"Sage100ERP-ABX-Sage100","ARDivisionNo":"ABF","CustomerNo":"ABF","TotalAmount":"518.00","LineTotal":518,"DocumentType":"Order","BillToAddress1":"2131 N. 14th Street","BillToAddress2":"","BillToAddress3":"","BillToCity":"Irvine","BillToState":"CA","BillToZipCode":"92618","BillToCountryCode":"USA","ShipToCode":"","ShipToName":"","ShipToAddress1":"","ShipToAddress2":"","ShipToAddress3":"","PrintOrder":"true","PrintPickSheets":"true","BatchFax":"true","ShipToCity":"","ShipToState":"","ShipToZipCode":"","ShipToCountryCode":"","PaymentType":"CASH","PrintSalesOrders":"Y","PrintPickingSheets":"Y","BatchFaxNo":"Y","DiscountType":"-- none --","DiscountPC":null,"DiscountAmt":0,"FreightAmt":0,"DepositAmt":0,"SalesTaxAmt":0,"AmtSubTax":0,"AmtAddTax":0,"CheckNoForDeposit":"","OrderRefNo":"","ReferenceNo":"","FOB":"","ContactName":"","UserName":"","TaxSchedule":"NONTAX","TermsCode":"00","SalesPersonNo":"00","Shipvia":"UPS BLUE","WarehouseCode":"000","OrderDate":"3/10/2016"}';
        SalesOrder100.JSONOrderDetails='[{"WarehouseCode":"NA012","UOM":"UN","UnitPrice":"4.6505","TaxClass":"NOR","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000tEjAAAU","plusTax":"4.65","minusTax":"4.65","ListPrice":"3.55","ItemTypeCode":null,"ItemType":null,"ItemDescription":"5 Sprockets","ItemCode":"BMS002","ExtensionAmt":"4.65","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}]';
        pRef=SalesOrder100.PromoteSage100Order();
         
        // string OrderNumber = SalesOrderX3Controller.getOrderNumber_X3('');
         
        SalesOrder100.JSONLineItems='[{"WarehouseCode":"NA012","UOM":"UN","UnitPrice":"4.6505","TaxClass":"NOR","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000tEjAAAU","plusTax":"4.65","minusTax":"4.65","ListPrice":"3.55","ItemTypeCode":null,"ItemType":null,"ItemDescription":"5 Sprockets","ItemCode":"BMS002","ExtensionAmt":"4.65","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}]';
        pRef=SalesOrder100.AddMultiLineItem();
        
        SalesOrder100Controller.GetCustomerCCList(Config.Id,'3GNEW');
        
        SalesOrder100.AccountId = act.Id;
        pRef=SalesOrder100.GetERPName();
        
        SalesOrder100Controller.ERPOrder erpodr = new SalesOrder100Controller.ERPOrder();
        erpodr.CustomerNo = '';
        erpodr.OrderLineItems = null;
        
        test.starttest();
        //SalesOrder100.Mode = '';
        //SalesOrder100.Synchronization ='';
        rs = SalesOrder100Controller.getRecords('24', pb.Id, '' ,'Invoice');
        rs = SalesOrder100Controller.getRecords('24', pb.Id, '' ,'order');
        SalesOrder100Controller.getFamilyRecords('Charge', Config.Id, 'Invoice');
        CheckPBEntryExists = SalesOrder100Controller.CheckPBEntryExists(pb.Id , 'BMS003');
        test.stoptest();
        
        SalesOrder100Controller.CustomerCreditCards cc = new SalesOrder100Controller.CustomerCreditCards();
        cc.CreditCardNo = '';
        cc.PaymentType = '';
        cc.ExpirationDateYear = '';
        cc.ExpirationDateMonth = '';
        cc.Last4UnencryptedCreditCardNos = '';
        cc.CorporateCustIDPurchOrder = '';
        
        map<String,String> RealTimeProductData=  SalesOrder100Controller.RealTimeProductData (Config.Id, act.Id, 'BMS002','1','0','ab','100',pb.Id);
        SalesOrder100.DocumentType = '';
        SalesOrder100.ErrorMessage = '';
        SalesOrder100.OrderDetailFields = '';
        SalesOrder100.OrderDate = '';
        SalesOrder100.orderConfigId = '';
        SalesOrder100.gbERPSystemName = '';
        SalesOrder100Controller.ERPVersion = '';
        SalesOrder100.AR_DivisonNo = '';
        
    }
    
    static testMethod void PostInstallScript()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('ABX', Config.ERP_Company_Code__c);
        
        
        InstallScriptSage100 ScriptSageX3 = new InstallScriptSage100(Config.Id);
         
    }
    
    static testMethod void Utility()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        
        PasswordSetting__c ppss = new PasswordSetting__c();
        ppss.Name = 'ps001';
        ppss.Password_Key__c = '123456789012345678901234';
        insert ppss;
        
        //-------------------------------------------------------------Utility---------------------------------
        Utility Utl = new Utility(); 
        string XMLString = Utility.getResourceContent('ParamConfig');
        XMLString = Utility.getResourceContent('ParamConfig12');

        Utility.FetchNameSpace();

        Utility.FormatERPInfo('info1','info2','info3');

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

        //string EndPoint='http://49.248.14.235:28880/adxwsvc/services/CAdxWebServiceXmlCC';
        //string request='<soapenv:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:wss="http://www.adonix.com/WSS"><soapenv:Header/><soapenv:Body><wss:run soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/"><callContext xsi:type="wss:CAdxCallContext"><codeLang xsi:type="xsd:string">ENG</codeLang><codeUser xsi:type="xsd:string">ADMIN</codeUser><password xsi:type="xsd:string">admin</password><poolAlias xsi:type="xsd:string">NATRAINV6</poolAlias></callContext><publicName xsi:type="xsd:string">YGTSOLST</publicName><inputXml xsi:type="xsd:string"><![CDATA[<?xml version="1.0" encoding="UTF-8"?> <PARAM> <TAB ID="AX_PAR"> <LIN NUM="1"> <FLD NAME="AXPARCOD">$REC_MAX</FLD> <FLD NAME="AXPARVAL">10</FLD> </LIN> <LIN NUM="2"> <FLD NAME="AXPARCOD">$REC_STARTAT</FLD> <FLD NAME="AXPARVAL">1</FLD> </LIN> <LIN NUM="3"> <FLD NAME="AXPARCOD">$TOTAL_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="4"> <FLD NAME="AXPARCOD">$RET_COUNT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> <LIN NUM="5"> <FLD NAME="AXPARCOD">$HAS_NEXT</FLD> <FLD NAME="AXPARVAL">0</FLD> </LIN> </TAB><TAB ID="AX_WHR" ><LIN NUM="1" ><FLD NAME="AXWHRLFTBRK" >0</FLD><FLD NAME="AXWHRCOD" >BPCORD</FLD><FLD NAME="AXWHROPE" >2</FLD><FLD NAME="AXWHRCODVAL" >C2201</FLD><FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN><LIN NUM="1" ><FLD NAME="AXWHRLFTBRK" >0</FLD><FLD NAME="AXWHRCOD" >ORDSTA</FLD><FLD NAME="AXWHROPE" >2</FLD><FLD NAME="AXWHRCODVAL" >1</FLD><FLD NAME="AXWHRRGTBRK" >0</FLD><FLD NAME="AXWHRANDOR" >1</FLD></LIN></TAB> </PARAM> ]]></inputXml></wss:run></soapenv:Body></soapenv:Envelope>';
        //Utility.httpRequest(EndPoint, request);
        
        string strRequestXml= Utility.requestXML('Action',Config.Id,'SORDER','','','','','');

        map<string ,string> formatInfo  = Utility.FormatERPInfo('Kd', 'Kx','Km');

        Utility.ProgramList prList = new Utility.ProgramList();
        prList.YGTCUSTLIST = 'YGTCUSTLST';

        map<string ,string> mapFormatERPInfo =Utility.FormatERPInfo('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','<PARAM NAME="Username"  VALUE="ADMIN" />','<PARAM NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>');
        mapFormatERPInfo =Utility.FormatERPInfo('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','NAME');
        mapFormatERPInfo =Utility.FormatERPInfo('<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','NAME','+');
        mapFormatERPInfo =Utility.FormatERPInfo('PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" />','</PARAMS></PARAM NAME="CompanyCode"  VALUE="SAMINC" />','');

        string strdate = Utility.dateFormat('2015-01-01');
        strdate = Utility.dateFormat('2015-01-011');

        string strEncrypt = Utility.Encrypt('sfadmin123');
        strEncrypt = Utility.Encrypt('XIx+5GgjZ8EmAWMQz2eG0hdJvnESyEnQh02qJjW40Es=');        
        string strDecrypt =Utility.Decrypt('sfadmin123');

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

        Utility.PageComponent pgcmp = new Utility.PageComponent();
        pgcmp.ComponentType = 'ctype';
        
        object ErrorMessage;
        Utility.ShowErrorMessage(ErrorMessage);
        Utility.parse('<param><root></root></param>','root');
        
        strRequestXml= Utility.requestXML('Read',Config.Id,'SORDER','','','','','');
        strRequestXml= Utility.requestXML('Write',Config.Id,'SORDER','','','','','');
        Utility.phoneformat('(011)2012010');
        
        //-----------------------Utility-----------------------------------------------------------
        
        //-----------------------GUMUException-----------------------------------------------------------start
        GUMUException exc = new GUMUException();
        System.ListException ex1 = new System.ListException()  ;
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex1);

        System.NoDataFoundException ex2=new System.NoDataFoundException ();
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex2);

        System.QueryException ex3=new System.QueryException ();
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex3);

        System.TypeException ex4=new  System.TypeException();
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex4);
        
        System.DmlException ex6=new System.DmlException(); 
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex6);

        System.JSONException ex5=new System.JSONException();
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex5);
        
        System.XmlException ex7=new System.XmlException ();
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex7);
        
        System.NullPointerException ex8=new System.NullPointerException();
        exc= new GUMUException('Newtest','getMapForXML_Addr',ex8);
        
    }
    
    static testMethod void IntegrationFrameworkBase()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('Both', Config.Synchronization__c);
        
        
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 300',ERP_System__c='Sage100ERP'
                    ,Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
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
        
        Entity__c objEmap = new Entity__c();
        objEmap.Entity_Code__c='Customer';
        objEmap.API_Method__c='ArCustomerFinder';
        insert objEmap;
        
        Entity_Mapping_Header__c EntityMap = new Entity_Mapping_Header__c();
        EntityMap.Source_Entity__c='Customer';
        EntityMap.Sync_Direction__c='Two Way';
        EntityMap.Target_Entity__c='Account';
        EntityMap.Entity_Id__c =objEmap.id; 
        EntityMap.Integration_Key__c=config.id;
        EntityMap.ERP_Function__c = 'ArCustomerFinder';
        EntityMap.Size__c=2;
        
        insert EntityMap;
        
        
        list<string> ConnectionParameters  = new list<string>();
        ConnectionParameters.add('CompanyCode=ABX');
        ConnectionParameters.add('Username=ADMIN'); 
        ConnectionParameters.add('Password=ADMIN'); 

        Sage100IntegrationFramework sag100IntgrFrm = new Sage100IntegrationFramework();
        boolean isconnected=sag100IntgrFrm.TestConnection('https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC',ConnectionParameters);
        
        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        list<object>  AttribParam= new list<object>();
        
        AttribParam= new list<object>();
        AttribParam.add(Config.Id);
        AttribParams.put('IntegrationId',AttribParam);
        
        Helper.MappingPurpose mappingType =Helper.MappingPurpose.SYNC;
        AttribParam= new list<object>();
        AttribParam.add(mappingType);
        AttribParams.put('MappingPurpose',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('Customer');
        AttribParams.put('SourceEntity',AttribParam);
        
        map<string,map<string,list<string>>> Params = new map<string,map<string,list<string>>>();
        Helper.GUMU_Response oGUMU_Response= sag100IntgrFrm.getData(Params,AttribParams);
        
        oGUMU_Response  = sag100IntgrFrm.ReadSchema('arCustomerFinder',Config.Id);
        
        list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
        map<string,string>ERPDataMap = new map<string,string>();
        ERPDataMap.put('IDCUST','NA002');
        ERPDataMap.put('IDGRP','2');
        ERPDataMap.put('NAMECUST','AMALGATE');        
        ERPDataMapList.add(ERPDataMap);
        
        Helper.GUMU_Response pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.ERPDataMap = ERPDataMapList;
        List<Helper.Customer> GenericCustomers=sag100IntgrFrm.GetGenericCustomers(pGUMU_Response);
        
        sag100IntgrFrm.GetFieldForAutoMatch();
        
        map<string,map<string,list<string>>> PrepareFieldParam =sag100IntgrFrm.PrepareFieldParam( '01/01/2016','');
        PrepareFieldParam =sag100IntgrFrm.PrepareFieldParam( '123','123');
        
        
        
        //---------------------------------------------------BaseIntegrationFramework---------------------Start
    	BaseIntegrationFramework BaseIntegration = new BaseIntegrationFramework();
    	BaseIntegration.TestConnection('https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC',ConnectionParameters);
    	oGUMU_Response= BaseIntegration.getData(Params,AttribParams);
    	
    	//-----------------------------------------------IntegrationFactory-----------------------------------------
    	
    	IntegrationFactory Factory = new IntegrationFactory();
    	IntegrationFactory.getERPProvider();
    	
    }
    
    static testMethod void CustomException()
    {
    	ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('Both', Config.Synchronization__c);
        
    	CustomException custom = new CustomException();
    	
    	System.QueryException ex1=new System.QueryException ();
        custom= new CustomException('Newtest','getMapForXML_Addr',ex1,true);

        System.TypeException ex2=new  System.TypeException();
        custom= new CustomException('Newtest','getMapForXML_Addr',ex2,true);
        
        System.DmlException ex3=new System.DmlException(); 
        custom= new CustomException('Newtest','getMapForXML_Addr',ex3,true);

        System.JSONException ex4=new System.JSONException();
        custom= new CustomException('Newtest','getMapForXML_Addr',ex4,true);
        
        System.XmlException ex5=new System.XmlException ();
        custom= new CustomException('Newtest','getMapForXML_Addr',ex5,true);
        
        System.NoDataFoundException ex6=new System.NoDataFoundException();
        custom= new CustomException('Newtest','getMapForXML_Addr',ex6,true);
        
        //LimitException ex7=new LimitException();
        //custom= new CustomException('Newtest','getMapForXML_Addr',ex7,true);
    	 CsvToSObjectParser CsvToSObject = new CsvToSObjectParser();
    	 CsvToSObject = new CsvToSObjectParser('EntityDetail');
    	 CsvToSObject = new CsvToSObjectParser('EntityDetail',Config.Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c','Sage100',0,300,'SEED');
    	 
    	 List<SObject> obct=CsvToSObject.parseCsv();
    }
    static testMethod void ERPAdministration() 
    {
    	ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage100ERP';
        Config.Name = 'Integration-ABC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='ABX';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('Both', Config.Synchronization__c);
        
        // intialize Configurationlist controller           
        sObject sObj = Schema.getGlobalDescribe().get('GUMU_Lite__ERP_Config__c').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        ConfigurationController ConfigCntlr = new ConfigurationController(StdCntlr);
        
        //ConfigCntlr.runInstallScript(Config.Id,'Sage100ERP');
        
        
    }   
    
}
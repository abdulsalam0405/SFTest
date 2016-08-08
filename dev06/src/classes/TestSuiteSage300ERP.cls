@isTest(SeeAllData=false)
private class TestSuiteSage300ERP 
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
        Security_Matrix__c securityMatrix = new Security_Matrix__c(name = 'SM001',Promote_Customer__c=true,Update_Customer__c=true); 
        insert securityMatrix;
        
        //inserting data into app setting       
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 300',ERP_System__c='Sage300ERP'
                    ,Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Integration-SAMINC';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        Config.Default__c=true;
        insert Config;
    	
    	System.assertEquals('Integration-SAMINC',Config.Name);
    //---------------------------------------SalesOrder300Controller-------------------------Start
    
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
    	//Product family
        ERP_Product_Family__c Family1 =new ERP_Product_Family__c();
        Family1.ERP_Product_Family_Code__c = 'Charge';
        Family1.ERP_Product_Family_Description__c = 'Charge';
        Family1.Integration_Key__c = Config.Id;
        insert Family1;
        
        sObject sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        PromoteCustomerSage300Controller PromoteCustomerSage3001= new PromoteCustomerSage300Controller(StdCntlr);
      
        ApexPages.currentPage().getParameters().put('id',act.Id);
        sObj = Schema.getGlobalDescribe().get('Account').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        PromoteCustomerSage300Controller PromoteCustomerSage300 = new PromoteCustomerSage300Controller(StdCntlr);
      
        PageReference pRef = PromoteCustomerSage300.PromoteCustomer_300();
        pRef = PromoteCustomerSage300.UnlinkAccount();
        pRef = PromoteCustomerSage300.GetCategoryValues();
      
        list<map<String,String>> ContactCodeslist = new list<map<String,String>>();
        map<String,String> ContactCodes = new map<String,String>();
        ContactCodes.put('ContactName','john son');
        ContactCodes.put('ContactCode','0111');
        ContactCodeslist.add(ContactCodes);
        PromoteCustomerSage300.UpdateCustomer(Config.Id,'ABX',act.Id,'3GNEW',ContactCodeslist);
        
        PromoteCustomerSage300.IntegrationKey =Config.Id;
        pRef = PromoteCustomerSage300.GetERPName();
        pRef = PromoteCustomerSage300.FetchERPName();
        PromoteCustomerSage300Controller.result rs = new PromoteCustomerSage300Controller.result();
        rs.Error ='' ;
        rs.CustomereNumber='';
        rs.ContactCodes = null;  
        
        PromoteCustomerSage300.CustomerNo300 = '';
        PromoteCustomerSage300.Category300 = '';
        PromoteCustomerSage300.Taxgroup300 = '';
        PromoteCustomerSage300.customerNoDisable = false;
        pRef = PromoteCustomerSage300.PromoteCustomer_300();
        
        //-------------------------------------------AddressSage300Controller--------------------------------------start
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
        AddressSage300Controller AddressSage1001 = new AddressSage300Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('id',objShipto.Id);
        AddressSage300Controller AddressSage1002 = new AddressSage300Controller(StdCntlr);
        
        
        AddressSage300Controller.Address  Addr = new  AddressSage300Controller.Address();
        Addr.Ship_To_Country_Code = '';
        boolean isValid = AddressSage1002.ApexMessages(Addr);
        
        Addr = new  AddressSage300Controller.Address();
        Addr.Ship_To_Code = '';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        Addr = new  AddressSage300Controller.Address();
        Addr.Ship_To_Zip_Code = '';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        AddressSage1002.pageMode = 'New';
        Addr = new  AddressSage300Controller.Address();
        Addr.Ship_To_Code = 'Corp';
        isValid = AddressSage1002.ApexMessages(Addr);
        
        Addr = new  AddressSage300Controller.Address();
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
        pRef=AddressSage1002.SavepromoteAddress();
        
        Addr = new AddressSage300Controller.Address();
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
        //AddressSage1002.isShipAddress='true';
      
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
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC';
        Config.Web_Service_URL__c = 'https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>'; 
        Config.Integration_Information_2__c ='NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SAMINC',Config.ERP_Company_Code__c);
        
        Account act = new Account();
        act.ERP_Customer_Number__c = '3GNEW';
        act.Integration_Key__c='';   
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
        //pb.isStandard = true;
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
        
        //----------------------------------------------SalesOrder300Controller------------------------------start
                        
        sObject sObj = Schema.getGlobalDescribe().get('Order').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        SalesOrder300Controller SalesOrder3003 = new SalesOrder300Controller(StdCntlr);
        
        ApexPages.currentPage().getParameters().put('Id',objOrder.Id);
        
        sObj = Schema.getGlobalDescribe().get('Order').newSObject() ;
        StdCntlr = new ApexPages.StandardController(sObj);
        SalesOrder300Controller SalesOrder300 = new SalesOrder300Controller(StdCntlr);
        
        list<SalesOrder300Controller.LineItem> OrderProduct=  SalesOrder300Controller.getOrderProduct(objOrder.Id);
        
         map<String,String> LoadAccountData =SalesOrder300Controller.LoadAccountData(act.Id);
         
         String Salesperson =SalesOrder300Controller.GetSalesperson(Config.Id);
         
         Ship_To__c ShipAddress =  SalesOrder300Controller.LoadShipAddress (objShipto.Id);
         
         list<SalesOrder300Controller.ResultSet> rs = SalesOrder300Controller.getRecords('24', pb.Id, 'Charge' ,'Invoice');
         SalesOrder300Controller.getFamilyRecords('Charge', Config.Id, 'Order');
         
         pRef=SalesOrder300.LoadItem();
         map<String,String> CheckPBEntryExists = SalesOrder300Controller.CheckPBEntryExists(pb.Id , 'BMS002');
         
         string JSONPrdDetails= '{"ProductCode":"A1-103/0","ProductId":"01u28000001u8b9AAA","Quantity":"1.00","UOM":"Ea.","IntegrationId":"a0C28000000XOZrEAO","AccountID":"0012800000DjS5yAAF","grossPrice":"0.00","shipAddr":"ADD02","Discount":"0.00","OrderDate":"3/10/2016","CustomerNo":"1200","ProductFamily":"A1","TaxGroup":"CALIF","ProductWarehouse":""}';
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
        pRef = SalesOrder300.CRUDLineItem();
        
        ApexPages.currentPage().getParameters().put('IntegrationKey',Config.Id );
        ApexPages.currentPage().getParameters().put('UniqueKey', '01-ABF');
        ApexPages.currentPage().getParameters().put('TaxSchedule', 'WI');
        ApexPages.currentPage().getParameters().put('DiscountPC', '0'); 
        pRef=SalesOrder300.RecalculateTax();
         
        //ApexPages.currentPage().getParameters().put('ERPOrderNumber', 'SOH00001');
        //pRef=SalesOrder100.UpdateOrderNumber();
        
        //SalesOrderX3.JSONOrderDetails='{"WarehouseCode":"NA012","OrderDate":"2/2/2016","UOM":"UN","UnitPrice":"5.1745","TaxClass":"GST","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000aD0jAAE","plusTax":"5.43","minusTax":"5.17","ListPrice":"3.95","ItemTypeCode":null,"ItemType":"BMSOL","ItemDescription":"7 Sprockets","ItemCode":"BMS003","ExtensionAmt":"5.43","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}';
        SalesOrder300.JSONOrderDetails='{"OrderDate":"3/10/2016","OrderType":"","OrderDescription":"","AccountId":"0012800000DjT60AAF","Account":"Smothers European Mercedes, Inc.","CompanyAuthorizedById":"","CustomerAuthorizedById":"","Pricebook2Id":"01s28000005hpCVAAY","PricebookName":"Sage300 - SAMINC","Termscode":"","ARDivisionNo":"SMOTHE","CustomerNo":"SMOTHE","LineTotal":28.73,"DocumentType":"Order","BillToAddress1":"","BillToAddress2":"","BillToAddress3":"","BillToCity":"","BillToState":"","BillToZipCode":"","BillToCountryCode":"","ShipToCode":"","ShipToName":"","TaxGroup":"CALIF","Accountset":"","SalesSiteId":"a0b28000000QHG4AAO","ShipmentSiteId":"","ShipToAddress1":"","ShipToAddress2":"","ShipToAddress3":"","ShipToCity":"","ShipToState":"","ShipToZipCode":"","ShipToCountryCode":"","Shipvia":"","TermsCode":"","PrintSalesOrders":"N","PrintPickingSheets":"N","BatchFaxNo":"N","DiscountType":"-- none --","DiscountPC":0,"DiscountAmt":0,"FreightAmt":null,"DepositAmt":null,"SalesTaxAmt":null,"AmtSubTax":null,"AmtAddTax":null,"ContactName":"","UserName":""}';
        pRef=SalesOrder300.SaveERPOrder();
         
        SalesOrder300.OrderHeaderDetails='{"OrderDate":"3/10/2016","OrderType":"","OrderDescription":"","AccountId":"0012800000DjT60AAF","Account":"Smothers European Mercedes, Inc.","CompanyAuthorizedById":"","CustomerAuthorizedById":"","Pricebook2Id":"01s28000005hpCVAAY","PricebookName":"Sage300 - SAMINC","Termscode":"","ARDivisionNo":"SMOTHE","CustomerNo":"SMOTHE","LineTotal":28.73,"DocumentType":"Order","BillToAddress1":"","BillToAddress2":"","BillToAddress3":"","BillToCity":"","BillToState":"","BillToZipCode":"","BillToCountryCode":"","ShipToCode":"","ShipToName":"","TaxGroup":"CALIF","Accountset":"","SalesSiteId":"a0b28000000QHG4AAO","ShipmentSiteId":"","ShipToAddress1":"","ShipToAddress2":"","ShipToAddress3":"","ShipToCity":"","ShipToState":"","ShipToZipCode":"","ShipToCountryCode":"","Shipvia":"","TermsCode":"","PrintSalesOrders":"N","PrintPickingSheets":"N","BatchFaxNo":"N","DiscountType":"-- none --","DiscountPC":0,"DiscountAmt":0,"FreightAmt":null,"DepositAmt":null,"SalesTaxAmt":null,"AmtSubTax":null,"AmtAddTax":null,"ContactName":"","UserName":""}';
        SalesOrder300.JSONOrderDetails='[{"WarehouseCode":"2","UOM":"Ea.","UnitPrice":"28.7300","TaxClass":null,"QuantityOrdered":"1.00","QOH":"","ProductId":"01u28000001u8b9AAA","plusTax":"0","minusTax":"0","ListPrice":"28.7300","ItemTypeCode":null,"ItemType":"A1","ItemDescription":"Fluorescent Desk Lamp","ItemCode":"A1-103/0","ExtensionAmt":"28.73","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}]';
        pRef=SalesOrder300.PromoteOrder();
        
      
        // string OrderNumber = SalesOrderX3Controller.getOrderNumber_X3('');
         
        SalesOrder300.JSONLineItems='[{"WarehouseCode":"NA012","UOM":"UN","UnitPrice":"4.6505","TaxClass":"NOR","QuantityOrdered":"1.00","QOH":"0.00","ProductId":"01u28000000tEjAAAU","plusTax":"4.65","minusTax":"4.65","ListPrice":"3.55","ItemTypeCode":null,"ItemType":null,"ItemDescription":"5 Sprockets","ItemCode":"BMS002","ExtensionAmt":"4.65","DropShip":"N","Discount":"0.00","Commissionable":"N","Comments":null}]';
        pRef=SalesOrder300.AddMultiLineItem();
        
        //SalesOrder300Controller.GetCustomerCCList(Config.Id,'3GNEW');
        
        SalesOrder300.AccountId = act.Id;
        pRef=SalesOrder300.GetERPName();
        
        SalesOrder300Controller.ERPOrder erpodr = new SalesOrder300Controller.ERPOrder();
        erpodr.CustomerNo = '';
        erpodr.OrderLineItems = null;
        
        test.starttest();
        //SalesOrder100.Mode = '';
        //SalesOrder100.Synchronization ='';
        rs = SalesOrder300Controller.getRecords('24', pb.Id, '' ,'Invoice');
        rs = SalesOrder300Controller.getRecords('24', pb.Id, '' ,'order');
        SalesOrder300Controller.getFamilyRecords('Charge', Config.Id, 'Invoice');
        CheckPBEntryExists = SalesOrder300Controller.CheckPBEntryExists(pb.Id , 'BMS003');
        test.stoptest();
        
        SalesOrder300Controller.CustomerCreditCards cc = new SalesOrder300Controller.CustomerCreditCards();
        cc.CreditCardNo = '';
        cc.PaymentType = '';
        cc.ExpirationDateYear = '';
        cc.ExpirationDateMonth = '';
        cc.Last4UnencryptedCreditCardNos = '';
        cc.CorporateCustIDPurchOrder = '';
        pRef=SalesOrder300.RedirectPage();
        SalesOrder300.IntegrationKey = Config.Id;
       ApexPages.currentPage().getParameters().put('PageIntegrationKey', Config.Id);        
        SalesOrder300.JSONPrdDetails= '{"ProductCode":"BMS002","ProductId":"01u28000001u8b9AAA","Quantity":"1.00","UOM":"Ea.","IntegrationId":"a0C28000000XOZrEAO","AccountID":"0012800000DjS5yAAF","grossPrice":"0.00","shipAddr":"ADD02","Discount":"0.00","OrderDate":"3/10/2016","CustomerNo":"1200","ProductFamily":"A1","TaxGroup":"CALIF","ProductWarehouse":""}';
        pRef=SalesOrder300.GetRealTimeProductData();
        string ERPOrderNumber= SalesOrder300.UpdateERPOrderNumber('SON001010','10.00','200.00');
        
        SalesOrder300.OrderDate = '';
        SalesOrder300.DocumentType = '';
        SalesOrder300.orderConfigId = '';
        SalesOrder300.gbERPSystemName = '';
        SalesOrder300.AccountName = '';
        SalesOrder300.PricebookName = '';
        SalesOrder300.oCurrency = '';
        SalesOrder300.ARDivisionNo = '';
        SalesOrder300.CustomerNo = '';
        SalesOrder300.ShipToCode = '';
        SalesOrder300.ShipToName = '';
        SalesOrder300.PrintSalesOrders = '';
        SalesOrder300.PrintPickingSheets = '';
        SalesOrder300.BatchFaxNo = '';
        SalesOrder300.DiscountType = '';
        SalesOrder300.TaxGroup = '';
        SalesOrder300.ShipVia = '';
        SalesOrder300.AccountSet = '';
        SalesOrder300.TermsCode = '';
        SalesOrder300.TotalAmount =0;
        SalesOrder300.DiscountPC = 0;
        SalesOrder300.DiscountAmt = 0;
        SalesOrder300.FreightAmt = 0;
        SalesOrder300.DepositAmt = 0;
        SalesOrder300.oSalesTaxAmt = 0;
        SalesOrder300.AmtSubTax = 0;
        SalesOrder300.UserName = 0;
        SalesOrder300.ContactName = 0;
        SalesOrder300.AmtAddTax = 0;
        SalesOrder300.IntegrationKeyList = null;
    }
    
    static testMethod void CustomerERPDetaitls300()
    {
    
        //create record for Configuration
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Integration-SAMINC1';
        Config.Web_Service_URL__c = 'https://magentosageerp.com:28843/adxwsvc/services/CAdxWebServiceXmlCC';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM'; 
        Config.Integration_Information_2__c = 'NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="71kfjX20FlT/R3dHpLif/UMR6k4v0etSFFNYuUH9MH4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC1';
        Config.Default__c=true;
        insert Config;
        
        System.assertEquals('Integration-SAMINC1',Config.Name);
        
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
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 300',ERP_System__c='Sage300ERP'
                    ,Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
        
    //---------------------------------------AccountTriggerHelper-------------------------Start
    
        Account act = new Account();
        act.ERP_Customer_Number__c = '300Cust';  
        act.ERP_Company_Code__c='SAMINC';
        act.Name = '300Cust';
        act.Integration_Key__c = Config.Id;
        insert act;
        //AccountTriggerHelper AccountTrigger = new AccountTriggerHelper();
        AccountTriggerHelper.UpdateERPCustomer_300(act, Config);    
    }
    
    static testMethod void PostInstallScript()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC';
        Config.Web_Service_URL__c = 'https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>'; 
        Config.Integration_Information_2__c ='NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SAMINC',Config.ERP_Company_Code__c);
        
        /*PasswordSetting__c pwsetting = new PasswordSetting__c();
        pwsetting.Name = 'PASS001'; 
        pwsetting.Password_Key__c = '123456789012345678901234';
        insert pwsetting;
        */
                
        InstallScriptSage300 ScriptSageX3 = new InstallScriptSage300(Config.Id);
        
    }
    
    static testMethod void Helper()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC';
        Config.Web_Service_URL__c = 'https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>'; 
        Config.Integration_Information_2__c ='NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        Config.Default__c=true;
        insert Config;
        
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 300',ERP_System__c='Sage300ERP'
                    ,Expiration_Date__c=system.today(),No_of_Users__c=10);
        insert app;
        
        Account act = new Account();
        act.ERP_Customer_Number__c = '300Cust';  
        act.ERP_Company_Code__c='SAMINC';
        act.Name = '300Cust';
        act.Integration_Key__c = Config.Id;
        insert act;
        
        Data_Page__c dataPage3 = new Data_Page__c();
        dataPage3.Description__c='Customer';
        dataPage3.ERP_System__c='Sage300ERP';
        dataPage3.Name__c='Customer'; 
        dataPage3.Name ='Customer';
        dataPage3.Type__c ='List';
        dataPage3.ERP_Function__c='ArCustomerFinder';
        dataPage3.Integration_Key__c = Config.Id;
        insert dataPage3;
        
        Helper hh = new Helper(); 
        hh.getERP('');
        
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
        
        string strERPDataMapRelSection='{"oeorderdetails":[{"lotnumbers":"","serialnumbers":"","kits":"","BOMs":"","CALC_INSTRUCTIONS":"","CALC_COMMENTS":"","CALC_QTYAVAIL":"196 Ea.","CALC_ITEMNO_MISCCHARGE":"A1-103/0","COMPLETE":"3","SIMPLEPCHK":"0","DRIVENBYUI":"false","TINCLUDED5":"false","TINCLUDED4":"false","TINCLUDED3":"false","TINCLUDED2":"false","TINCLUDED1":"false","TCLASS5":"0","TCLASS4":"0","TCLASS3":"0","TCLASS2":"1","TCLASS1":"1","LASTCOST":"18.750000","AVGCOST":"20.258832","COST2":"0.000000","COST1":"0.000000","MOSTREC":"20.296944","STDCOST":"0.000000","CATEGORY":"A1","UNITPRCDEC":"2","PRPRICEBY":"1","WEIGHTUNIT":"lbs.","PRWGHTUNIT":"lbs.","PRICEUNIT":"Ea.","PRICEOVER":"false","PRICELIST":"USA","COMMINST":"true","QTYCOMMIT":"0.0000","EDCORDMISC":"0.000","INVDISC":"0.000","DISCPER":"0.00000","EXTINVMISC":"0.000","PRIUNTPRC":"59.990000","ORDUNIT":"Ea.","QTYSHPTODT":"10.0000","QTYBACKORD":"0.0000","QTYSHIPPED":"0.0000","QTYORDERED":"0.0000","LOCDESC":"Port of San Fancisco","LOCATION":"4","DESC":"Fluorescent Desk Lamp","MISCCHARGE":"","UNFMTITEM":"A11030","ITEM":"A1-103/0","LINETYPE":"1","DDTLNO":"","DETAILNUM":"1"},{"lotnumbers":"","serialnumbers":"","kits":"","BOMs":"","CALC_INSTRUCTIONS":"","CALC_COMMENTS":"","CALC_QTYAVAIL":"90 Ea.","CALC_ITEMNO_MISCCHARGE":"A1-105/0","COMPLETE":"3","SIMPLEPCHK":"0","DRIVENBYUI":"false","TINCLUDED5":"false","TINCLUDED4":"false","TINCLUDED3":"false","TINCLUDED2":"false","TINCLUDED1":"false","TCLASS5":"0","TCLASS4":"0","TCLASS3":"0","TCLASS2":"1","TCLASS1":"1","LASTCOST":"3.350000","AVGCOST":"3.626000","COST2":"0.000000","COST1":"0.000000","MOSTREC":"3.626300","STDCOST":"0.000000","CATEGORY":"A1","UNITPRCDEC":"2","PRPRICEBY":"1","WEIGHTUNIT":"lbs.","PRWGHTUNIT":"lbs.","PRICEUNIT":"Ea.","PRICEOVER":"false","PRICELIST":"USA","COMMINST":"true","QTYCOMMIT":"0.0000","EDCORDMISC":"0.000","INVDISC":"0.000","DISCPER":"0.00000","EXTINVMISC":"0.000","PRIUNTPRC":"7.100000","ORDUNIT":"Ea.","QTYSHPTODT":"5.0000","QTYBACKORD":"0.0000","QTYSHIPPED":"0.0000","QTYORDERED":"0.0000","LOCDESC":"Port of San Fancisco","LOCATION":"4","DESC":"13W Mini Fluorescent Bulb","MISCCHARGE":"","UNFMTITEM":"A11050","ITEM":"A1-105/0","LINETYPE":"1","DDTLNO":"","DETAILNUM":"2"}]}';
        map<string,list<map<string,string>>> RecordList=(map<string,list<map<string,string>>>)JSON.deserializeStrict(strERPDataMapRelSection,map<string,list<map<string,string>>>.class);

        Helper.GUMU_Response resp = new Helper.GUMU_Response();
        resp.responseERPData = '<?xml version="1.0" encoding="UTF-8"?><feed xmlns="http://www.w3.org/2005/Atom" xmlns:http="http://schemas.sage.com/sdata/http/2008/1" xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/" xmlns:sdata="http://schemas.sage.com/sdata/2008/1" xmlns:sle="http://www.microsoft.com/schemas/rss/core/2005" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><title>Customers Finder</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="collection" scheme="http://schemas.sage.com/sdata/categories" term="collection"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder</id><opensearch:totalResults>1</opensearch:totalResults><opensearch:startIndex>1</opensearch:startIndex><opensearch:itemsPerPage>100</opensearch:itemsPerPage><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="self" title="Refresh" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="first" title="First Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder?where=IDCUST eq 3GNEW &amp;startIndex=1&amp;count=100" rel="last" title="Last Page" type="application/atom+xml; type=feed; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$schema" rel="http://schemas.sage.com/sdata/link-relations/schema" title="Schema" type="application/xml; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$template" rel="http://schemas.sage.com/sdata/link-relations/template" title="Template" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder" rel="http://schemas.sage.com/sdata/link-relations/post" title="Post" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder/$service" rel="http://schemas.sage.com/sdata/link-relations/service" title="Service" type="application/atom+xml; type=feed; charset=UTF-8"/><entry><title>Customers Finder 3GNEW</title><author><name>Generated</name></author><updated>2015-08-18T16:39:09Z</updated><category label="resource" scheme="http://schemas.sage.com/sdata/categories" term="resource"/><id>http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)</id><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="self" title="Refresh" type="application/atom+xml; type=entry; charset=UTF-8"/><link href="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)" rel="edit" title="Edit" type="application/atom+xml; type=entry; charset=UTF-8"/><sdata:payload><arCustomerFinder xmlns="http://schemas.sage.com/sageERP" sdata:key="3GNEW" sdata:url="http://49.248.14.237:8080/SDataServlet/sdata/sageerp/accpac/SAMINC/arCustomersFinder(3GNEW)"><IDCUST>3GNEW</IDCUST><NAMECUST>3G Homes</NAMECUST><TEXTSNAM>3G Homes</TEXTSNAM><SWHOLD>0</SWHOLD><IDGRP>WHL</IDGRP><IDNATACCT xsi:nil="false"/><CODECURN>USD</CODECURN><NAMECITY>BRACKNELL</NAMECITY><CODESTTE>Berkshire</CODESTTE><CODECTRY>United Kingdom</CODECTRY><SWACTV>1</SWACTV><SWBALFWD>0</SWBALFWD><TEXTSTRE1>Popes Manor</TEXTSTRE1><TEXTSTRE2>Murrell Hill Lane</TEXTSTRE2><TEXTSTRE3>Binfield</TEXTSTRE3><TEXTSTRE4 xsi:nil="false"/><CODEPSTL>RG42 4DA</CODEPSTL><TEXTPHON1>1344897 8791</TEXTPHON1><TEXTPHON2>1344897 8701</TEXTPHON2><NAMECTAC>Clemence Stickings</NAMECTAC><PRICLIST xsi:nil="false"/><DATEINAC xsi:nil="true"/><DATELASTMN>2012-11-12</DATELASTMN><CODETERR xsi:nil="false"/><IDACCTSET>TRADE</IDACCTSET><CODETERM>N30</CODETERM><CTACPHONE>1344897 8791</CTACPHONE><PAYMCODE xsi:nil="false"/><AMTCRLIMT>120000.000</AMTCRLIMT><LOCATION xsi:nil="false"/><CODETAXGRP>USDTAX</CODETAXGRP><FOB xsi:nil="false"/><SHPVIADESC xsi:nil="false"/></arCustomerFinder></sdata:payload><http:etag>2012111222382013ADMIN___SAMINC</http:etag></entry></feed>';
        resp.statusCode='200';
        resp.statusMessage='Ok';
        resp.ERPDataMap=ERPDataMapLst;
        resp.ERPDataMapRelSection=RecordList;
        resp.startIndex='1';
        resp.totalRecord='200';
        resp.itemPerPage='10';

        /// //BaseIntegrationFramework End///////

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
        pgComp.KeyField='keyAPI';
        pgComp.KeyValue='keyVal';

        lstPgComp.add(pgComp) ;
        string strPrepareTable=Helper.prepareTable(lstPgComp);
		

        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Text';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        strPrepareTable=Helper.prepareTable(lstPgComp);
        Component.Apex.PageBlock bpBlock=Helper.prepareFilterSection(lstPgComp, resp, 1);
        
        lstPgComp= new list< Utility.PageComponent>();
        pgComp = new Utility.PageComponent();
        pgComp.ComponentType='Detail';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='CHECKBOX';
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
        pgComp.DataType='Text';
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
        pgComp.ComponentType='Section';
        pgComp.Parent='Detail Line Item';
        pgComp.ComponentName='ITEM';
        pgComp.DataType='Grid';
        pgComp.APIName='_1_ITEM';
        pgComp.LinkTo='';
        pgComp.Value=lstObject;
        pgComp.ComponentSFId='a0K28000000KTF9EAO';
        lstPgComp.add(pgComp);
        bpBlock=Helper.prepareTabPage(lstPgComp, resp, 1);

       Helper.GUMU_UIResponse CustomerEnquiryPage =Helper.getCustomerEnquiryPage('Customer',act.Id,'BPCNUM','1200',1,5,'5') ;
       
        delete dataPage3;
        dataPage3 = new Data_Page__c();
        dataPage3.Description__c='Customer';
        dataPage3.ERP_System__c='Sage300ERP';
        dataPage3.Name__c='ARInquiry'; 
        dataPage3.Name ='ARInquiry';
        dataPage3.Type__c ='Detail';
        dataPage3.ERP_Function__c='ArCustomerFinder';
        insert dataPage3;
        
       CustomerEnquiryPage =Helper.getCustomerEnquiryPage('ARInquiry',act.Id,'BPCNUM','1200',1,5,'5') ;
          
       Helper.Customer cust = new Helper.Customer();
       cust.UniqueKey='';
       cust.CategoryCode ='';
       cust.CustomerName = ''; 
    }
    
    static testMethod void IntegrationFrameworkBase()
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC';
        Config.Web_Service_URL__c = 'https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>'; 
        Config.Integration_Information_2__c ='NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SAMINC',Config.ERP_Company_Code__c);
        
        GUMU_App_Setting__c app = new GUMU_App_Setting__c(Activation_Key__c='123456789',Name = 'GUMU Sage ERP 300',ERP_System__c='Sage300ERP'
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
        EntityMap.Size__c=2;
        
        insert EntityMap;
        
        
        Data_Page__c dataPage3 = new Data_Page__c();
        dataPage3.Description__c='Customer';
        dataPage3.ERP_System__c='Sage300ERP';
        dataPage3.Name__c='Customer'; 
        dataPage3.Name ='Customer';
        dataPage3.Type__c ='List';
        dataPage3.ERP_Function__c='ArCustomerFinder';
        insert dataPage3;
        
        //---------------------------------------------------------Sage300IntegrationFramework
        list<string> ConnectionParameters  = new list<string>();
        ConnectionParameters.add('CompanyCode=SAMINC');
        ConnectionParameters.add('Username=ADMIN'); 
        ConnectionParameters.add('Password=ADMIN'); 

        Sage300IntegrationFramework sag300IntgrFrm = new Sage300IntegrationFramework();
        boolean isconnected=sag300IntgrFrm.TestConnection('https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac',ConnectionParameters);
        
        
        map<string,list<object>> AttribParams=new map<string,list<object>> ();
        list<object>  AttribParam= new list<object>();
               
        AttribParam= new list<object>();
        AttribParam.add('YGTCUSTDTL');
        AttribParams.put('ERPFuncName',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('171');
        AttribParams.put('Version',AttribParam);
               
        AttribParam= new list<object>();
        AttribParam.add('1200');
        AttribParams.put('EQUAL',AttribParam);
        
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
        
        AttribParam= new list<object>();
        AttribParam.add('200');
        AttribParams.put('count',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('1');
        AttribParams.put('startIndex',AttribParam);
        
        map<string,map<string,list<string>>> Params = new map<string,map<string,list<string>>>();
        Helper.GUMU_Response GumuResp =sag300IntgrFrm.getData(Params,AttribParams);
        
        
        map<String,String> PromotionFields = new map<String,String>();
        PromotionFields.put('CustomerNo300','MN001');
        PromotionFields.put('Category','US');
        PromotionFields.put('Tax_group','USD');
   
        map<string,list<object>> SFObjectLists = new map<string,list<object>> ();
        SFObjectLists.put('Accounts',acnt);
        SFObjectLists.put('Contacts',ContactList);
        SFObjectLists.put('Addresses',shipToList);
        
        AttribParams=new map<string,list<object>> ();
        AttribParam= new list<object>();
        AttribParams=Utility.getAttribParameters('', '' , Config.Id, 'Customer', '' , Helper.MappingPurpose.POST); 
        
        AttribParam= new list<object>();
        AttribParam.add('arCustomersFinder');
        AttribParams.put('ERPFuncName',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('GETData');
        AttribParams.put('PostDataXml',AttribParam);
            
        Helper.GUMU_Response oGUMU_Response=sag300IntgrFrm.PostData(Config.Id,'Customer',SFObjectLists, PromotionFields,AttribParams);
        
        AttribParams=new map<string,list<object>> ();
        AttribParam= new list<object>();
        AttribParams=Utility.getAttribParameters('', '' , Config.Id, 'Address', '' , Helper.MappingPurpose.POST); 
        
        AttribParam= new list<object>();
        AttribParam.add('arCustomersFinder');
        AttribParams.put('ERPFuncName',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('PostOrder');
        AttribParams.put('PostDataXml',AttribParam);
        oGUMU_Response=sag300IntgrFrm.PostData(Config.Id,'Address',SFObjectLists, PromotionFields,AttribParams);
        
               
        AttribParams=new map<string,list<object>> ();
        AttribParam= new list<object>();
        AttribParams=Utility.getAttribParameters('', '' , Config.Id, 'Customer', '' , Helper.MappingPurpose.MODIFY);
        
        AttribParam= new list<object>();
        AttribParam.add('GETData');
        AttribParams.put('PostDataXml',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('arCustomersFinder');
        AttribParams.put('ERPFuncName',AttribParam);
        
        oGUMU_Response=sag300IntgrFrm.PostData(Config.Id,'Customer',SFObjectLists, PromotionFields,AttribParams);
        
        AttribParams=new map<string,list<object>> ();
        AttribParam= new list<object>();
        AttribParams=Utility.getAttribParameters('', '' , Config.Id, 'Address', '' , Helper.MappingPurpose.MODIFY);
        
        AttribParam= new list<object>();
        AttribParam.add('GETData');
        AttribParams.put('PostDataXml',AttribParam);
        
        AttribParam= new list<object>();
        AttribParam.add('arCustomersFinder');
        AttribParams.put('ERPFuncName',AttribParam);
        oGUMU_Response=sag300IntgrFrm.PostData(Config.Id,'Address',SFObjectLists, PromotionFields,AttribParams);
        
        Helper.GUMU_Response pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.responseERPData = ''; 
        oGUMU_Response=sag300IntgrFrm.getMapForXML_Schema(pGUMU_Response,AttribParams);
        
        oGUMU_Response=sag300IntgrFrm.ReadSchema('arCustomersFinder',Config.Id);
        
        list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
        map<string,string>ERPDataMap = new map<string,string>();
        ERPDataMap.put('IDCUST','1200');
        ERPDataMap.put('IDGRP','NTX');
        ERPDataMap.put('NAMECUST','AMALGATE');      
        ERPDataMapList.add(ERPDataMap);
        pGUMU_Response = new Helper.GUMU_Response();
        pGUMU_Response.ERPDataMap = ERPDataMapList;
        List<Helper.Customer> GetGenericCustomers = sag300IntgrFrm.GetGenericCustomers(pGUMU_Response);
        
        sag300IntgrFrm.GetFieldForAutoMatch();
        
        map<string,map<string,list<string>>> PrepareFieldParam=sag300IntgrFrm.PrepareFieldParam('1200', '1200');
        PrepareFieldParam=sag300IntgrFrm.PrepareFieldParam('01/01/2016', '');
        
        //-----------------------------------------------IntegrationFactory-----------------------------------------
        IntegrationFactory Factory = new IntegrationFactory();
        IntegrationFactory.getERPProvider();
    }
    
    static testMethod void ERPAdministration() 
    {
        ERP_Config__c Config =new ERP_Config__c();
        Config.ERP_System__c = 'Sage300ERP';
        Config.Name = 'Sage 300 ERP - SAMINC';
        Config.Web_Service_URL__c = 'https://www.magentosageerp.com:8080/SDataServlet/sdata/sageerp/accpac';
        Config.Inactive__c = false;
        Config.Integration_Information__c = '<PARAMS><PARAM NAME="CompanyCode"  VALUE="SAMINC" /><PARAM NAME="Username"  VALUE="ADMIN" /><PARAM NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>'; 
        Config.Integration_Information_2__c ='NAME="Username"  VALUE="ADMIN" /><PARAM ';
        Config.Integration_Information_3__c = 'NAME="Password"  VALUE="50keCR0n2/9RPa+XCrypFmQjAFzrfIv2P99NcFGI5i4=" /></PARAMS>';
        Config.Synchronization__c='Both';
        Config.ERP_Company_Code__c='SAMINC';
        Config.Default__c=true;
        insert Config;
        System.assertEquals('SAMINC',Config.ERP_Company_Code__c);
        
        // intialize Configurationlist controller           
        sObject sObj = Schema.getGlobalDescribe().get('GUMU_Lite__ERP_Config__c').newSObject() ;
        ApexPages.StandardController StdCntlr = new ApexPages.StandardController(sObj);
        ConfigurationController ConfigCntlr = new ConfigurationController(StdCntlr);
        
        ConfigCntlr.runInstallScript(Config.Id,'Sage300ERP');
        
        PostInstallRecords PSR= new PostInstallRecords();
        PSR.loadLicenceData();
        PSR.PasswordSetting();
        PSR.loadStandardSetting();
    }   

}
global with sharing class SalesOrder300Controller 
{

    public Boolean bShowSalesOrder { get; set; }

    //Properties for object prefix 
    public String AccountObjectPrefix {get;set;} 
    public String ContactObjectPrefix {get;set;}
    public String UserObjectPrefix {get;set;}
    public String ConfigObjectPrefix {get;set;}
    public String WarehouseObjectPrefix {get;set;}
    public String TermsObjectPrefix {get;set;}
    public String ShipObjectPrefix {get;set;}
    public String ShipToObjectPrefix {get;set;}
    public String TaxObjectPrefix {get;set;}
    public String TaxClassObjectPrefix {get;set;}
    public String TaxRuleObjectPrefix {get;set;} 
    public String SalesObjectPrefix {get;set;}
    public String PaymentObjectPrefix {get;set;} 
    public String ProductObjectPrefix {get;set;}
    public String ProductFamilyObjectPrefix {get;set;}
    public String UOMObjectPrefix {get;set;}   
    public String PBEntryOjectPrefix {get;set;}
    public String CurrencyObjectPrefix {get;set;}
    public String PriceListObjectPrefix {get;set;}
    // X3 Variables
    public String SalesSiteObjectPrefix {get;set;}
    public String ShipSiteObjectPrefix {get;set;}
    Public String ShipViaObjectPrefix {get;set;} 
    public boolean isNew {get;set;}

    public Order ERPOrder {get;set;}
    public String OrderNumber {get;set;}
    public String OrderDate {get;set;}
    public String JSONLineItems {get;set;}

    public String JSONOrderDetails {get;set;}
    public String IntegrationKey {get;set;}
    public String OrderHeaderDetails {get;set;}
    public String DocumentType {get;set;}

    public String JSONOrderItems {get;set;}
    public Decimal LineTotal {get;set;}
    public Decimal minusTaxTotal {get;set;}
    public Decimal plusTaxTotal {get;set;}

    public Decimal SalesTaxAmt {get;set;}
    public list<LineItem> LineItems {get;set;}
    public LineItem CurrentItem {get;set;}

    public static list<ResultSet> searchedRecord {get;set;}
    public static list<ProductFamilySet> searchedFamily {get;set;}

    public String orderPricebookId {get;set;}
    public String orderConfigId{get;set;}
    public String orderAccountID {get;set;}
    public String orderIntegrationKey {get;set;}
    public String orderIntegrationName {get;set;}

    public String OrderId{get;set;}
    public string ErrorMessage;
    

    public String ERPSystemName {get;set;}
    public String ERPCompanyCode {get;set;}
    public String AccountId {get;set;}

    public String gbERPSystemName {get;set;}
    public static String ERPVersion {get;set;}
    public String ProfileName {get;set;}
    public String Synchronization{get;set;}

    public String AccountName{get;set;}
    public String PricebookName{get;set;}
    public String oCurrency{get;set;}
    public String ARDivisionNo{get;set;}

    public String CustomerNo{get;set;}
    //public String DocumentType{get;set;}
    public String ShipToCode{get;set;}
    public String ShipToName{get;set;}
   // public String Price_List{get;set;}

    public String PrintSalesOrders{get;set;}
    public String PrintPickingSheets{get;set;}
    public String BatchFaxNo{get;set;}
    public String DiscountType{get;set;}

    public String TaxGroup{get;set;}
    public String ShipVia{get;set;}
    public String AccountSet{get;set;}
    public String TermsCode{get;set;}

    public decimal TotalAmount{get;set;}
    // public Decimal oLineTotal{get;set;}
    public Decimal DiscountPC{get;set;}
    public Decimal DiscountAmt{get;set;}

    public Decimal FreightAmt{get;set;}
    public Decimal DepositAmt{get;set;}
    public Decimal oSalesTaxAmt{get;set;}
    public Decimal AmtSubTax{get;set;}

    public String BillingStreet{get;set;}
    public String BillingCity{get;set;}
    public String BillingState{get;set;}
    public String BillingCountry{get;set;}
    public String BillingPostalCode{get;set;}

    public String ShippingStreet{get;set;}
    public String ShippingCity{get;set;}
    public String ShippingState{get;set;}
    public String ShippingCountry{get;set;}
    public String ShippingPostalCode{get;set;}

    public Decimal AmtAddTax{get;set;}
    public Decimal ContactName{get;set;}
    public Decimal UserName{get;set;} 
    public String Disabled {get;set;} 
    public boolean TextDisabled {get;set;}
    public String Mode{get;set;}
    public List<Order> IntegrationKeyList{get;set;}
    Public string PageIntegrationKey {get;set;}
    public string Namespace{get;set;}
    private static final string ClassName='SalesOrderController';  

    //Properties for order
    public SalesOrder300Controller(ApexPages.StandardController controller) 
    {
        try
        {       
            if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
            {
                // Check if the user has read access on the Profile.name
                if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                    ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                }
            }

            Security_Matrix__c SM = Security_Matrix__c.getInstance();
            bShowSalesOrder = Boolean.valueOf(SM.Promote_Order__c);

            OrderId = Apexpages.currentPage().getParameters().get('Id');

            Mode= Apexpages.currentPage().getParameters().get('Mode');
            NameSpace = Utility.FetchNameSpace();
            /*if(Mode=='View' && Mode=='Edit')
                {
                     TextDisabled=true;
                }
                else
                {
                     TextDisabled=false;
                }*/

            // Set Current Record
            list<Order> Orders = [Select 
                                  BillingStreet, BillingState, BillingPostalCode, BillingLongitude, BillingLatitude, BillingCountry, BillingCity,
                                  ShippingStreet, ShippingState, ShippingPostalCode, ShippingLongitude, ShippingLatitude, ShippingCountry, ShippingCity, 
                                  Pricebook2Id, OrderNumber, Type, TotalAmount, 
                                  SystemModstamp, StatusCode, Status, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, 
                                  IsDeleted, Id, EndDate, EffectiveDate, Description, 
                                  CustomerAuthorizedById, CreatedDate, CreatedById, ContractId, CompanyAuthorizedById,  ActivatedDate, ActivatedById, AccountId,
                                  ERP_Company_Code__c, ERP_Order_Details_Info__c, ERP_Order_Info__c, ERP_Order_Number__c, Integration_Key__c, ERP_Order_Total__c,
                                  ARDivisionNo__c,AccountName__c,PricebookName__c,Currency__c,CustomerNo__c,LineTotal__c,DiscountType__c,ShipToCode__c,
                                  ShipToName__c,SalesSite__c,SalesSiteId__c,PrintSalesOrders__c,PrintPickingSheets__c,BatchFaxNo__c,
                                  DiscountPC__c,DiscountAmt__c,FreightAmt__c,DepositAmt__c,SalesTaxAmt__c,AmtSubTax__c,AmtAddTax__c,UserName__c,ContactName__c,
                                  TaxGroup__c,ShipVia__c,AccountSet__c,TermsCode__c,Document_Type__c,
                                  account.BillingStreet, account.BillingCity, account.BillingState,account.BillingPostalCode,account.BillingCountry,
                                  account.ShippingStreet, account.ShippingCity, account.ShippingState,account.ShippingPostalCode,account.ShippingCountry
                                  ,account.Warehouse__c,account.Price_List__c
                                  From Order
                                  Where Id =:OrderId];// controller.getRecord().Id];

            if(Orders.size() > 0)
            {
                ERPOrder = Orders[0];
                OrderId = ERPOrder.id;

                if(string.IsBlank(ERPOrder.ERP_Order_Number__c)&& Mode=='Edit' )     
                {
                    TextDisabled=false;
                    Disabled = '';
                }
                else
                {
                    TextDisabled=true;
                    Disabled = ' Disabled = Disabled'; //Disabled=Disabled
                }

                if(ERPOrder.BillingStreet=='' || ERPOrder.BillingStreet== null)
                    BillingStreet = ERPOrder.account.BillingStreet;
                else
                    BillingStreet = ERPOrder.BillingStreet;

                if(ERPOrder.BillingCity=='' || ERPOrder.BillingCity== null)
                    BillingCity = ERPOrder.account.BillingCity;
                else
                    BillingCity = ERPOrder.BillingCity;

                if(ERPOrder.BillingState=='' || ERPOrder.BillingState== null)
                    BillingState = ERPOrder.account.BillingState;
                else
                    BillingState = ERPOrder.BillingState;

                if(ERPOrder.BillingCountry=='' || ERPOrder.BillingCountry== null)
                    BillingCountry = ERPOrder.account.BillingCountry;
                else
                    BillingCountry = ERPOrder.BillingCountry;

                if(ERPOrder.BillingPostalCode=='' || ERPOrder.BillingPostalCode== null)
                    BillingPostalCode = ERPOrder.account.BillingPostalCode;
                else
                    BillingPostalCode = ERPOrder.BillingPostalCode;

                if(ERPOrder.ShippingStreet=='' || ERPOrder.ShippingStreet== null)
                    ShippingStreet = ERPOrder.account.ShippingStreet;
                else
                    ShippingStreet = ERPOrder.ShippingStreet;

                if(ERPOrder.ShippingCity=='' || ERPOrder.ShippingCity== null)
                    ShippingCity = ERPOrder.account.ShippingCity;
                else
                    ShippingCity = ERPOrder.ShippingCity;

                if(ERPOrder.ShippingState=='' || ERPOrder.ShippingState== null)
                    ShippingState = ERPOrder.account.ShippingState;
                else
                    ShippingState = ERPOrder.ShippingState;

                if(ERPOrder.ShippingCountry=='' || ERPOrder.ShippingCountry== null)
                    ShippingCountry = ERPOrder.account.ShippingCountry;
                else
                    ShippingCountry = ERPOrder.ShippingCountry;

                if(ERPOrder.ShippingPostalCode=='' || ERPOrder.ShippingPostalCode== null)
                    ShippingPostalCode = ERPOrder.account.ShippingPostalCode;
                else
                    ShippingPostalCode = ERPOrder.ShippingPostalCode;

            }

            CurrentItem = new LineItem();
            LineItems = new list<LineItem>();
            OrderNumber = '';
            JSONOrderDetails ='';
            JSONOrderItems='';
            LineTotal=0.00;
            minusTaxTotal=0.00;
            plusTaxTotal=0.00;
            isNew = true;

            if(ERPOrder != null)
            {
                isNew = false;

                orderAccountID = ERPOrder.AccountId;

                ERP_Config__c config = [SELECT Id,Name,ERP_System__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c Where Id =: ERPOrder.Integration_Key__c limit 1];

                orderIntegrationKey = config.Id;
                orderIntegrationName = config.Name;
                ERPSystemName = config.ERP_System__c;

                //Map<String,String> ParamMap = Utility.FormatConnectionPairs(ConnectionInfo);
                Map<String,String> ParamMap = Utility.FormatERPInfo(config.Integration_Information__c,config.Integration_Information_2__c,config.Integration_Information_3__c);
                ERPVersion = ParamMap.get('version');


                if(String.isNotBlank(ERPOrder.Pricebook2Id))
                    orderPricebookId = ERPOrder.Pricebook2Id;

                if(String.isNotBlank(ERPOrder.ERP_Order_Number__c))
                    OrderNumber = ERPOrder.ERP_Order_Number__c;

                if(String.isNotBlank(ERPOrder.ERP_Order_Info__c))
                    JSONOrderDetails = ERPOrder.ERP_Order_Info__c;


                LineItems=getOrderProduct(OrderId);
                
                if(LineItems.size() > 0)
                {
                    for(LineItem Lt : LineItems)
                    {
                        LineTotal += decimal.valueOf(Lt.ExtensionAmt);
                        //minusTaxTotal += decimal.valueOf(Lt.minusTax);
                        //plusTaxTotal += decimal.valueOf(Lt.plusTax);
                    }
                }
                JSONOrderItems = json.serialize(LineItems);
            }
            else
            {
                orderPricebookId = '';
                orderAccountID = '';
                orderIntegrationKey = '';
                orderIntegrationName = '';

                IntegrationKey = Apexpages.currentPage().getParameters().get('PageIntegrationKey'); 
               
                

                if(IntegrationKey==''||IntegrationKey==null)
                { 
                    list<ERP_Config__c> configList = [SELECT Id,Name,ERP_System__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c
                                                      FROM ERP_Config__c Where ERP_System__c ='Sage300ERP' ];

                    IntegrationKey='';
                    for(ERP_Config__c configERP :configList)
                    {
                        IntegrationKey +=configERP.Id + '_';
                    }

                    IntegrationKey=IntegrationKey.substring(0,IntegrationKey.length()-1);
                    
                }
            }

            // Set object prefix properties
            AccountObjectPrefix = Utility.getSobjectKeyPrefix('Account');
            ContactObjectPrefix = Utility.getSobjectKeyPrefix('Contact');
            UserObjectPrefix = Utility.getSobjectKeyPrefix('User');
            ConfigObjectPrefix = Utility.getSobjectKeyPrefix('ERP_Config__c');
            WarehouseObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Warehouse__c');
            TermsObjectPrefix = Utility.getSobjectKeyPrefix('Terms_Code__c');
            ShipObjectPrefix = Utility.getSobjectKeyPrefix('Ship_Method__c');
            TaxObjectPrefix = Utility.getSobjectKeyPrefix('Tax_Schedule__c');
            TaxClassObjectPrefix = Utility.getSobjectKeyPrefix('Tax_Class__c');
            TaxRuleObjectPrefix = Utility.getSobjectKeyPrefix('TaxRule__c');
            SalesObjectPrefix = Utility.getSobjectKeyPrefix('Salesperson__c');
            ShipToObjectPrefix = Utility.getSobjectKeyPrefix('Ship_To__c');
            PaymentObjectPrefix = Utility.getSobjectKeyPrefix('Payment_Type__c');
            ProductObjectPrefix = Utility.getSobjectKeyPrefix('Product2');
            ProductFamilyObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Product_Family__c');
            UOMObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'UOM__c'); 
            PriceListObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Price_List__c');
            PBEntryOjectPrefix = Utility.getSobjectKeyPrefix('PricebookEntry');
            CurrencyObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Terms_Code__c');
            SalesSiteObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Tax_Group__c'); 
            ShipSiteObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Account_Set__c');
            ShipViaObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Ship_Via__c');
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'GetDataRequest',ex,true);
        }        

    }

    public static list<LineItem> getOrderProduct(string OrderID)
    {
        list<LineItem> LineItems = new list<LineItem>();
        LineItem lineItm ;
        list<OrderItem> OrderItems = [Select UnitPrice, Quantity, PricebookEntryId,PricebookEntry.ProductCode, OrderItemNumber, OrderId, 
                                      ListPrice, Id,PricebookEntry.Product2id, Warehouse_Code__c, UOM__c, TaxClass__c, QOH__c, PlusTax__c, MinusTax__c, ItemType__c, ItemTypeCode__c,Price_List__c, 
                                      ExtensionAmt__c, Drop_Ship__c, Discount__c, Commissionable__c, Comments__c, Description,
                                      UOM_Conversion_Factor__c
                                      From OrderItem where OrderId =:OrderID];
        if(OrderItems.size()>0)
        {
            for(OrderItem OrderItm :OrderItems )
            {
                lineItm = new LineItem();
                lineItm.Comments=OrderItm.Comments__c;
                lineItm.Commissionable=OrderItm.Commissionable__c;
                lineItm.Discount =String.valueOf(OrderItm.Discount__c);
                lineItm.DropShip=OrderItm.Drop_Ship__c;
                lineItm.ExtensionAmt=String.valueOf(OrderItm.ExtensionAmt__c);
                lineItm.ItemCode=OrderItm.PricebookEntry.ProductCode;
                lineItm.ItemDescription=OrderItm.Description;
                lineItm.ItemType=OrderItm.ItemType__c;
                lineItm.ItemTypeCode=OrderItm.ItemTypeCode__c;
                lineItm.ListPrice=String.valueOf(OrderItm.UnitPrice);         //ListPrice
                lineItm.minusTax=String.valueOf(OrderItm.MinusTax__c);
                lineItm.plusTax=String.valueOf(OrderItm.PlusTax__c);
                //lineItm.ProductId=OrderItm.PricebookEntry.Product2id;
                lineItm.ProductId=OrderItm.PricebookEntryId;
                lineItm.QOH=String.valueOf(OrderItm.QOH__c);
                lineItm.QuantityOrdered=String.valueOf(OrderItm.Quantity).replace('.00','');
                lineItm.TaxClass=OrderItm.TaxClass__c;
                lineItm.UnitPrice=String.valueOf(OrderItm.UnitPrice);
                lineItm.UOM=OrderItm.UOM__c;
                lineItm.UOMConversion=string.ValueOf(OrderItm.UOM_Conversion_Factor__c);
                lineItm.pricelist=OrderItm.Price_List__c;
                lineItm.WarehouseCode=OrderItm.Warehouse_Code__c;
                LineItems.add(lineItm);
            }               
        }
        
        return LineItems;
    }

    @RemoteAction    
    public static map<String,String> LoadAccountData(string AccountId)
    {
        map<String,String> DetailsMap = new map<String,String>();
        try
        {
            Account OrderAccount= [Select 
                                   Website, Type, Phone, Name, Id,  Integration_Key__c, ERP_Customer__c,Currency__c, ERP_Customer_Number__c, ERP_Company_Code__c, Fax, Description, 
                                   ShippingStreet, ShippingState, ShippingPostalCode, ShippingLongitude, ShippingLatitude, ShippingCountry, ShippingCity,AccountNumber,Warehouse__c,Price_List__c,  
                                   BillingStreet, BillingState, BillingPostalCode, BillingLongitude,BillingLatitude, BillingCountry, BillingCity
                                   From Account 
                                   Where Id= : AccountId limit 1];

            ERP_Config__c config = [SELECT Id,Name,ERP_System__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c Where Id =: OrderAccount.Integration_Key__c limit 1]; 

            //Map<String,String> ParamMap = Utility.FormatConnectionPairs(ConnectionInfo); 
            Map<String,String> ParamMap = Utility.FormatERPInfo(config.Integration_Information__c,config.Integration_Information_2__c,config.Integration_Information_3__c);
            string ERPSystemName=config.ERP_System__c;

            DetailsMap.put('erpSystem',ERPSystemName);
            DetailsMap.put('ERPVersion',ParamMap.get('version'));
            DetailsMap.put('Integration',config.Name);
            DetailsMap.put('IntegrationId',config.Id);
            DetailsMap.put('UniqueKey',OrderAccount.ERP_Customer_Number__c);
            DetailsMap.put('Acc_Warehouse',OrderAccount.Warehouse__c);
            DetailsMap.put('PriceList',OrderAccount.Price_List__c);

            list<Pricebook2> pb =[Select Id,Name from Pricebook2 where Integration_Key__c =: OrderAccount.Integration_Key__c limit 1 ];
            if(pb.size() > 0)
            {
                DetailsMap.put('Pricebook',pb[0].Name);
                DetailsMap.put('PricebookId',pb[0].Id);
            }

            DetailsMap.put('BillingStreet',OrderAccount.BillingStreet); 
            DetailsMap.put('BillingState',OrderAccount.BillingState);
            DetailsMap.put('BillingPostalCode', OrderAccount.BillingPostalCode);
            DetailsMap.put('BillingCountry', OrderAccount.BillingCountry);
            DetailsMap.put('BillingCity',OrderAccount.BillingCity);
            DetailsMap.put('Currency',OrderAccount.Currency__c);    
            String ShipCode='';
            String ShippingStreet='';
            String ShippingState='';
            String ShippingPostalCode='';
            String ShippingCountry='';
            String ShippingCity='';
            String Warehouse='';

            list<Ship_To__c> ShipTo = [SELECT 
                                       Id,Name,Account_Id__c,ERP_Contact_Code__c,Email_Address__c,Fax_No__c,Integration_Key__c,
                                       Salesperson_No__c,Ship_To_Address1__c,Ship_To_Address2__c,Ship_To_Address3__c,
                                       Ship_To_City__c,Ship_To_Code__c,Ship_To_Country_Code__c,Ship_To_Name__c,Ship_To_State__c,
                                       Ship_To_Zip_Code__c,Tax_Schedule__c,Telephone_Ext__c,Telephone_No__c,Warehouse_Code__c
                                       From Ship_To__c
                                       Where isShipTo__c ='Yes' and Default_ShipTo__c='Yes' and Account_Id__c =: OrderAccount.Id limit 1];

            if(ShipTo.size() > 0)
            {
                String Street = (String.isNotBlank(ShipTo[0].Ship_To_Address1__c) )? ShipTo[0].Ship_To_Address1__c : '';
                Street += (String.isNotBlank(ShipTo[0].Ship_To_Address2__c) )? ' '+ShipTo[0].Ship_To_Address2__c: '';
                Street += (String.isNotBlank(ShipTo[0].Ship_To_Address3__c) )? ' '+ShipTo[0].Ship_To_Address3__c : '';

                ShipCode=ShipTo[0].Ship_To_Code__c;
                ShippingStreet = Street;
                ShippingState = ShipTo[0].Ship_To_State__c;
                ShippingPostalCode = ShipTo[0].Ship_To_Zip_Code__c;
                ShippingCountry = ShipTo[0].Ship_To_Country_Code__c;
                ShippingCity = ShipTo[0].Ship_To_City__c;
                Warehouse = ShipTo[0].Warehouse_Code__c;
            }                     
            string sSalesperson = GetSalesperson(OrderAccount.Integration_Key__c);

            DetailsMap.put('Salesperson',sSalesperson);
            DetailsMap.put('ShipCode',ShipCode);
            DetailsMap.put('ShippingStreet',ShippingStreet);
            DetailsMap.put('ShippingState',ShippingState);
            DetailsMap.put('ShippingPostalCode',ShippingPostalCode);
            DetailsMap.put('ShippingCountry',ShippingCountry);
            DetailsMap.put('ShippingCity',ShippingCity);
            DetailsMap.put('Warehouse',Warehouse);
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'LoadAccountData',ex,true);
        } 
        return DetailsMap;
    } 

    public static String GetSalesperson(String IntegrationKey)
    {
        String Salesperson='';

        // Check if the user has read access on the Salesperson_Mapping__c fields
        if (!Schema.sObjectType.Salesperson_Mapping__c.fields.User_Id__c.isAccessible() 
                || !Schema.sObjectType.Salesperson_Mapping__c.fields.Salesperson_Id__c.isAccessible()
                || !Schema.sObjectType.Salesperson_Mapping__c.fields.Integration_Key__c.isAccessible()
                || !Schema.sObjectType.Salesperson_Mapping__c.fields.Id.isAccessible()){
            return null;
        }

        list<Salesperson_Mapping__c> mappings=[Select Id,Salesperson_Id__c,User_Id__c,Integration_Key__c From Salesperson_Mapping__c
                                               Where Integration_Key__c=:IntegrationKey AND User_Id__c=:UserInfo.getUserId() limit 1];

        if(mappings.size() > 0)
        {
            // Check if the user has read access on the Salesperson_Mapping__c fields
            if (!Schema.sObjectType.Salesperson__c.fields.Salesperson_Code__c.isAccessible()
                    || !Schema.sObjectType.Salesperson__c.fields.Integration_Key__c.isAccessible()
                    || !Schema.sObjectType.Salesperson__c.fields.AR_Division_Code__c.isAccessible()
                    || !Schema.sObjectType.Salesperson__c.fields.Id.isAccessible()){
                return null;
            }

            list<Salesperson__c> oSPs=[Select Id,Integration_Key__c,Salesperson_Code__c,AR_Division_Code__c
                                       From Salesperson__c Where Id= :mappings[0].Salesperson_Id__c Limit 1];

            if(oSPs.size() > 0 )
                Salesperson = oSPs[0].Salesperson_Code__c;
        }
        return Salesperson;
    }

    @RemoteAction
    public static Ship_To__c LoadShipAddress (String ShipToId)
    {
        Ship_To__c ShipTo = [SELECT 
                             Id,Name,Account_Id__c,ERP_Contact_Code__c,Email_Address__c,Fax_No__c,Integration_Key__c,
                             Salesperson_No__c,Ship_To_Address1__c,Ship_To_Address2__c,Ship_To_Address3__c,
                             Ship_To_City__c,Ship_To_Code__c,Ship_To_Country_Code__c,Ship_To_Name__c,Ship_To_State__c,
                             Ship_To_Zip_Code__c,Tax_Schedule__c,Telephone_Ext__c,Telephone_No__c,Warehouse_Code__c
                             From Ship_To__c
                             Where Id =: ShipToId limit 1];        
        return ShipTo;
    }

    @RemoteAction
    public static ResultSet[] getRecords(String searchText, String PriceBookId,String Family,String DocType) 
    {
        searchedRecord = new list<ResultSet>();
       //SOSL Text should be more then one charecter
        list<PricebookEntry> pricebook = [select Id,Name from PricebookEntry where ProductCode =:searchText];
        system.debug('pricebook' +pricebook); 

        try
        {
            if(searchText.length() >0)
            {
                String Test = '%' + String.escapeSingleQuotes(searchText) + '%';
				
                List<SObject> searchList = new List<SObject>();

                if(String.isNotBlank(Family))
                {
                	
                    searchList = [SELECT Id,Name,ProductCode,Category__c,Product_Description__c,UnitPrice  
                                  FROM PricebookEntry 
                                  WHERE Pricebook2Id =: PriceBookId
                                  AND ProductCode LIKE : String.escapeSingleQuotes(Test) AND Category__c=: Family LIMIT 200]; // ERP_PrdFamily_Code__c,ERP_PrdFamily_Desc__c,AND ERP_PrdFamily_Code__c=: Family
                    system.debug('searchList IF :' +searchList);               

                }
                else
                {  
                	                         
                        searchList = [SELECT Id,Name,ProductCode,ERP_PrdFamily_Code__c,ERP_PrdFamily_Desc__c,UnitPrice  
                                      FROM PricebookEntry 
                                      WHERE Pricebook2Id =: PriceBookId
                                      AND ProductCode LIKE : Test LIMIT 200];
                        system.debug('searchList ELSE :' +searchList);              
                }

                for(SObject s:searchList )
                {
                    searchedRecord.add(new SalesOrder300Controller.ResultSet(s));
                    system.debug('searchedRecord :' +searchedRecord);
                } 
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getRecords',ex,true);
        } 
        return searchedRecord;
    }

    @RemoteAction
        public static ProductFamilySet[] getFamilyRecords(String searchText, String IntegrationKey, String DocType) 
        {
                searchedFamily = new list<ProductFamilySet>();
                //SOSL Text should be more then one charecter
                if(searchText.length() >0)
                {
                        searchText = '%' + searchText + '%';
                        List<SObject> searchList = new List<SObject>();
 
 
                        if(DocType.toLowerCase() == 'Invoice')
                        {
                                searchList = [Select Id,Name,Integration_Key__c,ERP_Product_Family_Code__c,ERP_Product_Family_Description__c 
                                              From ERP_Product_Family__c 
                                              Where  Integration_Key__c =: IntegrationKey 
                                              AND ERP_Product_Family_Code__c LIKE : String.escapeSingleQuotes(searchText) 
                                              AND ERP_Product_Family_Code__c IN ('Charge','Comment','Miscellaneous')
                                              LIMIT 200];
                        }
                        else
                        {
                                searchList = [Select Id,Name,Integration_Key__c,ERP_Product_Family_Code__c,ERP_Product_Family_Description__c 
                                              From ERP_Product_Family__c 
                                              Where  Integration_Key__c =: IntegrationKey 
                                              AND ERP_Product_Family_Code__c LIKE : String.escapeSingleQuotes(searchText) LIMIT 200];
                                system.debug('searchList :'+searchList);              
                        }
                        for(SObject s : searchList )
                        {
                           searchedFamily.add(new SalesOrder300Controller.ProductFamilySet(s));
                           system.debug('searchedFamily :'+searchedFamily);
                        } 
                }
                return searchedFamily;
        }
 

    public Pagereference LoadItem ()
    {
        String index = Apexpages.currentPage().getParameters().get('Index');
        
        if (String.isNotBlank(index))
        {
            CurrentItem = LineItems[Integer.valueOf(index)];
            system.debug('CurrentItem'+CurrentItem);
        }
        else
            CurrentItem = new LineItem();
        return null;
    }

    @RemoteAction
    public static map<String,String> CheckPBEntryExists(String PricebookId , String ProductCode)
    {
        system.debug('CheckPBEntryExists'+PricebookId);
        map<String,String> mapPBData =new map<String,String>();
        try
        {
            list<PricebookEntry> PBEntry = [Select ProductCode, Product2Id, Pricebook2Id, Name,Id,Product_Description__c,Category__c
                                            From PricebookEntry
                                            Where Pricebook2Id =: PricebookId
                                            And ProductCode =: ProductCode];
            if(PBEntry.size() > 0)
            {
                mapPBData.put('Exists','true');
                mapPBData.put('Product2Id',PBEntry[0].Id);
                //return mapPBData;
                //return true;
            }
            else
            {
                mapPBData.put('Exists','false');
                mapPBData.put('Product2Id','');
                //return mapPBData;
                //return false;
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'CheckPBEntryExists',ex,true);
        } 
        return mapPBData;
    }


    public String JSONPrdDetails {get;set;}
    public map<String,String> RealTimeProductData {get;set;} 
    public  string RealTimeProductData1 {get;set;} 
    public PageReference GetRealTimeProductData ()
    { 
        RealTimeProductData = new  map<String,String>();
        try
        {       
            map<String,Object> params = (map<string,object>)JSON.deserializeUntyped(JSONPrdDetails);
            
             IntegrationKey = Apexpages.currentPage().getParameters().get('PageIntegrationKey'); 
            // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'IntegrationKey: '+IntegrationKey));
              
            string productCode=String.valueOf(params.get('ProductCode'));
            //apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'productCode: '+productCode));
           
           system.debug('IntegrationKey'+IntegrationKey);
           system.debug('productCode '+ productCode);
          
           
            list<PricebookEntry> prizebook =[Select id,Pricebook2Id,UnitPrice,Category__c,Product_Description__c,UOM__c 
                From PricebookEntry where Pricebook2.isstandard = false and Pricebook2.Integration_Key__c=:IntegrationKey and ProductCode =:productCode]; 
            
             system.debug('prizebook'+prizebook);

            string Category ='';
            string UOM ='';
            string ConversionFactor ='';
            string oderDate;
            if(prizebook.size() > 0)
            {
                string UnitPrices =string.valueof(prizebook[0].UnitPrice);
               
                string[] splitorderDate =string.valueOf(params.get('OrderDate')).split('/');
    
                if(splitorderDate[0].length()==1 && splitorderDate[1].length()==1)
                    oderDate = splitorderDate[2]+'-'+'0'+splitorderDate[0]+'-'+'0'+splitorderDate[1];
                else
                    oderDate = splitorderDate[2]+'-'+splitorderDate[0]+'-'+splitorderDate[1];
                
                if(params.get('ProductFamily') !='')
                    Category =string.valueOf(params.get('ProductFamily'));
                else
                    Category =prizebook[0].Category__c;
                
                if(params.get('UOM') !='')
                {
                    UOM =string.valueOf(params.get('UOM'));
                }
                else
                    UOM =prizebook[0].UOM__c;
            }
            else
            {
               // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Please Enter Valid Product Code'));
                RealTimeProductData = new map<String,String>();
                RealTimeProductData1='';
                return null;
            } 
              
            string Quantity ='';
            if(params.get('Quantity')!='')
                Quantity =string.valueOf(params.get('Quantity'));
            else
                Quantity ='1';
            
            
            string aPayload = '';
            aPayload += '<entry>';
            aPayload += '<sdata:payload>';
            aPayload +='<oepricefinderOepricPrimePricingFinder>';
            aPayload += '<request>';
            aPayload +='<CURRENCY>'+'USD'+'</CURRENCY>';   //params.get('currency')
            aPayload +='<ORDERDATE>'+oderDate+'</ORDERDATE>';//params.get('OrderDate')
            aPayload +='<FILTER_HORDDATE>'+oderDate +'</FILTER_HORDDATE>';//params.get('OrderDate')
            aPayload +='<FILTER_HORSOURCURR>'+'USD'+'</FILTER_HORSOURCURR>';
            aPayload +='<FILTER_HCUSTOMER>'+params.get('CustomerNo')+'</FILTER_HCUSTOMER>';
            aPayload +='<FILTER_HTAXGROUP>'+params.get('TaxGroup')+'</FILTER_HTAXGROUP>';
            aPayload +='<FILTER_HTAUTH1 xsi:nil=\"false\"/><FILTER_HTAUTH2 xsi:nil=\"false\"/><FILTER_HTAUTH3 xsi:nil=\"false\"/><FILTER_HTAUTH4 xsi:nil=\"false\"/><FILTER_HTAUTH5 xsi:nil=\"false\"/><FILTER_HTCLASS1>0</FILTER_HTCLASS1><FILTER_HTCLASS2>0</FILTER_HTCLASS2><FILTER_HTCLASS3>0</FILTER_HTCLASS3><FILTER_HTCLASS4>0</FILTER_HTCLASS4><FILTER_HTCLASS5>0</FILTER_HTCLASS5>';
            aPayload +='<ITEMNO>'+params.get('ProductCode')+'</ITEMNO>';
            aPayload +='<PRICELIST>'+params.get('PriceList')+'</PRICELIST>';
            aPayload +='<FILTER_DITEM>'+params.get('ProductCode')+'</FILTER_DITEM>';
            aPayload +='<FILTER_DPRICELIST>'+params.get('PriceList')+'</FILTER_DPRICELIST>';
            aPayload +='<FILTER_DLOCATION>'+params.get('ProductWarehouse')+'</FILTER_DLOCATION>'; //params.get('Warehouse')
            aPayload +='<FILTER_DORDUNIT>'+UOM+'</FILTER_DORDUNIT>';//params.get('UOM')
            aPayload +='<FILTER_DWEIGHTUNIT>'+UOM+'</FILTER_DWEIGHTUNIT>';//params.get('UOM')
            aPayload +='<FILTER_DPRPRICEBY>'+1+'</FILTER_DPRPRICEBY>';
            aPayload +='<FILTER_DCATEGORY>'+Category+'</FILTER_DCATEGORY>';  //params.get('ProductFamily')
            //aPayload +='<FILTER_DCATEGORY>A1</FILTER_DCATEGORY>';
            aPayload += '<FILTER_DSTDCOST>0.000000</FILTER_DSTDCOST>';
            aPayload += '<FILTER_DMOSTREC>0.000000</FILTER_DMOSTREC>';
            aPayload +='<FILTER_DCOST1>0.000000</FILTER_DCOST1>';
            aPayload +='<FILTER_DCOST2>0.000000</FILTER_DCOST2>';
            aPayload +='<FILTER_DAVGCOST>0.00</FILTER_DAVGCOST>'; //'+params.get('grossPrice')+'
            aPayload += '<FILTER_DLASTCOST>0.000000</FILTER_DLASTCOST>';
            aPayload += '<FILTER_DTCLASS1>0</FILTER_DTCLASS1>';
            aPayload +='<FILTER_DTCLASS2>0</FILTER_DTCLASS2>';
            aPayload +='<FILTER_DTCLASS3>0</FILTER_DTCLASS3>';
            aPayload +='<FILTER_DTCLASS4>0</FILTER_DTCLASS4>';
            aPayload +='<FILTER_DTCLASS5>0</FILTER_DTCLASS5>';
            aPayload +='<FILTER_DTINCLUDED1>false</FILTER_DTINCLUDED1>';
            aPayload +='<FILTER_DTTINCLUDED2>false</FILTER_DTTINCLUDED2>';
            aPayload +='<FILTER_DTINCLUDED3>false</FILTER_DTINCLUDED3>';
            aPayload +='<FILTER_DTINCLUDED4>false</FILTER_DTINCLUDED4>';
            aPayload +='<FILTER_DTINCLUDED5>false</FILTER_DTINCLUDED5>';
            aPayload +='<FILTER_DQTYORDERED>'+Quantity+'</FILTER_DQTYORDERED>';
            aPayload += '</request>';
            aPayload +='</oepricefinderOepricPrimePricingFinder>';
            aPayload += '</sdata:payload>';
            aPayload += '</entry>';
            //aPayload ='<entry><sdata:payload><oepricefinderOepricPrimePricingFinder><request><CURRENCY>USD</CURRENCY><ORDERDATE>2016-03-04</ORDERDATE><FILTER_HORDDATE>2016-03-04</FILTER_HORDDATE><FILTER_HORSOURCURR>USD</FILTER_HORSOURCURR><FILTER_HCUSTOMER>1200</FILTER_HCUSTOMER><FILTER_HTAXGROUP>CALIF</FILTER_HTAXGROUP><FILTER_HTAUTH1 xsi:nil=\"false\"/><FILTER_HTAUTH2 xsi:nil=\"false\"/><FILTER_HTAUTH3 xsi:nil=\"false\"/><FILTER_HTAUTH4 xsi:nil=\"false\"/><FILTER_HTAUTH5 xsi:nil=\"false\"/><FILTER_HTCLASS1>0</FILTER_HTCLASS1><FILTER_HTCLASS2>0</FILTER_HTCLASS2><FILTER_HTCLASS3>0</FILTER_HTCLASS3><FILTER_HTCLASS4>0</FILTER_HTCLASS4><FILTER_HTCLASS5>0</FILTER_HTCLASS5><ITEMNO>A1-401/0</ITEMNO><PRICELIST>CTPR01</PRICELIST><FILTER_DITEM>A1-401/0</FILTER_DITEM><FILTER_DPRICELIST>CTPR01</FILTER_DPRICELIST><FILTER_DLOCATION>2</FILTER_DLOCATION><FILTER_DORDUNIT>Ea.</FILTER_DORDUNIT><FILTER_DWEIGHTUNIT>lbs.</FILTER_DWEIGHTUNIT><FILTER_DPRPRICEBY>1</FILTER_DPRPRICEBY><FILTER_DCATEGORY>A1</FILTER_DCATEGORY><FILTER_DSTDCOST>0.000000</FILTER_DSTDCOST><FILTER_DMOSTREC>6.224545</FILTER_DMOSTREC><FILTER_DCOST1>0.000000</FILTER_DCOST1><FILTER_DCOST2>0.000000</FILTER_DCOST2><FILTER_DAVGCOST>0.000000</FILTER_DAVGCOST><FILTER_DLASTCOST>0.000000</FILTER_DLASTCOST><FILTER_DTCLASS1>1</FILTER_DTCLASS1><FILTER_DTCLASS2>1</FILTER_DTCLASS2><FILTER_DTCLASS3>0</FILTER_DTCLASS3><FILTER_DTCLASS4>0</FILTER_DTCLASS4><FILTER_DTCLASS5>0</FILTER_DTCLASS5><FILTER_DTINCLUDED1>false</FILTER_DTINCLUDED1><FILTER_DTTINCLUDED2>false</FILTER_DTTINCLUDED2><FILTER_DTINCLUDED3>false</FILTER_DTINCLUDED3><FILTER_DTINCLUDED4>false</FILTER_DTINCLUDED4><FILTER_DTINCLUDED5>false</FILTER_DTINCLUDED5><FILTER_DQTYORDERED>0.0000</FILTER_DQTYORDERED></request></oepricefinderOepricPrimePricingFinder></sdata:payload></entry>';
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'aPayload: '+aPayload));
            baseIntegrationFramework integrationFramework= new Sage300IntegrationFramework();
            
            
            string SourceEntity='';
            map<String,String> mapData =new map<String,String>();


            map<string,list<object>> AttribParams=new  map<string,list<object>>();
            list<object>  AttribParam= new list<object>();

            AttribParam= new list<object>();
            AttribParam.add(IntegrationKey);
            AttribParams.put('IntegrationId',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(aPayload);
            AttribParams.put('RequestXML',AttribParam);

            AttribParam= new list<object>();
            Helper.MappingPurpose mappingType =Helper.MappingPurpose.ACTION;
            AttribParam.add(mappingType);
            AttribParams.put('MappingPurpose',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('Order');
            AttribParams.put('SourceEntity',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('oepricefinders');
            AttribParam.add('oepricefinderOepricPrimePricingFinder');
            AttribParams.put('ERPFuncName',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('0');
            AttribParams.put('startIndex',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('GETData');
            AttribParams.put('PostDataXml',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('0');
            AttribParams.put('count',AttribParam);

            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
                       
            Helper.GUMU_Response resGUMU_Response =integrationFramework.PostData(IntegrationKey,SourceEntity,AttribParams,mapData,AttribParams);
            system.debug('resGUMU_Response :'+resGUMU_Response);
            list<map<string,string>> mapProERPData = resGUMU_Response.ERPDataMap;
            string KeyPrice ='0';
            string customertype ='0';
           //if(mapProERPData != null)<RETURNCODE>1</RETURNCODE>responseERPData
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'mapProERPData: '+mapProERPData));
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'responseERPData: '+resGUMU_Response.responseERPData));
            if(resGUMU_Response.responseERPData.contains('<RETURNCODE>1</RETURNCODE>'))
            {
                apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'Prizing does not exists for the Selected product.'));
                RealTimeProductData = new map<String,String>();
                RealTimeProductData1='';
                return null;
            }
                
            if(mapProERPData != null)
            {
                if(mapProERPData.size() > 0)
                {
                    for(map<string,string> mapERPData:mapProERPData)
                    {
                        customertype = mapERPData.get('CUSTTYPE');
                        
                        if(mapERPData.get('CUSTTYPE') == '0' || mapERPData.get('CUSTTYPE') == 'Base')
                        {
                            KeyPrice = mapERPData.get('KEYPRICE');
                            break;
                        }
                        else if(mapERPData.get('CUSTTYPE') == '1' || mapERPData.get('CUSTTYPE') == 'A')
                        {
                            KeyPrice = mapERPData.get('KEYPRICE');
                            break;
                        }
                        else if(mapERPData.get('CUSTTYPE') == '2' || mapERPData.get('CUSTTYPE') == 'B')
                        {
                            KeyPrice = mapERPData.get('KEYPRICE');
                            break;
                        }
                        else if(mapERPData.get('CUSTTYPE') == '3' || mapERPData.get('CUSTTYPE') == 'C')
                        {                            
                            KeyPrice = mapERPData.get('KEYPRICE');
                            break;
                        }
                        else if(mapERPData.get('CUSTTYPE') == '4' || mapERPData.get('CUSTTYPE') == 'D')
                        {                          
                            KeyPrice = mapERPData.get('KEYPRICE');
                            break;
                        }
                        
                        else if(mapERPData.get('CUSTTYPE') == '5' || mapERPData.get('CUSTTYPE') == 'E')
                        {
                            KeyPrice = mapERPData.get('KEYPRICE');
                            break;
                        }
                        else if (mapERPData.get('CUSTTYPE') == '7')
                        {                           
                            KeyPrice = mapERPData.get('KEYPRICE'); 
                            break;                       
                        }                      
                    }
                }
            }
            
            list<UOM__c> UOMConversion = [select id,Conversion_Factor__c from UOM__c where  UOM_Code__c =:UOM and Integration_Key__c=:IntegrationKey  LIMIT 1];
            if(UOMConversion.size() > 0) 
                 ConversionFactor = string.valueOf(UOMConversion[0].Conversion_Factor__c);
                  
            string Prddesc =prizebook[0].Product_Description__c;
            Prddesc = Prddesc.replace('\'','');
           // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'KeyPrice: '+KeyPrice));
            
            map<String,String> mapProData = new map<String,String>();
            mapProData.put('QOH','0');
            mapProData.put('discountper','0'); 
            //UnitPrices=resGUMU_Response.ERPDataMap.
            mapProData.put('UnitPrice',KeyPrice);
            mapProData.put('UOM',UOM);           
            //mapProData.put('Salessite','NA012');
            mapProData.put('ItemDescription',Prddesc);
            // mapProData.put('ItemCode','A1');
            mapProData.put('Quantity',Quantity);
            mapProData.put('ProductFamily',Category);
            mapProData.put('Conversion',ConversionFactor);
            
            // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'mapProData: '+mapProData));       
            RealTimeProductData = mapProData;
            RealTimeProductData1=JSON.Serialize(RealTimeProductData);

        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'GetRealTimeProductData',ex,true);
        }
        return null;

    }

    //public static map<String,String> RealTimeProductData_X3 (String IntegrationKey, String AccountID, String ProductCode,String Quantity,string discount, String UOM,String salesite,String shipSite,string grossPrice,string taxRule,string strCurrency)
    /*@RemoteAction
    public static map<String,String> RealTimeProductData (string JSONPrdDetails)
    {
        map<String,String> mapProData = new map<String,String>();
        try
        {
            map<String,Object> params = (map<string,object>)JSON.deserializeUntyped(JSONPrdDetails);
            baseIntegrationFramework integrationFramework= new Sage300IntegrationFramework();//IntegrationFactory.getIntegrationFramework();

            map<string,list<object>> AttribParams=new  map<string,list<object>>();
            list<object>  AttribParam= new list<object>();

            AttribParam= new list<object>();
            AttribParam.add(params.get('IntegrationId'));
            AttribParams.put('IntegrationId',AttribParam);

            string custId = (string)params.get('AccountID');
            list<Account> act=[select Id, Name, ERP_Customer_Number__c FROM Account WHERE Id=:custId limit 1];
            AttribParam= new list<object>();
            string AccountID=string.valueof(act[0].ERP_Customer_Number__c);
            AttribParam.add(AccountID);
            AttribParams.put('AccountID',AttribParam);

            AttribParam= new list<object>();
            string productCode=String.valueOf(params.get('ProductCode'));
            AttribParam.add(params.get('ProductCode'));
            AttribParams.put('ProductCode',AttribParam);

            AttribParam= new list<object>();
            if(params.get('Quantity') =='' || params.get('Quantity')== '0')
                AttribParam.add('1');
            else
                AttribParam.add(params.get('Quantity'));
            AttribParams.put('Quantity',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(params.get('Discount'));
            AttribParams.put('discount',AttribParam);

            AttribParam= new list<object>();
            if(params.get('UOM') =='' || params.get('UOM')== null)
                AttribParam.add('EA');
            else
                AttribParam.add(params.get('UOM'));

            AttribParams.put('UOM',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(params.get('SalesSite'));
            AttribParams.put('salesite',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(params.get('ShipmentSite'));
            AttribParams.put('shipSite',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(params.get('grossPrice'));
            AttribParams.put('grossPrice',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(params.get('taxRule'));
            AttribParams.put('taxRule',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(params.get('currency'));
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

            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            Helper.GUMU_Response resGUMU_Response =integrationFramework.getData(WhereParams, AttribParams);

            system.debug('resGUMU_Response '+resGUMU_Response);

            if(resGUMU_Response.statusCode =='100')
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));          
                mapProData.put('Connection','Failed');
                return mapProData;
            }

            mapProData =resGUMU_Response.SFDataMap;

            system.debug('mapProData '+mapProData);

            list<PricebookEntry> prizebook =[Select ProductCode, ERP_PrdFamily_Desc__c, ERP_PrdFamily_Code__c,Product_Desciption__c,Category__c  
                                             From PricebookEntry where ProductCode =:productCode];
            string FamilyCode = prizebook[0].ERP_PrdFamily_Code__c;
            mapProData.put('ItemTypeCode',FamilyCode);                            
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RealTimeProductData',ex,false);
        }                 
        return mapProData;
    }*/
    
    @RemoteAction
    public static map<String,String> RealTimeProductData (string JSONPrdDetails)
    {
        return null;
    }

    public Pagereference CRUDLineItem()
    {


        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'CRUDLineItem'));             

        String LineIndex = Apexpages.currentPage().getParameters().get('LineIndex');
        String LineOperation = Apexpages.currentPage().getParameters().get('LineOperation');
        String IntegrationKey = Apexpages.currentPage().getParameters().get('IntegrationKey');
        String UniqueKey = Apexpages.currentPage().getParameters().get('UniqueKey');
        String TaxSchedule = Apexpages.currentPage().getParameters().get('TaxSchedule');
        String DiscountPC = Apexpages.currentPage().getParameters().get('DiscountPC');

        String[] CustomerCode = UniqueKey.split('-'); 

        String ARDivisionNo = '';
        String CustomerNo = '';

        if(CustomerCode.size() > 0)
        {
            ARDivisionNo = CustomerCode[0];

            if(CustomerCode.size() > 1)
                CustomerNo = CustomerCode[1];
        }

        if(LineOperation.toLowerCase() == 'delete')
        {
            if(LineIndex.trim().toLowerCase() == 'all')
                LineItems = new list<LineItem>();
            else
                LineItems.remove(Integer.valueOf(LineIndex));
        }
        else
        {
            map<String,Object> mapLineDetails = (map<string,object>)JSON.deserializeUntyped(Apexpages.currentPage().getParameters().get('mapLineDetails'));

            LineItem itm =new LineItem();
            itm.ItemType = String.valueOf(mapLineDetails.get('ItemType'));
            itm.ItemCode = String.valueOf(mapLineDetails.get('ItemCode'));
            itm.ProductId = String.valueOf(mapLineDetails.get('ProductId'));
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info,'CRUDLineItem'+itm.ProductId));
            itm.WarehouseCode = String.valueOf(mapLineDetails.get('WarehouseCode'));
            itm.UOM = String.valueOf(mapLineDetails.get('UOM'));
            itm.pricelist = String.valueOf(mapLineDetails.get('pricelist'));
            itm.TaxClass = String.valueOf(mapLineDetails.get('TaxClass'));
            itm.ListPrice = String.valueOf(mapLineDetails.get('UnitPrice'));
            itm.UnitPrice = String.valueOf(mapLineDetails.get('UnitPrice'));
            itm.Discount = String.valueOf(mapLineDetails.get('Discount'));
            itm.QOH = String.valueOf(mapLineDetails.get('QOH'));
            itm.QuantityOrdered = String.valueOf(mapLineDetails.get('QuantityOrdered'));
            itm.Comments = String.valueOf(mapLineDetails.get('Comments'));
            itm.ItemDescription = String.valueOf(mapLineDetails.get('ItemDescription'));
            itm.Commissionable = String.valueOf(mapLineDetails.get('Commissionable'));
            itm.DropShip = String.valueOf(mapLineDetails.get('DropShip'));
            itm.ExtensionAmt  = String.valueOf(mapLineDetails.get('ExtensionAmt'));
            itm.minusTax  = String.valueOf(mapLineDetails.get('minusTax'));
            itm.plusTax  = String.valueOf(mapLineDetails.get('plusTax'));
            itm.UOMConversion=string.ValueOf(mapLineDetails.get('UOMConversion'));
            if(LineOperation.toLowerCase() == 'edit') 
                LineItems[Integer.valueOf(LineIndex)]=itm;
            else if(LineOperation.toLowerCase() == 'add')
                LineItems.add(itm);                
        }

        LineTotal=0.00;
        minusTaxTotal =0.00;
        plusTaxTotal =0.00;

        if(LineItems.size() > 0)
        {
            for(LineItem itm : LineItems)
            {
                LineTotal += decimal.valueOf(itm.ExtensionAmt); 
              //  minusTaxTotal += decimal.valueOf(itm.minusTax);
               // plusTaxTotal += decimal.valueOf(itm.plusTax);
            }
        }


        //OrderTotal = LineTotal + SalesTaxAmt - Freight;

        JSONOrderItems = JSON.serialize(LineItems);
        system.debug('JSONOrderItems'+JSONOrderItems);

        if(LineItems.size() > 0)
            SalesTaxAmt = CalculateTax(IntegrationKey,ARDivisionNo,CustomerNo,TaxSchedule,DiscountPC);
        else
            SalesTaxAmt = 0.00;

        return null;
    }

    public Pagereference RecalculateTax()
    {
        String IntegrationKey = Apexpages.currentPage().getParameters().get('IntegrationKey');
        String UniqueKey = Apexpages.currentPage().getParameters().get('UniqueKey');
        String TaxSchedule = Apexpages.currentPage().getParameters().get('TaxSchedule');
        String DiscountPC = Apexpages.currentPage().getParameters().get('DiscountPC');
        try
        {
            String[] CustomerCode = UniqueKey.split('-'); 

            String ARDivisionNo = '';
            String CustomerNo = '';

            if(CustomerCode.size() > 0)
            {
                ARDivisionNo = CustomerCode[0];

                if(CustomerCode.size() > 1)
                    CustomerNo = CustomerCode[1];
            }

            SalesTaxAmt = CalculateTax(IntegrationKey,ARDivisionNo,CustomerNo,TaxSchedule,DiscountPC);
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'RecalculateTax',ex,true);
        } 
        return null;
    }

    private decimal CalculateTax(String IntegrationKey,String ARDivisionNo,String CustomerNo,String TaxSchedule,String DiscountPC)
    {
        decimal TaxAmt = 0.00;
        try
        {
            string MAXCOUNT='200';
            string STARTAT='';
            string TOTALCOUNT='0';
            string RETCOUNT='';
            string HASNEXT='';
            string HASPREV='';
            string CompanyCode='';

            if(DiscountPC == '' || DiscountPC == null)
                DiscountPC = '0';

            /************ Create Header part*************/
            ERP_Config__c oIntegration = [SELECT ERP_System__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c,Inactive__c FROM ERP_Config__c WHERE ID =: IntegrationKey];

            String EndPoint= oIntegration.Web_Service_URL__c;

            String ERPSystemName= oIntegration.ERP_System__c;

            if(ERPSystemName =='SageERPX3')
            {
                TaxAmt=0.00;                   
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'CalculateTax',ex,true);
        } 
        return TaxAmt;
    }

    public Pagereference UpdateOrderNumber()
    {
        try
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'UpdateOrderNumber')); 
            //String OrderId= Apexpages.currentPage().getParameters().get('OrderId');
            String ERPOrderNumber = Apexpages.currentPage().getParameters().get('OrderNumber');

            ERPOrder = new Order();
            ERPOrder.Id = OrderId;
            ERPOrder.ERP_Order_Number__c = ERPOrderNumber;

            //update ERPOrder;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'UpdateOrderNumber',ex,true);
        }

        return null;
    }
    public string UpdateERPOrderNumber(String OrderNo,String includedTax,String TotalAmount)
    {
        try
        {
            ERPOrder = new Order();
            ERPOrder = [ select Id , ERP_Order_Number__c,SalesTaxAmt__c,ERP_Order_Total__c  
            from Order where id=:OrderId];
            //ERPOrder.Id = OrderId;
            ERPOrder.ERP_Order_Number__c = OrderNo;
            ERPOrder.SalesTaxAmt__c = String.isBlank(includedTax)? 0.00: Double.valueOf(includedTax);
            ERPOrder.ERP_Order_Total__c = String.isBlank(TotalAmount)? 0.00: Double.valueOf(TotalAmount);
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'ERPOrder'+ERPOrder));
            update ERPOrder;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'UpdateOrderNumber',ex,true);
        }

        return OrderNo;
    }

    public Pagereference SaveERPOrder()
    {
        try
        {
            system.debug('OrderId '+OrderId);
            system.debug('JSONOrderDetails '+JSONOrderDetails);
            map<String,Object> mapOrderDetails = (map<string,object>)JSON.deserializeUntyped(JSONOrderDetails);
                                
            if(string.isNotBlank(OrderId))
            {
                ERPOrder.Id = OrderId;
               // apexPages.addmessage(new ApexPages.message(ApexPages.severity.Info,'ERPOrder.Id '+ERPOrder.Id));

                list<OrderItem> Items= [Select Id from OrderItem where OrderId =: OrderId];
                delete Items;
            }
            else
                ERPOrder = new Order();


            ERPOrder.AccountId = String.valueOf(mapOrderDetails.get('AccountId'));

            ERPOrder.BillingCity = String.valueOf(mapOrderDetails.get('BillToCity'));
            ERPOrder.BillingCountry = String.valueOf(mapOrderDetails.get('BillToCountryCode'));
            ERPOrder.BillingPostalCode = String.valueOf(mapOrderDetails.get('BillToZipCode'));
            ERPOrder.BillingState = String.valueOf(mapOrderDetails.get('BillToState'));
            ERPOrder.BillingStreet = String.valueOf(mapOrderDetails.get('BillToAddress1')) + String.valueOf(mapOrderDetails.get('BillToAddress2')) + String.valueOf(mapOrderDetails.get('BillToAddress3'));

            if(String.isNotBlank(String.valueOf(mapOrderDetails.get('CompanyAuthorizedById'))))
                ERPOrder.CompanyAuthorizedById = String.valueOf(mapOrderDetails.get('CompanyAuthorizedById'));

            if(String.isNotBlank(String.valueOf(mapOrderDetails.get('CustomerAuthorizedById'))))
                ERPOrder.CustomerAuthorizedById = String.valueOf(mapOrderDetails.get('CustomerAuthorizedById'));

            ERPOrder.Description = String.valueOf(mapOrderDetails.get('OrderDescription'));

            ERPOrder.ERP_Order_Number__c = OrderNumber;

            ERPOrder.Pricebook2Id = String.valueOf(mapOrderDetails.get('Pricebook2Id'));

            ERPOrder.ShippingCity = String.valueOf(mapOrderDetails.get('ShipToCity'));
            ERPOrder.ShippingCountry = String.valueOf(mapOrderDetails.get('ShipToCountryCode'));
            ERPOrder.ShippingPostalCode = String.valueOf(mapOrderDetails.get('ShipToZipCode'));
            ERPOrder.ShippingState = String.valueOf(mapOrderDetails.get('ShipToState'));
            ERPOrder.ShippingStreet = String.valueOf(mapOrderDetails.get('ShipToAddress1')) + String.valueOf(mapOrderDetails.get('ShipToAddress2')) + String.valueOf(mapOrderDetails.get('ShipToAddress3'));
            ERPOrder.Type= String.valueOf(mapOrderDetails.get('OrderType'));

            ERPOrder.Status='Draft';

            ERPOrder.EffectiveDate = date.parse(String.valueOf(mapOrderDetails.get('OrderDate')));
            ERPOrder.Document_Type__c= String.valueOf(mapOrderDetails.get('DocumentType'));

            ERPOrder.ERP_Order_Total__c = Double.valueOf(mapOrderDetails.get('LineTotal'));
            ERPOrder.CustomerNo__c = String.valueOf(mapOrderDetails.get('CustomerNo'));
            ERPOrder.AccountName__c = String.valueOf(mapOrderDetails.get('Account'));
            ERPOrder.PricebookName__c = String.valueOf(mapOrderDetails.get('PricebookName'));
            ERPOrder.Currency__c = String.valueOf(mapOrderDetails.get('Currency'));
            ERPOrder.ARDivisionNo__c = String.valueOf(mapOrderDetails.get('ARDivisionNo'));
            // ERPOrder.TotalAmount__c = Double.valueOf(mapOrderDetails.get('TotalAmount'));
            ERPOrder.LineTotal__c = Double.valueOf(mapOrderDetails.get('LineTotal'));
            ERPOrder.ShipToCode__c = String.valueOf(mapOrderDetails.get('ShipToCode'));
            ERPOrder.SalesSite__c = String.valueOf(mapOrderDetails.get('SalesSite'));
            ERPOrder.ShipmentSite__c = String.valueOf(mapOrderDetails.get('ShipmentSite'));

            //ERPOrder.SalesSiteId__c = String.valueOf(mapOrderDetails.get('SalesSiteId'));
            //ERPOrder.ShipmentSiteId__c = String.valueOf(mapOrderDetails.get('ShipmentSiteId'));
            ERPOrder.PrintSalesOrders__c = String.valueOf(mapOrderDetails.get('PrintSalesOrders'));
            ERPOrder.PrintPickingSheets__c = String.valueOf(mapOrderDetails.get('PrintPickingSheets'));
            ERPOrder.BatchFaxNo__c = String.valueOf(mapOrderDetails.get('BatchFaxNo'));
            ERPOrder.DiscountType__c = String.valueOf(mapOrderDetails.get('DiscountType'));
            ERPOrder.DiscountPC__c = Double.valueOf(mapOrderDetails.get('DiscountPC'));
            ERPOrder.DiscountAmt__c = Double.valueOf(mapOrderDetails.get('DiscountAmt'));
            ERPOrder.FreightAmt__c = Double.valueOf(mapOrderDetails.get('FreightAmt'));
            ERPOrder.DepositAmt__c = Double.valueOf(mapOrderDetails.get('DepositAmt'));
            
            if(String.isBlank(string.valueOf(mapOrderDetails.get('SalesTaxAmt'))))
                ERPOrder.SalesTaxAmt__c =  0.00;
            else
                ERPOrder.SalesTaxAmt__c =Double.valueOf(mapOrderDetails.get('SalesTaxAmt'));
            
            //ERPOrder.SalesTaxAmt__c = String.isBlank(mapOrderDetails.get('SalesTaxAmt'))? 0.00:Double.valueOf(mapOrderDetails.get('SalesTaxAmt'));
            ERPOrder.AmtSubTax__c = Double.valueOf(mapOrderDetails.get('AmtSubTax'));
            ERPOrder.AmtAddTax__c = Double.valueOf(mapOrderDetails.get('AmtAddTax'));
            ERPOrder.ContactName__c = String.valueOf(mapOrderDetails.get('ContactName'));
            ERPOrder.UserName__c = String.valueOf(mapOrderDetails.get('UserName'));
            ERPOrder.TaxGroup__c = String.valueOf(mapOrderDetails.get('TaxGroup'));
            ERPOrder.TermsCode__c = String.valueOf(mapOrderDetails.get('Termscode'));
            ERPOrder.ShipVia__c = String.valueOf(mapOrderDetails.get('Shipvia'));
            ERPOrder.AccountSet__c = String.valueOf(mapOrderDetails.get('Accountset'));
            ERPOrder.Integration_Key__c = String.valueOf(mapOrderDetails.get('IntegrationKey'));
           // ERPOrder.ERPIntegration__c = String.valueOf(mapOrderDetails.get('IntegrationName'));

            ERPOrder.ERP_Order_Info__c = JSONOrderDetails;   
            ERPOrder.ERP_Order_Details_Info__c = JSON.serialize(LineItems);

            upsert ERPOrder;

            OrderId = ERPOrder.Id;

            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Order Saved'));
            
            for(LineItem itm : LineItems )
            {
                OrderItem oItem =new OrderItem ();
                oItem.PricebookEntryId=itm.ProductId;

                oItem.OrderId=ERPOrder.Id;
                oItem.Description = itm.ItemDescription;
                oItem.UnitPrice= decimal.valueOf(itm.unitPrice);
                oItem.Quantity = decimal.valueOf(itm.QuantityOrdered);

                // new added custom field
                oItem.Discount__c = decimal.valueOf(itm.Discount);
                oItem.Comments__c= itm.Comments;
                oItem.Commissionable__c = itm.Commissionable;

                oItem.Drop_Ship__c = itm.DropShip;
                oItem.ExtensionAmt__c= decimal.valueOf(itm.ExtensionAmt);
                oItem.ItemType__c = itm.ItemType;
                oItem.ItemTypeCode__c = itm.ItemTypeCode;
                oItem.QOH__c= string.isNotBlank(itm.QOH) ? decimal.valueOf(itm.QOH) : 0.00; 
                //oItem.TaxClass__c = itm.TaxClass;
                oItem.UOM__c= itm.UOM;
                oItem.Price_List__c= itm.pricelist;
                oItem.Warehouse_Code__c = itm.WarehouseCode;
                oItem.UOM_Conversion_Factor__c = string.isBlank(itm.UOMConversion)? 1: decimal.valueOf(itm.UOMConversion);
                //oItem.Order_Detail_Info__c =JSON.serialize(itm);  
                insert oItem;
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'SaveERPOrder',ex,true);
        }
        return null;
    }

    public pagereference PromoteOrder()
    {   
        try
        {
          //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'OrderHeaderDetails:'+OrderHeaderDetails));
                
            map<String,object> OrderHeaderFields  =(map<string,object>)JSON.deserializeUntyped(OrderHeaderDetails);
                    
            string publicName='';
            string UniqueKey=''; 
            string oderDate;

            string[] splitorderDate=string.valueOf(OrderHeaderFields.get('OrderDate')).split('/');

            // string oderDate = splitorderDate[2]+'-'+splitorderDate[0]+'-'+splitorderDate[1];
            // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'oderDate:'+splitorderDate[0]));
            if(splitorderDate[0].length()==1 && splitorderDate[1].length()==1)
                oderDate = splitorderDate[2]+'-'+'0'+splitorderDate[0]+'-'+'0'+splitorderDate[1];
            else
                oderDate = splitorderDate[2]+'-'+splitorderDate[0]+'-'+splitorderDate[1];
            
            string discountType =(string) OrderHeaderFields.get('DiscountType');
            string calcByAmount='';
            string calcByPerc='';
            string aCPayload = '';

            aCPayload +='<oeorders>';
            //  aCPayload +='<ORDNUMBER></ORDNUMBER>';

            //aCPayload +='<ORDDATE>'+OrderHeaderFields.get('OrderDate')+'</ORDDATE>';
            //date orderDate = (date) OrderHeaderFields.get('OrderDate');
            //string OrderYear = String.valueOf(orderDate.year());// orderDate.getYear();
            //string OrderMonth = String.valueOf(orderDate.month());
            //string OrderDay = String.valueOf(orderDate.day());
            aCPayload +='<ORDDATE>'+oderDate+ '</ORDDATE>';
            aCPayload +='<CUSTOMER>'+OrderHeaderFields.get('CustomerNo')+'</CUSTOMER>';
            //  aCPayload +='<BILNAME>'+ +'</BILNAME>';
            aCPayload +='<SHPNAME>'+OrderHeaderFields.get('ShipToName')+'</SHPNAME>';
           
            //aCPayload +='<TYPE>'+5+'</TYPE>';
            //aCPayload +='<REFERENCE>'+ OrderHeaderFields.get('OrderRefNo')==null ? '' :OrderHeaderFields.get('OrderRefNo') + '</REFERENCE>';
           
            if(OrderHeaderFields.get('Termscode') !='' &&  OrderHeaderFields.get('TaxGroup') !='' && OrderHeaderFields.get('Accountset') !='')
            {
                aCPayload +='<TERMS>'+OrderHeaderFields.get('Termscode')+'</TERMS>';
                aCPayload +='<TAXGROUP>'+ OrderHeaderFields.get('TaxGroup') +'</TAXGROUP>';
                aCPayload +='<CUSACCTSET>'+OrderHeaderFields.get('Accountset')+'</CUSACCTSET>';
            }
            
            aCPayload +='<SHIPVIA>'+OrderHeaderFields.get('Shipvia')+'</SHIPVIA>';
            aCPayload +='<INVDISCPER>'+OrderHeaderFields.get('DiscountPC')+'</INVDISCPER>';
            // aCPayload +='<CUSTGROUP>'+ +'</CUSTGROUP>';
            //  aCPayload +='<UNFMTITEM>'+ItemTypeCode +'</UNFMTITEM>';
            integer i=1;
            list<LineItem> objLineItems = (list<LineItem>) json.deserialize(JSONOrderDetails, List<LineItem>.class);

            aCPayload +='<oeorderdetails>';
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'objLineItems: '+objLineItems));
            for(LineItem itm : objLineItems)
            {
                aCPayload +='<oeorderdetail>';
                //aCPayload +='<LINETYPE>'+i+'</LINETYPE>';
                aCPayload +='<ITEM>'+itm.ItemCode+'</ITEM>' ;
                aCPayload +='<DESC>'+itm.ItemDescription+'</DESC>';
                aCPayload +='<QTYORDERED>'+itm.QuantityOrdered+'</QTYORDERED>';
                aCPayload +='<QTYBACKORD>'+itm.QuantityOrdered+'</QTYBACKORD>';
                aCPayload +='<DISCPER>'+itm.Discount+'</DISCPER>';
                // aCPayload +='<INVDISC>'+itm.Discount+'</INVDISC>';
                // aCPayload +='<QTYORDERED>'+Quantity +'</QTYORDERED>' ;
                aCPayload +='<ORDUNIT>'+itm.UOM+'</ORDUNIT>';
                aCPayload +='<PRICEUNIT>'+itm.UOM+'</PRICEUNIT>';                
                aCPayload +='<LOCATION>'+itm.WarehouseCode+'</LOCATION>';
                aCPayload +='<PRICELIST>'+itm.pricelist+'</PRICELIST>';
                aCPayload +='<PRIUNTPRC>'+itm.UnitPrice+'</PRIUNTPRC>';
               // aCPayload +='<EXTINVMISC>'+itm.ExtensionAmt+'</EXTINVMISC>';
                //aCPayload +='<CATEGORY>'+itm.ItemCode+'</CATEGORY>' ;
                i++;
                aCPayload +='</oeorderdetail>';
            }

            aCPayload +='</oeorderdetails>';
            aCPayload +='</oeorders>';

            string aPayload ='';
            aPayload +='<entry>';
            aPayload +='<sdata:payload>';
            aPayload +=aCPayload;
            aPayload +='</sdata:payload>';
            aPayload +='</entry>';
            
            
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'aPayload:'+aPayload));
            //return null;
            baseIntegrationFramework integrationFramework= new Sage300IntegrationFramework();//IntegrationFactory.getIntegrationFramework();
            map<string,list<object>> AttribParams=new  map<string,list<object>>();
            string SourceEntity='';
            map<String,String> mapData =new map<String,String>();

            list<object>  AttribParam= new list<object>();

            AttribParam= new list<object>();
            AttribParam.add(IntegrationKey);
            AttribParams.put('IntegrationId',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add(aPayload);
            AttribParams.put('RequestXML',AttribParam);

            AttribParam= new list<object>();
            Helper.MappingPurpose mappingType =Helper.MappingPurpose.POST;
            AttribParam.add(mappingType);
            AttribParams.put('MappingPurpose',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('Order');
            AttribParams.put('SourceEntity',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('oeorders');
            AttribParams.put('ERPFuncName',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('0');
            AttribParams.put('startIndex',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('0');
            AttribParams.put('count',AttribParam);

            AttribParam= new list<object>();
            AttribParam.add('PostOrder');
            AttribParams.put('PostDataXml',AttribParam);



            map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
            Helper.GUMU_Response resGUMU_Response =new  Helper.GUMU_Response();

            if(Test.isRunningTest())
            {
                string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                resGUMU_Response.responseERPData=TestResponseData;
                resGUMU_Response.statusMessage='Ok';
                resGUMU_Response.statusCode =string.valueof(200);

            }
            else
            {
                resGUMU_Response =integrationFramework.PostData(IntegrationKey,SourceEntity,AttribParams,mapData,AttribParams);
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'resGUMU_Response:'+resGUMU_Response));
                

            }   

            if(resGUMU_Response.statusCode =='100')
            {   
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));          
                return null;
            }


            list<map<string,string>> mapProData = resGUMU_Response.ERPDataMap;

            
            //string Messages ='<sdata:message>Invalid input. Item F2-101/L is not sellable.</sdata:message>';
            //string Message1= Messages.substring(15,59);
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'resGUMU_Response.SFDataMap:'+resGUMU_Response.ERPDataMap ));

            if(Test.isRunningTest())
                OrderNumber = ApexPages.currentPage().getParameters().get('Id' );
            else
            { 

                if( resGUMU_Response.statusCode == '500' || resGUMU_Response.statusCode == '400')
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error while promoting order to ERP'));
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error:Status Code:'+resGUMU_Response.statusCode  ));
                    ErrorMessage = Utility.parse(resGUMU_Response.responseERPData,'message');
                }

                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'resGUMU_Response.statusCode'+resGUMU_Response.statusCode ));
                if(resGUMU_Response.statusCode =='200' || resGUMU_Response.statusCode =='201' || resGUMU_Response.statusCode =='202')
                { 
                    if(mapProData.size() > 0)
                    {

                        if (mapProData[0].get('ORDNUMBER') !=null )
                        {
                            OrderNumber = mapProData[0].get('ORDNUMBER');
                            string includedTax = mapProData[0].get('INVTAXTOT');
                            string TotalAmount = mapProData[0].get('INVNETWTX');
                           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Order created:'+OrderNumber ));
                            // ErrorMessage = Utility.parse(resGUMU_Response.responseERPData,'message');
                            UpdateERPOrderNumber(OrderNumber,includedTax,TotalAmount);
                        }
                        else
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Order created but order number not found..'));
                    }
                    else
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'mapProData size zero..'));
                }

            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'PostRecords',ex,true);
        }

        return null;
        // CustomException exc= new CustomException (className,'PostRecords',ex,false);
        //throw ex;}  

    }

    //function created to get order number from X3. created on 17/02/15
    /*public static string getOrderNumber_X3(string getResponse)
        {


                ReadAndWriteXML.XmlNode objXmlNode ;        
                string orderNo;
                Dom.Document doc;
                doc = new Dom.Document();
                doc.load(getResponse);                          
                Dom.XMLNode Envelope1 = doc.getRootElement();       
                Dom.XMLNode Body1= Envelope1.getChildElements()[0];       

                String strResponse ;
                string sReturn = '0';
                try
                {
                        for(Dom.XMLNode child1 : Body1.getChildElements()) 
                        {
                                for(Dom.XMLNode subchild1 : child1.getChildElements()) 
                                {
                                        if(subchild1.getName() == 'resultXml')
                                        {
                                                strResponse = string.valueof(subchild1.getText());
                                                break;
                                        }   
                                }
                        }
                        objXmlNode = new ReadAndWriteXML.XmlNode();
                        objXmlNode = ReadAndWriteXML.ParseXmlString(strResponse);
                        list<ReadAndWriteXML.XmlNode> lstOrderRs = objXmlNode.ChildXmlNodes;
                        for(ReadAndWriteXML.XmlNode orderGrp :lstOrderRs)
                        {
                                list<ReadAndWriteXML.XmlNode> ordFlaLSt = orderGrp.ChildXmlNodes;
                                for(ReadAndWriteXML.XmlNode orderFLd :ordFlaLSt)
                                {
                                        if(orderFLd.Attributes.get('NAME') =='SOHNUM' || orderFLd.Attributes.get('NAME') =='SQHNUM')
                                        {
                                                orderNo =orderFLd.NodeValue;
                                                break;
                                        }
                                }
                                if(orderNo !='')
                                        break;
                        }
                }
                catch(Exception ex)
                {
                        CustomException exc= new CustomException(ClassName,'getOrderNumber',ex,true);
                } 
                return orderNo;
        }*/

    public Pagereference AddMultiLineItem()
    {
        
        String IntegrationKey = Apexpages.currentPage().getParameters().get('IntegrationKey');
        String UniqueKey = Apexpages.currentPage().getParameters().get('UniqueKey');
        String TaxSchedule = Apexpages.currentPage().getParameters().get('TaxSchedule');
        String DiscountPC = Apexpages.currentPage().getParameters().get('DiscountPC');

        try
        {
            String[] CustomerCode = UniqueKey.split('-'); 

            String ARDivisionNo = '';
            String CustomerNo = '';

            if(CustomerCode.size() > 0)
            {
                ARDivisionNo = CustomerCode[0];

                if(CustomerCode.size() > 1)
                    CustomerNo = CustomerCode[1];
            }

            // String ARDivisionNo = CustomerCode[0];
            // String CustomerNo = CustomerCode[1];

            
            list<LineItem> objLineItems = (list<LineItem>) json.deserialize(JSONLineItems, List<LineItem>.class);
           // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'JSONLineItems:'+JSONLineItems ));
            LineItems.addAll(objLineItems);

            LineTotal=0.00;
            minusTaxTotal =0.00;
            plusTaxTotal =0.00;

            if(LineItems.size() > 0)
            {
                for(LineItem itm : LineItems)
                {
                    LineTotal += decimal.valueOf(itm.ExtensionAmt);
                }
            }
            JSONOrderItems = JSON.serialize(LineItems);

            if(LineItems.size() > 0)
                SalesTaxAmt = CalculateTax(IntegrationKey,ARDivisionNo,CustomerNo,TaxSchedule,DiscountPC);
            else
                SalesTaxAmt = 0.00;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'AddMultiLineItem',ex,true);
        } 
        return null;
    }


    Public PageReference RedirectPage()
    {
        TextDisabled=false;
        OrderId = Apexpages.currentPage().getParameters().get('id');
        PageIntegrationKey = Apexpages.currentPage().getParameters().get('PageIntegrationKey');

        PageReference pgref = new PageReference('/apex/SalesOrder300?id=' + OrderId+'&Mode=Edit'+'&PageIntegrationKey='+PageIntegrationKey   );

        pgref.setRedirect(true);           
        return pgref;        


    }

    /*@RemoteAction 
        public static boolean validateSite(String IntegrationKey,String siteCode,String productCode)
        {
                boolean isExists=false;
                ReadAndWriteXML.XmlNode objXmlNode ;
                Utility.ProgramList sbr = new Utility.ProgramList();
                string publicName=sbr.YGTITMSITE; 
                String whereClause='<TAB ID="AX_WHR"><LIN NUM="1"><FLD NAME="AXWHRLFTBRK">0</FLD> <FLD NAME="AXWHRCOD">ITMREF</FLD> <FLD NAME="AXWHROPE" >2</FLD> <FLD NAME="AXWHRCODVAL" >'+productCode+'</FLD> <FLD NAME="AXWHRRGTBRK" >0</FLD> <FLD NAME="AXWHRANDOR" >2</FLD> </LIN> <LIN NUM="2" > <FLD NAME="AXWHRLFTBRK" >0</FLD> <FLD NAME="AXWHRCOD" >STOFCY</FLD> <FLD NAME="AXWHROPE" >2</FLD> <FLD NAME="AXWHRCODVAL" >'+siteCode+'</FLD> <FLD NAME="AXWHRRGTBRK" >0</FLD> <FLD NAME="AXWHRANDOR" >1</FLD> </LIN> </TAB>';

                string strResponse = Utility.requestXML('Run',IntegrationKey,publicName,whereClause,'','','10','1');
                objXmlNode = ReadAndWriteXML.ParseXmlString(strResponse);
                list<ReadAndWriteXML.XmlNode> itmSiteLst = objXmlNode.ChildXmlNodes;
                for(ReadAndWriteXML.XmlNode itmSite:itmSiteLst )
                {
                        string strAttrID  =itmSite.Attributes.get('ID');
                        if(strAttrID == 'RES')
                        {
                                isExists = true;
                                break;
                        }                       
                }
                return isExists;
        }*/

    /******************************/
    /********Wrapper Classes*******/
    /******************************/
    public class LineItem
    {
        public String ItemType {get;set;}
        public String ItemCode {get;set;}
        public String ItemTypeCode {get;set;}
        public String ProductId {get;set;}
        public String WarehouseCode {get;set;}
        public String UOM {get;set;}
        public String TaxClass {get;set;}
        public String ListPrice {get;set;}
        public String UnitPrice {get;set;}
        public String Discount {get;set;}
        public String QOH {get;set;}
        public String QuantityOrdered {get;set;}
        public String Comments {get;set;}
        public String ItemDescription {get;set;}
        public String ExtensionAmt {get;set;}
        public String Commissionable {get;set;}
        public String DropShip {get;set;}
        public String minusTax {get;set;}
        public String plusTax {get;set;}
        public string pricelist {get;set;}
        public string UOMConversion {get;set;}
    }

    public class ERPOrder
    {
        public string CustomerNo {get;set;}
        public list<LineItem> OrderLineItems {get;set;}
    }  

    /*Record Wrapper*/
    public class ResultSet 
    {
        public String Id {get;set;}
        public String Name {get;set;}
        public String ProductCode {get;set;}
        public String ProductFamily {get;set;}
        public String UnitPrice {get;set;}

        public ResultSet(sObject s) 
        {
            this.Id = s.Id;
            this.Name = s.get('Name') + '';
            this.ProductCode = s.get('ProductCode') + '';
            this.UnitPrice = s.get('UnitPrice') + '';
            this.ProductFamily = s.get('Category__c') + '';  //ERP_PrdFamily_Code__c
        }

        public ResultSet(String Id, String Name, String ProductCode, String UnitPrice,String ProductFamily) 
        {
            this.Id = Id;
            this.Name = Name;
            this.ProductCode = ProductCode;
            this.UnitPrice = UnitPrice;
            this.ProductFamily = ProductFamily;
        }
    }

    /*ProductFamilySet Wrapper*/
    public class ProductFamilySet 
    {
        public String Id {get;set;}
        public String Name {get;set;}
        public String FamilyCode {get;set;}
        public String FamilyDesc {get;set;}

        public ProductFamilySet(sObject s) 
        {
            this.Id = s.Id;
            this.Name = s.get('Name') + '';
            this.FamilyCode = s.get('ERP_Product_Family_Code__c') + ''; //ERP_PrdFamily_Code__c
            this.FamilyDesc = s.get('ERP_Product_Family_Code__c') + '';            
        }

        public ProductFamilySet(String Id, String Name, String FamilyCode, String FamilyDesc) 
        {
            this.Id = Id;
            this.Name = Name;
            this.FamilyCode = FamilyCode;
            this.FamilyDesc = FamilyDesc;            
        }
    }

    /*
     * Get Already Linked Products for Listing
     */
    public PageReference GetERPName() 
    {
        // Check if the user has read access on the ERP_Config__c fields
        if (!Schema.sObjectType.Account.fields.Integration_Key__c.isAccessible()
                || !Schema.sObjectType.Account.fields.ID.isAccessible()){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                    'Insufficient access to Account Fields'));
            return null;
        }

        // Check if the user has read access on the ERP_Config__c fields
        if (!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible() 
                || !Schema.sObjectType.ERP_Config__c.fields.ERP_Company_Code__c.isAccessible()
                || !Schema.sObjectType.ERP_Config__c.fields.ID.isAccessible()){

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,
                    'Insufficient access to ERP_Configuration__c Fields'));
            return null;
        }

        system.debug('AccountId'+AccountId);
        list<Account> oAct= new list<Account>();
        if(AccountId !='')
            oAct = [SELECT Id, Integration_Key__c FROM Account WHERE ID =: AccountId];

        list<ERP_Config__c> oIntegration = new list<ERP_Config__c>();
        if(oAct.Size() > 0)
        {
            system.debug('oAct '+oAct[0].Integration_Key__c);
            oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Synchronization__c FROM ERP_Config__c WHERE ID =: oAct[0].Integration_Key__c ];

            if(oIntegration.size() > 0)
            {
                ERPSystemName = oIntegration[0].ERP_System__c;
                Synchronization = oIntegration[0].Synchronization__c;
                system.debug('Synchronization'+Synchronization);
                ERPCompanyCode = oIntegration[0].ERP_Company_Code__c;
            }
        }
        return null;
    }

    //create wrapper class for credit cards 
    public class CustomerCreditCards
    {
        public string CreditCardNo{get;set;}
        public string PaymentType{get;set;}
        public string ExpirationDateYear{get;set;}
        public string ExpirationDateMonth{get;set;}
        public string Last4UnencryptedCreditCardNos{get;set;}
        public string CorporateCustIDPurchOrder{get;set;}

    }

}
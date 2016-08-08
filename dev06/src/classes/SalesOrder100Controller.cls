global with  sharing class SalesOrder100Controller 
{       
        public String DocumentType {get;set;}
        public String ErrorMessage {get;set;}
        public String OrderHeaderDetails {get;set;}
        public String  OrderDetailFields {get;set;}
        public Boolean bShowSalesOrder { get; set; }
        public String IntegrationKey {get;set;}
        Public string PageIntegrationKey {get;set;}
        public string Namespace{get;set;}
 
 
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
        Public String Mode{get; set;}
        // X3 Variables
        public String SalesSiteObjectPrefix {get;set;}
        public String ShipSiteObjectPrefix {get;set;}
        public boolean isNew {get;set;}
        public static list<CustomerCreditCards> CreditCardDetails{get;set;}
        public Order ERPOrder {get;set;}
        public static String OrderNumber {get;set;}
        public String salesTax {get;set;}
        public String OrderDate {get;set;}
        public String JSONLineItems {get;set;}
        public String JSONOrderDetails {get;set;}
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
        public String ERPSystemName {get;set;}
        public String ERPCompanyCode {get;set;}
        public String AccountId {get;set;}
        public String gbERPSystemName {get;set;}
        public static String ERPVersion {get;set;}
        public String ProfileName {get;set;}
        public String Synchronization{get;set;}  
        public boolean TextDisabled {get;set;}
        public String Disabled {get;set;} 
        public String Description{get;set;}
 
 
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
        public String AR_DivisonNo{get;set;}
        public decimal Sales_TaxAmt{get;set;}
        public string Conversion_Factor{get;set;}
 
 
        //Properties for order
        public SalesOrder100Controller(ApexPages.StandardController controller) 
        {
                if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
                {
                        // Check if the user has read access on the Profile.name
                        if (Schema.sObjectType.Profile.fields.name.isAccessible()) 
                        {
                                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
                        }
                }
 
 
                Security_Matrix__c SM = Security_Matrix__c.getInstance();
                bShowSalesOrder = Boolean.valueOf(SM.Promote_Order__c);
                TextDisabled=false;
                Mode= Apexpages.currentPage().getParameters().get('Mode');
                NameSpace = Utility.FetchNameSpace();
 
 
                OrderId = Apexpages.currentPage().getParameters().get('Id');
 
 
                // Set Current Record
                list<Order> Orders = [Select 
                                      BillingStreet, BillingState, BillingPostalCode, BillingLongitude, BillingLatitude, BillingCountry, BillingCity,
                                      ShippingStreet, ShippingState, ShippingPostalCode, ShippingLongitude, ShippingLatitude, ShippingCountry, ShippingCity, 
                                      Pricebook2Id, OrderNumber, Type, TotalAmount,OrderReferenceNumber,Document_Type__c, Payment_Type__c,Sales_Person__c,Ship_Expire_Date__c,
                                      FOB__c,Print_Order__c,Print_Picking_Sheets__c,Batch_Fax_No__c,
                                      SystemModstamp, StatusCode, Status, LastViewedDate, LastReferencedDate, LastModifiedDate, LastModifiedById, 
                                      IsDeleted, Id, EndDate, EffectiveDate, Description, ShipVia__c,Warehouse__c,Tax_Schedule__c,TermsCode__c,
                                      CustomerAuthorizedById, CreatedDate, CreatedById, ContractId, CompanyAuthorizedById,  ActivatedDate, ActivatedById, AccountId,
                                      ERP_Company_Code__c, ERP_Order_Details_Info__c, ERP_Order_Info__c, ERP_Order_Number__c, Integration_Key__c, ERP_Order_Total__c ,
                                      account.BillingStreet, account.BillingCity, account.BillingState,account.BillingPostalCode,account.BillingCountry,SalesTaxAmt__c,
                                      account.ShippingStreet, account.ShippingCity, account.ShippingState,account.ShippingPostalCode,account.ShippingCountry,account.AR_DivisonNo__c
                                      ,account.Name,FreightAmt__c
                                      From Order
                                      Where Id =:OrderId];// controller.getRecord().Id];
 
 
 
 
                //system.debug('Document '+Orders[0].Document_Type__c);
                if(Orders.size() > 0)
                {
                        ERPOrder = Orders[0];
                        OrderId = ERPOrder.id;
 
 
                        if(string.IsBlank(ERPOrder.ERP_Order_Number__c) && Mode=='Edit')
                        {
                                TextDisabled=false;
                                Disabled = '';
                        }
                        else
                        {
                                TextDisabled=true;
                                Disabled = ' Disabled = Disabled'; 
                        }
                        if(ERPOrder.Description=='' || ERPOrder.Description== null)
                                Description = ERPOrder.Description;
                        else
                                Description = '';           
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
                        if(ERPOrder.account.AR_DivisonNo__c=='' || ERPOrder.account.AR_DivisonNo__c== null)
                                AR_DivisonNo=ERPOrder.account.AR_DivisonNo__c;
 
 
                }
 
 
                CurrentItem = new LineItem();
                LineItems = new list<LineItem>();
                OrderNumber = '';
                salesTax='';
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
                        ERP_Config__c config = [SELECT Id,Name,ERP_System__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c
                                                FROM ERP_Config__c Where Id =: ERPOrder.Integration_Key__c limit 1];
 
 
                        orderIntegrationKey = config.Id;
                        orderIntegrationName = config.Name;
                        ERPSystemName = config.ERP_System__c;
                        IntegrationKey =orderIntegrationKey ;
                        Map<String,String> ParamMap = Utility.FormatERPInfo(config.Integration_Information__c,config.Integration_Information_2__c,config.Integration_Information_3__c);
                        if(String.isNotBlank(ERPOrder.Pricebook2Id))
                                orderPricebookId = ERPOrder.Pricebook2Id;
 
 
                        if(String.isNotBlank(ERPOrder.ERP_Order_Number__c))
                                OrderNumber = ERPOrder.ERP_Order_Number__c;
 
 
                        if(String.isNotBlank(ERPOrder.ERP_Order_Info__c))
                                JSONOrderDetails = ERPOrder.ERP_Order_Info__c;
                                
                                                  
                       // if(String.isNotBlank(ERPOrder.SalesTaxAmt__c))
                              // salesTax=String.valueOf(ERPOrder.SalesTaxAmt__c);
                                
                                
 
 
                        LineItems=getOrderProduct(OrderId);
                        if(LineItems.size() > 0)
                        {
                                for(LineItem Lt : LineItems)
                                {
                                        LineTotal +=Lt.ExtensionAmt==null?0:  decimal.valueOf(Lt.ExtensionAmt);
                                        minusTaxTotal += Lt.minusTax==null?0: decimal.valueOf(Lt.minusTax);
                                        plusTaxTotal += Lt.plusTax==null?0:  decimal.valueOf(Lt.plusTax);
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
                                                                  FROM ERP_Config__c Where ERP_System__c ='Sage100ERP' ];
 
 
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
                ConfigObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Config__c');
                WarehouseObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Warehouse__c');
                TermsObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Terms_Code__c');
                ShipObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Ship_Via__c');
                TaxObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Tax_Schedule__c');
                TaxClassObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Tax_Class__c');
                TaxRuleObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Tax_Rule__c');
                SalesObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Salesperson__c');
                ShipToObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Ship_To__c');
                PaymentObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Payment_Type__c');
                ProductObjectPrefix = Utility.getSobjectKeyPrefix('Product2');
                ProductFamilyObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Product_Family__c');
                UOMObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'UOM__c'); 
                PBEntryOjectPrefix = Utility.getSobjectKeyPrefix('PricebookEntry');
                CurrencyObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'Currency__c');
                SalesSiteObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Site__c'); 
                ShipSiteObjectPrefix = Utility.getSobjectKeyPrefix(NameSpace+'ERP_Site__c'); 
        }
 
 
        public static list<LineItem> getOrderProduct(string OrderID)
        {
                list<LineItem> LineItems = new list<LineItem>();
                LineItem lineItm ;
                list<OrderItem> OrderItems = [Select UnitPrice, Quantity, PricebookEntryId,PricebookEntry.ProductCode, OrderItemNumber, OrderId, 
                                              ListPrice, Id,PricebookEntry.Product2id, Warehouse_Code__c, UOM__c, TaxClass__c, QOH__c, PlusTax__c, MinusTax__c, ItemType__c, ItemTypeCode__c, 
                                              ExtensionAmt__c, Drop_Ship__c, Discount__c, Commissionable__c, Comments__c, Description,UOM_Conversion_Factor__c
                                              From OrderItem where OrderId =:OrderID];
                string itemType='';
                if(OrderItems.size()>0)
                {
                        for(OrderItem OrderItm :OrderItems )
                        {
                                /*if(string.isBlank(OrderItm.ItemType__c))
                                {
                                    
                                }*/
                                
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
                                lineItm.ListPrice=String.valueOf(OrderItm.ListPrice);
                                lineItm.minusTax=String.valueOf(OrderItm.MinusTax__c);
                                lineItm.plusTax=String.valueOf(OrderItm.PlusTax__c);
                                lineItm.ProductId=OrderItm.PricebookEntryId;
                                lineItm.QOH=String.valueOf(OrderItm.QOH__c);
                                //lineItm.QuantityOrdered=String.valueOf(OrderItm.Quantity);
                                lineItm.QuantityOrdered=String.valueOf(OrderItm.Quantity).replace('.00','');
                                lineItm.TaxClass=OrderItm.TaxClass__c;
                                lineItm.UnitPrice=String.valueOf(OrderItm.UnitPrice);
                                lineItm.UOM=OrderItm.UOM__c;
                                lineItm.WarehouseCode=OrderItm.Warehouse_Code__c;
                                lineItm.Conversion=string.ValueOf(OrderItm.UOM_Conversion_Factor__c);
                                LineItems.add(lineItm);
                        }
 
 
                }
                return LineItems;
        }
        @RemoteAction    
        public static map<String,String> LoadAccountData(string AccountId)
        {
                map<String,String> DetailsMap = new map<String,String>();
 
 				system.debug('AccountId ****  '+AccountId);
 					
                Account OrderAccount= [Select 
                                       Website, Type, Phone, Name, Id, AR_DivisonNo__c,Integration_Key__c, ERP_Customer__c,Currency__c, ERP_Customer_Number__c, ERP_Company_Code__c, Fax, Description, 
                                       ShippingStreet, ShippingState, ShippingPostalCode, ShippingLongitude, ShippingLatitude, ShippingCountry, ShippingCity,AccountNumber, 
                                       BillingStreet, BillingState, BillingPostalCode, BillingLongitude,BillingLatitude, BillingCountry, BillingCity    
                                       From Account 
                                       Where Id= : AccountId limit 1];
                                       
                system.debug('OrderAccount.Integration_Key__c '+OrderAccount.Integration_Key__c);
                                       
                list<ERP_Config__c> config = [SELECT Id,Name,ERP_System__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c 
                                        FROM ERP_Config__c Where Id =: OrderAccount.Integration_Key__c limit 1];
                if(config.size() == 0)
                {
                	DetailsMap.put('Error','Related integration has been deleted of this account. please check the Integration.');
                	return DetailsMap;
                } 
 
 
 
 
                Map<String,String> ParamMap = Utility.FormatERPInfo(config[0].Integration_Information__c,config[0].Integration_Information_2__c,config[0].Integration_Information_3__c);
                string ERPSystemName=config[0].ERP_System__c;
 
 
                DetailsMap.put('erpSystem',ERPSystemName);
                DetailsMap.put('Integration',config[0].Name);
                DetailsMap.put('IntegrationId',config[0].Id);
                DetailsMap.put('UniqueKey',OrderAccount.ERP_Customer_Number__c);
 
 
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
                DetailsMap.put('ARDivisionNo',OrderAccount.AR_DivisonNo__c);  
                String ShipCode='';
                String ShippingStreet='';
                String ShippingState='';
                String ShippingPostalCode='';
                String ShippingCountry='';
                String ShippingCity='';
                String Warehouse='';
 
 
                if(ERPSystemName =='Sage100ERP')
                {
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
                }
                string sSalesperson = GetSalesperson(OrderAccount.Integration_Key__c);
                system.debug('sSalesperson '+sSalesperson);
                DetailsMap.put('Salesperson',sSalesperson);
                DetailsMap.put('ShipCode',ShipCode);
                DetailsMap.put('ShippingStreet',ShippingStreet);
                DetailsMap.put('ShippingState',ShippingState);
                DetailsMap.put('ShippingPostalCode',ShippingPostalCode);
                DetailsMap.put('ShippingCountry',ShippingCountry);
                DetailsMap.put('ShippingCity',ShippingCity);
                DetailsMap.put('Warehouse',Warehouse);
                system.debug('DetailsMap '+DetailsMap);
                
                list<map<string,string>> DefaultValuesList= LoadDefaultValues(OrderAccount.ERP_Customer_Number__c,OrderAccount.AR_DivisonNo__c,config[0].Id);
                
                if(DefaultValuesList.size()>0)
                {
                    for(map<string,string> DefaultValues:DefaultValuesList)
                    {
                        for(string key:DefaultValues.keySet())
                        {
                            if(key == 'TermsCode')
                                DetailsMap.put('TermsCode',DefaultValues.get('TermsCode'));
                            else if(key == 'TaxSchedule')
                                DetailsMap.put('TaxSchedule',DefaultValues.get('TaxSchedule'));
                            else if(key == 'ShipMethod')
                                DetailsMap.put('ShipMethod',DefaultValues.get('ShipMethod'));
                            else if(key == 'SalespersonNo')
                                DetailsMap.put('SalespersonNo',DefaultValues.get('SalespersonNo'));
                        }
                    }
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
                                                       
                system.debug('mappings '+json.serialize(mappings));   
                //system.debug('UserId '+mappings.User_Id__c);                                    
                if(mappings.size() > 0)
                {
                        // Check if the user has read access on the Salesperson_Mapping__c fields
                        if (!Schema.sObjectType.Salesperson__c.fields.Salesperson_Code__c.isAccessible()
                                        || !Schema.sObjectType.Salesperson__c.fields.Integration_Key__c.isAccessible()
                                        || !Schema.sObjectType.Salesperson__c.fields.AR_Division_Code__c.isAccessible()
                                        || !Schema.sObjectType.Salesperson__c.fields.Id.isAccessible()){
                                return null;
                        }
                        
                        
                      // Account OrderAccount= [Select Id, AR_DivisonNo__c From Account  Where Id= : AccountId limit 1];
                        
                        list<Salesperson__c> oSPs=[Select Id,Integration_Key__c,Salesperson_Code__c,AR_Division_Code__c
                                                   From Salesperson__c Where Id= :mappings[0].Salesperson_Id__c  Limit 1];
                       // system.debug('oSPs '+oSPs);
                        
                        if(oSPs.size() > 0 )
                                Salesperson = oSPs[0].Salesperson_Code__c;
                }
                return Salesperson;
        }
 
 
        public static list<map<string,string>> LoadDefaultValues(string CustomerNo,string ARDivision,string IntegrationId)
        {
            list<map<string,string>> DefaultValues = new list<map<string,string>>();
            string PublicationName = 'AR_Customer';
            list<object>  AttribParam= new list<object>();
            
            baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
                               
            AttribParams=Utility.getAttribParameters('1', '1' , IntegrationId, 'Customer', '' , Helper.MappingPurpose.DISPLAY);
                                   
            AttribParam.add(PublicationName);
            AttribParams.put('ERPFuncName',AttribParam);  
            
            map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();             
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();
            listParams.add(CustomerNo);
            parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
            fieldParameters.put('CustomerNo',parameter);
            
            parameter = new map<string,list<string>>(); 
            listParams=new list<string> ();
            listParams.add(ARDivision);
            parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
            
            fieldParameters.put('ARDivisionNo',parameter); 
            
            Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
            
            resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
            
            if(resGUMU_Response.statusCode =='100')             
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));
            else if(resGUMU_Response.statusCode =='0') 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resGUMU_Response.statusMessage));                               
            else if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Service Temporarily Unavailable.please check the Services.'));
            else
                DefaultValues= resGUMU_Response.ERPDataMap;

            return DefaultValues;
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
                //sObject List
                searchedRecord = new list<ResultSet>();
                //SOSL Text should be more then one charecter
                if(searchText.length() >0)
                {
                        String Test = '%' + String.escapeSingleQuotes(searchText) + '%';
                        List<SObject> searchList = new List<SObject>();
 
 
                        if(String.isNotBlank(Family))
                        {
                                searchList = [SELECT Id,Name,ProductCode,ERP_PrdFamily_Code__c,ERP_PrdFamily_Desc__c,UnitPrice 
                                              FROM PricebookEntry 
                                              WHERE Pricebook2Id =: PriceBookId
                                              AND ProductCode LIKE : String.escapeSingleQuotes(Test) 
                                              AND ERP_PrdFamily_Code__c =: Family LIMIT 200];
                        }
                        else
                        {
                                if(DocType.toLowerCase() == 'Invoice')
                                {
                                        searchList = [SELECT Id,Name,ProductCode,ERP_PrdFamily_Code__c,ERP_PrdFamily_Desc__c,UnitPrice 
                                                      FROM PricebookEntry 
                                                      WHERE Pricebook2Id =: PriceBookId
                                                      AND ProductCode LIKE : String.escapeSingleQuotes(Test) 
                                                      AND ERP_PrdFamily_Code__c IN ('Charge','Comment','Miscellaneous') LIMIT 200];
                                }
                                else
                                {
                                        searchList = [SELECT Id,Name,ProductCode,ERP_PrdFamily_Code__c,ERP_PrdFamily_Desc__c,UnitPrice 
                                                      FROM PricebookEntry 
                                                      WHERE Pricebook2Id =: PriceBookId
                                                      AND ProductCode LIKE : Test LIMIT 200];
                                }
                        }
                        for(SObject s:searchList )
                        {
                                searchedRecord.add(new SalesOrder100Controller.ResultSet(s));
                        } 
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
                        }
                        for(SObject s:searchList )
                        {
                                searchedFamily.add(new SalesOrder100Controller.ProductFamilySet(s));
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
                }
                else
                        CurrentItem = new LineItem();
                return null;
        }
 
 
        @RemoteAction
        public static map<String,String> CheckPBEntryExists(String PricebookId , String ProductCode)
        {
                list<PricebookEntry> PBEntry = [Select ProductCode, Product2Id, Pricebook2Id, Name,Id
                                                From PricebookEntry
                                                Where Pricebook2Id =: PricebookId
                                                And ProductCode =: ProductCode];
 
 
                map<String,String> mapPBData =new map<String,String>();
 
 
                if(PBEntry.size() > 0)
                {
                        mapPBData.put('Exists','true');
                        mapPBData.put('Product2Id',PBEntry[0].Id);
                        system.debug('mapPBData  '+mapPBData);
                        return mapPBData;
                }
                else
                {
                        mapPBData.put('Exists','false');
                        mapPBData.put('Product2Id','');
                        return mapPBData;
                }
        }
 
 
 
 
 
 
 
 
        @RemoteAction
        public static map<String,String> Check_PBEntry_Exists(String PricebookId , String productFamily)
        {
                system.debug('PricebookId12 '+PricebookId);
                system.debug('productFamily12 '+productFamily);
                
                list<PricebookEntry> PBEntry = [Select ProductCode, ERP_PrdFamily_Code__c,Product2Id, Category__c,Pricebook2Id, Name,Id
                                                From PricebookEntry
                                                Where Pricebook2Id =: PricebookId
                                                And Category__c =: productFamily];
                
                system.debug('PBEntry '+PBEntry);
 
 
                map<String,String> mapPBData =new map<String,String>();
 
 
                if(PBEntry.size() > 0)
                {
                        mapPBData.put('Exists','true');
                        mapPBData.put('Product2Id',PBEntry[0].Id);
                        system.debug('mapPBData  '+mapPBData);
                        return mapPBData;
                }
                else
                {
                        mapPBData.put('Exists','false');
                        mapPBData.put('Product2Id','');
                        return mapPBData;
                }
        }
 
 
        @RemoteAction
        public static map<String,String> RealTimeProductData(String IntegrationKey, String AcntID, String ProductCode,String Quantity,string discount,String UOM,string grossPrice,string pricebookId)
        {        
              // system.debug('UOM56 '+UOM);       
                map<String,String> mapProData = new map<String,String>();
                //string ConversionFactor ='';
                baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
                map<string,list<object>> AttribParams=new  map<string,list<object>>();
                list<object>  AttribParam= new list<object>();
                AttribParam= new list<object>();
                AttribParam.add(IntegrationKey);
                AttribParams.put('IntegrationId',AttribParam);
 
 
                map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
                map<string,list<string>> parameter = new map<string,list<string>>();
                list<string> listParams=new list<string> ();
                listParams.add(ProductCode);
                parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
                WhereParams.put('ItemCode',parameter);
 
 
                AttribParam= new list<object>();
                Helper.MappingPurpose mappingType =Helper.MappingPurpose.ACTION;
                AttribParam.add(mappingType);
                AttribParams.put('MappingPurpose',AttribParam);
 
 
                AttribParam= new list<object>();
                AttribParam.add('CI_Item');
                AttribParams.put('ERPFuncName',AttribParam);
                
                AttribParam= new list<object>();
                AttribParam.add('CI_Item');
                AttribParams.put('DataFinder',AttribParam);
                
 
 
                AttribParam= new list<object>();
                AttribParam.add('');
                AttribParams.put('SourceEntity',AttribParam);
 
 
                AttribParam= new list<object>();
                AttribParam.add('0');
                AttribParams.put('startIndex',AttribParam);
 
 
                AttribParam= new list<object>();
                AttribParam.add('1');
                AttribParams.put('count',AttribParam);
                                
                if(string.isBlank(Quantity) || Quantity=='0.00')
                        Quantity='1';                
                
                Helper.GUMU_Response resGUMU_Response = new Helper.GUMU_Response();
 
                if(Test.isRunningTest()) 
                {
                    resGUMU_Response.statusCode =string.valueOf('200');
                    list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                    map<string,string>ERPDataMap = new map<string,string>();
                    ERPDataMap.put('SalesOrderNo','SON000111');                 
                    ERPDataMapList.add(ERPDataMap);
                    resGUMU_Response.ERPDataMap=ERPDataMapList;
                }
                else
                    resGUMU_Response =integrationFramework.getData(WhereParams,AttribParams);
                    
                system.debug('resGUMU_Response123 '+json.serialize(resGUMU_Response.ERPDataMap));
                //TotalQuantityOnHand
                if(resGUMU_Response.statusCode =='100')
                {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));          
                    mapProData.put('Connection','Failed');
                    mapProData.put('isvalidate','false');
                    system.debug('mapProData1 '+mapProData);
                    return mapProData;
                }
                else if(resGUMU_Response.statusCode !='200' && resGUMU_Response.statusCode !='201')
                {   
                    mapProData.put('Connection','OK');
                    mapProData.put('isvalidate','true');
                    mapProData.put('Error',resGUMU_Response.statusMessage); 
                    system.debug('mapProData2 '+mapProData);
                    return mapProData;
                }
                else
                {
                    mapProData.put('Connection','Ok');
                    mapProData.put('isvalidate','true');
  
                    map<string,string> ERPDataMaps  =   new map<string,string>();
                    //ERPDataMaps=resGUMU_Response.ERPDataMap[0];
                    ERPDataMaps=resGUMU_Response.ERPDataMap[0];
                    system.debug('ERPDataMaps'+json.serialize(ERPDataMaps));
                    if (ERPDataMaps==null)
                    {
                        mapProData= new map<String,String>();
                        mapProData.put('Error',resGUMU_Response.statusMessage); 
                        system.debug('mapProData3 '+mapProData);
                        return mapProData;
                    }
                        
                    mapProData.put('Quantity',Quantity); 
                    mapProData.put('ItemTypeCode',ERPDataMaps.get('ProductLine'));
                    mapProData.put('UnitPrice',ERPDataMaps.get('StandardUnitPrice'));
                    mapProData.put('ItemDescription',ERPDataMaps.get('ItemCodeDesc'));
                    mapProData.put('QOH',ERPDataMaps.get('TotalQuantityOnHand'));
                     
                } 

                list<UOM__c> UOMConversion  = new list<UOM__c>();
                string ConversionFactor ='';
                mapProData.put('ConversionFactor','1');
                if(string.isBlank(UOM))
                {
                    mapProData.put('UOM','EACH');
                    mapProData.put('Conversion','1'); 
                }                
                   
                system.debug('mapProDataConver5656  '+mapProData);         
                return mapProData;
        } 
        
        
        @RemoteAction
        public static map<String,String> UOMConvirsionFactor(String IntegrationKey, String UOM)
        {    
        	list<map<string,string>> mapProDataList = new list<map<string,string>>();
        	map<string,string> mapProData = new map<string,string>();
        	
            baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
            list<object>  AttribParam= new list<object>();    
            map<string,list<object>> AttribParams=new map<string,list<object>> ();
            
            
        	AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'UOM', '' , Helper.MappingPurpose.DISPLAY);
            
            AttribParam.add('CI_UnitOfMeasure');
            AttribParams.put('ERPFuncName',AttribParam);
                                  
            map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();             
            map<string,list<string>> parameter = new map<string,list<string>>();
            list<string> listParams=new list<string> ();
            listParams.add(UOM);
            parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
            fieldParameters.put('UnitOfMeasure',parameter);
            
                        
            Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
            
            resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
            
            if(resGUMU_Response.statusCode =='100')             
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));
            else if(resGUMU_Response.statusCode =='0') 
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resGUMU_Response.statusMessage));                               
            else if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Service Temporarily Unavailable.please check the Services.'));
            else
            	mapProDataList= resGUMU_Response.ERPDataMap;
            
            for(map<string,string> readProData:mapProDataList)
            {
            	for(String key :readProData.keySet())
            	{
        			if(readProData.get(key) == 'EACH')
            		{
            			mapProData = new map<string,string>(); 
            			string UOMChar = key.substring(key.length()-1,key.length());
            			mapProData.put('ConversionFactor',readProData.get('ConversionFactor'+UOMChar));
            			break;
            		}
            		else
            			mapProData.put('ConversionFactor',readProData.get('ConversionFactor1'));
            	}
            }
            
            if(mapProData == null)
            	mapProData.put('Error',resGUMU_Response.statusMessage);
            
           // system.debug('mapProData *** '+mapProData);
            //system.debug('mapProDataList *** '+jSon.serialize(mapProDataList));
  
            return mapProData;
        }
        
        @RemoteAction
        public static map<String,String> QuantityOnHand(String IntegrationKey, String Warehouse,string ProductCode)
        {    
        	list<map<string,string>> mapProDataList = new list<map<string,string>>();
        	map<string,string> mapProData = new map<string,string>();
        	try
	        {
	            if(IntegrationKey !=null)  
	            {	            		            			        	
		            baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
		            list<object>  AttribParam= new list<object>();    
		            map<string,list<object>> AttribParams=new map<string,list<object>> ();
		            		            
		        	AttribParams=Utility.getAttribParameters('1', '1' , IntegrationKey, 'QOH', '' , Helper.MappingPurpose.DISPLAY);
		            
		            AttribParam.add('IM_ItemWarehouse');
	                AttribParams.put('ERPFuncName',AttribParam); 
	                
	                map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();             
	                map<string,list<string>> parameter = new map<string,list<string>>();
	                list<string> listParams=new list<string> ();
	                listParams.add(ProductCode);
	                parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
	                fieldParameters.put('ItemCode',parameter);
	                
	                parameter = new map<string,list<string>>(); 
	                listParams=new list<string> ();
	                listParams.add(Warehouse);
	                parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);	                
	                fieldParameters.put('WarehouseCode',parameter);
	                
	                Helper.GUMU_Response resGUMU_Response = new  Helper.GUMU_Response();
	                if(Test.isRunningTest()) 
	                {                       
	                    resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
	                }
	                else
	                    resGUMU_Response =integrationFramework.getData(fieldParameters, AttribParams);
						
	                if(resGUMU_Response.statusCode =='100')             
	                    mapProData.put('Error', 'Unable to connect ERP System. please check the connection');
	                else if(resGUMU_Response.statusCode =='0') 
	                    mapProData.put('Error',  resGUMU_Response.statusMessage);                               
	                else if(resGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
	                    mapProData.put('Error', 'Service Temporarily Unavailable.please check the Services.');
	                else
            			mapProDataList= resGUMU_Response.ERPDataMap;
            			
            			
            		if(mapProDataList.size() > 0)
            		{
			            for(map<string,string> readProData:mapProDataList)
			            {
			            	integer QOH = integer.valueOf(readProData.get('QuantityOnHand'));
			            	integer QOSalesOrder = integer.valueOf(readProData.get('QuantityOnSalesOrder'));
			            	integer calculatedQOH = QOH-QOSalesOrder;
			            	system.debug('QOH *** '+QOH);
			            	system.debug('QOSalesOrder *** '+QOSalesOrder);
			            	system.debug('calculatedQOH *** '+calculatedQOH);
			            	
			            	mapProData.put('QTY',string.valueOf(calculatedQOH));
	        			}
            		}
            
		            if(mapProData == null)
		            	mapProData.put('Error',resGUMU_Response.statusMessage);
		           
		           system.debug('mapProData '+mapProData); 	 
            		
        		} 
        		return mapProData;           
	        }
	        catch(Exception ex)
	        {
	            return mapProData;
	        }  
        }
        
        
        public Pagereference CRUDLineItem()
        {
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
 
 
                        system.debug('mapLineDetails '+JSON.serialize(mapLineDetails));
                        LineItem itm =new LineItem();
 
 
                        itm.ItemType = String.valueOf(mapLineDetails.get('ItemType'));
                        itm.ItemCode = String.valueOf(mapLineDetails.get('ItemCode'));
                        itm.ProductId = String.valueOf(mapLineDetails.get('ProductId'));
                        itm.WarehouseCode = String.valueOf(mapLineDetails.get('WarehouseCode'));
                        itm.UOM = String.valueOf(mapLineDetails.get('UOM'));
                        itm.Conversion = String.valueOf(mapLineDetails.get('Conversion'));
                        itm.TaxClass = String.valueOf(mapLineDetails.get('TaxClass'));
                        itm.ListPrice = String.valueOf(mapLineDetails.get('ListPrice'));
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
                                //minusTaxTotal += decimal.valueOf(itm.minusTax);
                                //plusTaxTotal += decimal.valueOf(itm.plusTax);
                        }
                }
                JSONOrderItems = JSON.serialize(LineItems);
 
 
                if(LineItems.size() > 0)
                        Sales_TaxAmt = CalculateTax(IntegrationKey,ARDivisionNo,CustomerNo,TaxSchedule,DiscountPC);
                else
                        Sales_TaxAmt = 0.00;
                return null;
        }
 
 
        public Pagereference RecalculateTax()
        {
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
 
 
                Sales_TaxAmt = CalculateTax(IntegrationKey,ARDivisionNo,CustomerNo,TaxSchedule,DiscountPC);
                return null;
        }
 
 
        private decimal CalculateTax(String IntegrationKey,String ARDivisionNo,String CustomerNo,String TaxSchedule,String DiscountPC)
        {
                decimal TaxAmt = 0.00;
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
 
 
                TaxAmt=0.00;
                return TaxAmt;
        }
        public Pagereference SaveERPOrder()
        {
                try
                {
                        map<String,Object> mapOrderDetails = (map<string,object>)JSON.deserializeUntyped(JSONOrderDetails);
                        system.debug('JSONOrderDetails '+json.serialize(mapOrderDetails));
                        if(string.isNotBlank(OrderId))
                        {
                                ERPOrder.Id = OrderId;
                                list<OrderItem> Items= [Select Id from OrderItem where OrderId =: OrderId];
                                delete Items;
                        }
                        else
                                ERPOrder = new Order();
 
 
                        ERPOrder.AccountId = String.valueOf(mapOrderDetails.get('AccountId'));
                        ERPOrder.Warehouse__c = String.valueOf(mapOrderDetails.get('WarehouseCode'));
                        ERPOrder.ShipVia__c = String.valueOf(mapOrderDetails.get('Shipvia'));
                        ERPOrder.Ship_Expire_Date__c = String.valueOf(mapOrderDetails.get('ShipExpireDate'));
                        ERPOrder.TermsCode__c = String.valueOf(mapOrderDetails.get('TermsCode'));
                        ERPOrder.EffectiveDate = date.parse(String.valueOf(mapOrderDetails.get('OrderDate')));
                        ERPOrder.Sales_Person__c = String.valueOf(mapOrderDetails.get('SalesPersonNo'));
                        ERPOrder.Tax_Schedule__c = String.valueOf(mapOrderDetails.get('TaxSchedule'));
                        ERPOrder.AccountId = String.valueOf(mapOrderDetails.get('AccountId'));
                        ERPOrder.Batch_Fax_No__c = Boolean.valueOf(mapOrderDetails.get('BatchFax'));
                        ERPOrder.Print_Picking_Sheets__c = Boolean.valueOf(mapOrderDetails.get('PrintPickSheets'));
                        ERPOrder.Print_Order__c = Boolean.valueOf(mapOrderDetails.get('PrintOrder'));
                        ERPOrder.PricebookName__c = String.valueOf(mapOrderDetails.get('PricebookName'));
                        ERPOrder.Description = String.valueOf(mapOrderDetails.get('OrderDescription'));
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
 
 
 
 
                        ERPOrder.FOB__c = String.valueOf(mapOrderDetails.get('FOB'));
                        ERPOrder.Payment_Type__c = String.valueOf(mapOrderDetails.get('PaymentType'));
                        ERPOrder.OrderReferenceNumber = String.valueOf(mapOrderDetails.get('OrderRefNo'));
                        ERPOrder.ShippingCity = String.valueOf(mapOrderDetails.get('ShipToCity'));
                        ERPOrder.ShippingCountry = String.valueOf(mapOrderDetails.get('ShipToCountryCode'));
                        ERPOrder.ShippingPostalCode = String.valueOf(mapOrderDetails.get('ShipToZipCode'));
                        ERPOrder.ShippingState = String.valueOf(mapOrderDetails.get('ShipToState'));
                        ERPOrder.ShippingStreet = String.valueOf(mapOrderDetails.get('ShipToAddress1')) + String.valueOf(mapOrderDetails.get('ShipToAddress2')) + String.valueOf(mapOrderDetails.get('ShipToAddress3'));
                        ERPOrder.Type= String.valueOf(mapOrderDetails.get('OrderType'));
                        ERPOrder.Status='Draft';
                        ERPOrder.EffectiveDate = date.parse(String.valueOf(mapOrderDetails.get('OrderDate')));
                        ERPOrder.Document_Type__c= String.valueOf(mapOrderDetails.get('DocumentType'));
                        ERPOrder.ERP_Order_Total__c = Double.valueOf(mapOrderDetails.get('TotalAmount'));
                        ERPOrder.Taxable_Amount__c = Double.valueOf(mapOrderDetails.get('NetAmount'));                     
                          
                        ERPOrder.Integration_Key__c = String.valueOf(mapOrderDetails.get('IntegrationKey'));
                        ERPOrder.ERP_Order_Info__c = JSONOrderDetails;   
                        ERPOrder.ERP_Order_Details_Info__c = JSON.serialize(LineItems);
 
 
                        upsert ERPOrder;
                        OrderId = ERPOrder.Id;
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
                                //oItem.MinusTax__c= decimal.valueOf(itm.minusTax);
                                //oItem.PlusTax__c = decimal.valueOf(itm.plusTax);
                                oItem.QOH__c= string.isNotBlank(itm.QOH) ? decimal.valueOf(itm.QOH) : 0.00; 
                                oItem.TaxClass__c = itm.TaxClass;
                                oItem.UOM__c= itm.UOM;
                                if(string.isBlank(itm.Conversion))
                                    oItem.UOM_Conversion_Factor__c= decimal.valueOf('1');
                                else
                                    oItem.UOM_Conversion_Factor__c= decimal.valueOf(itm.Conversion);
                                    
                                oItem.Warehouse_Code__c = itm.WarehouseCode;
                                insert oItem;
                        }
                }
                catch(Exception ex)
                {
                        CustomException exc= new CustomException('100','SalesOrder100Controller',ex,true);
                }
                return null;
        }
 
 
        // Promote Order to Sage 100 ERP.
        public pagereference PromoteSage100Order()
        {
                try
                {   
                        map<String,object> OrderHeaderFields  =(map<string,object>)JSON.deserializeUntyped(OrderHeaderDetails);
                        
                        system.debug('OrderHeaderFields '+json.serialize(OrderHeaderFields));
                        string acntId=String.valueOf(OrderHeaderFields.get('AccountId'));
                        Account AR_DivisonNo_1 = [SELECT AR_DivisonNo__c ,Integration_Key__c FROM Account where ID=: acntId];
                        OrderHeaderFields.put('ARDivisionNo',AR_DivisonNo_1.AR_DivisonNo__c);
 
 
                        ReadAndWriteXML.XmlNode objXmlNode ;        
                        string orderNo;
                        ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,
                                                      Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
 
                        String IntegrationKey=AR_DivisonNo_1.Integration_Key__c;
                        String EndPoint= oIntegration.Web_Service_URL__c;                                
                        String ERPSystemName= oIntegration.ERP_System__c;
                        String CompanyCode=oIntegration.ERP_Company_Code__c;
                        String publicName='';
                        String UniqueKey='';
                        string aCPayload = '<SO_SalesOrderHeaderSPECIAL xmlns="" >';
                        aCPayload += '<ARDivisionNo>' +OrderHeaderFields.get('ARDivisionNo')  + '</ARDivisionNo>';
                        aCPayload += '<CustomerNo>' + OrderHeaderFields.get('CustomerNo') + '</CustomerNo>';
                        aCPayload += '<FOB>' + OrderHeaderFields.get('FOB') + '</FOB>';
                        aCPayload += '<CheckNoForDeposit>' + OrderHeaderFields.get('CheckNoForDeposit') + '</CheckNoForDeposit>';
                        
                        aCPayload += '<DiscountRate>' +OrderHeaderFields.get('DiscountPC') + '</DiscountRate>';
                        aCPayload += '<DiscountAmt>' +OrderHeaderFields.get('DiscountAmt') + '</DiscountAmt>';
                        aCPayload += '<FreightAmt>' + OrderHeaderFields.get('FreightAmt')+ '</FreightAmt>';
                        //aCPayload += '<FreightAmt>10.00</FreightAmt>';
                        aCPayload += '<PrintPickingSheets>' + OrderHeaderFields.get('PrintPickingSheets')+ '</PrintPickingSheets>';
                        aCPayload += '<PrintSalesOrders>' + OrderHeaderFields.get('PrintSalesOrders') + '</PrintSalesOrders>';
                        aCPayload += '<TermsCode>' + OrderHeaderFields.get('TermsCode') + '</TermsCode>';
                        aCPayload += '<SalespersonDivisionNo>' +OrderHeaderFields.get('ARDivisionNo')  + '</SalespersonDivisionNo>';
                        aCPayload += '<SalespersonNo>' +OrderHeaderFields.get('SalesPersonNo')  + '</SalespersonNo>';
                        aCPayload += '<TaxSchedule>' + OrderHeaderFields.get('TaxSchedule') + '</TaxSchedule>';
                        aCPayload += '<WarehouseCode>' +OrderHeaderFields.get('WarehouseCode') + '</WarehouseCode>';
                        aCPayload += '<ShipVia>' + OrderHeaderFields.get('Shipvia') + '</ShipVia>';
                        aCPayload += '<ShipToCountryCode>' + OrderHeaderFields.get('ShipToCountryCode') + '</ShipToCountryCode>';
                        aCPayload += '<ShipToZipCode>' + OrderHeaderFields.get('ShipToZipCode') + '</ShipToZipCode>';
                        aCPayload += '<ShipToState>' + OrderHeaderFields.get('ShipToState') + '</ShipToState>';
                        aCPayload += '<ShipToCity>' +OrderHeaderFields.get('ShipToCity')+ '</ShipToCity>';
                        aCPayload += '<ShipToAddress3>' + OrderHeaderFields.get('ShipToAddress3') + '</ShipToAddress3>';
                        aCPayload += '<ShipToAddress2>' + OrderHeaderFields.get('ShipToAddress2') + '</ShipToAddress2>';
                        aCPayload += '<ShipToAddress1>' +OrderHeaderFields.get('ShipToAddress1') + '</ShipToAddress1>';
                        aCPayload += '<ShipToName>' + OrderHeaderFields.get('ShipToName') + '</ShipToName>';
                        aCPayload += '<BillToCountryCode>' +OrderHeaderFields.get('BillToCountryCode') + '</BillToCountryCode>';
                        aCPayload += '<BillToZipCode>' +OrderHeaderFields.get('BillToZipCode') + '</BillToZipCode>';
                        aCPayload += '<BillToState>' + OrderHeaderFields.get('BillToState') + '</BillToState>';
                        aCPayload += '<BillToCity>' + OrderHeaderFields.get('BillToCity') + '</BillToCity>';
                        aCPayload += '<BillToAddress3>' + OrderHeaderFields.get('BillToAddress3') + '</BillToAddress3>';
                        aCPayload += '<BillToAddress2>' + OrderHeaderFields.get('BillToAddress2') + '</BillToAddress2>';
                        aCPayload += '<BillToAddress1>' +OrderHeaderFields.get('BillToAddress1') + '</BillToAddress1>';
                        aCPayload += '<PaymentType>' +OrderHeaderFields.get('PaymentType')+ '</PaymentType>';
                        aCPayload += '<BatchFax>' +OrderHeaderFields.get('BatchFaxNo')  + '</BatchFax>';
                       
                        integer i=1;
                        list<LineItem> objLineItems = (list<LineItem>) json.deserialize(JSONOrderDetails, List<LineItem>.class); 
                        system.debug('objLineItems '+objLineItems);
                       //integer i=1;
                        for(LineItem itm : objLineItems)
                        {
                            string WarehouseCode = string.IsBlank(itm.WarehouseCode) ? '' : itm.WarehouseCode;
                            string taxClass= string.IsBlank(itm.TaxClass) ? 'TX' : itm.TaxClass;  
                            string comments= string.IsBlank(itm.Comments) ? ' ' : itm.Comments; 
                            system.debug('cmnt '+itm.Comments);
                            // string Conversion_Factor='';
                            //list<UOM__c> UOMConversion = [select id,Conversion_Factor__c from UOM__c where  UOM_Code__c =:itm.UOM and Integration_Key__c=:IntegrationKey];
                          
                            aCPayload += '<SO_SalesOrderHeaderSPECIALSECOND>';
                            
                            aCPayload += '<ItemCode>' + itm.ItemCode + '</ItemCode>';
                            // aCPayload += '<ItemCodeDesc>' + itm.ItemDescription + '</ItemCodeDesc>';
                            aCPayload += '<Commissionable>' + itm.Commissionable + '</Commissionable>';
                            aCPayload += '<WarehouseCode>' + WarehouseCode + '</WarehouseCode>';
                            aCPayload += '<UnitOfMeasure>' + itm.UOM + '</UnitOfMeasure>';
                            aCPayload += '<DropShip>' + itm.DropShip + '</DropShip>';
                            aCPayload += '<TaxClass>'+taxClass+'</TaxClass>';
                            //aCPayload += '<TaxClass>'+itm.TaxClass+'</TaxClass>';
                            aCPayload += '<QuantityOrdered>' + itm.QuantityOrdered + '</QuantityOrdered>';
                            aCPayload += '<ExtensionAmt>' + itm.ExtensionAmt + '</ExtensionAmt>';
                            aCPayload += '<UnitPrice>' + itm.UnitPrice + '</UnitPrice>';
                            aCPayload += '<CommentText>' + comments + '</CommentText>';
                            aCPayload +='<LineDiscountPercent>' +itm.Discount+ '</LineDiscountPercent>';
        
                                
                                aCPayload += '</SO_SalesOrderHeaderSPECIALSECOND>';
                                i++;
                        }
                        aCPayload += '</SO_SalesOrderHeaderSPECIAL>';
 
 
                        string aPayload = '<entry xmlns:atom="http://www.w3.org/2005/Atom"' ;
                        aPayload += ' xmlns:xs="http://www.w3.org/2001/XMLSchema"';
                        aPayload += ' xmlns:cf="http://www.microsoft.com/schemas/rss/core/2005"' ;
                        aPayload += ' xmlns="http://www.w3.org/2005/Atom"' ;
                        aPayload += ' xmlns:sdata="http://schemas.sage.com/sdata/2008/1"' ;
                        aPayload += ' xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"' ;
                        aPayload += ' xmlns:opensearch="http://a9.com/-/spec/opensearch/1.1/"' ;
                        aPayload += ' xmlns:sync="http://schemas.sage.com/sdata/sync/2008/1"' ;
                        aPayload += ' xmlns:sme="http://schemas.sage.com/sdata/sme/2007"' ;
                        aPayload += ' xmlns:http="http://schemas.sage.com/sdata/http/2008/1">' ;
                        aPayload += '<sdata:payload>';
                        aPayload += aCPayload;
                        aPayload += '</sdata:payload>';
                        aPayload += '</entry>';
 
 
                        system.debug('aPayload '+aPayload);
                        baseIntegrationFramework integrationFramework= new Sage100IntegrationFramework();
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
                        AttribParam.add('SO_SalesOrderHeaderSPECIAL');
                        AttribParams.put('ERPFuncName',AttribParam);
                        AttribParam= new list<object>();
                        AttribParam.add('0');
                        AttribParams.put('startIndex',AttribParam);
                        AttribParam= new list<object>();
                        AttribParam.add('0');
                        AttribParams.put('count',AttribParam);
 
 
                        system.debug('AttribParams111'+AttribParams);
 
 
                        map<string,map<string,list<string>>> WhereParams = new map<string,map<string,list<string>>>();
                        Helper.GUMU_Response resGUMU_Response =new  Helper.GUMU_Response();
 
 
                        if(Test.isRunningTest())
                        {
                                string TestResponseData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:runResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><runReturn href="#id0"/></ns1:runResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;AX_PAR&quot; SIZE=&quot;5&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_MAX&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$REC_STARTAT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$TOTAL_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;221&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$RET_COUNT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;10&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;AXPARCOD&quot; TYPE=&quot;Char&quot;&gt;$HAS_NEXT&lt;/FLD&gt;&lt;FLD NAME=&quot;AXPARVAL&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;100&quot; ID=&quot;RES&quot; SIZE=&quot;10&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Originals Factory, Best Seller 3 Corner Lines&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;AD01&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;AB Corp.&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ABCORP&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;AD02&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.abcorp.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;PR&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;00638&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Ab Corp Ro&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Ciales&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;4222355656&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151223&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;New Jumeirah Street 052 85th West Avenue&lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Billing Address&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;ALMEH Companay1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;ALMEH&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;1254589658&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;&gt;almeh@gmail.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;&gt;www.almeh.com&lt;/FLD&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;&gt;CA&lt;/FLD&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;90013&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;new Street&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Los Angeles&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;7854581236&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151222&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;77, Rua Soba Mandume Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Luanda BTT&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229090988&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;77, Rua So&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879878&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Av.Pedro de C. Van-Dunem Loy &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Ciclo Belas&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO002&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;219898989&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Av.Ped&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219999999&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;R. Presidente Marien Ngouabi &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Farm&#xE1;cia Saude e Higiene1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO003&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;229696969&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;R. Preside&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;229879887&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151216&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;52, Rua Alda Lara Vila Alice &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribui&#xE7;&#xE3;o Angola Farma&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO004&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;52, Rua Al&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;219988776&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;7&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;43, Rua da Ambaca &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Super Mar&#xE7;al 1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Supermercados do Mar&#xE7;al&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO005&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;265788009&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;43, Rua da&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Luanda - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;265788000&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;8&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Estrada do Caxito &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Distribuidora do Caxito&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO006&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;&gt;252372979&lt;/FLD&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Estrada do&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;Caxito - Angola&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;&gt;252372970&lt;/FLD&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20140310&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;9&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;Largo Irene Cohen &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Brinquedos da Tita&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO007&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;Largo Iren&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;LUANDA - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151016&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;10&quot;&gt;&lt;FLD NAME=&quot;BADDLIG1&quot; TYPE=&quot;Char&quot;&gt;61, Rua Henrique de Carvalho &lt;/FLD&gt;&lt;FLD NAME=&quot;BCRY&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;FLD NAME=&quot;BCTY&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BPAADDFLG&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD NAME=&quot;BPADES&quot; TYPE=&quot;Char&quot;&gt;Sede&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Angola Industrial&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNUM&quot; TYPE=&quot;Char&quot;&gt;AO008&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;401&quot; NAME=&quot;BPCTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDADD&quot; TYPE=&quot;Char&quot;&gt;001&lt;/FLD&gt;&lt;FLD NAME=&quot;BPOSCOD&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;BSAT&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Daily Rate&quot; MENULOCAL=&quot;202&quot; NAME=&quot;CHGTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;AOA&lt;/FLD&gt;&lt;FLD NAME=&quot;FAX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;FCYWEB&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SADDLIG1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCRY&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;SCTY&quot; TYPE=&quot;Char&quot;&gt;58639&lt;/FLD&gt;&lt;FLD NAME=&quot;SPOSCOD&quot; TYPE=&quot;Char&quot;&gt;61, Rua He&lt;/FLD&gt;&lt;FLD NAME=&quot;SSAT&quot; TYPE=&quot;Char&quot;&gt;MALANJE - ANGOLA&lt;/FLD&gt;&lt;FLD NAME=&quot;TEL&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;UPDDATTIM&quot; TYPE=&quot;Date&quot;&gt;20151019&lt;/FLD&gt;&lt;FLD NAME=&quot;WEB&quot; TYPE=&quot;Char&quot;&gt;AO&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.1238</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">2.2376</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">4104.859</poolExecDuration><poolRequestDuration xsi:type="xsd:double">4107.3992</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.2995</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">4160.6443</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                                resGUMU_Response.responseERPData=TestResponseData;
                                resGUMU_Response.statusMessage='Ok';
                                resGUMU_Response.statusCode =string.valueof(200);
                                list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                                map<string,string>ERPDataMap = new map<string,string>();
                                ERPDataMap.put('SalesOrderNo','SON000111');                 
                                ERPDataMapList.add(ERPDataMap);
                                resGUMU_Response.ERPDataMap=ERPDataMapList;
                        }
                        else
                        {
                                resGUMU_Response =integrationFramework.PostData(IntegrationKey,SourceEntity,AttribParams,mapData,AttribParams);
                                // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'resGUMU_Response Control:  '+resGUMU_Response));
                        }   
 
 
                        if(resGUMU_Response.statusCode =='100')
                        {   
                                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));          
                        }
 
 
                        if( resGUMU_Response.statusCode == '500' || resGUMU_Response.statusCode == '400')
                        {
                                system.debug('500');
                                ErrorMessage = Utility.parse(resGUMU_Response.responseERPData,'message');
                        }
                        if(resGUMU_Response.statusCode =='200' || resGUMU_Response.statusCode =='201' || resGUMU_Response.statusCode =='202')
                        { 
                                string OrderNumber1='';
                                string SalesTax_Amt='';
                                string FreightAmount ='';
                                list<map<string,string>> ERPDatamapList = resGUMU_Response.ERPDataMap;
 
 
                                system.debug('ERPDatamapList '+JSON.serialize(ERPDatamapList[0]));
                                for(map<string,string> ERPDatamap :ERPDatamapList)
                                {
                                        OrderNumber1=ERPDatamap.get('SalesOrderNo');
                                        SalesTax_Amt=ERPDatamap.get('SalesTaxAmt');
                                        FreightAmount =ERPDatamap.get('FreightAmt');
                                        SalesTaxAmt=decimal.ValueOf(SalesTax_Amt);
                                        system.debug('SalesTaxAmt '+SalesTaxAmt);
                                }
 
 
                                ERPOrder.ERP_Order_Number__c = OrderNumber1;
                                OrderId = ERPOrder.Id;
                                ERPOrder.SalesTaxAmt__c=SalesTaxAmt;
                                ERPOrder.FreightAmt__c=decimal.ValueOf(FreightAmount);
                                update ERPOrder;
                               // return null;
                                pageReference pgref =new PageReference('/apex/ERPOrderList');
                                OrderId = Apexpages.currentPage().getParameters().get('id');
                                pgref.setRedirect(true);
                                return pgref;
                        }
                }
                catch(Exception ex)
                {
                         ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Error:' ));
                    
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'Error:' + ex ));
                }
                return null;
        }
 
 
        public Pagereference AddMultiLineItem()
        {
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
 
 
                list<LineItem> objLineItems = (list<LineItem>) json.deserialize(JSONLineItems, List<LineItem>.class);
                LineItems.addAll(objLineItems);
                LineTotal=0.00;
                minusTaxTotal =0.00;
                plusTaxTotal =0.00;
                if(LineItems.size() > 0)
                {
                        for(LineItem itm : LineItems)
                        {
                                LineTotal += decimal.valueOf(itm.ExtensionAmt);
                                //minusTaxTotal += decimal.valueOf(itm.minusTax);
                                //plusTaxTotal += decimal.valueOf(itm.plusTax);
                        }
                }
                JSONOrderItems = JSON.serialize(LineItems);
 
 
                if(LineItems.size() > 0)
                        SalesTaxAmt = CalculateTax(IntegrationKey,ARDivisionNo,CustomerNo,TaxSchedule,DiscountPC);
                else
                        SalesTaxAmt = 0.00;
                return null;
        }
        //code for credit cards details
        @RemoteAction
        public static list<CustomerCreditCards> GetCustomerCCList(String IntegrationKey,String UniqueKey)
        {
                string STARTAT='';
                string MAXCOUNT='200';
                string TOTALCOUNT='';
                string RETCOUNT='';
                string HASNEXT='';
                string HASPREV='';
                return null;
        }
 
 
 
 
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
                public String Conversion{get;set;}
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
                        this.FamilyCode = s.get('ERP_Product_Family_Code__c') + '';
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
                                || !Schema.sObjectType.Account.fields.ID.isAccessible())
                {
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
 
 
                list<Account> oActList = [SELECT Id, Integration_Key__c FROM Account WHERE ID =: AccountId];
                Account oAct;
                //ABDS:Added if 
                if (oActList.size()>0) 
                {
                        oAct=oActList[0]; 
                        list<ERP_Config__c> oIntegrationList =[SELECT ERP_System__c,ERP_Company_Code__c,Synchronization__c FROM ERP_Config__c WHERE ID =: oAct.Integration_Key__c ];
                        if (oIntegrationList.size()>0)
                        {
                                ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Synchronization__c FROM ERP_Config__c WHERE ID =: oAct.Integration_Key__c ];
                                ERPSystemName = oIntegration.ERP_System__c;
                                Synchronization = oIntegration.Synchronization__c;  
                                ERPCompanyCode = oIntegration.ERP_Company_Code__c;
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
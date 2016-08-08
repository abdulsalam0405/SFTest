public with sharing class ERPOrderListController 
{
    public Boolean bShowSalesOrder { get; set;}
    public Integer PAGE_SIZE{get;set;}
    public Integer page{get;set;}
    public Integer totalRecords{get;set;}
    public Integer totalPages{get;set;}
    public Integer startIdx{get;set;}
    public Integer endIdx{get;set;}
    public list<Order> Orders {get;set;}
    public String ProfileName {get;set;}   
    public Integer OffsetSize {get;set;}
    public Integer QueryLimit =10; 
    public Integer CountTotalRecords{get;set;}
    public string ERPSystemName{get;set;}
    public string ERPIntegrationName{get;set;} 
    public String selectedERP{get;set;}
    public String OrderId{get;set;}
    public List<Order> IntegrationKeyList{get;set;}
    public string IntegrationName{get;set;}
    public list<ERP_Config__c> ERPConfigList  {get;set;}
    public  List<SelectOption> IntegrationList {get;set;}
    public String PageIntegrationKey{get;set;}
    public String PageMode {get;set;} 

    public ERPOrderListController() 
    {
        /// Constructor calling with default values set.
        OffsetSize = 0;
       // CountTotalRecords= [select count() from order WHERE Integration_Key__c !=: ''];
        this.Orders = new list<Order>();
        //set initial page
        this.page = 1;
        this.PAGE_SIZE=10;
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'PAGE_SIZE '+PAGE_SIZE ));

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
        
        IntegrationList = new List<SelectOption>();
        IntegrationList.add(new SelectOption('All','All Integrations'));

        list <ERP_Config__c> config = [select Id,Name,ERP_System__c from ERP_Config__c where Default__c= true];
        ERPSystemName = '';
        if(config.size()>0)
        {
            ERPSystemName = config[0].ERP_System__c;
            ERPIntegrationName = config[0].Id;
            selectedERP=config[0].Id;
        }
         else
            selectedERP='All';
                
        list<ERP_Config__c> ERPConfigList = [select Id,Name,ERP_System__c from ERP_Config__c where Inactive__c =false];//select Id,ERP_System__c,Name,Default__c  from ERP_Config__c
        for(ERP_Config__c ERP :ERPConfigList )
        {
            IntegrationList.add(new SelectOption(ERP.Id, ERP.Name));
        }
        
        GetOrders();
    } 

    //Advance to next page
    public void doNext()
    {
         if(OffsetSize + QueryLimit > CountTotalRecords)
            return;
            
        OffsetSize += QueryLimit;
        this.page++;
        GetOrders();
    }

    //Advance to previous page
    public void doPrevious()
    {
        if(OffsetSize == 0)
            return;
            
        OffsetSize -= QueryLimit;
        this.page--;  
        GetOrders();
    } 

    //Returns whether the previous page exists
    public Boolean getHasPrevious()
    {        
        if(OffsetSize ==0)
        {
            return false;
        }
        else
            return true;
    }


    //Returns whether the next page exists
    public Boolean getHasNext()
    {
        if(OffsetSize + QueryLimit < countTotalRecords)
        {
            return true;          
        }
        else 
            return false;
    }  

    //Get Sales Order Created for ERP
    public PageReference GetOrders() 
    {       
        if(Apexpages.hasMessages())
            Apexpages.getMessages().clear();

        //calculate range of records for capture
        this.startIdx = (this.page-1)*PAGE_SIZE;
        this.endIdx = this.page*PAGE_SIZE;
        this.totalRecords = 0;
        QueryLimit = PAGE_SIZE;
        // Check if the user has read access on the Order fields
        if (!Schema.sObjectType.order.fields.OrderNumber.isAccessible() 
                || !Schema.sObjectType.order.fields.EffectiveDate.isAccessible()
                || !Schema.sObjectType.order.fields.TotalAmount.isAccessible()
                || !Schema.sObjectType.order.fields.ERP_Order_Number__c.isAccessible()
                || !Schema.sObjectType.order.fields.TotalAmount.isAccessible()
                || !Schema.sObjectType.order.fields.ShipStatus__c.isAccessible()
                || !Schema.sObjectType.order.fields.Document_Type__c.isAccessible()
                || !Schema.sObjectType.order.fields.ERP_Order_Total__c.isAccessible()
                || !Schema.sObjectType.order.fields.Integration_Key__c.isAccessible()
                || !Schema.sObjectType.order.fields.Id.isAccessible())
        { 
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Insufficient access to Fields'));
            return null;
        }
        String query='SELECT Id,OrderNumber,Account.name,EffectiveDate,TotalAmount,ERP_Order_Number__c,ShipStatus__c,Document_Type__c,ERP_Order_Total__c,Order_Total__c,Integration_Key__c,Taxable_Amount__c FROM order';

        //query+=' and Integration_Key__c = \''+ selectedERP  +'\' AND Integration_Key__c != \''+ String.escapeSingleQuotes('') +'\'';
        //AND Integration_Key__c != \''+ String.escapeSingleQuotes('') +'\'';
        if(selectedERP !='All')
        {
            query+=' WHERE  Integration_Key__c =\''+ String.escapeSingleQuotes(selectedERP)+'\'';
            CountTotalRecords= [select count() from Order where Integration_Key__c =:selectedERP]; // where condition Active__c=true and and from Entity_Mapping_Header__c 
        }  
        else
        {           
            CountTotalRecords= [select count() from Order limit 50000 ]; // where Active__c=true
        }  

        query+=' ORDER BY Account.name limit '+ QueryLimit +' offset '+ OffsetSize +'';
        list<Order> lstOrders = Database.Query(query);

        Orders = new list<Order>();
        string SOintegrationKey ='';
        string SONewIntegrationKey ='';
        if(lstOrders.size() > 0)
        {
            
            for(Order oOrder : lstOrders)
            {
                SOintegrationKey = string.valueOf(oOrder.Integration_Key__c);
                if(SONewIntegrationKey !=oOrder.Integration_Key__c)
                {
                    list<ERP_Config__c> ERPConfigList = [select ERP_System__c from ERP_Config__c where Id =:SOintegrationKey limit 1];
                    SONewIntegrationKey=SOintegrationKey;
                    if(ERPConfigList.size()>0)
                        ERPSystemName = ERPConfigList[0].ERP_System__c;
                }
                
                if(ERPSystemName == 'Sage100ERP')
                    {
                        if(string.isNotBlank(string.valueOf(oOrder.Taxable_Amount__c)))
                            oOrder.ERP_Order_Total__c=oOrder.Order_Total__c;
                        system.debug('total '+oOrder.ERP_Order_Total__c);
                        //system.debug('total '+oOrder.Order_Total__c);
                    }
                                
                Orders.add(oOrder);
                //count the total number of records
                this.totalRecords++;
            }
        } 
       
        //calculate total pages
        this.totalRecords=this.CountTotalRecords;
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
        return null;                            
    }
    
    Public PageReference RedirectPage()
    {
        system.debug('RedirectPage');
        PageReference pgref ;
        list<ERP_Config__c> ERPconfigList;
        String RedirectPageURL;

       
        if(OrderId =='' && selectedERP == 'All')
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'Select integration' ));
            return null;
        }
        else if(OrderId =='' && selectedERP != 'All'){
            PageIntegrationKey = selectedERP;
        }
        else
        {
            IntegrationKeyList = [select Id,Integration_Key__c from Order where id=:OrderId];
            PageIntegrationKey = IntegrationKeyList[0].Integration_Key__c;
            
        }
        
        ERPconfigList = [select Id,ERP_System__c from ERP_Config__c where Id =:PageIntegrationKey];
        
        if(ERPconfigList.size()>0)
            IntegrationName = ERPconfigList[0].ERP_System__c;
        
        if(IntegrationName == 'SageERPX3')
            RedirectPageURL = '/apex/SalesOrderX3?PageIntegrationKey='+PageIntegrationKey+'&Mode='+PageMode;
        else if(IntegrationName == 'Sage300ERP')
            RedirectPageURL = '/apex/SalesOrder300?PageIntegrationKey='+PageIntegrationKey+'&Mode='+PageMode;
        else if(IntegrationName == 'Sage100ERP')
            RedirectPageURL = '/apex/SalesOrder100?PageIntegrationKey='+PageIntegrationKey+'&Mode='+PageMode;
        
        if(OrderId != '')
            RedirectPageURL += '&id=' + OrderId; 
              
        pgref =new PageReference(RedirectPageURL);
        pgref.setRedirect(true);

        return pgref;
    }
}
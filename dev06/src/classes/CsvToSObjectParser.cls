public class CsvToSObjectParser {
    private final String RESOURCE_NAME = 'object_csv';
 
    private List<String> lines = new List<String>();
 
    private  Map<string,sObject> objsToInsert = new  Map<string,sObject>();
    private Map<string,sObject> extIdMap = new Map<string,sObject>();
    private string tblName {get;set;}
    private string prntObject {get;set;}
    private string prntField {get;set;}
    private string chldField {get;set;}
    private string IntgrtnKey {get;set;}
    //private list<string> listOfReferenceFld = new list<string>();
    map<string,string> mapId=new map<string,string>();
    private string NameSpace{get;set;}
    private string ERPType{get;set;}
    private integer StartIndex{get;set;}
    private integer EndIndex{get;set;}
    public StaticResource theStaticResource{get;set;}
 	public string LogMessage='';
 	public string CompanyName='';
    public CsvToSObjectParser(){
        fetchResource(RESOURCE_NAME);
    }
 
    public CsvToSObjectParser(String resourceName){
        fetchResource(resourceName);
    }
    
    public CsvToSObjectParser(String resourceName,String IntegrationKey,string tableName,string parentObject,string parentField,
    string childField,string ERP,integer StartRecordIndex,integer EndRecordIndex,string CompName){
        LogMessage='';
        fetchResource(resourceName);
        tblName =tableName;
        IntgrtnKey=IntegrationKey;
        prntObject =parentObject;
        prntField =parentField;
        chldField =childField;
        NameSpace=Utility.FetchNameSpace();
        ERPType=ERP;
        StartIndex=StartRecordIndex;
        EndIndex=EndRecordIndex;
        CompanyName=CompName;
    }
 	
    // Run over the lines in the files
    public List<SObject> parseCsv(){
        String bodyText = theStaticResource.body.toString();
        List<string> bodyLines = bodyText.split('\r');
        integer k=0;
        integer i=0;
        
        if (prntField !='')
        {
            string sQuery = 'select Id,'+NameSpace+prntField+' from '+ prntObject +
            ' where '+NameSpace + prntField + ' != null and '+ NameSpace + prntField + '!=' + '\'\''  +'  ';
            
            list<sObject> objList=Database.query(sQuery);
            
            for(sObject obj :objList)
                mapId.put((string)obj.get(prntField),(string) obj.get('Id'));
        }
        
        
        for(String line: bodyLines){
            if (StartIndex!=-1)
            {
            	if (!(StartIndex<=k && EndIndex>=k))
            	{
            		k++;
            		continue;
            	}
            }
            
            if(line.trim().length() == 0 || k==0){
                k++;
                continue;
            }
            
            k++;
            string lineWithKeyValue='';
            i=0;
            for(i=0 ;  i < (bodyLines[0].split(',').size()) ; i++ )
            {
                    lineWithKeyValue += bodyLines[0].split(',')[i] + ':' +line.split(',')[i] ;
                    if ( (i+1) !=(bodyLines[0].split(',').size())) 
                        lineWithKeyValue += ',';
            }
            
            lineWithKeyValue=lineWithKeyValue.replace('"','').replace('\r','');//.replace('\n','');
            lineWithKeyValue  ='object:' + NameSpace + tblName  + ',' + lineWithKeyValue ;
            SObject s = munch(lineWithKeyValue);
        }
        List<SObject> objs = objsToInsert.values();
        
        return objs;
    }
    
    private SObject munch(String s){
        SObject obj;
 		boolean AddRecord=true;
 		if (tblName=='Entity__c' || tblName=='Entity_Detail__c' || tblName=='Entity_Key__c'
 		 || tblName=='Entity_Mapping_Header__c' || tblName=='Entity_Fields_Mapping_Detail__c' 
 		 || tblName=='Entity_Fields_Map_Parent__c')
 			AddRecord=false;
 		 
        // Rearrange the CSV line into a list of string values
        List<string> keyValuePairs = s.split(',');
        String eId;
        for(String pairString: keyValuePairs){
            List<String> pairs = pairString.split(':');
            String key = pairs[0].trim();  
            String value=''; 
            if (pairs.size()>1)
                value= pairs[1].trim();  
 				
 				if(key=='NAME' && value.contains(ERPType) && tblName=='Entity__c')
            	{
            		AddRecord=true;
            	}
            	else if(key=='ENTITY_CODE__C' && value.contains(ERPType) && tblName=='Entity_Detail__c')
            	{
            		AddRecord=true;
            	}else if(key=='ENTITY_CODE__C' && value.contains(ERPType) && tblName=='Entity_Key__c')
            	{
            		AddRecord=true;
            	}else if(key=='NAME' && value.contains(ERPType) && tblName=='Entity_Mapping_Header__c')
            	{
            		AddRecord=true;
            	}else if(key=='Source_Entity__c' && value.contains(ERPType) && tblName=='Entity_Fields_Mapping_Detail__c')
            	{
            		AddRecord=true;
            	}else if(key=='Source_Entity__c' && value.contains(ERPType) && tblName=='Entity_Fields_Map_Parent__c')
            	{
            		AddRecord=true;
            	}
 			
 			if(key == 'object'){
                obj = createSObject(value);
                continue;
            } else if(key == prntField){
                if (value!='')
                {
                	//listOfReferenceFld.add(value);
                	//obj.put(chldField,(string) mapId.get(value)) ;
                	obj.put(chldField,(string) mapId.get(value.replace(ERPType,CompanyName+'-'))) ;
                	 
                }
                continue;
            } else if(key == chldField){ 
                continue;
            } else if( key == 'ID' ){
                eId = value;
                continue;
            } else {
            	
            	if ((key=='NAME' && tblName=='Entity_Mapping_Header__c') ||
                	(key=='NAME' && tblName=='Entity_Fields_Mapping_Detail__c')||
                	(key=='ENTITY_MAPPING_CODE__C' && tblName=='Entity_Fields_Mapping_Detail__c')||
                	(key=='LAST_SYNC_DATE__C') ||(key=='SCHEDULE_START__C') || 
                	(key=='Next_EMH_Id__c') || (key=='INTEGRATION_KEY__C') || 
                	(key=='PARENT_ENTITY_ID__C' && tblName=='Entity__c')  
                	)
                {
                	continue;
                }
                else if (key=='KEY_ORDER__C' || key== 'SIZE__C' || key== 'ORDER__C' )
                	obj.put(key, decimal.valueOf(value));
                	
                else if(key=='ISSYNCKEY__C' || key=='ISSTANDARDPB__C' || key=='ISSYNC__C' || key=='ACTIVE__C' )
                 obj.put(key, boolean.valueOf(value));
                else
                {
                	//TODO:Write logic to remove Sage300,Sage100,SageX3 to company name for the field and object  
                	if ((key=='TARGET_ENTITY__C' && tblName=='Entity_Mapping_Header__c') ||
                		(key=='TARGET_FIELD__C' && tblName=='Entity_Fields_Map_Parent__c') ||
                		(key=='PARENT_OBJECT_NAME__C' && tblName=='Entity_Fields_Map_Parent__c') ||
                		(key=='SALESFORCE_FIELD__C' && tblName=='Entity_Fields_Mapping_Detail__c')  )
                	{
                		if (value.contains('__C')||value.contains('__c'))
                		{               			
                			value=NameSpace+value;
                		}
                	}	
                	
                	if(key=='NAME' && value.contains(ERPType) && tblName=='Entity__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}
	            	else if(key=='ENTITY_CODE__C' && value.contains(ERPType) && tblName=='Entity_Detail__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}else if(key=='ENTITY_CODE__C' && value.contains(ERPType) && tblName=='Entity_Key__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}else if(key=='NAME' && value.contains(ERPType) && tblName=='Entity_Mapping_Header__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}else if(key=='Source_Entity__c' && value.contains(ERPType) && tblName=='Entity_Fields_Mapping_Detail__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}else if(key=='Source_Entity__c' && value.contains(ERPType) && tblName=='Entity_Fields_Map_Parent__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}else if(key=='Source_Entity__c' && value.contains(ERPType) && tblName=='Entity_Mapping_Header__c')
	            	{
	            		//value=value.replace(ERPType,CompanyName);
	            	}
                	
                	obj.put(key, value.replace(ERPType,CompanyName+'-'));
                }	
            }
        }
        try
        {
            obj.put('Integration_Key__c',IntgrtnKey);
        }
        catch(Exception ex)
        {
        }
        if (AddRecord==false)
        {
        	//Do nothoing
        }
        else if (chldField=='')
            objsToInsert.put(eId, obj);
        else
        {
            if ( obj.get(chldField) !=null)
            {
                if ( string.valueOf(obj.get(chldField)) !='')
                {
                    objsToInsert.put(eId, obj);
                }
            }
            
        }
        return obj;
    }
 
    // Helper that instantiates a generic SObject
    private SObject createSObject(String objectName){
        Schema.SObjectType t = Schema.getGlobalDescribe().get(objectName);
        SObject s = t.newSObject();
        return s;
    }
 
    private void fetchResource(String resourceName){
        try{
 
            theStaticResource = [SELECT id, Body FROM StaticResource WHERE name = :resourceName];
 
        }catch(System.QueryException e){
            System.debug(e);
            // You should always let the admins/devs know if
            // something unexpected happened.
            // e.g. ExceptionUtils.mail(Administrator);
        }
    }
    
    public void UpdateEntityFilters(string IntegrationKey,string CompanyCode)
    {
    	string jSonEntityFilter='';
    	if (Test.isRunningTest())
        {
               // string strDataPageDtlforCustomer = '[{"Sort_Order__c":"1","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":"InvoiceNo","Field_Label__c":"Invoice Number","Field_API__c":"InvoiceNo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":"Sage100ARInquiryDetails","Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"3","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Invoice Date","Field_API__c":"InvoiceDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"10","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Sales Order No.","Field_API__c":"SalesorderNo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"7","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Balance","Field_API__c":"Balance","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"5","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"InvoiceDueDate","Field_API__c":null,"ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"8","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Invoice Amount","Field_API__c":"InvoiceAmt","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"6","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Salesperson Name","Field_API__c":"SalespersonName","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"5","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Discount Amount","Field_API__c":null,"ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"10","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Customer PO No.","Field_API__c":"CustomerPONo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"2","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"OpenInvoices","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Invoice Type","Field_API__c":"InvoiceType","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100ARInquiry"},{"Sort_Order__c":"4","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Customer Type","Field_API__c":"CustomerType","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"8","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Price level","Field_API__c":"Pricelevel","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"6","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Print Dun message","Field_API__c":"PrintDunningmessage","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"7","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Batch Fax","Field_API__c":"BatchFax","ERP_System__c":"Sage100ERP","Data_Type__c":"Checkbox","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"1","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Comment","Field_API__c":"Comment","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"3","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Sort","Field_API__c":"Sort","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"11","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Finance Charge Rate(%)","Field_API__c":"ServiceChargeRate","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"12","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Temporary Customer","Field_API__c":"TemporaryCustomer","ERP_System__c":"Sage100ERP","Data_Type__c":"Checkbox","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"5","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Statement Cycle","Field_API__c":"StatementCycle","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"2","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Open Item Customer","Field_API__c":"OpenItemCustomer","ERP_System__c":"Sage100ERP","Data_Type__c":"Checkbox","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"9","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Additional","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Default Payment Type","Field_API__c":"DefaultPaymentType","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"2","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Customer Name","Field_API__c":"CustomerName","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"7","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Credit Limit","Field_API__c":"CreditLimit","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"9","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Ship Method","Field_API__c":"ShipMethod","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"6","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Credit Hold","Field_API__c":"CreditHold","ERP_System__c":"Sage100ERP","Data_Type__c":"Checkbox","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"4","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Tax Schedule","Field_API__c":"TaxSchedule","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"3","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"AR Division","Field_API__c":"ARDivisionNo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"1","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Customer Number","Field_API__c":"CustomerNo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"8","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Sales person","Field_API__c":"SalespersonName","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"5","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Main","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Terms Code","Field_API__c":"TermsCode","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"3","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Last Statement Date","Field_API__c":"LastStatementDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"10","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Date Established","Field_API__c":"DateEstablished","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"7","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Average Days to Pay","Field_API__c":"AvgDaysPaymentInvoice","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"11","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Date Of Last Activity","Field_API__c":"DateLastActivity","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"2","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Last Payment Amount","Field_API__c":"LastpaymentAmt","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"4","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Heighest Balance","Field_API__c":"HigheststmntBalance","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"5","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Last Finance Charge Date","Field_API__c":"LastFinanceChargeDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"9","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Average Days Overdue","Field_API__c":"AvgDaysOverDue","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"6","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Unpaid Finance Charges","Field_API__c":"UnpaidServicechrg","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"12","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Temporary Customer","Field_API__c":"TemporaryCustomer","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"1","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Last Payment Date","Field_API__c":"LastPaymentDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"8","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Statistics","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Price level","Field_API__c":null,"ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100Customer"},{"Sort_Order__c":"3","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Order Date","Field_API__c":"OrderDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"2","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Sales Order Type","Field_API__c":"OrderType","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"6","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Ship To","Field_API__c":"ShipToCode","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"7","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Order Amount","Field_API__c":"OrderAmt","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"8","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Last Invoice/Order","Field_API__c":"LastInvoiceOrderNo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"4","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Ship/Expiry Date","Field_API__c":"ShipExpireDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Date","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"5","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Customer Po","Field_API__c":"CustomerPONo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"1","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Orders","Key_Value__c":null,"Key_Field__c":"SalesOrderNo","Field_Label__c":"Sales Order No","Field_API__c":"SalesOrderNo","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":"Sage100SalesOrderDetails","Data_Page_Id__r.Name":"Sage100SalesOrder"},{"Sort_Order__c":"2","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Sales Summary","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Period To Date","Field_API__c":"YeartoPeriod","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesSummary"},{"Sort_Order__c":"1","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Sales Summary","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":null,"Field_API__c":"RowCaption","ERP_System__c":"Sage100ERP","Data_Type__c":"Text","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesSummary"},{"Sort_Order__c":"3","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Sales Summary","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Year To Date","Field_API__c":"YeartoDate","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesSummary"},{"Sort_Order__c":"4","Select_Field__c":"false","Data_Page_Section_Id__r.Section_Name__c":"Sales Summary","Key_Value__c":null,"Key_Field__c":null,"Field_Label__c":"Prior Year","Field_API__c":"PriorYear","ERP_System__c":"Sage100ERP","Data_Type__c":"Decimal","Link_To__r.Name":null,"Data_Page_Id__r.Name":"Sage100SalesSummary"}]';
            jSonEntityFilter='[{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3ImportProspect","Value__c":"2","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"}]';
        }
        else
    		jSonEntityFilter='[{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3ImportProspect","Value__c":"2","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3ImportCustomer","Value__c":"1","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3ProspectAddress","Value__c":"2","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3CustomerAddress","Value__c":"1","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3Shipping","Value__c":"1","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3Customer","Value__c":"1","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3Prospect","Value__c":"2","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3ProspectContact","Value__c":"2","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"},{"Entity_Mapping_Header_Id__r.Source_Entity__c":"SageX3CustomerContact","Value__c":"1","Operator__c":"equals","IsSync__c":"true","Field__c":"PPTFLG","Active__c":"true"}]';
        List<map<String,String>> RecordList=(List<map<String,String>>)JSON.deserializeStrict(jSonEntityFilter,List<map<String,String>>.class);
        
        list<Entity_Sync_Filteration__c> lstEntityFilter = new list<Entity_Sync_Filteration__c>();
        Entity_Sync_Filteration__c EntityFilter;
        integer cnt =1;
        
        //string IntegrationKey='a0O28000001alOrEAI';
        //string CompanyCode='SEED-TEST';
        
     	string EntityName='';
        string EntityNameTemp='';
        string EntityNameId='';
            
        for(map<String,String> Record :RecordList)
        {           
            EntityFilter = new Entity_Sync_Filteration__c();
            EntityName=Record.get('Entity_Mapping_Header_Id__r.Source_Entity__c');
            EntityName = CompanyCode+EntityName.replace('SageX3','-');
            
            system.debug('EntityName '+EntityName);
            
            if(EntityNameTemp ==  EntityName)
            	EntityFilter.put('Entity_Mapping_Header_Id__c',EntityNameId);
            else
            {            
                Entity_Mapping_Header__c EntityMappingHdrId =[select Id from Entity_Mapping_Header__c where Source_Entity__c=:EntityName and Integration_Key__c=:IntegrationKey limit 1];
                EntityNameId = string.valueOf(EntityMappingHdrId.Id);
                EntityFilter.put('Entity_Mapping_Header_Id__c',EntityNameId);
                EntityNameTemp=EntityName;
            }
            
            
            for(string key :Record.keyset())
            {                                  
                if(key =='IsSync__c' || key =='Active__c')
                { 
                    EntityFilter.put(key,boolean.valueof(Record.get(key)));
                }                            
                else
                {   
                	if(key !='Entity_Mapping_Header_Id__r.Source_Entity__c')    
                    	EntityFilter.put(key,Record.get(key));
                }
            }   
            lstEntityFilter.add(EntityFilter);
            if(math.mod(cnt,10) ==0)
            {       
                insert lstEntityFilter;
                system.debug('lstEntityMap '+lstEntityFilter);
                lstEntityFilter = new list<Entity_Sync_Filteration__c>();
            }
            cnt++;           
        }
        if(lstEntityFilter.size()>0)
        {
        	system.debug('lstEntityMap '+lstEntityFilter);
            insert lstEntityFilter;
        }
        
        
    }
   
   public void UpdateChainTo(string IntegrationKey,string CompanyCode,string ERPSystemName)
   {
   	// ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO,'CompanyCode'+CompanyCode));
   	 
   	 list<Entity_Mapping_Header__c> EntityMapList = [select Id,Name,Source_Entity__c  from Entity_Mapping_Header__c where Integration_Key__c =:IntegrationKey];
   	   	 
   	 string ChainToId=''; 
   	 // string EntityId='';
   	 string AccountIDs='';
   	 string ContactIDs='';
   	 string AddressIDs='';
   	 string ShipIDs=''; 
   	 
    if(EntityMapList.size()>0)
     {
     	map<string,string> chainToObject = new map<string,string>();  
     	for(Entity_Mapping_Header__c entity : EntityMapList)
     	{
     		if(ERPSystemName =='Sage100ERP')
     		{
     			if(entity.Source_Entity__c == CompanyCode+'-OrdersLines')
	     			chainToObject.put(CompanyCode+'-Order',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-Contact')
	     			chainToObject.put(CompanyCode+'-Customer',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-ShipTo')
	     			chainToObject.put(CompanyCode+'-Contact',entity.Id);
	     		
	     		//product
	     		else if(entity.Source_Entity__c == CompanyCode+'-Products')
	     			chainToObject.put(CompanyCode+'-ProductFamily',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntrySTD')
	     			chainToObject.put(CompanyCode+'-Products',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntry')
	     			chainToObject.put(CompanyCode+'-PricebookEntrySTD',entity.Id);
	     		
	     		//Dropdowns
	     		else if(entity.Source_Entity__c == CompanyCode+'-TaxClass')
	     			chainToObject.put(CompanyCode+'-UOM',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-Warehouse')
	     			chainToObject.put(CompanyCode+'-TaxClass',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-SalesPerson')
	     			chainToObject.put(CompanyCode+'-Warehouse',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-ShipVia')
	     			chainToObject.put(CompanyCode+'-SalesPerson',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-TermsCode')
	     			chainToObject.put(CompanyCode+'-ShipVia',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-PaymentType')
	     			chainToObject.put(CompanyCode+'-TermsCode',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-ARDivision')
	     			chainToObject.put(CompanyCode+'-PaymentType',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-ShipMethod')
	     			chainToObject.put(CompanyCode+'-ARDivision',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-TaxSchedule')
	     			chainToObject.put(CompanyCode+'-ShipMethod',entity.Id);
	     			
     		}
     		else if(ERPSystemName =='SageERPX3')
     		{
	     		if(entity.Source_Entity__c == CompanyCode+'-CustomerContact')
	     			chainToObject.put(CompanyCode+'-ImportCustomer',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-CustomerAddress')
	     			chainToObject.put(CompanyCode+'-CustomerContact',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-Shipping')
	     			chainToObject.put(CompanyCode+'-CustomerAddress',entity.Id);
	     		
	     		//Prospect	
	     		else if(entity.Source_Entity__c == CompanyCode+'-PropectContact')
	     			chainToObject.put(CompanyCode+'-ImportProspect',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-ProspectAddress')
	     			chainToObject.put(CompanyCode+'-PropectContact',entity.Id);
	     		
	     		//Product	
	     		else if(entity.Source_Entity__c == CompanyCode+'-Products')
	     			chainToObject.put(CompanyCode+'-ImportProduct',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntrySTD')
	     			chainToObject.put(CompanyCode+'-Products',entity.Id);
	 			else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntry')
	 				chainToObject.put(CompanyCode+'-PricebookEntrySTD',entity.Id);
	     		
	     		//Dropdown	
	     		else if(entity.Source_Entity__c == CompanyCode+'-Currency')
	     			chainToObject.put(CompanyCode+'-SyncDropdown',entity.Id);
	     		else if(entity.Source_Entity__c == CompanyCode+'-Language')
	     			chainToObject.put(CompanyCode+'-Currency',entity.Id);
	 			else if(entity.Source_Entity__c == CompanyCode+'-SalesPerson')
	 				chainToObject.put(CompanyCode+'-Language',entity.Id);
	 			else if(entity.Source_Entity__c == CompanyCode+'-Site')
	 				chainToObject.put(CompanyCode+'-SalesPerson',entity.Id);	
	     		else if(entity.Source_Entity__c == CompanyCode+'-TaxRule')
	 				chainToObject.put(CompanyCode+'-Site',entity.Id);
	 			else if(entity.Source_Entity__c == CompanyCode+'-TermsCode')
	 				chainToObject.put(CompanyCode+'-TaxRule',entity.Id);
	 			else if(entity.Source_Entity__c == CompanyCode+'-UOM')
	 				chainToObject.put(CompanyCode+'-TermsCode',entity.Id);
	 			
	 			//Sales order
	 			
	 			else if(entity.Source_Entity__c == CompanyCode+'-SalesOrderLines')
	     			chainToObject.put(CompanyCode+'-ImportSalesOrder',entity.Id);
     		}
			else
			{
			  //Customer
			  if(entity.Source_Entity__c == CompanyCode+'-Location')
				chainToObject.put(CompanyCode+'-Customer',entity.Id);
			else if(entity.Source_Entity__c == CompanyCode+'-Customer')
				chainToObject.put(CompanyCode+'-Location',entity.Id);
				
			 // Product	
			 
			else if(entity.Source_Entity__c == CompanyCode+'-Item')
				chainToObject.put(CompanyCode+'-ProductFamily',entity.Id);
			else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntrySTD')
				chainToObject.put(CompanyCode+'-Item',entity.Id);
			else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntry')
				chainToObject.put(CompanyCode+'-PricebookEntrySTD',entity.Id);
			/*else if(entity.Source_Entity__c == CompanyCode+'-ProductFamily')
				chainToObject.put(CompanyCode+'-PricebookEntry',entity.Id);	*/	
							
			//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO,'chainToObject'+chainToObject ));
				
			}
     			          		 	
     	}
     	
     	 
     	 //system.debug('chainToObject'+chainToObject);
     	
     	for(Entity_Mapping_Header__c entity : EntityMapList)
     	{
			if(ERPSystemName =='Sage100ERP')
     		{
     			if(entity.Source_Entity__c == CompanyCode+'-Order')	     			
	     			entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Order');
	     		else if(entity.Source_Entity__c == CompanyCode+'-Customer')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Customer');
				else if(entity.Source_Entity__c == CompanyCode+'-Contact')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Contact');
			
				//product
				 else if(entity.Source_Entity__c == CompanyCode+'-ProductFamily')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ProductFamily');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-Products')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Products');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntrySTD')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-PricebookEntrySTD');
				 }
				 
				 //Dropdowns
				 else if(entity.Source_Entity__c == CompanyCode+'-UOM')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-UOM');
				else if(entity.Source_Entity__c == CompanyCode+'-TaxClass')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-TaxClass');
				else if(entity.Source_Entity__c == CompanyCode+'-Warehouse')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Warehouse');
				else if(entity.Source_Entity__c == CompanyCode+'-SalesPerson')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-SalesPerson');
				else if(entity.Source_Entity__c == CompanyCode+'-ShipVia')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ShipVia');
				else if(entity.Source_Entity__c == CompanyCode+'-TermsCode')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-TermsCode');
				else if(entity.Source_Entity__c == CompanyCode+'-PaymentType')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-PaymentType');
				else if(entity.Source_Entity__c == CompanyCode+'-ARDivision')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ARDivision');
				else if(entity.Source_Entity__c == CompanyCode+'-ShipMethod')
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ShipMethod'); 
				 	     		
     		}
     		else if(ERPSystemName =='SageERPX3')
     		{
				if(entity.Source_Entity__c == CompanyCode+'-ImportCustomer')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ImportCustomer');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-CustomerContact')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-CustomerContact');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-CustomerAddress')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-CustomerAddress');
				 }
				 
				 //
				 else if(entity.Source_Entity__c == CompanyCode+'-ImportProspect')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ImportProspect');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-PropectContact')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-PropectContact');
				 }
				 
				 
				 //product
				 else if(entity.Source_Entity__c == CompanyCode+'-ImportProduct')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ImportProduct');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-Products')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Products');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntrySTD')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-PricebookEntrySTD');
				 }
				 
				 //DropDown
				 
				 else if(entity.Source_Entity__c == CompanyCode+'-SyncDropdown')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-SyncDropdown');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-Currency')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Currency');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-Language')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Language');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-SalesPerson')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-SalesPerson');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-Site')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Site');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-TaxRule')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-TaxRule');
				 }
				 else if(entity.Source_Entity__c == CompanyCode+'-TermsCode')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-TermsCode');
				 }
				 
				 //Salesorder
				 else if(entity.Source_Entity__c == CompanyCode+'-ImportSalesOrder')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ImportSalesOrder');
				 }
     		}
			else
			{
			// ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO,'EntityMapList'+JSON.serialize(EntityMapList)));
			// Customer
			  if(entity.Source_Entity__c == CompanyCode+'-Customer')
				 {
					entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Customer');
				 }
			//Product
				else if(entity.Source_Entity__c == CompanyCode+'-ProductFamily')
				{
				  entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-ProductFamily');
				}
				else if(entity.Source_Entity__c == CompanyCode+'-Item')
				{
				  entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-Item');
				}
				else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntrySTD')
				{
				  entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-PricebookEntrySTD');
				}
				/*else if(entity.Source_Entity__c == CompanyCode+'-PricebookEntry')
				{
				  entity.Next_EMH_Id__c = chainToObject.get(CompanyCode+'-PricebookEntrySTD');
				}*/
				
				
			}
			 		 
		}			
     	//update EntityMapList;
     }
    // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.INFO,'EntityMapList'+JSON.serialize(EntityMapList)));
     update EntityMapList;                                 
   }
    
}
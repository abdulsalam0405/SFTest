public with sharing class ConfigurationController
{
    public string ServiceURL {get; set;} 
    public string parameter {get; set;}
    public static BaseIntegrationFramework oFramework ;
    public list<ERP> SageERPs {get;set;}
    public ERP_Config__c oConfiguration{get;set;}
    public list<ERP_Config__c> oConfigurationList{get;set;}
    public String ERPSystem{get;set;}
    public String ConfigObjectPrefix{get;set;}
    public Date UpdateDate {get;set;}
    public String ERPName {get; set;}
    public List<SelectOption> ERPOptions {get;set;}
    public static String ERPXMLJson {get;set;} 
    public Boolean bAdministration{get;set;}
    public String NameSpace {get;set;} 
    public String IntegrationNames {get;set;} 
    public String ProfileName {get;set;} 
    
    public String IntegrationKey {get;set;}
    public String ERPCompanyCode {get;set;}
    public Boolean isSelected{get;set;}
    public string gIntegrationInfo{get;set;}    
    public String ERPConfigDetail {get;set;}
    
    // PROPERTIES FOR TEST CONNECTION
    public string WebServiceURL {get;set;}
    public string ConParams{get;set;}   
    public String ERPSystemName {get;set;}
    public String PageAction {get;set;}
    public String ConfigurationId {get;set;}
    public String ConfigurationInfo {get;set;}
    
    // render buttons
    public Boolean bTestConnection{get;set;}
    public Boolean bEdit{get;set;}
    public Boolean bCancel{get;set;}
    public Boolean bSave{get;set;}
    public integer ImportDatastep{get;set;}
    
   public Boolean shouldDisable{get;set;}

   public String pageMode{get;set;} 

    public ConfigurationController(ApexPages.StandardController controller) 
    {       
        oFramework = IntegrationFactory.getIntegrationFramework();
        parameter='';
        ServiceURL ='';
        if(UserInfo.getProfileId() != '' && UserInfo.getProfileId() != null) 
        {
            // Check if the user has read access on the Profile.name
            if (Schema.sObjectType.Profile.fields.name.isAccessible()) {
                ProfileName = [select name from profile where id =: UserInfo.getProfileId() limit 1].name;
            }
        }
        Security_Matrix__c SM = Security_Matrix__c.getInstance();
        bAdministration = Boolean.valueOf(SM.GUMU_Administration__c);
        ERPName='';
        ERPOptions = new List<SelectOption>();
        ERPOptions.add(new SelectOption(String.escapeSingleQuotes(''),'None'));       
       // oConfiguration = (ERP_Config__c)controller.getRecord();
        
        
        string ConID= ApexPages.currentPage().getParameters().get('Id');
        pageMode= ApexPages.currentPage().getParameters().get('Mode');
        
        if(pageMode =='View')
        {
            bTestConnection = false;
            bEdit = true;
            bCancel = true;
            bSave = false;
            shouldDisable = true;
            
        }
        else if(pageMode =='Edit')
        {
            bTestConnection=true;
            bEdit = false;
            bCancel = true;
            bSave = true;
            shouldDisable = false;            
        }
        else
        {
            bTestConnection = true;
            bEdit = false;
            bCancel = true;
            bSave = true;
            shouldDisable = false;
        }

        oConfigurationList = [SELECT Id,ERP_System__c,Web_Service_URL__c,Synchronization__c,Integration_Information__c,
                                Integration_Information_2__c,Integration_Information_3__c,Name,Inactive__c, Default__c 
                                FROM ERP_Config__c where Id=:ConID limit 1 ];
                                
        LoadParams();
        if(oConfigurationList.size() >0)
        {
            oConfiguration = oConfigurationList[0];            
            ERPSystem = oConfiguration.ERP_System__c;
            RequiredComapnyParams();
        }
        else  
            oConfiguration = new ERP_Config__c();
                                
    }    

   
    public PageReference enableButtons()
    {      
        string configId = ApexPages.currentPage().getParameters().get('id');        
        PageReference pageRef = new PageReference('/apex/Configuration?id='+configId+'&Mode=Edit');       
        pageRef.getParameters().put('id',configId);
        pageRef.setRedirect(true);
        return pageRef ;
    }
   
    private static String getResourceContent(String staticResourceName)
    {
        // Check if the user has read access on the StaticResource.Bodyfield
        if (!Schema.sObjectType.StaticResource.fields.Body.isAccessible()){
            return '';
        }
        StaticResource sr = [select Body from StaticResource where Name = :staticResourceName];
        return sr.Body.toString();
    }

    /*
     *  Returns all the configurations save in the configuration object.
     */
    public list<ERP_Config__c> getAvailableERPs() 
    {
        list<ERP_Config__c> ERPs= [SELECT Id,ERP_System__c,Web_Service_URL__c,Synchronization__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c,Name,Inactive__c, Default__c FROM ERP_Config__c limit 200];
        ReadAndWriteXML.XmlNode objXmlNode;
        for(ERP_Config__c ERP : ERPs)
        {
            string IntegrationInfo  = '';
            IntegrationInfo += string.isNotBlank(ERP.Integration_Information__c) ? ERP.Integration_Information__c : '';

            if(string.isNotBlank(ERP.Integration_Information_2__c))
            { 
                if(ERP.Integration_Information_2__c.startsWith('NAME') || ERP.Integration_Information_2__c.startsWith('VALUE'))
                    IntegrationInfo += ' ';
            }   
            IntegrationInfo += string.isNotBlank(ERP.Integration_Information_2__c) ? ERP.Integration_Information_2__c : '';
            if(string.isNotBlank(ERP.Integration_Information_3__c))
            { 
                if(ERP.Integration_Information_3__c.startsWith('NAME') || ERP.Integration_Information_3__c.startsWith('VALUE'))
                    IntegrationInfo += ' ';
            } 
            IntegrationInfo += string.isNotBlank(ERP.Integration_Information_3__c) ? ERP.Integration_Information_3__c : '';

            objXmlNode = ReadAndWriteXML.ParseXmlString(IntegrationInfo);
            list<ReadAndWriteXML.XmlNode> lstParams = objXmlNode.ChildXmlNodes;
            string generateXML='<PARAMS>';
            for(ReadAndWriteXML.XmlNode Param : lstParams)
            {
                string AttrName = param.Attributes.get('NAME');
                string AttrValue = param.Attributes.get('VALUE');

                if(AttrName == 'Password' || AttrName == 'WindowsPassword')
                {
                    string EncryptPassword='';
                    if(AttrValue !='' && AttrValue != null)
                        EncryptPassword=Utility.Decrypt(AttrValue);                                    
                    generateXML +='<PARAM NAME="'+AttrName+'"  VALUE="'+EncryptPassword+'" />';
                }
                else
                    generateXML +='<PARAM NAME="'+AttrName+'"  VALUE="'+AttrValue+'" />';                   
            }
            generateXML +='</PARAMS>';

            ERP.Integration_Information__c = generateXML;
            gIntegrationInfo = generateXML;
        }
        IntegrationNames = JSON.Serialize(ERPs);

        return ERPs;
    }

    /*
     * Returns true if configuration exists in salesforce else false
     */
    public Boolean getIsERPConfigSettingExist() 
    {
        list<ERP_Config__c > ERPs=getAvailableERPs();

        if (ERPs.size()>0) 
            return true;            
        else 
            return false;
    }

    /*
     * Prepares the various configuration settings for all the ERP systems provided by the product  
     */
    public void LoadParams()
    {
        string XMLContent=getResourceContent('ParamConfig');

        list<ERP> ERPs =new list<ERP>(); 

        ReadAndWriteXML.XmlNode objXmlNode = ReadAndWriteXML.ParseXmlString(XMLContent);
        list<ReadAndWriteXML.XmlNode> lstNodes = objXmlNode.ChildXmlNodes;

        for(ReadAndWriteXML.XmlNode Node : lstNodes)
        {
            ERP currentERP=new ERP();
            string ERPName= String.escapeSingleQuotes(Node.Attributes.get('NAME'));
            ERPOptions.add(new SelectOption(ERPName,ERPName));
            currentERP.ERPName =ERPName;
            list<Param>currentERPParams=new list<Param>();

            list<ReadAndWriteXML.XmlNode> ParamNodes =Node.ChildXmlNodes[0].ChildXmlNodes;
            for(ReadAndWriteXML.XmlNode ParamNode: ParamNodes )
            {
                Param ERPParam=new Param();
                ERPParam.ParamName=ParamNode.NodeValue;
                ERPParam.ParamCode=ParamNode.Attributes.get('CODE');
                ERPParam.Length=string.isBlank(ParamNode.Attributes.get('LENGTH')) ? 0 : Integer.valueOf(ParamNode.Attributes.get('LENGTH'));
                ERPParam.Width=string.isBlank(ParamNode.Attributes.get('WIDTH')) ? 0 : Integer.valueOf(ParamNode.Attributes.get('WIDTH'));
                ERPParam.Required = ParamNode.Attributes.get('REQUIRED') == 'TRUE' ? true : false;

                ERPParam.ParamType=ParamNode.Attributes.get('TYPE');
                if (! string.isBlank(ParamNode.Attributes.get('OPTIONS')))
                    ERPParam.Options= ParamNode.Attributes.get('OPTIONS').split(',');
                currentERPParams.add(ERPParam);                
            }
            currentERP.Params=currentERPParams;
            ERPs.add(currentERP);
        }
        ERPXMLJson=JSON.serialize(ERPs);
        SageERPs=ERPs;
         
    }

   //Returns the page block section component to be displayed for connection setting according to the ERP system selected  
   public PageReference RequiredComapnyParams() 
    {
        string SelectedERP = ERPSystem;     
        string  integartionInfo1 = string.isBlank(oConfiguration.Integration_Information__c) ? '' : oConfiguration.Integration_Information__c;
        string  integartionInfo2 = string.isBlank(oConfiguration.Integration_Information_2__c) ? '' : oConfiguration.Integration_Information_2__c;
        string  integartionInfo3 = string.isBlank(oConfiguration.Integration_Information_3__c) ? '' : oConfiguration.Integration_Information_3__c;
        
        string integartionInfo = integartionInfo1+ integartionInfo2+integartionInfo3;
        map<string,string> integartionInfoMap = new map<string,string>();  
        integartionInfoMap = Utility.FormatConnectionPairs(integartionInfo);
        
        //Pgae Block Section
        string HTMLContent='';
        HTMLContent+='<table class="detailList" id="tblParams" name="tblParams" border="0" cellpadding="0" cellspacing="0">';
        HTMLContent+='<tbody>';      

        for(ERP SageERP: SageERPs)
        {                   
            if(SageERP.ERPName==SelectedERP)
            {
                for(Param P : SageERP.Params)
                {
                     HTMLContent +='<tr>';
                     HTMLContent +='<th class="labelCol vfLabelColTextWrap  first " scope="row" ><label>'+P.ParamName+'</label></th>';
                    
                    //Create component for parameter input
                    if(P.ParamType=='TEXT')
                    {
                        if(integartionInfoMap.get(P.ParamCode) == null)
                        {
                        	if(P.ParamCode =='poolAlias' || P.ParamCode =='poolId')
                        		HTMLContent+='<td class="data2Col first"><div class="requiredInput"><div class="requiredBlock"></div><input required="required" id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'" class="conparam" style="width:'+P.Width+'px" ></div></td>';
                        	else
                        		HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'" class="conparam" style="width:'+P.Width+'px" ></td>';
                        }
                        else
                        {
                        	if(P.ParamCode =='poolAlias' || P.ParamCode =='poolId')
                        		HTMLContent+='<td class="data2Col first"><div class="requiredInput"><div class="requiredBlock"></div><input required="required" id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'" class="conparam" style="width:'+P.Width+'px" value="'+integartionInfoMap.get(P.ParamCode)+'"></div></td>';
                        	else
                        		HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'" class="conparam" style="width:'+P.Width+'px" value="'+integartionInfoMap.get(P.ParamCode)+'"></td>';
                        	
                            
                        }
                    }
                    else if(P.ParamType=='PICKLIST')
                    {
 
                    }
                    else if(P.ParamType=='PASSWORD')
                    {
                        HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="password" name="'+P.ParamCode+'"  class="conparam" style="width:'+P.Width+'px" ></td>';
                    }
                    else if(P.ParamType=='NUMBER')
                    {
                        if(integartionInfoMap.get(P.ParamCode) == null)
                            HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'"  class="conparam" style="width:'+P.Width+'px" ></td>';
                        else
                            HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'"   class="conparam" style="width:'+P.Width+'px" value="'+integartionInfoMap.get(P.ParamCode)+'"></td>';
                    }
                    else
                    {
                        if(integartionInfoMap.get(P.ParamCode) == null)
                            HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'"  class="conparam" style="width:'+P.Width+'px" ></td>';
                        else
                            HTMLContent+='<td class="data2Col first"><input  id="'+P.ParamCode+'" maxlength="'+P.Length+'" type="text" name="'+P.ParamCode+'"  class="conparam" style="width:'+P.Width+'px" value="'+integartionInfoMap.get(P.ParamCode)+'"></td>';                      
                    }
                    HTMLContent+='</tr>';
                }
            }
        }
         HTMLContent +='</tbody>';  
         HTMLContent +='</table>';
        //HTMLContent +='</div>';
        // HTMLContent +='</div>';
        
        ERPConfigDetail  =HTMLContent;
        return null;    
    }
    
    public boolean ImportError = false;
    public string ImportErrorMessage = '';
    public PageReference CreatePostInstallData()
    {   
        string CompanyName; 
        
        if(ImportDatastep ==1)
        {
            ImportError = false;
        }
        
        list<Entity__c> objEntity=[select Id from Entity__c where Integration_key__c =: oConfigurationList[0].Id  limit 1];
        
        CompanyName=oConfigurationList[0].Name; 
        
        if (objEntity.size()>0 && ImportDatastep ==1)
        {
            ImportErrorMessage='Default data already exist for this integration.';
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning,ImportErrorMessage));
            ImportError =true;
            return null; 
        }
        if (ImportError == true)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Warning,ImportErrorMessage));
            return null; 
        }
        
        string ERPType='';
        if(oConfiguration.ERP_System__c =='SageERPX3')  
        {   
            oFramework = new SageX3IntegrationFramework();
            ERPType='SageX3';
        }    
        else if(oConfiguration.ERP_System__c =='Sage100ERP')
        {
            oFramework = new Sage100IntegrationFramework();
            ERPType='Sage100';
        }    
        else if(oConfiguration.ERP_System__c =='Sage300ERP')
        {
            oFramework = new Sage300IntegrationFramework();
            ERPType='Sage300';
        }  
         
        try
            {     
                    CsvToSObjectParser ctop ;
                    List<SObject> objects ;
                    if (ImportDatastep ==1)
                    {
                        //Insert Entity
                        //          CsvToSObjectParser(resourceName,IntegrationKey          ,tableName  ,parentObject , parentField      , childField,ERPType)
                        ctop = new  CsvToSObjectParser('Entity'    ,oConfigurationList[0].Id,'Entity__c',''           , ''               , '',ERPType,0,100000,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of Entity inserted:'+objects.size()));
                         
                    }
                    
                    if (ImportDatastep ==2)
                    {
                        //Insert Entity Detail1
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,0,400,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED1 inserted:'+objects.size()));
                     
                    }
                    
                    if (ImportDatastep ==3)
                    {
                        //Insert Entity Detail2
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,401,800,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED2 inserted:'+objects.size()));
                         
                    }
                    
                    if (ImportDatastep ==4)
                    {   
                        //Insert Entity Detail3
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,801,1200,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED3 inserted:'+objects.size()));
                        
                    }
                    
                    if (ImportDatastep ==5)
                    {
                        //Insert Entity Detail4
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,1201,1600,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED4 inserted:'+objects.size()));
                         
                    }    
                    
                    if (ImportDatastep ==6)
                    {   //Insert Entity Detail5
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,1601,2000,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED5 inserted:'+objects.size()));
                    }
                    if (ImportDatastep ==7)
                    {   //Insert Entity Detail6
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,2001,2400,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED5 inserted:'+objects.size()));
                    }
                    if (ImportDatastep ==8)
                    {   //Insert Entity Detail7
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,2401,2800,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED5 inserted:'+objects.size()));
                    }
                    if (ImportDatastep ==9)
                    {   //Insert Entity Detail8
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,2801,3200,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED5 inserted:'+objects.size()));
                    }
                    if (ImportDatastep ==10)
                    {   //Insert Entity Detail9
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,3201,3600,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED5 inserted:'+objects.size()));
                    }
                    if (ImportDatastep ==11)
                    {   //Insert Entity Detail10
                        ctop = new CsvToSObjectParser('EntityDetail',oConfigurationList[0].Id,'Entity_Detail__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,3601,32786,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of ED5 inserted:'+objects.size()));
                    }
                    
                    if (ImportDatastep ==12)
                    {     
                        //Insert Entity Key
                        ctop = new CsvToSObjectParser('EntityKey',oConfigurationList[0].Id,'Entity_Key__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,0,100000,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of EntityKey inserted:'+objects.size()));
                    }
                    
                    if (ImportDatastep ==13)
                    {    
                        //Insert Entity mapping Header
                        ctop = new CsvToSObjectParser('EntityMappingHdr',oConfigurationList[0].Id,'Entity_Mapping_Header__c','Entity__c','Entity_Code__c','Entity_Id__c',ERPType,0,200000,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of EntityMappingHdr inserted:'+objects.size()));
                    }
                                        
                    if (ImportDatastep ==14)
                    {   
                        //Insert Entity mapping Detail
                        ctop = new CsvToSObjectParser('EntityMappingDtl',oConfigurationList[0].Id,'Entity_Fields_Mapping_Detail__c','Entity_Mapping_Header__c','Source_Entity__c','Entity_Mapping_Id__c',ERPType,0,100000,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of EntityMappingDtl inserted:'+objects.size()));
                    }
                    
                    if (ImportDatastep ==15)
                    {   
                        //Insert Entity mapping parent
                        ctop = new CsvToSObjectParser('EntityMappingParent',oConfigurationList[0].Id,'Entity_Fields_Map_Parent__c','Entity_Mapping_Header__c','Source_Entity__c','Entity_Fields_Map_Header_Id__c',ERPType,0,100000,CompanyName);
                        objects = ctop.parseCsv();
                        insert objects;
                        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'No. of EntityMappingParent inserted:'+objects.size()));
                        
                        
                        if(oConfigurationList[0].ERP_System__c=='SageERPX3')
                        {
                        	 ctop.UpdateEntityFilters(oConfigurationList[0].Id,CompanyName);
                             ctop.UpdateChainTo(oConfigurationList[0].Id,CompanyName,oConfigurationList[0].ERP_System__c);
                        }
                        else if(oConfigurationList[0].ERP_System__c=='Sage100ERP')
                        	ctop.UpdateChainTo(oConfigurationList[0].Id,CompanyName,oConfigurationList[0].ERP_System__c);
                        else if(oConfigurationList[0].ERP_System__c=='Sage300ERP')	
                        	ctop.UpdateChainTo(oConfigurationList[0].Id,CompanyName,oConfigurationList[0].ERP_System__c);	
                        
                    }
                    
                    if(ImportDatastep ==15)
                    {
                        if(oConfigurationList[0].ERP_System__c=='SageERPX3')
                        {
                            updateParentEntity(CompanyName,oConfigurationList[0].Id);
                            //UpdateChainTo(CompanyName,oConfigurationList[0].Id);
                        }
                            
                        runInstallScript(oConfigurationList[0].Id,oConfigurationList[0].ERP_System__c);
                        
                        updateDataPageEntitySage(oConfigurationList[0].Id,oConfigurationList[0].ERP_System__c, CompanyName);
                    }
                                    
                    
            }
            catch(Exception ex)
            {
                ImportError=true;
                ImportErrorMessage+= 'Error:'+ex + '\n'+ ex.getStackTraceString();
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'Error:'+ex));
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'Error Detail:'+ ex.getStackTraceString()));
            }
        
        
        
        ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'Imported '+ ImportDatastep + ' of 15.' ));
        
        return null;
    }
    
    private void updateParentEntity(string CompanyName, string ConfigId)
    {
        list<Entity__c> EntityList = [select Id,Name,Parent_Entity_Id__c,Entity_Detail_Id__c
                                      from Entity__c where Integration_Key__c =:ConfigId];
        string EntityCustListId='';
        string EntitySOListId='';
        string masterFieldCustId='';
        string masterFieldSOId='';
        if(EntityList.size()>0)
        {
            for(Entity__c entity:EntityList)
            {
                if(entity.Name == CompanyName+'-CutomerList' || entity.Name == CompanyName+'-OrderList')
                {                   
                    list<Entity_Detail__c> Entity_DetailList = [select Id ,name,Entity_Id__c from Entity_Detail__c 
                                                                where Entity_Id__c =:entity.Id] ;
                    
                    if(entity.Name == CompanyName+'-CutomerList')
                        EntityCustListId = entity.Id;
                    else if(entity.Name == CompanyName+'-OrderList')
                        EntitySOListId = entity.Id;
                    
                    if(Entity_DetailList.size()>0)
                    {
                        for(Entity_Detail__c EntityDetail:Entity_DetailList)
                        {
                            if(EntityDetail.Name == 'Customer')
                                masterFieldCustId = EntityDetail.Id;
                            else if(EntityDetail.Name == 'Order no.')
                                masterFieldSOId = EntityDetail.Id;
                        }                   
                    }
                }
            }
            
            for(Entity__c entity:EntityList)
            {
                if(entity.Name == CompanyName+'-CutomerHeader' || entity.Name == CompanyName+'-CustomerContact'||entity.Name == CompanyName+'-CustomerAddress' ||entity.Name == CompanyName+'-CustomerShipping'
                        || entity.Name == CompanyName+'-ProspectContact' ||entity.Name == CompanyName+'-ProspectHeader'||entity.Name == CompanyName+'-ProspectAddress')
                {
                    entity.Parent_Entity_Id__c =EntityCustListId;
                    entity.Entity_Detail_Id__c =masterFieldCustId;
                }
                else if(entity.Name == CompanyName+'-OrderHeader' ||entity.Name == CompanyName+'-OrderLine')
                {
                    entity.Parent_Entity_Id__c =EntitySOListId;
                    entity.Entity_Detail_Id__c =masterFieldSOId;
                }
            }
        }
               
        update EntityList;
    }
    
    public void runInstallScript(string IntegrationKey,string ERPSystemName)
    {
            
        if(ERPSystemName == 'SageERPX3')
        {
            InstallScriptSageX3 sageX3 = new InstallScriptSageX3(IntegrationKey);
        }
        else if(ERPSystemName == 'Sage100ERP')
        {
            InstallScriptSage100 sage100 = new InstallScriptSage100(IntegrationKey);
        }
        else if(ERPSystemName == 'Sage300ERP')
        {
            InstallScriptSage300 sage300 = new InstallScriptSage300(IntegrationKey);
        }
    }
    
    public void updateDataPageEntitySage(string IntegrationKey,string ERPSystemName,string CompanyName)
    {
    
        list<Data_Page__c> DataPageLst;
        DataPageLst =[select Id,Name,Entity_Id__c from Data_Page__c where  Integration_Key__c=:IntegrationKey];
        
        list<Entity__c> EntityList = [select Id,Name,Parent_Entity_Id__c,Entity_Detail_Id__c
                                      from Entity__c where Integration_Key__c =:IntegrationKey];
        if(DataPageLst.size()>0)
        {
            for(Data_Page__c DataPage:DataPageLst)
            {
                string datapageName = DataPage.Name;
                
                for(Entity__c Entity:EntityList)
                {
                    if(ERPSystemName =='Sage300ERP')
                    {
                        if(Entity.Name == CompanyName+'-Customer' && datapageName =='Customer')
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if(Entity.Name == CompanyName+'-SalesOrderHeader' && (datapageName =='SalesOrder'||datapageName =='Sales_Order_Details'))
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if(Entity.Name == CompanyName+'-ARInquiry' && (datapageName =='ARInquiry' ||datapageName =='Invoice_Detail'))
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if(Entity.Name == CompanyName+'-Item' && datapageName =='Product_Detail')
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                    }
                    else if(ERPSystemName =='SageERPX3')
                    {
                        if(Entity.Name == CompanyName+'-CutomerHeader' && datapageName =='Customer')
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if(Entity.Name == CompanyName+'-OrderHeader' && (datapageName =='SalesOrder'||datapageName =='SalesOrderLineItem' ||datapageName =='SalesOrderDetail'))
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if(Entity.Name == CompanyName+'-Inquiry' && (datapageName =='ARInquiry' ||datapageName =='ARInquiryDetails' ))
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if(Entity.Name == CompanyName+'-Shipment' && (datapageName =='Shipment' ||datapageName =='ShipmentDetails'||datapageName =='ShipmentLineItem'))
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        else if((Entity.Name == CompanyName+'-Quotes'|| Entity.Name == CompanyName+'-Qoutes') && (datapageName =='QuoteInquiry' ||datapageName =='QuoteDetails' ||datapageName =='QuoteLineItem'))
                        {
                            DataPage.Entity_Id__c = Entity.Id;
                        }
                        
                    }
                }
            }
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'DataPageLst '+ DataPageLst));
            update DataPageLst;
        }
        
        
    }
            
    
   public PageReference TestConnection()
    {   
       
        string ERPType='';
        list<string> ParamPairs =  (list<string>)JSON.deserialize(ConParams, list<string>.class);

        
        if(oConfiguration.ERP_System__c =='SageERPX3')  
        {   
            oFramework = new SageX3IntegrationFramework();
            ERPType='SageX3';
        }    
        else if(oConfiguration.ERP_System__c =='Sage100ERP')
        {
            oFramework = new Sage100IntegrationFramework();
            ERPType='Sage100';
        }    
        else if(oConfiguration.ERP_System__c =='Sage300ERP')
        {
            oFramework = new Sage300IntegrationFramework();
            ERPType='Sage300';
        }    
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'WebServiceURL - '+WebServiceURL));
        boolean result= oFramework.TestConnection(WebServiceURL, ParamPairs);
    
        if(PageAction == 'Test&Save' && result)
        {
            map<String,Object> ConfigurationInfoMap  = new map<String,Object>();
            if (Test.isRunningTest())
            {
                ConfigurationInfoMap.put('CompanyCode','SEED');
                ConfigurationInfoMap.put('IntegrationInformation','<PARAMS><PARAM NAME="poolAlias" VALUE="SEED"/><PARAM NAME="codeUser" VALUE="ADMIN"/><PARAM NAME="password" VALUE=""/><PARAM NAME="poolId" VALUE="SEED"/><PARAM NAME="codeLang" VALUE="ENG"/><PARAM NAME="version" VALUE="171"/></PARAMS>');                
            }
            else
               {
                ConfigurationInfoMap= (map<string,object>)JSON.deserializeUntyped(ConfigurationInfo);
                
                }
            
                boolean saveResult =CRUDConfig(ConfigurationId,PageAction,ConfigurationInfoMap);
                
            if(saveResult)
            {
                
                
                 String fullFileURL = URL.getSalesforceBaseUrl().toExternalForm();
                 PageReference rPage = new PageReference(fullFileURL+'/apex/Configurationlist');
                 rPage.setRedirect(true);
                 return rPage;
                 //return null;
            }
            else
                return null;
        }
        
        if(result)
        {
            try
            {   
                  ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'Connection Successful'));
            }
            catch(Exception ex)
            {
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'Error:'+ex));
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Fatal,'Error Detail:'+ ex.getStackTraceString()));
            }
         }
         else
            ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error,'Connection Failed.'));//Please Provide the correct details
        
        
        return null;
    }

    /*private static boolean TestConnection_X3(String EndPoint, list<String> ParamPairs,String source)
    {
        return null;
    }*/
   
    //Remote action method to get configuration record
    @RemoteAction
    public static configuration FetchConfig (String IntegrationKey)
    {
        ERP_Config__c cfg;
        
        system.debug('IntegrationKey '+IntegrationKey);
        
        cfg=[SELECT id,Name,ERP_Customer_Last_Sync_Date__c,Inactive__c,Web_Service_URL__c,ERP_System__c,ERP_Company_Code__c,
             Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c, Default__c, ERP_Product_Last_Sync_Date__c 
             FROM ERP_Config__c 
             Where id=: IntegrationKey limit 1];

        configuration config =new configuration();

        config.Id=cfg.id;
        config.Name=cfg.Name;
        config.WebServiceURL=cfg.Web_Service_URL__c;

        String IntInfo= String.isNotBlank(cfg.Integration_Information__c) ? cfg.Integration_Information__c : ''; 
        if(string.isNotBlank(cfg.Integration_Information_2__c))
        { 
            if(cfg.Integration_Information_2__c.startsWith('NAME') || cfg.Integration_Information_2__c.startsWith('VALUE'))
                IntInfo += ' ';
        }  

        IntInfo += String.isNotBlank(cfg.Integration_Information_2__c) ? cfg.Integration_Information_2__c : '';

        if(string.isNotBlank(cfg.Integration_Information_3__c))
        { 
            if(cfg.Integration_Information_3__c.startsWith('NAME') || cfg.Integration_Information_3__c.startsWith('VALUE'))
                IntInfo += ' ';
        }

        IntInfo += String.isNotBlank(cfg.Integration_Information_3__c) ? cfg.Integration_Information_3__c : '';

        config.IntegrationInformation=IntInfo;
        config.DefaultIntegration=cfg.Default__c;
        config.Inactive=cfg.Inactive__c;
        config.ERPSystem=cfg.ERP_System__c;
        config.CustomerLastSyncDate=cfg.ERP_Customer_Last_Sync_Date__c;
        config.ProductLastSyncDate = cfg.ERP_Product_Last_Sync_Date__c;
        config.CompanyCode=cfg.ERP_Company_Code__c;

        return config;
    }

    //Remote action method to get configuration record
    //@RemoteAction
    public boolean CRUDConfig(String IntegrationKey,string Action,map<String,object> Info)
    {
        try
        {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'IntegrationInformation '+info.get('IntegrationInformation')));
            
            ERP_Config__c cfg=new ERP_Config__c();
            ReadAndWriteXML.XmlNode objXmlNode;
    
            string IntegrationInformation = (string)info.get('IntegrationInformation');
            objXmlNode = ReadAndWriteXML.ParseXmlString(IntegrationInformation);
            list<ReadAndWriteXML.XmlNode> lstParams = objXmlNode.ChildXmlNodes;
            string generateXML='<PARAMS>';
            for(ReadAndWriteXML.XmlNode Param : lstParams)
            {
                string AttrName = param.Attributes.get('NAME');
                string AttrValue = param.Attributes.get('VALUE');
    
                if(AttrName == 'Password' || AttrName == 'WindowsPassword')
                {
                    string EncryptPassword='';
                    if(AttrValue !='' && AttrValue != null)
                        EncryptPassword=Utility.Encrypt(AttrValue);
    
                    generateXML +='<PARAM NAME="'+AttrName+'"  VALUE="'+EncryptPassword+'" />';
                }
                else
                    generateXML +='<PARAM NAME="'+AttrName+'"  VALUE="'+AttrValue+'" />';
            }
            generateXML +='</PARAMS>';
                            
            if(String.isNotBlank(IntegrationKey))
                cfg.id=IntegrationKey;
    
                       
                cfg.Name=(string)Info.get('Name');
                cfg.Web_Service_URL__c=(string)Info.get('WebServiceURL');
    
                //String IntInfo=String.valueOf(Info.get('IntegrationInformation'));
                String IntInfo=generateXML;
                Integer InfoLength = IntInfo.length();
    
                if(InfoLength > 510)
                {
                    cfg.Integration_Information__c = IntInfo.substring(0,255);
                    cfg.Integration_Information_2__c = IntInfo.substring(255,510);
                    cfg.Integration_Information_3__c = IntInfo.substring(510,InfoLength);                 
                }
                else if(InfoLength > 255)
                {
                    cfg.Integration_Information__c = IntInfo.substring(0,255);
                    cfg.Integration_Information_2__c = IntInfo.substring(255,InfoLength);
                    cfg.Integration_Information_3__c = '';                                     
                }
                else if(InfoLength > 0)
                {
                    cfg.Integration_Information__c = IntInfo;
                    cfg.Integration_Information_2__c = '';
                    cfg.Integration_Information_3__c = '';
                }
                
                
                cfg.Inactive__c=Boolean.valueOf(Info.get('Inactive'));
                
                if(Boolean.valueOf(Info.get('Inactive')))
                    cfg.Default__c=false;
                else
                    cfg.Default__c=Boolean.valueOf(Info.get('Default'));
                cfg.ERP_System__c=(string)Info.get('ERPSystem');
                cfg.ERP_Company_Code__c=(string)Info.get('CompanyCode');
                cfg.Synchronization__c = (string)Info.get('Synchronization');
                         
                if(String.isNotBlank(IntegrationKey))  
                    update cfg;
                else
                    insert cfg;
    
                // Update other integration Default Flag
                if(Boolean.valueOf(Info.get('Default')))
                {
                    List<ERP_Config__c> lstConfig = [SELECT id,Name,ERP_Customer_Last_Sync_Date__c,Inactive__c,Web_Service_URL__c,ERP_System__c,ERP_Company_Code__c,
                                                     Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c, Default__c, ERP_Product_Last_Sync_Date__c 
                                                     FROM ERP_Config__c 
                                                     Where id!=: cfg.Id]; 
                    for(ERP_Config__c config: lstConfig)
                    {
                        if(config.Default__c == true)
                            config.Default__c = false;
                    }
                    upsert lstConfig;
                }
                
                
                list<pricebook2> pblist = [select Id from pricebook2 where Integration_Key__c=:cfg.Id];
                if(pblist.size() ==0)
                {  
                    //creating Price book entries
                    pricebook2 pb = new pricebook2();
                    pb.name  = cfg.ERP_System__c+'-'+cfg.Name;
                    pb.Description  = 'Pricebook for '+cfg.ERP_System__c+'-'+cfg.Name;
                    pb.Integration_Key__c  = cfg.Id;
                    pb.External_UId__c  = cfg.Id;
                    upsert pb;
                }
           
                return true;
        }
        catch (Exception e)
        {
            CustomException exc= new CustomException('ConfigurationController','CRUDConfig',e,true);
              return false;
        }
              
    }
    
    

    // Get Already Linked Products for Listing
    public PageReference GetERPName() 
    {
        // Check if the user has read access on the ERP_Configuration__c fields
        if (!Schema.sObjectType.ERP_Config__c.fields.ERP_System__c.isAccessible() 
                || !Schema.sObjectType.ERP_Config__c.fields.ERP_Company_Code__c.isAccessible()
                || !Schema.sObjectType.ERP_Config__c.fields.ID.isAccessible()){
            return null;
        }
       
        ERP_Config__c oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c FROM ERP_Config__c WHERE ID =: IntegrationKey];
        ERPSystemName= oIntegration.ERP_System__c;
        ERPCompanyCode = oIntegration.ERP_Company_Code__c;
        return null;
    }

    // Wrapper Classes
    public class ERP
    {
        public string ERPName{get;set;}
        public list<Param> Params{get;set;}       
    }

    public class configuration
    {
        public string Id {get;set;}
        public string Name {get;set;}
        public string CompanyCode {get;set;}
        public string ERPSystem {get;set;}
        public string IntegrationInformation {get;set;}
        public Boolean Inactive {get;set;}
        public Date CustomerLastSyncDate {get;set;}
        public Date ProductLastSyncDate {get;set;}
        public String WebServiceURL {get;set;}
        public Boolean DefaultIntegration{get;set;}
    }

    public class Param
    {
        public string ParamName{get;set;}
        public string ParamCode{get;set;}
        public integer Length{get;set;}
        public integer Width{get;set;}
        public string ParamType{get;set;}
        public Boolean Required {get;set;}
        public list<string> Options{get;set;}
    }
    
    public  PageReference doCancel()
    {
        PageReference pageRef = new PageReference('/apex/Configurationlist');
        pageRef.setRedirect(true);
        return pageRef ;

    }

}
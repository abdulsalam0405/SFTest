// This is used for returning integration framework of SageX3 ERP
public with sharing Class SageX3IntegrationFramework extends BaseIntegrationFramework
{
    BaseERPProvider provider;

    private static final string className='SageX3IntegrationFramework';
    list<ERP_Product_Family__c> objProductFamily;
    public list<map<String,String>> PrdRecordList{get;set;}
    public list<String> gProductCodes{get;set;}
             
    // LIST ADDED TO FETCH eNTITY DETAILS
    private list<Entity_Detail__c> EntityDetailList = new list<Entity_Detail__c> (); 

    public string gPriceBookId {get;set;}

    public SageX3IntegrationFramework()
    {     
        provider= new SageX3ERPProvider();
    }   

    // Method to establish connection
    public override boolean TestConnection(String URL, list<String> ConnectionParameters)  
    {      
        boolean result= provider.TestConnection(URL, ConnectionParameters);

        if (Test.isRunningTest())
        {
            result=true;
        }
        return result;
    }
 
    public override Helper.GUMU_Response getData(map<string,map<string,list<string>>> Params,map<string,list<object>> Attributes)
    {   
        
        return getRecords(Params,Attributes);
         
    }

    public override Helper.GUMU_Response PostData(string IntegrationId,string SourceEntity,map<string,list<object>> SFObject,map<string,string> PromotionFields,map<string,list<object>> AttribParams)
    { 
        Helper.MappingPurpose purpose;
        ERP_Config__c oIntegration ;
        Entity_Mapping_Header__c oMappingHeader; 
        list<Data_Page__c> DataPageList = new List<Data_Page__c>();
        Helper.GUMU_Response oGUMU_Response; 
        string ERPFuncName='';
        string objectXML  ;
        string Version ='';
        list<object> Versions;
        list<string> objectXMLList=new list<string>();
        try
        {
            //Create Utility function to validate WhereParams and AttribParams
            list<object> AttribParam=AttribParams.get('IntegrationId');
            integrationID=(String)AttribParam[0];

            AttribParam=AttribParams.get('SourceEntity');
            sourceEntity=(String)AttribParam[0];

            AttribParam=AttribParams.get('MappingPurpose');         
            purpose=(Helper.MappingPurpose) AttribParam[0];

            list<string> RequestType = new list<string>();
            if(purpose == Helper.MappingPurpose.POST)
            {
                if(sourceEntity =='Customer')
                {
                    AttribParam=AttribParams.get('ERPFuncName');
                    ERPFuncName=(String)AttribParam[0];
                    RequestType.add('save');
                    //set the attributes
                    
                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');  
                    list<Contact>   Contacts        =(list<Contact>)SFObject.get('Contacts');
                    list<Ship_To__c> Addresses      =(list<Ship_To__c>)SFObject.get('Addresses');
                    Versions=(list<object>)AttribParams.get('Version');
                    Version=(string)Versions[0];
                    objectXML = setAccountXML(CurrentAccount[0],PromotionFields,Contacts,Addresses,Version);
                   
                   system.debug('objectXML '+objectXML);
                    if(string.isBlank(objectXML))
                        return oGUMU_Response;
                    
                    objectXMLList.Add(objectXML);  
                    AttribParams.put('RequestXML',objectXMLList); 
                }
                
                
            }
            if(purpose == Helper.MappingPurpose.MODIFY)
            {
                    AttribParam=AttribParams.get('ERPFuncName');
                    ERPFuncName=(String)AttribParam[0];
                    RequestType.add('modify');
                    //set the attributes
                    
                    list<Account>   CurrentAccount  =(list<Account>)SFObject.get('Accounts');  
                    list<Contact>   Contacts        =(list<Contact>)SFObject.get('Contacts');
                    list<Ship_To__c> Addresses      =(list<Ship_To__c>)SFObject.get('Addresses');
                    Versions=(list<object>)AttribParams.get('Version');
                    Version=(string)Versions[0];
                    objectXML = setAccountXML(CurrentAccount[0],PromotionFields,Contacts,Addresses,Version);
                   
                   system.debug('objectXML '+objectXML);//to check contains cust no or not and add in attribparams
                    if(string.isBlank(objectXML))
                        return oGUMU_Response;
                    
                    objectXMLList.Add(objectXML);  
                    AttribParams.put('RequestXML',objectXMLList); 
            }
            

            //Add Finder values
            list<string> FinderName = new list<string>();
            FinderName.add(ERPFuncName);
            AttribParams.put('DataFinder',FinderName);
            AttribParams.put('RequestType',RequestType);
            oGUMU_Response=new  Helper.GUMU_Response();   
            system.debug('AttribParams678 '+AttribParams);  
            oGUMU_Response=provider.PostRecords(AttribParams);
            system.debug('oGUMU_Response fram '+oGUMU_Response);
            
            if (Test.isRunningTest())
            {
                oGUMU_Response.statusCode='100';
            }
            oGUMU_Response=getMapForXML(oGUMU_Response,AttribParams);
            system.debug('getMapForXML '+oGUMU_Response);
            if(oGUMU_Response.statusCode =='100')
            {           
                //Utility.parse(oGUMU_Response.responseERPData,'message');          
                return oGUMU_Response;
            }
            else if(oGUMU_Response.statusCode =='0')
            {                  
                // Utility.parse(oGUMU_Response.responseERPData,'message');         
                
                return oGUMU_Response;      
            }
            else if(oGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
            {
                return oGUMU_Response;
            }
            
            return oGUMU_Response; 
        }
        catch(Exception ex)
        {
        	if(system.isFuture() == false)
            	CustomException exc= new CustomException(ClassName,'PostData',ex,false);
            throw ex;   
        }
    }
    
    //Create object XML for Promoting Customer/Prospects to the Sage X3 ERP
    private string setAccountXML(Account Act, map<String,String> PromotionFields,list<Contact> Contacts,list<Ship_To__c> shipToLst, string strVersion) 
    {
        system.debug('type '+Act.Type );
        string CustomerNoX3 = PromotionFields.get('CustomerNoX3');
        if (CustomerNoX3 ==null ||CustomerNoX3 =='null' ) 
            CustomerNoX3 =Act.ERP_Customer_Number__c;
            
        string Category = PromotionFields.get('Category');
        string sCurrency = PromotionFields.get('Currency');
        string Language = PromotionFields.get('Language');
        string Tax_rule = PromotionFields.get('Tax_rule');
        string Terms_Code = PromotionFields.get('Terms_Code');
        string SalesPersonX3 = PromotionFields.get('SalesPersonX3');
        boolean isShippingAddressExists = false;

        if(string.isNotBlank(Act.ShippingStreet) || string.isNotBlank(Act.ShippingCity)|| 
            string.isNotBlank(Act.ShippingState) || string.isNotBlank(Act.ShippingPostalCode)|| 
            string.isNotBlank(Act.ShippingCountry)) 
            isShippingAddressExists = true;
        
        string Address1 = '';
        string Address2 = '';
        string Address3 = '';

        if(Act.BillingStreet != null)
        {
            string[] Address = Act.BillingStreet.split('\n');
            if (Address.size() > 2)
            { 
                Address1 = Address[0]==null? '' : Address[0];
                Address2 = Address[1]==null? '' : Address[1];
                Address3 = Address[2]==null? '' : Address[2];           
            }
            else if (Address.size() > 1)
            { 
                Address1 = Address[0]==null? '' : Address[0];
                Address2 = Address[1]==null? '' : Address[1];
            }
            else if (Address.size() > 0)
                Address1 = Address[0]==null? '' : Address[0];
        }
        
        string strObjXML = '';
        string BPAddName = string.valueof(Act.Name);
        string ACCNAME = string.valueof(Act.Name);
        string BillingCountry = '';

        if(Act.BillingCountry!= null)
        {
            if(Act.BillingCountry.length() >2)
                BillingCountry = Act.BillingCountry.substring(0,2);
            else
                BillingCountry = string.valueof(Act.BillingCountry);
        }

        if(BPAddName.length() >30)
            BPAddName=BPAddName.substring(0,30);
        if(BPAddName.length() >10)
            ACCNAME=ACCNAME.substring(0,10);
            
        string Website = '';
        if(Act.Website != null)
            Website = Act.Website;
            
        string AccountType = Act.Type;
        if(string.isBlank(AccountType))
        {
            AccountType='Prospect';
        }
                
        strObjXML += '<PARAM>';
        
        //Main Group
        if(AccountType == 'Prospect')
        {
            strObjXML += '<GRP ID="BPP0_1">';
            if(decimal.valueOf(strVersion) >= 171)
            {
                if (Category!=null )
                    strObjXML += '<FLD NAME="BCGCOD" TYPE="Char">'+ Category +'</FLD>';
            }                   

            strObjXML += '<FLD NAME="BPCNUM" TYPE="Char">'+ CustomerNoX3 +'</FLD>';
            strObjXML += '<FLD NAME="BPCNAM" TYPE="Char">'+ Act.Name +'</FLD>';
            strObjXML += '</GRP>';
        } 
        else
        {
            strObjXML += '<GRP ID="BPC0_1">';
            if (Category!=null )
                strObjXML += '<FLD NAME="BCGCOD" TYPE="Char">'+ Category +'</FLD>';
            //strObjXML += '<FLD NAME="ZBCGCOD" TYPE="Char" />';
            strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCSTA" TYPE="Integer">2</FLD>';
            strObjXML += '<FLD NAME="BPCNUM" TYPE="Char">'+ CustomerNoX3 +'</FLD>';
            strObjXML += '<FLD NAME="BPCNAM" TYPE="Char">'+ Act.Name +'</FLD>';
            strObjXML += '</GRP>';          
        }

        //Currecny, Language Group
        if(AccountType == 'Prospect')
        {
            strObjXML += '<GRP ID="BPRP_1" >';
            strObjXML +='<FLD NAME="BPRSHO" TYPE="Char">'+ACCNAME +'</FLD>';
            strObjXML +='<FLD NAME="BPRLOG" TYPE="Char">'+ACCNAME +'</FLD>';
            strObjXML += '<LST NAME="BPRNAM" SIZE="1" TYPE="Char">';
            strObjXML += '<ITM>'+ Act.Name +'</ITM>';
            strObjXML += '</LST>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="LEGETT" TYPE="Integer" >1</FLD>';
            strObjXML += '<FLD NAME="CRY" TYPE="Char">'+ BillingCountry.toUpperCase() +'</FLD>';
            if (Language!=null)
                strObjXML += '<FLD NAME="LAN" TYPE="Char">'+ Language +'</FLD>';
            if (sCurrency!=null )
                strObjXML += '<FLD NAME="CUR" TYPE="Char">'+ sCurrency +'</FLD>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="BPRFBDMAG" TYPE="Integer" >1</FLD>';
            strObjXML += '</GRP>';
        }
        else
        {
            strObjXML += '<GRP ID="BPRC_1">';
            strObjXML += '<FLD NAME="BPRSHO" TYPE="Char">'+ACCNAME +'</FLD>';
            strObjXML += '<FLD NAME="BPRLOG" TYPE="Char">'+ ACCNAME +'</FLD>';
            strObjXML += '<LST NAME="BPRNAM" SIZE="1" TYPE="Char">';
            strObjXML += '<ITM>'+ Act.Name +'</ITM>';
            strObjXML += '</LST>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="LEGETT" TYPE="Integer">1</FLD>';
            strObjXML += '<FLD NAME="CRY" TYPE="Char">'+ BillingCountry.toUpperCase() +'</FLD>';
            if (Language!=null)
                strObjXML += '<FLD NAME="LAN" TYPE="Char">'+ Language +'</FLD>';
            if (sCurrency!=null )
                strObjXML += '<FLD NAME="CUR" TYPE="Char">'+ sCurrency +'</FLD>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="BPRFBDMAG" TYPE="Integer">1</FLD>';
            //strObjXML += '<FLD NAME="EECNUM" TYPE="Char" >1</FLD>';
            strObjXML += '</GRP>';
        }

        if(AccountType == 'Prospect')
        {       
            strObjXML += '<GRP ID="BPRP_2" >';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="BETFCY" TYPE="Integer" >1</FLD>';
            strObjXML += '<FLD NAME="FCY" TYPE="Char" ></FLD>';
            strObjXML += '<FLD NAME="ZFCY" TYPE="Char" ></FLD>';
            strObjXML += '</GRP>';
        }

        //Role Group
        if(AccountType == 'Prospect')
        {
            strObjXML += '<GRP ID="BPRP_3">';
            strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCFLG" TYPE="Integer">1</FLD>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="REPFLG" TYPE="Integer">1</FLD>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="PPTFLG" TYPE="Integer">2</FLD>';
        }
        else
        {
            strObjXML += '<GRP ID="BPRC_3">';
            strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPCFLG" TYPE="Integer">2</FLD>';
            strObjXML += '<FLD MENULAB="No"  MENULOCAL="1" NAME="REPFLG" TYPE="Integer">1</FLD>';
            strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="PPTFLG" TYPE="Integer">1</FLD>';
        }

        strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="BPSFLG" TYPE="Integer">1</FLD>';
        strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="BPRACC" TYPE="Integer">1</FLD>';
        strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="PRVFLG" TYPE="Integer">1</FLD>';
        strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="BPTFLG" TYPE="Integer">1</FLD>';
        strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="DOOFLG" TYPE="Integer">1</FLD>';
        strObjXML += '</GRP>';

        string AddressCode = '';
        integer shipToCnt=0; 
        if(shipToLst.size() > 2)
        {
            if(AccountType == 'Prospect')
                strObjXML += '<TAB DIM="30" ID="BPAP_1" SIZE="'+shipToLst.size()+'">';
            else
                strObjXML += '<TAB DIM="30" ID="BPAC_1" SIZE="'+shipToLst.size()+'" >';

            integer i=1;
            for(Ship_To__c readAddr : shipToLst)
            {
                string Ship_To_Code =string.isBlank(readAddr.Ship_To_Code__c) ? '' : readAddr.Ship_To_Code__c;
                
                string Ship_To_Name =string.isBlank(readAddr.Ship_To_Name__c) ? '' : readAddr.Ship_To_Name__c;
                string Ship_To_Country_Code =string.isBlank(readAddr.Ship_To_Country_Code__c) ? '' : readAddr.Ship_To_Country_Code__c;
                string Ship_To_Address1 =string.isBlank(readAddr.Ship_To_Address1__c) ? '' : readAddr.Ship_To_Address1__c;
                string Ship_To_Address2 =string.isBlank(readAddr.Ship_To_Address2__c) ? '' : readAddr.Ship_To_Address2__c;
                string Ship_To_Address3 =string.isBlank(readAddr.Ship_To_Address3__c) ? '': readAddr.Ship_To_Address3__c; 
                string Ship_To_Zip_Code =string.isBlank(readAddr.Ship_To_Zip_Code__c) ? '' : readAddr.Ship_To_Zip_Code__c;
                string Ship_To_City =string.isBlank(readAddr.Ship_To_City__c) ?'' : readAddr.Ship_To_City__c; 
                string Ship_To_State =string.isBlank(readAddr.Ship_To_State__c) ? '' : readAddr.Ship_To_State__c;
                string Telephone_No =string.isBlank(readAddr.Telephone_No__c) ? '' : readAddr.Telephone_No__c;
                string IsPrimary =string.isBlank(readAddr.IsPrimary__c) ? '' : readAddr.IsPrimary__c;      
                string isShipTo =string.isBlank(readAddr.isShipTo__c) ? '' : readAddr.isShipTo__c;
                string EmailAddress =string.isBlank(readAddr.Email_Address__c) ? '' : readAddr.Email_Address__c;
                string faxNo = string.isBlank(readAddr.Fax_No__c) ? '' : readAddr.Fax_No__c;
                
                if(Ship_To_Country_Code != '')
                {
                    if(Ship_To_Country_Code.length() > 2)
                        Ship_To_Country_Code = Ship_To_Country_Code.substring(0,2);                   
                }
                
                if(string.isNotBlank(Telephone_No))
                    Telephone_No = Utility.phoneformat(Telephone_No);
                
                if(string.isNotBlank(faxNo))
                    faxNo = Utility.phoneformat(faxNo);
                
                boolean isBillingAddressExists = false;  
                if(string.isNotBlank(Ship_To_Zip_Code) && string.isNotBlank(Ship_To_State)&& string.isNotBlank(Ship_To_Country_Code)) 
                    isBillingAddressExists = true;     
                
                if(isBillingAddressExists == false)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter proper address in Addresses.'));
                    return '';
                }
                                
                AddressCode = Ship_To_Code; 
                
                strObjXML += '<LIN NUM="'+i+'" >';
                strObjXML += '<FLD NAME="CODADR" TYPE="Char" >'+Ship_To_Code+'</FLD>';
                strObjXML += '<FLD NAME="BPADES" TYPE="Char" >'+Ship_To_Name+'</FLD>';
                strObjXML += '<FLD NAME="BPACRY" TYPE="Char" >'+Ship_To_Country_Code.toUpperCase()+'</FLD>';
                //strParam += '<FLD NAME="CRYNAM" TYPE="Char" >United States of America</FLD>';
                strObjXML += '<FLD NAME="ADDLIG1" TYPE="Char" >'+Ship_To_Address1+'</FLD>';
                strObjXML += '<FLD NAME="ADDLIG2" TYPE="Char" >'+Ship_To_Address2+'</FLD>';
                strObjXML += '<FLD NAME="ADDLIG3" TYPE="Char" >'+Ship_To_Address3+'</FLD>';
                strObjXML += '<FLD NAME="POSCOD" TYPE="Char" >'+Ship_To_Zip_Code+'</FLD>';
                strObjXML += '<FLD NAME="CTY" TYPE="Char" >'+Ship_To_City+'</FLD>';
                strObjXML += '<FLD NAME="SAT" TYPE="Char" >'+Ship_To_State.toUpperCase()+'</FLD>';
                //strObjXML += '<FLD NAME="TEL1" TYPE="Char" >'+Telephone_No+'</FLD>';
                //strParam += '<FLD NAME="TEL2" TYPE="Char" >'+readAddr.Telephone_No+'</FLD>';
                strObjXML += '<FLD NAME="TEL1" TYPE="Char" >'+Telephone_No+'</FLD>';
                strObjXML += '<FLD NAME="TEL2" TYPE="Char" >'+faxNo+'</FLD>';
                strObjXML += '<FLD NAME="WEB1" TYPE="Char" >'+EmailAddress+'</FLD>';
                strObjXML += '<FLD NAME="FCYWEB" TYPE="Char">'+ Website +'</FLD>';
                string primary='';
                if(IsPrimary =='Yes' || IsPrimary =='2')
                    primary='2';
                else
                    primary='1';

                strObjXML += '<FLD MENULAB="'+IsPrimary+'" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer" >'+primary+'</FLD>';
                strObjXML += '</LIN>';

                if(isShipTo =='Yes')
                    shipToCnt++;

                i++;
            }
            strObjXML += '</TAB>';
        }
        else
        {
            list<Standard_Setting__c> AddressCodes = [select Address_Code_1__c,Address_Code_2__c from Standard_Setting__c LIMIT 1];                       
            string AddressCode2='';
            if(AddressCodes.size()>0)
            {            
                AddressCode = string.isBlank(AddressCodes[0].Address_Code_1__c) ? 'AD01' : AddressCodes[0].Address_Code_1__c;
                AddressCode2 =string.isBlank(AddressCodes[0].Address_Code_2__c) ? 'AD02' : AddressCodes[0].Address_Code_2__c;
            }
            else
            {
                AddressCode='AD01';
                AddressCode2='AD02';
                
            }
            
            
            if(AccountType == 'Prospect')
                strObjXML += '<TAB DIM="30" ID="BPAP_1" SIZE="1">';
            else
            {
                if(isShippingAddressExists)
                    strObjXML += '<TAB DIM="30" ID="BPAC_1" SIZE="2">';
                else
                    strObjXML += '<TAB DIM="30" ID="BPAC_1" SIZE="1">';
            }

            string BillingPostalCode = '';
            if(Act.BillingPostalCode!= null)
                BillingPostalCode = Act.BillingPostalCode;

            string BillingCity = '';
            if(Act.BillingCity != null)
                BillingCity = Act.BillingCity;

            string BillingState = '';
            if(Act.BillingState != null)
                BillingState = Act.BillingState ;
                    
            string Phone = '';
            if(Act.Phone != null)
                Phone = Utility.phoneformat(string.valueOf(Act.Phone));
            
            string Fax = '';
            if(Act.Fax != null)
                Fax = Utility.phoneformat(string.valueOf(Act.Fax)) ;
                
            boolean isBillingAddressExists = false;  
            if(string.isBlank(BillingPostalCode) && string.isBlank(BillingState)&&
            string.isBlank(BillingCountry)) 
                isBillingAddressExists = false;
            else
            	isBillingAddressExists = true;     
            
            if(isBillingAddressExists == false)
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Please enter proper address in Billing Address. Address is mandatory in ERP while promoting customer.'));
                return '';
            }
            
            strObjXML += '<LIN NUM="1">';
            strObjXML += '<FLD NAME="CODADR" TYPE="Char">'+ AddressCode +'</FLD>';
            strObjXML += '<FLD NAME="BPADES" TYPE="Char">'+BPAddName+'</FLD>';
            strObjXML += '<FLD NAME="BPACRY" TYPE="Char">'+ BillingCountry.toUpperCase() +'</FLD>';
            strObjXML += '<FLD NAME="ADDLIG1" TYPE="Char">'+ Address1 +'</FLD>';
            strObjXML += '<FLD NAME="ADDLIG2" TYPE="Char">'+ Address2 +'</FLD>';
            strObjXML += '<FLD NAME="ADDLIG3" TYPE="Char">'+ Address3 +'</FLD>';
            strObjXML += '<FLD NAME="POSCOD" TYPE="Char">'+ BillingPostalCode  +'</FLD>';
            strObjXML += '<FLD NAME="CTY" TYPE="Char">'+ BillingCity +'</FLD>';
            strObjXML += '<FLD NAME="SAT" TYPE="Char">'+ BillingState.toUpperCase()  +'</FLD>';
            strObjXML += '<FLD NAME="TEL1" TYPE="Char">'+ Phone +'</FLD>';
            strObjXML += '<FLD NAME="TEL2" TYPE="Char">'+ Fax +'</FLD>';
            strObjXML += '<FLD NAME="FCYWEB" TYPE="Char">'+ Website +'</FLD>';
            strObjXML += '<FLD NAME="EXTNUM" TYPE="Char" />';
            strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer">2</FLD>';
            strObjXML += '<FLD NAME="FLMOD" TYPE="Integer">0</FLD>';
            strObjXML += '<FLD NAME="FLMODFONC" TYPE="Integer">0</FLD>';
            strObjXML += '</LIN>';

            //Adding second address and it would be the Ship To Address
            if(isShippingAddressExists)
            {
                if(Act.ShippingStreet!= null)
                {
                    String[] Address = Act.ShippingStreet.split('\n');
                    if (Address.size() > 2)
                    { 
                        Address1 = Address[0]==null? '' : Address[0];
                        Address2 = Address[1]==null? '' : Address[1];
                        Address3 = Address[2]==null? '' : Address[2];
                    }
                    else if (Address.size() > 1)
                    { 
                        Address1 = Address[0]==null? '' : Address[0];
                        Address2 = Address[1]==null? '' : Address[1];
                    }
                    else if (Address.size() > 0)
                    { 
                        Address1 = Address[0]==null? '' : Address[0];
                    }
                }
                string ShippingPostalCode= '';
                if(Act.ShippingPostalCode!= null)
                    ShippingPostalCode= Act.ShippingPostalCode;

                string ShippingCity= '';
                if(Act.ShippingCity!= null)
                    ShippingCity = Act.ShippingCity;

                string ShippingState= '';
                if(Act.ShippingState != null)
                    ShippingState = Act.ShippingState;

                String ShippingCountry= '';

                if(Act.ShippingCountry!= null)
                {
                    if(Act.ShippingCountry.length() > 2)
                        ShippingCountry = Act.ShippingCountry.substring(0,2);
                    else
                        ShippingCountry = string.valueof(Act.ShippingCountry);
                }

                strObjXML += '<LIN NUM="2">';
                strObjXML += '<FLD NAME="CODADR" TYPE="Char">'+AddressCode2+'</FLD>';
                strObjXML += '<FLD NAME="BPADES" TYPE="Char">'+BPAddName+'</FLD>';
                strObjXML += '<FLD NAME="BPACRY" TYPE="Char">'+ ShippingCountry.toUpperCase()+'</FLD>';
                strObjXML += '<FLD NAME="ADDLIG1" TYPE="Char">'+ Address1 +'</FLD>';
                strObjXML += '<FLD NAME="ADDLIG2" TYPE="Char">'+ Address2 +'</FLD>';
                strObjXML += '<FLD NAME="ADDLIG3" TYPE="Char">'+ Address3 +'</FLD>';
                strObjXML += '<FLD NAME="POSCOD" TYPE="Char">'+ ShippingPostalCode +'</FLD>';
                strObjXML += '<FLD NAME="CTY" TYPE="Char">'+ ShippingCity +'</FLD>';
                strObjXML += '<FLD NAME="SAT" TYPE="Char">'+ ShippingState.toUpperCase() +'</FLD>';
                strObjXML += '<FLD NAME="TEL1" TYPE="Char">'+ Phone +'</FLD>';
                strObjXML += '<FLD NAME="TEL2" TYPE="Char">'+ Fax +'</FLD>';
                strObjXML += '<FLD NAME="FCYWEB" TYPE="Char">'+ Website +'</FLD>';
                strObjXML += '<FLD NAME="EXTNUM" TYPE="Char" />';
                strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPAADDFLG" TYPE="Integer">1</FLD>';
                strObjXML += '<FLD NAME="FLMOD" TYPE="Integer">0</FLD>';
                strObjXML += '<FLD NAME="FLMODFONC" TYPE="Integer">0</FLD>';
                strObjXML += '</LIN>';
            }
            strObjXML += '</TAB>';
        }

        if(AccountType == 'Prospect')
        {
            if (SalesPersonX3!=null)
            {
                strObjXML += '<GRP ID="BPP1_2" >';
                strObjXML += '<FLD MENULAB="Category 1" MENULOCAL="403" NAME="COMCAT" TYPE="Integer" >1</FLD>';
                strObjXML += '<LST NAME="REP" SIZE="1" TYPE="Char">';
                strObjXML += '<ITM>'+ SalesPersonX3 +'</ITM>';
                strObjXML += '</LST>';
                strObjXML += '<FLD NAME="MORREP" TYPE="Char" />';
                strObjXML += '</GRP>';
            }               
        }
        else
        {
            //Sales Rep
            if (SalesPersonX3!=null)
            { 
                strObjXML += '<GRP ID="BPC1_3">';
                strObjXML += '<FLD MENULAB="Category 1" MENULOCAL="403" NAME="COMCAT" TYPE="Integer">1</FLD>';
                strObjXML += '<LST NAME="REP" SIZE="1" TYPE="Char">';
                strObjXML += '<ITM>'+ SalesPersonX3 +'</ITM>';
                strObjXML += '</LST>';
                strObjXML += '<FLD NAME="MORREP" TYPE="Char" />';
                strObjXML += '</GRP>';
            }
            
            //Sales Rep
            strObjXML += '<GRP ID="BPC2_1">';
            strObjXML += '<FLD MENULAB="Normal" MENULOCAL="401" NAME="BPCTYP" TYPE="Integer">1</FLD>';
            strObjXML += '</GRP>';

            //Address Code
            strObjXML += '<GRP ID="BPC3_1">';
            strObjXML += '<FLD NAME="BPAINV" TYPE="Char">'+ AddressCode +'</FLD>';
            strObjXML += '<FLD NAME="BPAPYR" TYPE="Char">'+ AddressCode +'</FLD>';
            strObjXML += '</GRP>';
            //Tax Rule
            
            if (Tax_rule!=null)
            {
                strObjXML += '<GRP ID="BPC3_2">';
                strObjXML += '<FLD NAME="VACBPR" TYPE="Char">'+ Tax_rule +'</FLD>';
                strObjXML += '</GRP>';
            }
            
            //Terms Code            
            if (Terms_Code!=null)
            {
                strObjXML += '<GRP ID="BPC3_3">';
                strObjXML += '<FLD NAME="PTE" TYPE="Char">'+ Terms_Code +'</FLD>';
                strObjXML += '<FLD NAME="ZPTE" TYPE="Char">'+ Terms_Code +'</FLD>';
                strObjXML += '</GRP>';
            }           
        }

        //This section for Ship-To
        if(AccountType != 'Prospect' && isShippingAddressExists)
        {
            if(ShipToLst.size()>0)
            {
                strObjXML += '<TAB DIM="30" ID="BPC4_1" SIZE="'+shipToCnt+'" >';
                integer r=1;
                for(Ship_To__c readAddr : ShipToLst)
                {
                    string DefaultShip_To =string.isBlank(readAddr.Default_ShipTo__c) ? '' : readAddr.Default_ShipTo__c;
                    string Ship_To_Code =string.isBlank(readAddr.Ship_To_Code__c) ? '' : readAddr.Ship_To_Code__c;
                    string isShipTo =string.isBlank(readAddr.isShipTo__c) ? '' : readAddr.isShipTo__c;

                    if(isShipTo =='Yes')
                    {
                        strObjXML += '<LIN NUM="'+r+'" >';
                        strObjXML += '<FLD NAME="BPAADD" TYPE="Char" >'+Ship_To_Code+'</FLD>';

                        string defaultshipTo='';
                        if(DefaultShip_To=='Yes')
                            defaultshipTo='2';
                        else
                            defaultshipTo='1';

                        strObjXML += '<FLD MENULAB="'+DefaultShip_To+'" MENULOCAL="1" NAME="BPDADDFLG" TYPE="Integer" >'+defaultshipTo+'</FLD>';
                        strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="ENAFLG" TYPE="Integer" >2</FLD>';
                        strObjXML += '</LIN>';
                        r++;
                    }
                }
                strObjXML += '</TAB>';
            }
            else
            {
                strObjXML += '<TAB DIM="30" ID="BPC4_1" SIZE="1" >';
                strObjXML += '<LIN NUM="1" >';
                strObjXML += '<FLD NAME="BPAADD" TYPE="Char" >AD02</FLD>';
                strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="BPDADDFLG" TYPE="Integer" >2</FLD>';
                strObjXML += '</LIN></TAB>';
            }
        }

        //Remove This Condition and New condition on Based on X3 Version
        if(decimal.valueOf(strVersion) >= 171) 
        {
            if(Contacts.size() > 0)
            {
                if(AccountType == 'Prospect')
                    strObjXML += '<TAB DIM="50" ID="CNTP_1" SIZE="'+ Contacts.size() +'" >';
                else
                    strObjXML += '<TAB DIM="50" ID="CNTC_1" SIZE="'+ Contacts.size() +'" >';

                Integer LineNum  = 0;
                for(Integer i = 0 ; i < Contacts.size();i++)
                {
                    LineNum += 1;                   
                    Double rand = Math.random();

                    String RandomNumber = string.valueOf(Crypto.getRandomInteger());
                    if(RandomNumber.length() > 12)
                        RandomNumber = RandomNumber.substring(0,12);
                                              
                    strObjXML += '<LIN NUM="'+ LineNum +'" >';
                    strObjXML += '<FLD NAME="CCNCRM" TYPE="Char" >CNT'+ RandomNumber +'</FLD>';
                    strObjXML += '<FLD NAME="CNTLNA" TYPE="Char" >'+ Contacts[i].LastName +'</FLD>';
                    strObjXML += '<FLD NAME="CNTFNA" TYPE="Char" >'+ Contacts[i].FirstName +'</FLD>';

                    if(Contacts[i].MailingCountry == null)
                        strObjXML += '<FLD NAME="CNTCRY" TYPE="Char" ></FLD>';
                    else
                    {
                        if(Contacts[i].MailingCountry.length() > 2)
                            strObjXML += '<FLD NAME="CNTCRY" TYPE="Char" >'+ Contacts[i].MailingCountry.substring(0,2) +'</FLD>';
                        else
                            strObjXML += '<FLD NAME="CNTCRY" TYPE="Char" >'+ Contacts[i].MailingCountry +'</FLD>';
                    }

                    strObjXML += '<FLD MENULAB="Yes" MENULOCAL="1" NAME="CNTFLG" TYPE="Integer" >2</FLD>';

                    string Title = string.isBlank(Contacts[i].Salutation) ? '': Contacts[i].Salutation;
                    list<Menu_Setting__c> menus = [select Sequence_Number__c,Code__c from Menu_Setting__c where Code__c=:Title LIMIT 1];

                    string seqNo='';
                    if(menus.size()>0)
                        seqNo = string.valueOf(menus[0].Sequence_Number__c);

                    if(menus.size()>0)
                        strObjXML += '<FLD MENULAB="'+Title+'" MENULOCAL="941" NAME="CNTTTL" TYPE="Integer" >'+seqNo+'</FLD>';

                    strObjXML += '<FLD MENULAB="Buyer" MENULOCAL="233" NAME="CNTFNC" TYPE="Integer" >6</FLD>';
                    
                    string Department =string.isBlank(Contacts[i].Department) ? '' : Contacts[i].Department;
                    strObjXML += '<FLD NAME="CNTSRV" TYPE="Char">'+Department+'</FLD>';
                    //strObjXML += '<FLD NAME="CNTADD" TYPE="Char" >'+ AddressCode +'</FLD>';
                    
                    string ContactPhone = '';
                    if(Contacts[i].Phone != null)
                        ContactPhone = Utility.phoneformat(string.valueOf(Contacts[i].Phone));
                    strObjXML += '<FLD NAME="CNTTEL" TYPE="Char" >'+ContactPhone+'</FLD>';


                    string ContactFax = '';
                    if(Contacts[i].Fax != null)
                        ContactFax = Utility.phoneformat(string.valueOf(Contacts[i].Fax));
                    strObjXML += '<FLD NAME="CNTFAX" TYPE="Char" >'+ContactFax+'</FLD>';

                    string ContactMobileNo = '';
                    if(Contacts[i].MobilePhone != null)
                        ContactMobileNo = Utility.phoneformat(string.valueOf(Contacts[i].MobilePhone));                     
                    strObjXML += '<FLD NAME="CNTMOB" TYPE="Char" >'+ContactMobileNo+'</FLD>';
                    
                    if(Contacts[i].Email == null)
                        strObjXML += '<FLD NAME="CNTWEB" TYPE="Char" ></FLD>';
                    else
                        strObjXML += '<FLD NAME="CNTWEB" TYPE="Char" >'+ Contacts[i].Email +'</FLD>';
                    
                    string Birthdate =string.isBlank(string.valueOf(Contacts[i].Birthdate)) ? '' : string.valueOf(Contacts[i].Birthdate);
                    if(string.isNotBlank(Birthdate))
                    {
                        Birthdate = Birthdate.subString(0,10);
                        Birthdate = Birthdate.replace('-','');
                    }
                    strObjXML += '<FLD NAME="CNTBIR" TYPE="Date">'+Birthdate+'</FLD>';
                    
                    strObjXML += '<FLD NAME="CNTMSS" TYPE="Char" ></FLD>';
                    strObjXML += '<FLD NAME="CNTFULNAM" TYPE="Char" ></FLD>';
                    strObjXML += '<FLD MENULAB="No" MENULOCAL="1" NAME="CNTFBDMAG" TYPE="Integer" >1</FLD>';
                    strObjXML += '<FLD NAME="CNTLAN" TYPE="Char" >ENG</FLD>';
                    strObjXML += '<FLD NAME="CNTCSP" TYPE="Char" ></FLD>';
                    strObjXML += '<FLD NAME="FLMOD" TYPE="Integer" >0</FLD>';
                    strObjXML += '<FLD NAME="FLMODFONC" TYPE="Integer" >0</FLD>';
                    strObjXML += '<FLD NAME="FLNEW" TYPE="Integer" >1</FLD>';
                    strObjXML += '</LIN>';
                }    
                strObjXML += '</TAB>';
            }
        }

        strObjXML += '</PARAM>';
        
        system.debug('strObjXML34 '+strObjXML);
       // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'strObjXML '+strObjXML));
        
        return strObjXML; 
    }   
    
    private Helper.GUMU_Response getRecords(map<string,map<string,list<string>>> WhereParams,map<string,list<object>> AttribParams)
    {
        Helper.MappingPurpose purpose;
        string sourceEntity; 
        string integrationID;
        ERP_Config__c oIntegration ;
        Entity_Mapping_Header__c oMappingHeader; 
        Entity__c ObjEntity;
        //Data_Page__c   = new Data_Page__c();
        List<Data_Page__c> DataPageList = new List<Data_Page__c>();
        Helper.GUMU_Response oGUMU_Response; 
        Helper.GUMU_Response pGUMU_Response; 
        String ERPFuncName='';
        try
        {
            //Create Utility function to validate WhereParams and AttribParams
            list<object> AttribParam=AttribParams.get('IntegrationId');
            integrationID=(String)AttribParam[0];

            AttribParam=AttribParams.get('SourceEntity');
            sourceEntity=(String)AttribParam[0];

            AttribParam=AttribParams.get('MappingPurpose');         
            purpose=(Helper.MappingPurpose) AttribParam[0];

            //Get the connection information from custom setting 
            oIntegration = [SELECT ERP_System__c,ERP_Company_Code__c,Web_Service_URL__c,Integration_Information__c,Integration_Information_2__c,Integration_Information_3__c FROM ERP_Config__c WHERE ID =: integrationID];
            
            list<string> RequestType = new list<string>();

            if(purpose == Helper.MappingPurpose.SYNC)
            {
                oMappingHeader = [SELECT ERP_Function__c,IsStandardPB__c,Source_Entity__c,Sync_Direction__c,Entity_Id__c,
                                  Target_Entity__c,Parent_Target_Entity__c FROM Entity_Mapping_Header__c WHERE Source_Entity__c =:sourceEntity ];//AND ERP_System__c=:oIntegration.ERP_System__c              
                //ERP_System__c,
                ObjEntity=[select Id,API_Method__c,Entity_Code__c,Group_Name__c,Entity_Detail_Id__c,Entity_Detail_Id__r.Field_APIName__c ,Parent_Entity_Id__c,Parent_Entity_Id__r.API_Method__c from  
                                         Entity__c Where Id=:oMappingHeader.Entity_Id__c];
                                         
                if(string.isNotBlank(oMappingHeader.Entity_Id__c))
                 {
                    EntityDetailList = [select Field_APIName__c,Values__c from Entity_Detail__c 
                                             where Entity_Id__c=:oMappingHeader.Entity_Id__c];
                 }
                    
                if (string.IsBlank(ObjEntity.Parent_Entity_Id__c))
                {
                    ERPFuncName=oMappingHeader.ERP_Function__c;
                    ERPFuncName=ObjEntity.API_Method__c;
                }    
                else
                    ERPFuncName=ObjEntity.Parent_Entity_Id__r.API_Method__c;                    
                
                RequestType.add('run');
            }
            else if(purpose == Helper.MappingPurpose.ACTION)
            {
                ERPFuncName='YGTORDER';
                RequestType.add('actionObject');    
            }
            else if(purpose == Helper.MappingPurpose.POST)
            {
                if(sourceEntity =='Customer')
                {
                    AttribParam=AttribParams.get('ERPFuncName');
                    ERPFuncName=(String)AttribParam[0];                 
                    RequestType.add('save');
                }
                else if(sourceEntity =='Order')
                {
                    ERPFuncName='YGTORDER';
                    RequestType.add('save');
                }
            }
            else if(purpose == Helper.MappingPurpose.MODIFY)
            {
                AttribParam=AttribParams.get('ERPFuncName');
                ERPFuncName=(String)AttribParam[0];
                RequestType.add('modify');        
            }
            else
            {   
                DataPageList = [SELECT Name, Description__c, ERP_Function__c, Name__c, Type__c,Entity_Id__c FROM Data_Page__c 
                                WHERE Name =:sourceEntity AND Integration_Key__c=:oIntegration.Id];
                
                system.debug('DataPageList '+DataPageList);
                // ERP_System__c,   
                if(DataPageList.size()>0)
                {
                    ERPFuncName=DataPageList[0].ERP_Function__c;
                  
                    if (DataPageList[0].Type__c=='List')
                        RequestType.add('run');
                    else
                        RequestType.add('read');
                        
                   if(string.isNotBlank(DataPageList[0].Entity_Id__c))
                     {
                        EntityDetailList = [select Field_APIName__c,Values__c from Entity_Detail__c 
                                                 where Entity_Id__c=:DataPageList[0].Entity_Id__c ];
                     }
                  //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:EntityDetailList:'+ jSon.serialize(EntityDetailList)));                  
                }
                AttribParam=AttribParams.get('AccountType');
                system.debug('AttribParam1 '+AttribParam);
                if(AttribParam !=null)
                {
                    string AccountType=(String)AttribParam[0];
                    if(AccountType =='Prospect')
                        ERPFuncName='YGTPROSDTL' ;
                }
                system.debug('ERPFuncName1 '+ERPFuncName);
            }               

            if (string.isBlank(ERPFuncName))
            {
                NoDataFoundException NoERPFuncName=new NoDataFoundException();
                //NoERPFuncName.setMessage('ERP Function not defined.');
                NoERPFuncName.setMessage('ERP Function not definied - '+ oIntegration.ERP_System__c + ' SourceEntity:' + sourceEntity);
                throw NoERPFuncName; 
            }

            //Add Finder values
            list<string> FinderName = new list<string>();
            FinderName.add(ERPFuncName);
            AttribParams.put('DataFinder',FinderName);
            AttribParams.put('RequestType',RequestType);

            oGUMU_Response=new  Helper.GUMU_Response();   
             if (Test.isRunningTest())
             {
                oGUMU_Response.statusCode='200';
                oGUMU_Response.responseERPData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:actionObjectResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><actionObjectReturn href="#id0"/></ns1:actionObjectResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;GRP ID=&quot;SOH0_1&quot;&gt;&lt;FLD NAME=&quot;SALFCY&quot; TYPE=&quot;Char&quot;&gt;NA012&lt;/FLD&gt;&lt;FLD NAME=&quot;SOHTYP&quot; TYPE=&quot;Char&quot;&gt;SON&lt;/FLD&gt;&lt;FLD NAME=&quot;ZSOHTYP&quot; TYPE=&quot;Char&quot;&gt;Normal&lt;/FLD&gt;&lt;FLD NAME=&quot;SOHNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;REVNUM&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;CUSORDREF&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ORDDAT&quot; TYPE=&quot;Date&quot;&gt;20160314&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCORD&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;W1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WSOHCAT&quot; TYPE=&quot;Char&quot;&gt;Category : Normal&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_1&quot;&gt;&lt;FLD NAME=&quot;BPCINV&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPINAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCPYR&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;ZBPCPYR&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCGRU&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;ZBPCGRU&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDNAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_2&quot;&gt;&lt;FLD NAME=&quot;PJT&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_3&quot;&gt;&lt;LST NAME=&quot;REP&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;NA102&lt;/ITM&gt;&lt;/LST&gt;&lt;LST NAME=&quot;ZREP&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;ANDERSON Bill&lt;/ITM&gt;&lt;/LST&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_4&quot;&gt;&lt;FLD NAME=&quot;CCLREN&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VACBPR&quot; TYPE=&quot;Char&quot;&gt;NTX&lt;/FLD&gt;&lt;FLD NAME=&quot;ZVACBPR&quot; TYPE=&quot;Char&quot;&gt;No Tax&lt;/FLD&gt;&lt;FLD NAME=&quot;SSTENTCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZSSTENTCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;ZCUR&quot; TYPE=&quot;Char&quot;&gt;US Dollar&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Exclude tax&quot; MENULOCAL=&quot;243&quot; NAME=&quot;PRITYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_5&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;280&quot; NAME=&quot;APPFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Open&quot; MENULOCAL=&quot;415&quot; NAME=&quot;ORDSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Not Allocated&quot; MENULOCAL=&quot;416&quot; NAME=&quot;ALLSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Not delivered&quot; MENULOCAL=&quot;417&quot; NAME=&quot;DLVSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Not Invoiced&quot; MENULOCAL=&quot;418&quot; NAME=&quot;INVSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;OK&quot; MENULOCAL=&quot;419&quot; NAME=&quot;CDTSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CDTBTN&quot; TYPE=&quot;Char&quot;&gt;280&lt;/FLD&gt;&lt;FLD MENULAB=&quot;OK&quot; MENULOCAL=&quot;491&quot; NAME=&quot;HLDSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;HLDBTN&quot; TYPE=&quot;Char&quot;&gt;280&lt;/FLD&gt;&lt;FLD NAME=&quot;HLDCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_6&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;OCNPRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BETFCY&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BETCPY&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_1&quot;&gt;&lt;FLD NAME=&quot;STOFCY&quot; TYPE=&quot;Char&quot;&gt;NA012&lt;/FLD&gt;&lt;FLD NAME=&quot;ZSTOFCY&quot; TYPE=&quot;Char&quot;&gt;NA BikeToy&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;410&quot; NAME=&quot;DLVPIO&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_2&quot;&gt;&lt;FLD NAME=&quot;DEMDLVDAT&quot; TYPE=&quot;Date&quot;&gt;20160315&lt;/FLD&gt;&lt;FLD NAME=&quot;DAYLTI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;SHIDAT&quot; TYPE=&quot;Date&quot;&gt;20160314&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_3&quot;&gt;&lt;FLD MENULAB=&quot;Route Code 1&quot; MENULOCAL=&quot;409&quot; NAME=&quot;DRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;MDL&quot; TYPE=&quot;Char&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;ZMDL&quot; TYPE=&quot;Char&quot;&gt;Ground&lt;/FLD&gt;&lt;FLD NAME=&quot;BPTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECICT&quot; TYPE=&quot;Char&quot;&gt;FOB&lt;/FLD&gt;&lt;FLD NAME=&quot;ICTCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_4&quot;&gt;&lt;FLD NAME=&quot;LASDLVNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_5&quot;&gt;&lt;FLD NAME=&quot;SDHTYP&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZSDHTYP&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ORDCLE&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ODL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_6&quot;&gt;&lt;FLD MENULAB=&quot;Allowed&quot; MENULOCAL=&quot;414&quot; NAME=&quot;DME&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_7&quot;&gt;&lt;FLD MENULAB=&quot;Global&quot; MENULOCAL=&quot;450&quot; NAME=&quot;ALLTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH3_1&quot;&gt;&lt;FLD MENULAB=&quot;One/Shipment&quot; MENULOCAL=&quot;408&quot; NAME=&quot;IME&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH3_2&quot;&gt;&lt;FLD NAME=&quot;PTE&quot; TYPE=&quot;Char&quot;&gt;CH30NET&lt;/FLD&gt;&lt;FLD NAME=&quot;DEP&quot; TYPE=&quot;Char&quot;&gt;SGL01&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDEP&quot; TYPE=&quot;Char&quot;&gt;2%10 InvDa&lt;/FLD&gt;&lt;FLD NAME=&quot;SQHNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PRFNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;LASINVNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;SOH3_3&quot; SIZE=&quot;6&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;CCT&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Cost Center&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;MAR&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Market&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;&gt;WHOLESALE&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;PRO&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Product&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;PRJ&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Projects&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;ENV&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Envelopes&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;ENT&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Entities&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;30&quot; ID=&quot;SOH3_4&quot; SIZE=&quot;3&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Discount %&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;%&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;3&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Freight char&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Tax excl&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Insurance&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Tax excl&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;SOH4_2&quot;&gt;&lt;FLD NAME=&quot;DLRNOT&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;PFMTOT&quot; TYPE=&quot;Decimal&quot;&gt;1.39&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH4_3&quot;&gt;&lt;FLD NAME=&quot;ORDNOT&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH4_4&quot;&gt;&lt;FLD NAME=&quot;ORDINVNOT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;ORDINVATI&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;500&quot; ID=&quot;SOH4_1&quot; SIZE=&quot;1&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;NUMLIG&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;ITMREF&quot; TYPE=&quot;Char&quot;&gt;BMS002&lt;/FLD&gt;&lt;FLD NAME=&quot;ITMDES&quot; TYPE=&quot;Char&quot;&gt;5 Sprockets&lt;/FLD&gt;&lt;FLD NAME=&quot;ITMDES1&quot; TYPE=&quot;Char&quot;&gt;5 Sprockets&lt;/FLD&gt;&lt;FLD NAME=&quot;DSTOFCY&quot; TYPE=&quot;Char&quot;&gt;NA012&lt;/FLD&gt;&lt;FLD NAME=&quot;SAU&quot; TYPE=&quot;Char&quot;&gt;UN&lt;/FLD&gt;&lt;FLD NAME=&quot;QTY&quot; TYPE=&quot;Decimal&quot;&gt;1.00&lt;/FLD&gt;&lt;FLD NAME=&quot;SAUSTUCOE&quot; TYPE=&quot;Decimal&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;STU&quot; TYPE=&quot;Char&quot;&gt;UN&lt;/FLD&gt;&lt;FLD NAME=&quot;ALLQTY&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;SHTQTY&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;WALLQTY&quot; TYPE=&quot;Decimal&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Global&quot; MENULOCAL=&quot;450&quot; NAME=&quot;DALLTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;TDLQTY&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;GROPRI&quot; TYPE=&quot;Decimal&quot;&gt;5.1745&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL1&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL2&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL3&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL4&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL5&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL6&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;NETPRI&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;CPRPRI&quot; TYPE=&quot;Decimal&quot;&gt;3.78&lt;/FLD&gt;&lt;FLD NAME=&quot;PFM&quot; TYPE=&quot;Decimal&quot;&gt;1.39&lt;/FLD&gt;&lt;FLD NAME=&quot;VACITM1&quot; TYPE=&quot;Char&quot;&gt;NOR&lt;/FLD&gt;&lt;FLD NAME=&quot;VACITM2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VACITM3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;REP1&quot; TYPE=&quot;Char&quot;&gt;NA102&lt;/FLD&gt;&lt;FLD NAME=&quot;REPRAT1&quot; TYPE=&quot;Decimal&quot;&gt;5&lt;/FLD&gt;&lt;FLD NAME=&quot;REP2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;REPRAT2&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;REPCOE&quot; TYPE=&quot;Decimal&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DDEMDLVDAT&quot; TYPE=&quot;Date&quot;&gt;20160315&lt;/FLD&gt;&lt;FLD NAME=&quot;DDAYLTI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DSHIDAT&quot; TYPE=&quot;Date&quot;&gt;20160314&lt;/FLD&gt;&lt;FLD NAME=&quot;EXTDLVDAT&quot; TYPE=&quot;Date&quot;&gt;20160315&lt;/FLD&gt;&lt;FLD NAME=&quot;DBPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;CNDNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;USEPLC&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;410&quot; NAME=&quot;DDLVPIO&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Route Code 1&quot; MENULOCAL=&quot;409&quot; NAME=&quot;DDRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DMDL&quot; TYPE=&quot;Char&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;DBPTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PRECOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PCK&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PCKCAP&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE2&quot; TYPE=&quot;Char&quot;&gt;WHOLESALE&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE6&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE7&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE8&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE9&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE10&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE11&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE12&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE13&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE14&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE15&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE16&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE17&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE18&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE19&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE20&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Firm&quot; MENULOCAL=&quot;317&quot; NAME=&quot;DEMSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Stock&quot; MENULOCAL=&quot;445&quot; NAME=&quot;FMI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;FMINUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;LINORDNOT&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;LINORDATI&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;LINPFM&quot; TYPE=&quot;Decimal&quot;&gt;1.39&lt;/FLD&gt;&lt;FLD NAME=&quot;DETSQHNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;423&quot; NAME=&quot;LINTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;439&quot; NAME=&quot;FOCFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Pending&quot; MENULOCAL=&quot;279&quot; NAME=&quot;SOQSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DCCLREN&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;ADB1_1&quot;&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;Ad001&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;LST NAME=&quot;BPAADDLIG&quot; SIZE=&quot;3&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;700, Northside Street&lt;/ITM&gt;&lt;ITM&gt;700, Northside Street&lt;/ITM&gt;&lt;ITM&gt;700, Northside Street&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;ITINERAIRE&quot; TYPE=&quot;Char&quot;&gt;226&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD NAME=&quot;VALADR&quot; TYPE=&quot;Char&quot;&gt;102&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ADRVAL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADB2_1&quot;&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;LST NAME=&quot;BPAADDLIG&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;136 Wexford Run Road&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;15143&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Sewickley&lt;/FLD&gt;&lt;FLD NAME=&quot;ITINERAIRE&quot; TYPE=&quot;Char&quot;&gt;226&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;PA&lt;/FLD&gt;&lt;FLD NAME=&quot;CNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECNUMX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VALADR&quot; TYPE=&quot;Char&quot;&gt;102&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADB3_1&quot;&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;LST NAME=&quot;BPAADDLIG&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;136 Wexford Run Road&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;15143&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Sewickley&lt;/FLD&gt;&lt;FLD NAME=&quot;ITINERAIRE&quot; TYPE=&quot;Char&quot;&gt;226&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;PA&lt;/FLD&gt;&lt;FLD NAME=&quot;CNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECNUMX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VALADR&quot; TYPE=&quot;Char&quot;&gt;102&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ADRVAL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADXTEC&quot;&gt;&lt;FLD NAME=&quot;WW_MODSTAMP&quot; TYPE=&quot;Char&quot;&gt;00000000000000&lt;/FLD&gt;&lt;FLD NAME=&quot;WW_MODUSER&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.132</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">5.9373</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">803.5804</poolExecDuration><poolRequestDuration xsi:type="xsd:double">810.0612</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.5377</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">851.9312</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
             }
             else
                oGUMU_Response=provider.getRecords(WhereParams,AttribParams);
            
            if(oGUMU_Response.statusCode =='101' || oGUMU_Response.statusCode =='100' || oGUMU_Response.statusCode =='0')
            {               
                return oGUMU_Response;
            }
            else if(!(oGUMU_Response.statusCode =='200' || oGUMU_Response.statusCode =='201' ))
            {
                return oGUMU_Response;
            }
            else if(oGUMU_Response.responseERPData.contains('Service Temporarily Unavailable'))
            {
                return oGUMU_Response;
            }
            
            //Loop through each record and get the each record detail
            list<map<string,string>> ErpDataList ;
            
            if(purpose != Helper.MappingPurpose.SYNC)
            {   
                if(DataPageList.size()>0)
                {
                    if (DataPageList[0].Type__c=='List')
                        ErpDataList = PrepareERPDataList(oGUMU_Response);
                    else
                        oGUMU_Response=getMapForXML(oGUMU_Response,AttribParams);
                }
                else 
                    oGUMU_Response=getMapForXML(oGUMU_Response,AttribParams);
            //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:ErpDataList:'+ jSon.serialize(ErpDataList)));
            
            }
            else
            {             
                ErpDataList = PrepareERPDataList(oGUMU_Response);
                //pGUMU_Response = new Helper.GUMU_Response();
                pGUMU_Response=oGUMU_Response;
            }   

            if(purpose == Helper.MappingPurpose.SYNC)
            {
              
                if (!string.IsBlank(ObjEntity.Parent_Entity_Id__c) )
                {
                    list<sObject> customObjectsList = new list<sObject> ();
                    list<sObject> customObjects = new list<sObject> ();
                    
                    map<string,list<object>> RelSFData = new  map<string,list<object>> ();
                    
                    //TODO:FOR Multiple Relation Code:s
                    list<Entity__c> ObjChildEntities = [select Id,API_Method__c,Entity_Code__c,Group_Name__c,Entity_Detail_Id__c,
                                                        Entity_Detail_Id__r.Field_APIName__c ,Parent_Entity_Id__c,Parent_Entity_Id__r.API_Method__c 
                                                        from Entity__c Where Parent_Entity_Id__c =:ObjEntity.Parent_Entity_Id__c];
                    
                    list <Entity_Mapping_Header__c> oChildMappingHeaders = [SELECT ERP_Function__c,Source_Entity__c,Sync_Direction__c,Entity_Id__c,
                                    Entity_Id__r.Group_Name__c,
                                    Target_Entity__c,Parent_Target_Entity__c FROM Entity_Mapping_Header__c WHERE Entity_Id__c in: ObjChildEntities ];
                                    //ERP_System__c,              
                    
                    //TODO:FOR Multiple Relation Code:e
                //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'ErpDataList '+jSon.Serialize(ErpDataList)));
                    for(map<string,string> ErpData : ErpDataList)
                    {   
                        FinderName = new list<string>();
                        FinderName.add(ObjEntity.API_Method__c);
                        AttribParams.put('DataFinder',FinderName);
                        
                        RequestType = new list<string>();
                        RequestType.add('read');
                        AttribParams.put('RequestType',RequestType);
                       
                       // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'ErpData '+jSon.Serialize(ErpData )));
                        
                        list<string> Include = new list<string>();
                        if(!string.IsBlank(ObjEntity.Group_Name__c))
                        {
                            //Group_Name__c
                            Include.add(ObjEntity.Group_Name__c);
                            AttribParams.put('include',Include);
                        }   
                        
                        /**/
                        
                        map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
                        map<string,list<string>> parameter = new map<string,list<string>>();
                        list<string> listParams=new list<string> ();
                        listParams.add(ErpData.get(ObjEntity.Entity_Detail_Id__r.Field_APIName__c));
                        parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
                        fieldParameters.put(ObjEntity.Entity_Detail_Id__r.Field_APIName__c,parameter);
                        WhereParams=fieldParameters;
                        
                        oGUMU_Response=provider.getRecords(WhereParams,AttribParams);
                    
                        if (oGUMU_Response.statusMessage == 'Record does not exist')
                        {
                            continue ;  
                        }
                        
                        oGUMU_Response =getGenericMapForXML(oGUMU_Response,AttribParams);
                        
                        //TODO:FOR Multiple Relation Code:s
                       
                        //TODO:FOR Multiple Relation Code:e
                        
                        if(!string.IsBlank(ObjEntity.Group_Name__c))
                        {
                             //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Confirm,'ErpData '+jSon.Serialize(oGUMU_Response.ERPDataMapDetail)));
                            customObjects=getCustomObject(oIntegration ,oMappingHeader, oGUMU_Response.ERPDataMapDetail);
                        }   
                        else
                        {
                            customObjects=getCustomObject(oIntegration ,oMappingHeader, oGUMU_Response.ERPDataMap);
                        }   
                        
                        if (customObjects != null)
                            customObjectsList.addAll(customObjects) ;
                       
                    }
                    
                    //TODO:FOR Multiple Relation Code
                    //oGUMU_Response.responseRelSFData=RelSFData;
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info,'customObjectsList '+jSon.serialize(customObjectsList)));
                    
                    oGUMU_Response.responseSFData=customObjectsList;
                    oGUMU_Response.ERPDataMap=ErpDataList;
                    oGUMU_Response.totalRecord=pGUMU_Response.totalRecord;
                    oGUMU_Response.startIndex=pGUMU_Response.startIndex;
                    oGUMU_Response.itemPerPage=pGUMU_Response.itemPerPage;
                    oGUMU_Response.statusCode=pGUMU_Response.statusCode;
                    
                }
                else
                {
                    list<sObject> customObjects = new list<sObject> ();
                    customObjects=getCustomObject(oIntegration ,oMappingHeader, ErpDataList);
                    oGUMU_Response.responseSFData=customObjects;
                    oGUMU_Response.ERPDataMap=ErpDataList;
                    oGUMU_Response.totalRecord=pGUMU_Response.totalRecord;
                    oGUMU_Response.startIndex=pGUMU_Response.startIndex;
                    oGUMU_Response.itemPerPage=pGUMU_Response.itemPerPage;
                    oGUMU_Response.statusCode=pGUMU_Response.statusCode;
                }
            }
            else if(purpose == Helper.MappingPurpose.ACTION)
            {
                oGUMU_Response.SFDataMap=getRealTimeProductData(oGUMU_Response);
            }
            else if(purpose == Helper.MappingPurpose.POST)
            {
                oGUMU_Response.SFDataMap=getReferenceID(oGUMU_Response);
            }
            else if(purpose == Helper.MappingPurpose.MODIFY)
            {
                oGUMU_Response.SFDataMap=getReferenceID(oGUMU_Response);
            }
        }
        catch(Exception ex)
        {
        	if(system.isFuture() == false)
            	CustomException exc= new CustomException(ClassName,'getRecords',ex,false);
            throw ex;   
        }

        return oGUMU_Response ; 
    }
    
    list<log__c> logs=new list<log__c >();
    Log__c oLog;
    //This function is used to get the list of map of Sage X3 ERP data  
    public Helper.GUMU_Response getGenericMapForXML(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
    { 
        string custResponse=getResultXML(pGUMU_Response.responseERPData);
        
        list<object> sourceEntity = AttribParams.get('SourceEntity');
        string strSourceEntity = string.valueOf(sourceEntity[0]);
        
                                
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';
        map<string,string> Sections = new map<string,string>();
        
        if(strSourceEntity.contains('Customer'))
        {
            Sections.put('BPAC_1','BPAC_1');
        }
        
        for(string fieldKey : AttribParams.keySet()) 
        {
            //TODO include some cons
            if (fieldKey=='include')
            {
                list<object> IncludeParams=  AttribParams.get('include');
                for (object param :IncludeParams)
                {
                    Sections.put((string)param,(string)param);
                }      
            }
        }
        
        map<string,string> ERPDataMap            =      new map<string,string>();
        list<map<string,string>> ERPDataMapAll   =      new list<map<string,string>>();

        map<string,string> ERPDataMapDetail                           =      new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll    =      new list<map<string,string>>(); 
        map<string,list<map<string,string>>> ERPDataMapRelSections    = new map<string,list<map<string,string>>> ();

        try
        { 
            objXmlNode = new ReadAndWriteXML.XmlNode();
            objXmlNode = ReadAndWriteXML.ParseXmlString(custResponse);
            list<ReadAndWriteXML.XmlNode> lstRsltNode = objXmlNode.ChildXmlNodes;
            for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
            {
                //ERPDataMap= new map<string,string>();
                list<ReadAndWriteXML.XmlNode> lstTabNodes = readRsltNode.ChildXmlNodes;
                if(readRsltNode.NodeName != 'TAB')
                {
                    string strGetID=readRsltNode.Attributes.get('ID'); 
                    for(ReadAndWriteXML.XmlNode readLineNode:lstTabNodes)
                    {
                        if(readLineNode.NodeName == 'LIN')
                        {
                            for(ReadAndWriteXML.XmlNode LineNode:readLineNode.ChildXmlNodes)
                            {
                                string menuval=valuesdescription(LineNode.Attributes.get('NAME'), LineNode.NodeValue);
                                if(menuval =='')                               
                                    ERPDataMap.put(LineNode.Attributes.get('NAME'),LineNode.NodeValue);
                                else
                                    ERPDataMap.put(LineNode.Attributes.get('NAME'),menuval);
                            }
                        }
                        else
                        {
                            string menuval=valuesdescription(readLineNode.Attributes.get('NAME'), readLineNode.NodeValue);
                            if(menuval =='')
                                ERPDataMap.put(readLineNode.Attributes.get('NAME'),readLineNode.NodeValue);
                            else
                                ERPDataMap.put(readLineNode.Attributes.get('NAME'),menuval);
                        }
                    }
                }
                else
                {
                    if (Sections.get(readRsltNode.Attributes.get('ID'))!=null )
                    {
                        for(ReadAndWriteXML.XmlNode readLineNode:lstTabNodes)
                        {      
                            //ERPDataMapDetailAll  = new list<map<string,string>>();
                            ERPDataMapDetail = new map<string,string>();  
                            if(readLineNode.NodeName == 'LIN')
                            {
                                for(ReadAndWriteXML.XmlNode LineNode:readLineNode.ChildXmlNodes)
                                {
                                    string menuval=valuesdescription(LineNode.Attributes.get('NAME'), LineNode.NodeValue);
                                    if(menuval =='')
                                    {
                                        ERPDataMapDetail.put(LineNode.Attributes.get('NAME') ,LineNode.NodeValue);
                                        ERPDataMap.put(LineNode.Attributes.get('NAME') ,LineNode.NodeValue);
                                    }
                                    else
                                    {
                                        ERPDataMapDetail.put(LineNode.Attributes.get('NAME') ,menuval);
                                        ERPDataMap.put(LineNode.Attributes.get('NAME') ,menuval);
                                    }
                                }
                            }
                            
                            for(string fieldKey : ERPDataMap.keySet()) 
                                ERPDataMapDetail.put(fieldKey,ERPDataMap.get(fieldKey));
                            
                            ERPDataMapDetailAll.Add(ERPDataMapDetail);
                        }
                        ERPDataMapRelSections.put(readRsltNode.Attributes.get('ID'),ERPDataMapDetailAll);
                    }
                }

            }
            
            ERPDataMapAll.add(ERPDataMap);

            //ERPDataMapAll.add(ERPDataMapDetail);
            pGUMU_Response.ERPDataMap  = ERPDataMapAll;
            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll; 
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections; 
            
            //Now write the code to code to merge the header to detail
            
            //set the veriable for paging
            //TODO:Remove below 
            pGUMU_Response.TotalRecord = '1';
            pGUMU_Response.startIndex  = '1';
            pGUMU_Response.itemPerPage = '1';
            return pGUMU_Response;                   
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getGenericMapForXML',ex,false);
            throw ex;
        }                    
    }   
    
    
    //This function is used to get the list of map of Sage X3 ERP data  
    public Helper.GUMU_Response getMapForXML(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
    { 
        system.debug('getMapForXMLrtyu');
        string custResponse=getResultXML(pGUMU_Response.responseERPData);
                
        system.debug('custResponse '+custResponse);
        pGUMU_Response.responseERPData=custResponse;
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';
        map<string,string> Sections = new map<string,string>();
        for(string fieldKey : AttribParams.keySet()) 
        {
            //TODO include some cons
            if (fieldKey=='include')
            {
                list<object> IncludeParams=  AttribParams.get('include');
                for (object param :IncludeParams)
                {
                    Sections.put((string)param,(string)param);
                }      
            }
        }

        map<string,string> ERPDataMap            =      new map<string,string>();
        list<map<string,string>> ERPDataMapAll   =      new list<map<string,string>>();

        map<string,string> ERPDataMapDetail                           =      new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll    =      new list<map<string,string>>(); 
        map<string,list<map<string,string>>> ERPDataMapRelSections    = new map<string,list<map<string,string>>> ();

        try
        { 
            objXmlNode = new ReadAndWriteXML.XmlNode();
            objXmlNode = ReadAndWriteXML.ParseXmlString(custResponse);
            list<ReadAndWriteXML.XmlNode> lstRsltNode = objXmlNode.ChildXmlNodes;
            for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
            {
                //ERPDataMap= new map<string,string>();
                list<ReadAndWriteXML.XmlNode> lstTabNodes = readRsltNode.ChildXmlNodes;
                if(readRsltNode.NodeName != 'TAB')
                {
                    string strGetID=readRsltNode.Attributes.get('ID'); 
                    for(ReadAndWriteXML.XmlNode readLineNode:lstTabNodes)
                    {
                    	if(string.isNotBlank(ERPDataMap.get(readLineNode.Attributes.get('NAME'))))
                    		continue;
                    	
                        if(readLineNode.NodeName == 'LIN')
                        {
                            for(ReadAndWriteXML.XmlNode LineNode:readLineNode.ChildXmlNodes)
                            {
                                string menuval=valuesdescription(LineNode.Attributes.get('NAME'), LineNode.NodeValue);
                                if(menuval =='')
                                    ERPDataMap.put(LineNode.Attributes.get('NAME'),LineNode.NodeValue);
                                else
                                    ERPDataMap.put(LineNode.Attributes.get('NAME'),menuval);
                            }
                        }
                        else
                        {                     
                            if(readLineNode.Attributes.get('NAME')=='PPTFLG')
                            {   
                                if(readLineNode.NodeValue =='2')
                                    ERPDataMap.put(readLineNode.Attributes.get('NAME'),'Prospect');
                                else
                                    ERPDataMap.put(readLineNode.Attributes.get('NAME'),'Customer - Direct');
                            }
                            else
                            {
                                if (strGetID=='BPC1_3' || strGetID=='BPP1_2')
                                {
                                    for(ReadAndWriteXML.XmlNode ContactLineNode:readRsltNode.ChildXmlNodes[1].ChildXmlNodes)
                                    {
                                        string menuval=valuesdescription( readRsltNode.ChildXmlNodes[1].Attributes.get('NAME'), readRsltNode.ChildXmlNodes[1].ChildXmlNodes[0].NodeValue);
                                        if(menuval =='')
                                            ERPDataMap.put(readRsltNode.ChildXmlNodes[1].Attributes.get('NAME'),readRsltNode.ChildXmlNodes[1].ChildXmlNodes[0].NodeValue);
                                        else
                                            ERPDataMap.put(readRsltNode.ChildXmlNodes[1].Attributes.get('NAME'),menuval);
                                    }
                                    
                                }   
                                else
                                {
                                    if(strGetID !='ALF_1')
                                    {
                                        string listNodeval='';
                                        if(readLineNode.NodeName == 'LST')
                                        {                                                                                           
                                            listNodeval=readLineNode.ChildXmlNodes[0].NodeValue;                                        
                                            //ERPDataMap.put(readLineNode.Attributes.get('NAME'),listNodeval);
                                        }
                                        string menuval=valuesdescription(readLineNode.Attributes.get('NAME'), readLineNode.NodeValue);
                                        if(menuval =='')
                                        {
                                            if(readLineNode.NodeName == 'LST')
                                                ERPDataMap.put(readLineNode.Attributes.get('NAME'),listNodeval);
                                            else
                                                ERPDataMap.put(readLineNode.Attributes.get('NAME'),readLineNode.NodeValue);
                                        }
                                        else
                                            ERPDataMap.put(readLineNode.Attributes.get('NAME'),menuval);
                                    }
                                }
                            }      
                        }
                    }
                }
                else
                {
                    if (Sections.get(readRsltNode.Attributes.get('ID'))!=null )
                    {
                        for(ReadAndWriteXML.XmlNode readLineNode:lstTabNodes)
                        {      
                            //ERPDataMapDetailAll  =      new list<map<string,string>>();
                            ERPDataMapDetail = new map<string,string>();  
                            if(readLineNode.NodeName == 'LIN')
                            {
                                for(ReadAndWriteXML.XmlNode LineNode:readLineNode.ChildXmlNodes)
                                {
                                    string menuval=valuesdescription(LineNode.Attributes.get('NAME'), LineNode.NodeValue);
                                    if(menuval =='')
                                        ERPDataMapDetail.put(LineNode.Attributes.get('NAME') ,LineNode.NodeValue);
                                    else
                                        ERPDataMapDetail.put(LineNode.Attributes.get('NAME') ,menuval);
                                }
                            }
                            ERPDataMapDetailAll.Add(ERPDataMapDetail);
                        }
                        ERPDataMapRelSections.put(readRsltNode.Attributes.get('ID'),ERPDataMapDetailAll);
                    }
                }

            }

            ERPDataMapAll.add(ERPDataMap);
                      
            pGUMU_Response.ERPDataMap  = ERPDataMapAll;
            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll; 
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections; 

            //set the veriable for paging
            //TODO:Remove below 
            pGUMU_Response.TotalRecord = '1';
            pGUMU_Response.startIndex  = '1';
            pGUMU_Response.itemPerPage = '1';
            return pGUMU_Response;                   
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getMapForXML',ex,false);
            throw ex;
        }                    
    }   
           
    private list<map<string,string>> PrepareERPDataList(Helper.GUMU_Response pGUMU_Response)
    {
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';
        string retCount='';

        ReadAndWriteXML.XmlNode objXmlNode ;    
        list<map<string,string>> ErpDataList=new list<map<string,string>>();
        map<string,string> ErpData = new map<string,string>();  
        try
        {
            objXmlNode = ReadAndWriteXML.ParseXmlString(getResultXML(pGUMU_Response.responseERPData));
            list<ReadAndWriteXML.XmlNode> lstTabNodes = objXmlNode.ChildXmlNodes;

            for(ReadAndWriteXML.XmlNode TabNode :lstTabNodes)
            {
                string strAttrID  =TabNode.Attributes.get('ID');
                if(strAttrID == 'AX_PAR')
                {
                    list<ReadAndWriteXML.XmlNode> ParaMeterNodeslst = TabNode.ChildXmlNodes;
                    for(ReadAndWriteXML.XmlNode ParaMeterNodes :ParaMeterNodeslst)
                    {                      
                        if(ParaMeterNodes.ChildXmlNodes[0].NodeValue =='$REC_MAX')
                            itemPerPage =  ParaMeterNodes.ChildXmlNodes[1].NodeValue;

                        else if(ParaMeterNodes.ChildXmlNodes[0].NodeValue =='$REC_STARTAT')
                            startIndex=  ParaMeterNodes.ChildXmlNodes[1].NodeValue;

                        else if(ParaMeterNodes.ChildXmlNodes[0].NodeValue =='$TOTAL_COUNT')
                            totalRecords=  ParaMeterNodes.ChildXmlNodes[1].NodeValue;

                        else if(ParaMeterNodes.ChildXmlNodes[0].NodeValue =='$RET_COUNT')
                            retCount =  ParaMeterNodes.ChildXmlNodes[1].NodeValue;

                        else if(ParaMeterNodes.ChildXmlNodes[0].NodeValue =='$HAS_NEXT')
                            hasNext=  ParaMeterNodes.ChildXmlNodes[1].NodeValue;
                    }
                }
                else if(strAttrID=='RES')
                {   
                    list<ReadAndWriteXML.XmlNode> lstLineNodes = TabNode.ChildXmlNodes;             
                    for(ReadAndWriteXML.XmlNode LineNodes :lstLineNodes)
                    {
                        ErpData = new map<string,string>();
                        list<ReadAndWriteXML.XmlNode> lstFldNodes = LineNodes.ChildXmlNodes;
                        for(ReadAndWriteXML.XmlNode FldNodes :lstFldNodes)
                        {
                            string strchNodes =FldNodes.NodeValue;
                            
                            string menuval=valuesdescription(FldNodes.Attributes.get('NAME'), strchNodes);
                            if(menuval =='')                          
                                ErpData.put(FldNodes.Attributes.get('NAME'),strchNodes);
                            else
                                ErpData.put(FldNodes.Attributes.get('NAME'),menuval);                    
                        }
                        ErpDataList.add(ErpData);   
                    } 
                }                                       
            }
                      
            pGUMU_Response.ERPDataMap           = ErpDataList;
            pGUMU_Response.ERPDataMapDetail     = new list<map<string,string>>(); 
            pGUMU_Response.ERPDataMapRelSection = new map<string,list<map<string,string>>> ();
            //pGUMU_Response.TotalRecord = TotalRecords;
            pGUMU_Response.startIndex  = startIndex;
            pGUMU_Response.itemPerPage = itemPerPage;
            pGUMU_Response.totalRecord = totalRecords;
            return ErpDataList;     
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(className,'PrepareERPDataList',ex,false);
            throw ex;
        }   
    }
    
    public string getResultXML(string ERPData) 
    {
        system.debug('getResultXML123');
        system.debug('ERPData '+ERPData);
        try
        {
            String strResponse ;
            Dom.Document doc; 
            doc = new Dom.Document();
            if (Test.isRunningTest())
            {
                ERPData='<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"><soapenv:Body><ns1:actionObjectResponse soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns1="http://www.adonix.com/WSS"><actionObjectReturn href="#id0"/></ns1:actionObjectResponse><multiRef id="id0" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns2:CAdxResultXml" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/" xmlns:ns2="http://www.adonix.com/WSS"><messages soapenc:arrayType="ns2:CAdxMessage[0]" xsi:type="soapenc:Array"/><resultXml xsi:type="xsd:string">&lt;?xml version=&quot;1.0&quot; encoding=&quot;UTF-8&quot;?&gt;&lt;RESULT&gt;&lt;GRP ID=&quot;SOH0_1&quot;&gt;&lt;FLD NAME=&quot;SALFCY&quot; TYPE=&quot;Char&quot;&gt;NA012&lt;/FLD&gt;&lt;FLD NAME=&quot;SOHTYP&quot; TYPE=&quot;Char&quot;&gt;SON&lt;/FLD&gt;&lt;FLD NAME=&quot;ZSOHTYP&quot; TYPE=&quot;Char&quot;&gt;Normal&lt;/FLD&gt;&lt;FLD NAME=&quot;SOHNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;REVNUM&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;CUSORDREF&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ORDDAT&quot; TYPE=&quot;Date&quot;&gt;20160314&lt;/FLD&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCORD&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCNAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;W1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;WSOHCAT&quot; TYPE=&quot;Char&quot;&gt;Category : Normal&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_1&quot;&gt;&lt;FLD NAME=&quot;BPCINV&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;BPINAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCPYR&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;ZBPCPYR&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPCGRU&quot; TYPE=&quot;Char&quot;&gt;NA002&lt;/FLD&gt;&lt;FLD NAME=&quot;ZBPCGRU&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;BPDNAM&quot; TYPE=&quot;Char&quot;&gt;Amalgamate Supply&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_2&quot;&gt;&lt;FLD NAME=&quot;PJT&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_3&quot;&gt;&lt;LST NAME=&quot;REP&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;NA102&lt;/ITM&gt;&lt;/LST&gt;&lt;LST NAME=&quot;ZREP&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;ANDERSON Bill&lt;/ITM&gt;&lt;/LST&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_4&quot;&gt;&lt;FLD NAME=&quot;CCLREN&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VACBPR&quot; TYPE=&quot;Char&quot;&gt;NTX&lt;/FLD&gt;&lt;FLD NAME=&quot;ZVACBPR&quot; TYPE=&quot;Char&quot;&gt;No Tax&lt;/FLD&gt;&lt;FLD NAME=&quot;SSTENTCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZSSTENTCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CUR&quot; TYPE=&quot;Char&quot;&gt;USD&lt;/FLD&gt;&lt;FLD NAME=&quot;ZCUR&quot; TYPE=&quot;Char&quot;&gt;US Dollar&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Exclude tax&quot; MENULOCAL=&quot;243&quot; NAME=&quot;PRITYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_5&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;280&quot; NAME=&quot;APPFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Open&quot; MENULOCAL=&quot;415&quot; NAME=&quot;ORDSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Not Allocated&quot; MENULOCAL=&quot;416&quot; NAME=&quot;ALLSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Not delivered&quot; MENULOCAL=&quot;417&quot; NAME=&quot;DLVSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Not Invoiced&quot; MENULOCAL=&quot;418&quot; NAME=&quot;INVSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;OK&quot; MENULOCAL=&quot;419&quot; NAME=&quot;CDTSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;CDTBTN&quot; TYPE=&quot;Char&quot;&gt;280&lt;/FLD&gt;&lt;FLD MENULAB=&quot;OK&quot; MENULOCAL=&quot;491&quot; NAME=&quot;HLDSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;HLDBTN&quot; TYPE=&quot;Char&quot;&gt;280&lt;/FLD&gt;&lt;FLD NAME=&quot;HLDCOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH1_6&quot;&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;OCNPRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BETFCY&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;BETCPY&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_1&quot;&gt;&lt;FLD NAME=&quot;STOFCY&quot; TYPE=&quot;Char&quot;&gt;NA012&lt;/FLD&gt;&lt;FLD NAME=&quot;ZSTOFCY&quot; TYPE=&quot;Char&quot;&gt;NA BikeToy&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;410&quot; NAME=&quot;DLVPIO&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_2&quot;&gt;&lt;FLD NAME=&quot;DEMDLVDAT&quot; TYPE=&quot;Date&quot;&gt;20160315&lt;/FLD&gt;&lt;FLD NAME=&quot;DAYLTI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;SHIDAT&quot; TYPE=&quot;Date&quot;&gt;20160314&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_3&quot;&gt;&lt;FLD MENULAB=&quot;Route Code 1&quot; MENULOCAL=&quot;409&quot; NAME=&quot;DRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;MDL&quot; TYPE=&quot;Char&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;ZMDL&quot; TYPE=&quot;Char&quot;&gt;Ground&lt;/FLD&gt;&lt;FLD NAME=&quot;BPTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECICT&quot; TYPE=&quot;Char&quot;&gt;FOB&lt;/FLD&gt;&lt;FLD NAME=&quot;ICTCTY&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_4&quot;&gt;&lt;FLD NAME=&quot;LASDLVNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_5&quot;&gt;&lt;FLD NAME=&quot;SDHTYP&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZSDHTYP&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Yes&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ORDCLE&quot; TYPE=&quot;Integer&quot;&gt;2&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ODL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_6&quot;&gt;&lt;FLD MENULAB=&quot;Allowed&quot; MENULOCAL=&quot;414&quot; NAME=&quot;DME&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH2_7&quot;&gt;&lt;FLD MENULAB=&quot;Global&quot; MENULOCAL=&quot;450&quot; NAME=&quot;ALLTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH3_1&quot;&gt;&lt;FLD MENULAB=&quot;One/Shipment&quot; MENULOCAL=&quot;408&quot; NAME=&quot;IME&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH3_2&quot;&gt;&lt;FLD NAME=&quot;PTE&quot; TYPE=&quot;Char&quot;&gt;CH30NET&lt;/FLD&gt;&lt;FLD NAME=&quot;DEP&quot; TYPE=&quot;Char&quot;&gt;SGL01&lt;/FLD&gt;&lt;FLD NAME=&quot;ZDEP&quot; TYPE=&quot;Char&quot;&gt;2%10 InvDa&lt;/FLD&gt;&lt;FLD NAME=&quot;SQHNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PRFNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;LASINVNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;20&quot; ID=&quot;SOH3_3&quot; SIZE=&quot;6&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;CCT&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Cost Center&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;MAR&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Market&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;&gt;WHOLESALE&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;PRO&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Product&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;4&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;PRJ&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Projects&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;5&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;ENV&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Envelopes&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;6&quot;&gt;&lt;FLD NAME=&quot;DIE&quot; TYPE=&quot;Char&quot;&gt;ENT&lt;/FLD&gt;&lt;FLD NAME=&quot;NAMDIE&quot; TYPE=&quot;Char&quot;&gt;Entities&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;TAB DIM=&quot;30&quot; ID=&quot;SOH3_4&quot; SIZE=&quot;3&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Discount %&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;%&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;3&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;2&quot;&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Freight char&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Tax excl&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;LIN NUM=&quot;3&quot;&gt;&lt;FLD NAME=&quot;SHO&quot; TYPE=&quot;Char&quot;&gt;Insurance&lt;/FLD&gt;&lt;FLD NAME=&quot;INVDTAAMT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Tax excl&quot; MENULOCAL=&quot;2227&quot; NAME=&quot;INVDTATYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;SOH4_2&quot;&gt;&lt;FLD NAME=&quot;DLRNOT&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;PFMTOT&quot; TYPE=&quot;Decimal&quot;&gt;1.39&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH4_3&quot;&gt;&lt;FLD NAME=&quot;ORDNOT&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;SOH4_4&quot;&gt;&lt;FLD NAME=&quot;ORDINVNOT&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;ORDINVATI&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;/GRP&gt;&lt;TAB DIM=&quot;500&quot; ID=&quot;SOH4_1&quot; SIZE=&quot;1&quot;&gt;&lt;LIN NUM=&quot;1&quot;&gt;&lt;FLD NAME=&quot;NUMLIG&quot; TYPE=&quot;Integer&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;ITMREF&quot; TYPE=&quot;Char&quot;&gt;BMS002&lt;/FLD&gt;&lt;FLD NAME=&quot;ITMDES&quot; TYPE=&quot;Char&quot;&gt;5 Sprockets&lt;/FLD&gt;&lt;FLD NAME=&quot;ITMDES1&quot; TYPE=&quot;Char&quot;&gt;5 Sprockets&lt;/FLD&gt;&lt;FLD NAME=&quot;DSTOFCY&quot; TYPE=&quot;Char&quot;&gt;NA012&lt;/FLD&gt;&lt;FLD NAME=&quot;SAU&quot; TYPE=&quot;Char&quot;&gt;UN&lt;/FLD&gt;&lt;FLD NAME=&quot;QTY&quot; TYPE=&quot;Decimal&quot;&gt;1.00&lt;/FLD&gt;&lt;FLD NAME=&quot;SAUSTUCOE&quot; TYPE=&quot;Decimal&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;STU&quot; TYPE=&quot;Char&quot;&gt;UN&lt;/FLD&gt;&lt;FLD NAME=&quot;ALLQTY&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;SHTQTY&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;WALLQTY&quot; TYPE=&quot;Decimal&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Global&quot; MENULOCAL=&quot;450&quot; NAME=&quot;DALLTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;TDLQTY&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;GROPRI&quot; TYPE=&quot;Decimal&quot;&gt;5.1745&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL1&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL2&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL3&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL4&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL5&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;DISCRGVAL6&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;NETPRI&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;CPRPRI&quot; TYPE=&quot;Decimal&quot;&gt;3.78&lt;/FLD&gt;&lt;FLD NAME=&quot;PFM&quot; TYPE=&quot;Decimal&quot;&gt;1.39&lt;/FLD&gt;&lt;FLD NAME=&quot;VACITM1&quot; TYPE=&quot;Char&quot;&gt;NOR&lt;/FLD&gt;&lt;FLD NAME=&quot;VACITM2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VACITM3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;REP1&quot; TYPE=&quot;Char&quot;&gt;NA102&lt;/FLD&gt;&lt;FLD NAME=&quot;REPRAT1&quot; TYPE=&quot;Decimal&quot;&gt;5&lt;/FLD&gt;&lt;FLD NAME=&quot;REP2&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;REPRAT2&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;REPCOE&quot; TYPE=&quot;Decimal&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DDEMDLVDAT&quot; TYPE=&quot;Date&quot;&gt;20160315&lt;/FLD&gt;&lt;FLD NAME=&quot;DDAYLTI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DSHIDAT&quot; TYPE=&quot;Date&quot;&gt;20160314&lt;/FLD&gt;&lt;FLD NAME=&quot;EXTDLVDAT&quot; TYPE=&quot;Date&quot;&gt;20160315&lt;/FLD&gt;&lt;FLD NAME=&quot;DBPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;CNDNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;USEPLC&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;410&quot; NAME=&quot;DDLVPIO&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Route Code 1&quot; MENULOCAL=&quot;409&quot; NAME=&quot;DDRN&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DMDL&quot; TYPE=&quot;Char&quot;&gt;3&lt;/FLD&gt;&lt;FLD NAME=&quot;DBPTNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PRECOD&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PCK&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;PCKCAP&quot; TYPE=&quot;Decimal&quot;&gt;0&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE1&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE2&quot; TYPE=&quot;Char&quot;&gt;WHOLESALE&lt;/FLD&gt;&lt;FLD NAME=&quot;CCE3&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE4&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE5&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE6&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE7&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE8&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE9&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE10&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE11&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE12&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE13&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE14&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE15&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE16&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE17&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE18&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE19&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;CCE20&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Firm&quot; MENULOCAL=&quot;317&quot; NAME=&quot;DEMSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Stock&quot; MENULOCAL=&quot;445&quot; NAME=&quot;FMI&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;FMINUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;LINORDNOT&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;LINORDATI&quot; TYPE=&quot;Decimal&quot;&gt;5.17&lt;/FLD&gt;&lt;FLD NAME=&quot;LINPFM&quot; TYPE=&quot;Decimal&quot;&gt;1.39&lt;/FLD&gt;&lt;FLD NAME=&quot;DETSQHNUM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD MENULAB=&quot;Normal&quot; MENULOCAL=&quot;423&quot; NAME=&quot;LINTYP&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;439&quot; NAME=&quot;FOCFLG&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD MENULAB=&quot;Pending&quot; MENULOCAL=&quot;279&quot; NAME=&quot;SOQSTA&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;FLD NAME=&quot;DCCLREN&quot; TYPE=&quot;Char&quot;/&gt;&lt;/LIN&gt;&lt;/TAB&gt;&lt;GRP ID=&quot;ADB1_1&quot;&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;Ad001&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;LST NAME=&quot;BPAADDLIG&quot; SIZE=&quot;3&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;700, Northside Street&lt;/ITM&gt;&lt;ITM&gt;700, Northside Street&lt;/ITM&gt;&lt;ITM&gt;700, Northside Street&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;00501&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Holtsville&lt;/FLD&gt;&lt;FLD NAME=&quot;ITINERAIRE&quot; TYPE=&quot;Char&quot;&gt;226&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;NY&lt;/FLD&gt;&lt;FLD NAME=&quot;VALADR&quot; TYPE=&quot;Char&quot;&gt;102&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ADRVAL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADB2_1&quot;&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;LST NAME=&quot;BPAADDLIG&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;136 Wexford Run Road&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;15143&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Sewickley&lt;/FLD&gt;&lt;FLD NAME=&quot;ITINERAIRE&quot; TYPE=&quot;Char&quot;&gt;226&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;PA&lt;/FLD&gt;&lt;FLD NAME=&quot;CNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECNUMX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VALADR&quot; TYPE=&quot;Char&quot;&gt;102&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADB3_1&quot;&gt;&lt;LST NAME=&quot;BPRNAM&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;Amalgamate Supply&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;BPAADD&quot; TYPE=&quot;Char&quot;&gt;CORP&lt;/FLD&gt;&lt;FLD NAME=&quot;CRY&quot; TYPE=&quot;Char&quot;&gt;US&lt;/FLD&gt;&lt;FLD NAME=&quot;CRYNAM&quot; TYPE=&quot;Char&quot;&gt;United States of America&lt;/FLD&gt;&lt;LST NAME=&quot;BPAADDLIG&quot; SIZE=&quot;1&quot; TYPE=&quot;Char&quot;&gt;&lt;ITM&gt;136 Wexford Run Road&lt;/ITM&gt;&lt;/LST&gt;&lt;FLD NAME=&quot;POSCOD&quot; TYPE=&quot;Char&quot;&gt;15143&lt;/FLD&gt;&lt;FLD NAME=&quot;CTY&quot; TYPE=&quot;Char&quot;&gt;Sewickley&lt;/FLD&gt;&lt;FLD NAME=&quot;ITINERAIRE&quot; TYPE=&quot;Char&quot;&gt;226&lt;/FLD&gt;&lt;FLD NAME=&quot;SAT&quot; TYPE=&quot;Char&quot;&gt;PA&lt;/FLD&gt;&lt;FLD NAME=&quot;CNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;ZCNTNAM&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;EECNUMX&quot; TYPE=&quot;Char&quot;/&gt;&lt;FLD NAME=&quot;VALADR&quot; TYPE=&quot;Char&quot;&gt;102&lt;/FLD&gt;&lt;FLD MENULAB=&quot;No&quot; MENULOCAL=&quot;1&quot; NAME=&quot;ADRVAL&quot; TYPE=&quot;Integer&quot;&gt;1&lt;/FLD&gt;&lt;/GRP&gt;&lt;GRP ID=&quot;ADXTEC&quot;&gt;&lt;FLD NAME=&quot;WW_MODSTAMP&quot; TYPE=&quot;Char&quot;&gt;00000000000000&lt;/FLD&gt;&lt;FLD NAME=&quot;WW_MODUSER&quot; TYPE=&quot;Char&quot;/&gt;&lt;/GRP&gt;&lt;/RESULT&gt;</resultXml><status xsi:type="xsd:int">1</status><technicalInfos href="#id1"/></multiRef><multiRef id="id1" soapenc:root="0" soapenv:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/" xsi:type="ns3:CAdxTechnicalInfos" xmlns:ns3="http://www.adonix.com/WSS" xmlns:soapenc="http://schemas.xmlsoap.org/soap/encoding/"><busy xsi:type="xsd:boolean">false</busy><changeLanguage xsi:type="xsd:boolean">false</changeLanguage><changeUserId xsi:type="xsd:boolean">false</changeUserId><flushAdx xsi:type="xsd:boolean">false</flushAdx><loadWebsDuration xsi:type="xsd:double">0.132</loadWebsDuration><nbDistributionCycle xsi:type="xsd:int">1</nbDistributionCycle><poolDistribDuration xsi:type="xsd:double">5.9373</poolDistribDuration><poolEntryIdx xsi:type="xsd:int">0</poolEntryIdx><poolExecDuration xsi:type="xsd:double">803.5804</poolExecDuration><poolRequestDuration xsi:type="xsd:double">810.0612</poolRequestDuration><poolWaitDuration xsi:type="xsd:double">0.5377</poolWaitDuration><processReport xsi:type="xsd:string" xsi:nil="true"/><processReportSize xsi:type="xsd:int">0</processReportSize><reloadWebs xsi:type="xsd:boolean">false</reloadWebs><resumitAfterDBOpen xsi:type="xsd:boolean">false</resumitAfterDBOpen><rowInDistribStack xsi:type="xsd:int">1</rowInDistribStack><totalDuration xsi:type="xsd:double">851.9312</totalDuration><traceRequest xsi:type="xsd:string" xsi:nil="true"/><traceRequestSize xsi:type="xsd:int">0</traceRequestSize></multiRef></soapenv:Body></soapenv:Envelope>';
                //return strResponse;
            }
            doc.load(ERPData);
            Dom.XMLNode Envelope = doc.getRootElement();       
            Dom.XMLNode Body= Envelope.getChildElements()[0];       
            for(Dom.XMLNode child : Body.getChildElements()) 
            {
                for(Dom.XMLNode subchild : child.getChildElements()) 
                {
                    if(subchild.getName() == 'resultXml')
                    {
                        strResponse = string.valueof(subchild.getText());
                        if(strResponse !=null ||strResponse!='')
                            break;                        
                    }
                    else if(subchild.getName() == 'message' && child.getAttribute('id','')=='id1' && (strResponse ==null ||strResponse==''))
                    {
                        strResponse = string.valueof(subchild.getText());
                        strResponse ='Error '+strResponse;
                        return strResponse;
                    }
                }
            }
            
            return strResponse;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getResultXML',ex,false);
            throw ex;
        }
    }
    
    
    //This function is used to creare parameters based on no of parameters 
    public override map<string,map<string,list<string>>> PrepareFieldParam(String Param1, String Param2)
    {   
        map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
        try
        {
            if(Param1 == '' && Param2=='')
                return fieldParameters ;  
            else if (Param1 != '' && Param2=='') 
            {
                map<string,list<string>> parameter = new map<string,list<string>>();
                list<string> listParams=new list<string> ();
    
                //TODO for date field do this discuss where we need to implement this 
                String[] aDatePart= Param1.split('/');
                listParams.add(aDatePart[2]+aDatePart[0]+aDatePart[1]);
                parameter.put(string.valueOf(Helper.Operator.GREATER_OR_EQUAL),listParams);
                fieldParameters.put('UPDDAT',parameter);
            }
            else
            {
                map<string,list<string>> parameter = new map<string,list<string>>();
                list<string> listParams=new list<string> ();
                listParams.add(Param1);
                listParams.add(Param2);
                parameter.put(string.valueOf(Helper.Operator.RANGE),listParams);
                fieldParameters.put('BPCNUM',parameter);
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'PrepareFieldParam',ex,false);
            throw ex;
        } 

        return fieldParameters ;  
    }

    //This function is used to get the field name that used for auto match
    public override string GetFieldForAutoMatch()
    {
        return 'BPCNAM';
    }

    //This function is used to get the common ERP data map format for specific ERP data
    public override list<Helper.Customer> GetGenericCustomers(Helper.GUMU_Response pGUMU_Response)
    {
        List<Helper.Customer> lstCustomer = New List<Helper.Customer>();
        Helper.Customer oCustomer;
        
        try
        {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Info, 'pGUMU_Response.ERPDataMap '+pGUMU_Response.ERPDataMap)); 

            if(pGUMU_Response.ERPDataMap!= null)
            {
                for (Map<String,String> RecMap : pGUMU_Response.ERPDataMap)
                {
                    oCustomer = new Helper.Customer();
                    oCustomer.UniqueKey =  RecMap.get('BPCNUM'); 
                    oCustomer.CategoryCode =  RecMap.get('BPCTYP'); //TODO //Check this
                    oCustomer.CustomerName =  RecMap.get('BPCNAM'); 
                    lstCustomer.add(oCustomer);
                }  
            }              
        }
        catch(exception ex)
        {
            CustomException exc= new CustomException(ClassName,'GetGenericCustomers',ex,false);
            throw ex;          
        }
        return lstCustomer;
        
    }


    /*getting all dropdown data from erp and inseting into salesforce*/
   /* public list<sObject> getDropDowns(ERP_Config__c oIntegration,Entity_Mapping_Header__c MappingHeader, list<map<String,String>> RecordList)
    {
        sObject records = Schema.getGlobalDescribe().get(MappingHeader.TARGET_ENTITY__C).newSObject() ;
        Schema.SObjectType sObj = records.getSObjectType();

        List<SObject> sObjectList;
        try
        {
            if (sObj != null)
            {
                sObjectList = (List<SObject>)Type.forName('List<'+sObj+'>').newInstance();
            }
    
            list<Entity_Fields_Mapping_Detail__c> fieldMappingDetails;               
    
            fieldMappingDetails=[select Salesforce_Field__c,ERP_Field__c From Entity_Fields_Mapping_Detail__c where  Entity_Mapping_Id__c=:MappingHeader.Id]; 
    
            for (map<String,String> record : RecordList)
            {
                sObject sObjData =sObj.newSObject();
                sObjData.put('Integration_Key__c',oIntegration.Id);
    
                for(Entity_Fields_Mapping_Detail__c fieldMap:fieldMappingDetails) 
                {                                       
                    if (record.get(fieldMap.ERP_Field__c) != null)
                    {
                        sObjData.put(fieldMap.Salesforce_Field__c,record.get(fieldMap.ERP_Field__c));
                    }   
                }
                if(MappingHeader.TARGET_ENTITY__C =='Currency__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('CUR'));
                }
    
                else if(MappingHeader.TARGET_ENTITY__C =='Language__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('LAN'));
                }
    
                else if(MappingHeader.TARGET_ENTITY__C =='Salesperson__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('REPNUM'));
                }
    
                else if(MappingHeader.TARGET_ENTITY__C =='TermsCode__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('PTE')+'-'+ record.get('LEG')+'-'+ record.get('PTELIN'));
                }
    
                else if(MappingHeader.TARGET_ENTITY__C =='CustomerCategory__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('BCGCOD'));
                }
    
                else if(MappingHeader.TARGET_ENTITY__C =='TaxRule__c')
                {
                    sObjData.put('External_UId__c', oIntegration.Id+'-'+record.get('VACBPR')+'-'+record.get('LEG'));
                }
                else if(MappingHeader.TARGET_ENTITY__C =='ERPSite__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('FCY'));
                }
                else if(MappingHeader.TARGET_ENTITY__C =='UOM__c')
                {
                    sObjData.put('External_UId__c',oIntegration.Id+'-'+record.get('UOM'));
                }
                                                    
                sObjectList.add(sObjData); 
                
            } 
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getDropDowns',ex,false);
            throw ex;
        }  
        if (sObjectList.size()>0)
            return sObjectList;
        else
            return null;                

    }*/
    
    
    private map<string,string> getRealTimeProductData(Helper.GUMU_Response oGUMU_Response)
    {
        map<string,string> SFMapData = new map<string,string>();
        list<map<string,string>> mapData = oGUMU_Response.ERPDataMap;
        system.debug('mapData '+jSon.serialize(mapData));
        try
        {
           if(mapData !=null)
           {
                SFMapData.put('hdr-Tax',mapData[0].get('ORDINVNOT'));
                SFMapData.put('hdr+Tax',mapData[0].get('ORDINVATI'));
        
                mapData = new list<map<string,string>>();
                mapData = oGUMU_Response.ERPDataMapDetail;
                if(mapData.size() >0)
                {
                    SFMapData.put('ItemCode',mapData[0].get('ITMREF'));
                    SFMapData.put('ItemDescription',mapData[0].get('ITMDES'));
                    SFMapData.put('UOM',mapData[0].get('SAU'));
                    SFMapData.put('UnitPrice',mapData[0].get('GROPRI'));
                    SFMapData.put('TaxClass',mapData[0].get('VACITM1'));
                    SFMapData.put('Salessite',mapData[0].get('DSTOFCY'));
                    SFMapData.put('discountper',mapData[0].get('DISCRGVAL1'));
                    SFMapData.put('taxrate',mapData[0].get('REPRAT1'));
                    SFMapData.put('netPrice',mapData[0].get('ORDNOT'));
                    SFMapData.put('amt+tax',mapData[0].get('LINORDATI'));
                    SFMapData.put('amt-tax',mapData[0].get('LINORDNOT'));
                    SFMapData.put('Quantity',mapData[0].get('QTY'));
                    SFMapData.put('QOH','0');
                }
           }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getRealTimeProductData',ex,false);
            throw ex;
        } 
        
        return SFMapData;
    }
    
    private map<string,string> getReferenceID(Helper.GUMU_Response oGUMU_Response)
    {
        map<string,string> SFMapData = new map<string,string>();
        list<map<string,string>> mapSFDataList = oGUMU_Response.ERPDataMap;
        try
        {       
            if(mapSFDataList !=null)
            {
                for(map<string,string> mapSFData :mapSFDataList)
                {
                    for(string key : mapSFData.keySet())
                    {
                        if(key == 'SOHNUM')
                            SFMapData.put('OrderNo',mapSFData.get(key));
                        if(key == 'BPCNUM')
                            SFMapData.put('CustNo',mapSFData.get(key));
                    }
                }
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getReferenceID',ex,false);
            throw ex;
        } 
        return SFMapData;
    }
    
    
    //This function is used to get the list of map of Sage X3 ERP data  
    public Helper.GUMU_Response getMapForXML_Schema(Helper.GUMU_Response pGUMU_Response,map<string,list<object>> AttribParams)
    { 
        string Response=getResultXML(pGUMU_Response.responseERPData);
        pGUMU_Response.responseERPData=Response;
        Dom.Document doc;
        ReadAndWriteXML.XmlNode objXmlNode;
        string totalRecords='';  
        string itemPerPage='';  
        string startIndex=''; 
        string hasNext='';    
        string nodeText='';
        map<string,string> Sections = new map<string,string>();
        map<string,string> ERPDataMap            =      new map<string,string>();
        list<map<string,string>> ERPDataMapAll   =      new list<map<string,string>>();

        map<string,string> ERPDataMapDetail             =      new map<string,string>();
        list<map<string,string>> ERPDataMapDetailAll    =      new list<map<string,string>>(); 
        map<string,list<map<string,string>>> ERPDataMapRelSections    = new map<string,list<map<string,string>>> ();

        try
        { 
            objXmlNode = new ReadAndWriteXML.XmlNode();
            objXmlNode = ReadAndWriteXML.ParseXmlString(Response);
            list<ReadAndWriteXML.XmlNode> lstRsltNode = objXmlNode.ChildXmlNodes;
            map<string,list<string>> MapValuesList = new map<string,list<string>>();
            
            for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
            {
                if(readRsltNode.NodeName == 'ADXMEN')
                {
                    list<ReadAndWriteXML.XmlNode> lstMNUNodes = readRsltNode.ChildXmlNodes;
                    for(ReadAndWriteXML.XmlNode readLineNode:lstMNUNodes)
                    {
                        if(readLineNode.NodeName == 'MNU')
                        {
                             list<ReadAndWriteXML.XmlNode> lstVALNodes = readLineNode.ChildXmlNodes;
                             list<string> ValueList = new list<string>(); 
                                              
                             for(ReadAndWriteXML.XmlNode lstVALNode:lstVALNodes)
                                ValueList.Add(lstVALNode.Attributes.get('IND') + '-' + lstVALNode.Attributes.get('C_ENG') + '\n');
                             MapValuesList.put(readLineNode.Attributes.get('NO'),ValueList);
                        }
                    }
                }
            }
            
            for(ReadAndWriteXML.XmlNode readRsltNode:lstRsltNode)
            {
                if(readRsltNode.NodeName == 'ADXDATA')
                {
                    list<ReadAndWriteXML.XmlNode> lstGRPNodes = readRsltNode.ChildXmlNodes;
                    
                    for(ReadAndWriteXML.XmlNode readLineNode:lstGRPNodes)
                    {   
                        if (readLineNode.Attributes.get('NAM') == 'AX_PAR' ||
                        readLineNode.Attributes.get('NAM') == 'AX_WHR' ||
                        readLineNode.Attributes.get('NAM') == 'AX_ORD' )
                            continue;
                            
                        string GroupName= '';
                        if(readLineNode.NodeName == 'GRP')
                        {   
                             if(readLineNode.Attributes.get('TYB') == 'Table')
                             {
                                GroupName = readLineNode.Attributes.get('NAM');                             
                             }
                             
                             list<ReadAndWriteXML.XmlNode> lstFLDNodes = readLineNode.ChildXmlNodes;
                             for(ReadAndWriteXML.XmlNode lstFLDNode:lstFLDNodes)
                             {              
                                    ERPDataMap= new map<string,string>();
                                    ERPDataMap.put('GroupName',GroupName);
                                    ERPDataMap.put('APILabel',lstFLDNode.Attributes.get('C_ENG'));
                                    ERPDataMap.put('DataType',lstFLDNode.Attributes.get('TYP'));
                                    ERPDataMap.put('APIName',lstFLDNode.Attributes.get('NAM'));
                                                
                                    if ( lstFLDNode.Attributes.get('MEN') !=null)
                                    {
                                        list<string> ValueList;
                                        string values='';
                                        ValueList = MapValuesList.get ( lstFLDNode.Attributes.get('MEN'));
                                        for (string val:ValueList )
                                            values=values  + val; 
                                        ERPDataMap.put('ListOfValues',values );
                                    }               
                                    ERPDataMapAll.add(ERPDataMap);
                               }
                        }
                    }
                }
            }
                                                  
            ERPDataMapAll.add(ERPDataMap);
            pGUMU_Response.ERPDataMap  = ERPDataMapAll;
            pGUMU_Response.ERPDataMapDetail     = ERPDataMapDetailAll; 
            pGUMU_Response.ERPDataMapRelSection = ERPDataMapRelSections; 
                                                
            //set the veriable for paging
            //TODO:Remove below 
            pGUMU_Response.TotalRecord = '1';
            pGUMU_Response.startIndex  = '1';
            pGUMU_Response.itemPerPage = '1';
            return pGUMU_Response;                   
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'getMapForXML_Schema',ex,false);
            throw ex;
        }                    
    }   
    
    //Get the field of Web method
    public override Helper.GUMU_Response ReadSchema(string MethodName,string Integration_Key)
    {
        try
        {
            map<string,list<object>> AttribParams = new map<string,list<object>>();
            list<string> FinderName = new list<string>();
            list<string> RequestType = new list<string>();
            list<string> IntegrationId= new list<string>();
            list<string> startIndex= new list<string>();
            list<string> count= new list<string>();
            Entity_Detail__c Entity_Detail ;
            list<Entity_Detail__c> Entity_Details = new list<Entity_Detail__c>() ;
            FinderName.add(MethodName);
            RequestType.add('getDescription');
            IntegrationId.add(Integration_Key);
            startIndex.add('1');
            count.add('1');
            AttribParams.put('DataFinder',FinderName);
            AttribParams.put('RequestType',RequestType);
            AttribParams.put('IntegrationId',IntegrationId);
            AttribParams.put('startIndex',startIndex);
            AttribParams.put('count',count);
            
            Helper.GUMU_Response oGUMU_Response=new  Helper.GUMU_Response();             
            oGUMU_Response=provider.getRecords(null,AttribParams);
               
            if(oGUMU_Response.statusCode =='0')
            {
                return oGUMU_Response;
            }
            if(oGUMU_Response.statusCode !='200' && oGUMU_Response.statusCode !='201'  )
            {
                
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'Status Code:'+oGUMU_Response.statusCode));
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'Status Message:'+oGUMU_Response.statusMessage));
                ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Error, 'Detail Message:'+oGUMU_Response.responseERPData));
                return oGUMU_Response;
            }
            
            getMapForXML_Schema(oGUMU_Response,AttribParams);    
            map<string,string> AddedMap = new map<string,string> ();
              
            for(map<string,string> mapSFData : oGUMU_Response.ERPDataMap)
            {
                Entity_Detail = new Entity_Detail__c ();
                Entity_Detail.Name= mapSFData.get('APILabel');
                Entity_Detail.Data_Type__c=mapSFData.get('DataType');
                Entity_Detail.Field_APIName__c=mapSFData.get('APIName');
                Entity_Detail.Values__c=mapSFData.get('ListOfValues');
                Entity_Detail.Group_Name__c=mapSFData.get('GroupName');
                if (mapSFData.get('APILabel') !=null && AddedMap.get(mapSFData.get('APIName'))==null)   
                {
                    Entity_Details.Add(Entity_Detail);
                    AddedMap.put(mapSFData.get('APIName'),mapSFData.get('APIName'));
                }
            }
   
             oGUMU_Response.responseSFData=Entity_Details;
             return oGUMU_Response;
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException(ClassName,'ReadSchema',ex,false);
            throw ex;
        } 
    } 
    
    //function to create for fetching menu values
    public string valuesdescription(string ERPField,string ERPValue)
    {
        string menulab='';
        //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:ErpDataList:'+ jSon.serialize(EntityDetailList)));
         for( Entity_Detail__c EntityDetail:EntityDetailList)
         {
            if(EntityDetail.Field_APIName__c == ERPField && string.isNotBlank(EntityDetail.Values__c))
            {
                string erpdecval = EntityDetail.Values__c;
                list<string> valuelist =  erpdecval.split('\n');
                for(string values : valuelist)
                {
                    if(ERPValue == values.subString(0,1))
                        menulab = values.subString(2,values.length());
                        
                    if(ERPField == 'PPTFLG')
                    {
                        if(menulab == 'Yes')
                            menulab='Prospect';
                        else
                            menulab='Customer';
                    }   
                }
            }
            
            else if(ERPField == 'STA')
            {
                if(ERPValue == '3')
                    menulab='Posted';
                else if(ERPValue == '2')
                    menulab='Not used';
                else
                    menulab='Not posted';
            }
         } 
         return menulab;    
    } 
 
}
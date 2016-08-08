//This class is used Common Helper Methods of inegtration
global class Helper
{
    //Enum to check HttpResponse status
    public enum Status {SUCCESS, UNAUTHORISED}
    //Enum to define filtering operators
    public enum Operator {EQUAL, RANGE, INSPECIFIED, GREATER_OR_EQUAL, LESSER_OR_EQUAL, IN_CLAUSE, LIKE_CALUSE, GREATER_THAN, NOT_EQUAL,STARTS_WITH,DOES_NOT_CONTAIN,LESS_THAN,CONTAINS}
    //Enum to define filtering operators
    public enum MappingPurpose {SYNC, DISPLAY, POST, ACTION, MODIFY}
    //ClassName
    private static final string className='Helper';
    public static list<string> retURL=new list<string> ();

    public  Helper(){}
    
    //Method will return the ERP and using the same Framework will work
     public String getERP(string IntegrationKey)
        {
            string sERPSystemName='';
            if(string.isNotBlank(IntegrationKey))
            {
                sERPSystemName = [select ERP_System__c from ERP_Config__c where Id=:IntegrationKey].ERP_System__c;                  
            }
            else
            {
                List<GUMU_App_Setting__c> AppSettings = GUMU_App_Setting__c.getall().values();
                if (AppSettings.size()==0)
                    return '';
                sERPSystemName = AppSettings[0].ERP_System__c;
            }
            
            return sERPSystemName;
        }


    //Method will preapre html table code to display Sections & grids on vf page
    public static String prepareTable(List<Utility.PageComponent> griddetaildata)
    {
        String createGridHTML='';
        Boolean check=true;
        integer recordscount=0;
        string Inquiry='';
        list<Data_Page__c> Data_Page;
        try
        {
            // Check if the user has read access on the StaticResource.Bodyfield
            if (!Schema.sObjectType.Data_Page__c.fields.Name.isAccessible()){
              return '';
            }
            
            createGridHTML +='<table border="1" cellpadding="5" cellspacing="0" class="list" style="width:100%; height: 70%;border-left:0px !important;border-right:0px !important">';     
            createGridHTML+='<tr class="headerRow" >';
            
            for(Utility.PageComponent griddata: griddetaildata) 
            {
                if(griddata.DataType == 'Decimal' || griddata.DataType == 'Number' )
                    createGridHTML+='<td class="hdr" align="right">'+griddata.ComponentName+'</td>';
                else
                    createGridHTML+='<td class="hdr">'+griddata.ComponentName+'</td>';
                
                if(check == true)
                {
                    recordscount= griddata.Value.size();
                    check= false;
                }
            }
            for(integer j=0; j< griddetaildata.Size(); j++)
            {
                integer blankCount= recordscount-griddetaildata[j].Value.size();
                if(blankCount > 0)
                {
                    for(integer m=0; m< blankCount; m++)
                    {
                        griddetaildata[j].Value.add('');
                    }
                }
            }
            createGridHTML+='</tr>';
            for(integer i=0; i< recordscount; i++)
            {
                createGridHTML+='<tr class="dataRow">';
                for(integer j=0; j< griddetaildata.Size(); j++)
                {
                    if(griddetaildata[j].DataType == 'Checkbox')
                    {
                        if(griddetaildata[j].Value[i] == 'true' ||griddetaildata[j].Value[i] == '2' ||griddetaildata[j].Value[i] == 'Y')
                            createGridHTML+='<td class="dataCell"><form><input type="checkbox" disabled = true checked="checked"></form></td>';
                        else
                            createGridHTML+='<td class="dataCell"><form><input type="checkbox" disabled = true ></form></td>';
                    }
                    else if(griddetaildata[j].DataType == 'Date')
                    {
                        string strdate= string.valueof(griddetaildata[j].Value[i]);
                        //String[] tokens = strdate.split('-');
                        string tokens = strdate.replace('-','');
                        string newDate ;
                        
                        if (tokens.length()==8)
                        {
                            newDate = tokens.subString(4,6) +'/'+tokens.subString(6,8)+'/'+tokens.subString(0,4);
                        }
                        else
                        {
                        	
                            newDate = Utility.dateFormat(tokens);
                        }  
                        
                         
                       
                        createGridHTML+='<td class="dataCell">'+newDate+'</td>';             
                    }
                    else
                    {
                    	//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:griddetaildata: '+ jSon.serialize(griddetaildata)));
                        if(griddetaildata[j].Value.size() > 0)
                        {
                            if(griddetaildata[j].Value[i] != null && griddetaildata[j].Value[i] != '')
                            {   
                                if(griddetaildata[j].LinkTo == '' || griddetaildata[j].LinkTo == null)
                                {
                                    if(griddetaildata[j].DataType == 'Number' || griddetaildata[j].DataType == 'Decimal')
                                    {
                                        if(griddetaildata[j].Value[i] =='**NA**' || griddetaildata[j].Value[i]== null || griddetaildata[j].Value[i]== '')
                                            createGridHTML+='<td class="dataCell">'+' '+'</td>';
                                        else
                                        {
                                            if(griddetaildata[j].DataType == 'Decimal')
                                            {
                                                decimal decimalFld = double.valueof(griddetaildata[j].Value[i]);
                                                createGridHTML+='<td class="dataCell" align="right">'+decimalFld.setscale(2)+'</td>';  
                                            }
                                            else
                                                createGridHTML+='<td class="dataCell" align="right">'+griddetaildata[j].Value[i]+'</td>';  
                                        } 
                                    }
                                    else
                                    {
                                        if(griddetaildata[j].Value[i] =='**NA**' || griddetaildata[j].Value[i]== null || griddetaildata[j].Value[i]== '')
                                            createGridHTML+='<td class="dataCell">'+' '+'</td>';
                                        else
                                            createGridHTML+='<td class="dataCell">'+griddetaildata[j].Value[i]+'</td>';    
                                    }
                                }
                                else
                                {                                   
                                    //createGridHTML+='<td class="dataCell"><a class="actionLink" href="javascript:void(0)" onclick="showLoading(); fncdisplayDetail(false, \''+griddetaildata[j].ComponentSFId+'\', \''+griddetaildata[j].Value[i]+'\')">'+griddetaildata[j].Value[i]+'</a></td>';
                                    string KeyField=griddetaildata[j].KeyField;
                                    
                                    
                                    //Run only first time 
                                    if (Inquiry=='')
                                    {
                                        Data_Page= [select Name from Data_Page__c where Id =: griddetaildata[j].LinkTo];
                                        Inquiry = Data_Page[0].Name;
                                    }  

                                    createGridHTML+='<td class="dataCell"><a class="actionLink" href="javascript:void(0)" onclick="showLoading(); fncdisplayDetail(\''+Inquiry +'\',\''  + KeyField +'\', \''+griddetaildata[j].Value[i]+'\')">'+griddetaildata[j].Value[i]+'</a></td>';
                                    
                                }
                            }
                            else
                                createGridHTML+='<td class="dataCell">'+' '+'</td>';
                        }
                        else
                            createGridHTML+='<td class="dataCell">'+' '+'</td>';
                    }
                }
                createGridHTML+='</tr>';
            }

            createGridHTML +='</table>';
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException(className,'prepareTable',ex);
            throw ex;
        }
        return createGridHTML;
    }

    //Creates actual filter section on visualforce page.
    public static Component.Apex.PageBlock prepareFilterSection(List<Utility.PageComponent> pagecomponents, Helper.GUMU_Response resGUMU_Response, integer endindex)
    { 

        integer sectioncount = 0;
        Component.Apex.PageBlock dnyPageBlock = new Component.Apex.PageBlock();          
        Component.Apex.PageBlockSection dnyPageBlockSec;
        Component.Apex.PageBlockSectionItem dnyPageBlockSecItm;
        integer sindex=0;
        integer retcount=0;
        String retcnt = '';
        String si ='';
        try
        {
            for (integer i=0; i< pagecomponents.size(); i++)  
            {
                if(pagecomponents[i].ComponentType == 'Section')
                    sectioncount++;
                if(sectioncount == 2)
                    break;
            }

            for (integer i=0; i< pagecomponents.size(); i++)        
            {
                if(pagecomponents[i].ComponentType == 'Detail')
                {
                    dnyPageBlockSecItm = new Component.Apex.PageBlockSectionItem();
                    Component.Apex.OutputLabel outputlbl = new Component.Apex.OutputLabel();
                    Component.Apex.OutputLabel outputlblval = new Component.Apex.OutputLabel();
                    outputlbl.value = pagecomponents[i].ComponentName;
                    string datatype= pagecomponents[i].DataType;
                    dnyPageBlockSecItm.childComponents.add(outputlbl);          
                    if (datatype == 'CHECKBOX' ||datatype == 'Checkbox') 
                    {
                        Component.Apex.InputCheckbox checkbox = new Component.Apex.InputCheckbox();
                        checkbox.id = pagecomponents[i].APIName;
                        for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                        {
                        	if(pagecomponents[i].Value[0] =='2' ||pagecomponents[i].Value[0] =='true' ||pagecomponents[i].Value[0] =='Y')
                        		checkbox.value = true;
                        	else
                            	checkbox.value = false;
                            //checkbox.value = ERPCustomerDetailCntlr_TEST1.checkval;
                        }
                        checkbox.disabled = true;
                        dnyPageBlockSecItm.childComponents.add(checkbox);
                    } 
                    else 
                    {           
                        if (datatype == 'Date')
                        {
                            for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                            {
                                
                                string strdate= string.valueof(pagecomponents[i].Value[0]);
                                //String[] tokens = strdate.split('-');
                                string tokens = strdate.replace('-','');
                                string newDate ;
                               // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:tokens: '+ tokens));
                                if (tokens.length()==8)
                                {
                                    newDate = tokens.subString(4,6) +'/'+tokens.subString(6,8)+'/'+tokens.subString(0,4);
                                }
                                else
                                {
                                    newDate = Utility.dateFormat(tokens);
                                } 
                               // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:newDate: '+ newDate));
                                
                               /* if(newDate == '01/01/0001')
                                    outputlblval.value = '';
                                else    
                               		outputlblval.value = newDate;*/
                            }

                            for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                            {
                                String data= string.valueof(pagecomponents[i].Value[0]);                                                            
                                outputlblval.value = data;
                            }
                        }
                        else
                        {
                            for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                            {
                                String data= string.valueof(pagecomponents[i].Value[0]);                                                            
                                outputlblval.value = data;
                            }
                        }
                        dnyPageBlockSecItm.childComponents.add(outputlblval);
                    }
                    dnyPageBlockSec.childComponents.add(dnyPageBlockSecItm);
                }
            }
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException(className,'prepareFilterSection',ex);
            if (!(Test.isRunningTest()))
                throw ex;
        }
              
        return dnyPageBlock; 

    }

    //Creates actual page components on visualforce page.
    public static Component.Apex.PageBlock prepareTabPage(List<Utility.PageComponent> pagecomponents, Helper.GUMU_Response resGUMU_Response, integer endindex)
    {   
        integer sectioncount = 0;
        Component.Apex.PageBlock dnyPageBlock = new Component.Apex.PageBlock();          
        Component.Apex.PageBlockSection dnyPageBlockSec = new Component.Apex.PageBlockSection();
        Component.Apex.PageBlockSectionItem dnyPageBlockSecItm = new Component.Apex.PageBlockSectionItem();
        integer sindex=0;
        integer retcount=0;
        String retcnt = '';
        String si ='';
        try
        {
            for (integer i=0; i< pagecomponents.size(); i++)  
            {
                if(pagecomponents[i].ComponentType == 'Section')
                    sectioncount++;
                if(sectioncount == 2)
                    break;
            }

            for (integer i=0; i< pagecomponents.size(); i++)        
            {
                if(pagecomponents[i].ComponentType == 'Section')
                {
                    dnyPageBlockSec = new Component.Apex.PageBlockSection();
                    dnyPageBlockSec.title = pagecomponents[i].ComponentName;
                    //dnyPageBlockSec.id = 'PageBlockSection'+i;
                    dnyPageBlockSec.id ='PageBlock' + i + '_Section';
                    dnyPageBlockSec.columns = 2;    
                    dnyPageBlock.childComponents.add(dnyPageBlockSec); 

                    Component.Apex.OutputText outputtextvalgap = new Component.Apex.OutputText();

                    outputtextvalgap.escape= false;
                    outputtextvalgap.value= '<br/>';
                    dnyPageBlock.childComponents.add(outputtextvalgap); 
                    if(pagecomponents[i].DataType == 'Grid')
                    {   
                        List<Utility.PageComponent> gridlists= new List<Utility.PageComponent>();
                        for(i=i+1; i< pagecomponents.size(); i++)
                        {
                            if(pagecomponents[i].ComponentType == 'Section')
                                break;                                                          

                            gridlists.add(pagecomponents[i]);
                        }
                       
                        i--;

                        String htmltabledata=prepareTable(gridlists);
                        
                        dnyPageBlockSec.columns = 1;
                        dnyPageBlockSecItm = new Component.Apex.PageBlockSectionItem();
                        Component.Apex.OutputLabel outputlbl = new Component.Apex.OutputLabel();
                        Component.Apex.OutputText outputtextval = new Component.Apex.OutputText();
                        outputlbl.value = pagecomponents[i].ComponentName;
                        outputtextval.escape= false;
                        outputtextval.value= htmltabledata;                 
                        dnyPageBlockSec.childComponents.add(outputtextval);

                        //Bottom Navigation Panel
                        if(sectioncount == 1 )
                        {
                            Component.Apex.OutputPanel navigation = new Component.Apex.OutputPanel(styleclass = 'bottomNavExt',layout='block');
                            Component.Apex.OutputPanel paginator = new Component.Apex.OutputPanel(styleclass = 'paginator', style='border:0px !important',layout='block' );
                            Component.Apex.OutputText outTitle = new Component.Apex.OutputText(value='Page Size',style = 'float:right;margin-right:5px');
                            Component.Apex.SelectList pagesize = new Component.Apex.SelectList(multiselect=false,  style = 'width:45px; float: right! important;' ,styleClass='NavSelect');

                            pagesize.size = 1; 
                            pagesize.onchange= '  showLoading(), PageSizeContent(this.value)';
                            pagesize.expressions.value = '{!selectedPagesize}';

                            Component.Apex.SelectOption pagesizeval= new Component.Apex.SelectOption();
                            pagesizeval.itemValue = 5;
                            pagesizeval.itemLabel = '5'; 

                            Component.Apex.selectOption pagesizeval1 = new Component.Apex.SelectOption();
                            pagesizeval1.itemValue = 10;
                            pagesizeval1.itemLabel = '10';

                            Component.Apex.selectOption pagesizeval2 = new Component.Apex.SelectOption();
                            pagesizeval2.itemValue = 25;
                            pagesizeval2.itemLabel = '25';

                            Component.Apex.selectOption pagesizeval3 = new Component.Apex.SelectOption();
                            pagesizeval3.itemValue = 50;
                            pagesizeval3.itemLabel = '50';

                            Component.Apex.selectOption pagesizeval4 = new Component.Apex.SelectOption();
                            pagesizeval4.itemValue = 100;
                            pagesizeval4.itemLabel = '100';

                            Component.Apex.selectOption pagesizeval5 = new Component.Apex.SelectOption();
                            pagesizeval5.itemValue = 200;
                            pagesizeval5.itemLabel = '200';

                            pagesize.childComponents.add(pagesizeval);
                            pagesize.childComponents.add(pagesizeval1);
                            pagesize.childComponents.add(pagesizeval2);
                            pagesize.childComponents.add(pagesizeval3);
                            pagesize.childComponents.add(pagesizeval4);
                            pagesize.childComponents.add(pagesizeval5);    


                            retcnt = resGUMU_Response.totalRecord;
                            si = resGUMU_Response.startIndex;
                            if(retcnt != '')                                   
                                retcount = Integer.valueOf(retcnt);           
                            if(si != '')   
                                sindex = Integer.valueOf(si);

                            //left commandlinkarrow
                            Component.Apex.CommandLink linkPrevicon = new Component.Apex.CommandLink(onComplete='hideLoading();',reRender='opInquiry,IdLog',style = 'align: center;width: 10px !important;text-decoration: none;');
                            linkPrevicon.value = '';
                            linkPrevicon.expressions.action='{!navigatePrevious}';
                            Component.Apex.Image leftarrow = new Component.Apex.Image(style = 'width: 10px !important;');
                            if(sindex == 1 )
                            {
                                leftarrow.expressions.value = '{!URLFOR($Resource.IntegrationResources,"/Images/Other/LeftArrowGrey.gif")}';
                                leftarrow.title='No previous records available';
                                linkPrevicon.onclick = 'return false;';
                            }
                            else
                            {
                                linkPrevicon.onclick = 'showLoading();';
                                leftarrow.expressions.value = '{!URLFOR($Resource.IntegrationResources,"/Images/Other/LeftArrowBlack.gif")}';    
                            }

                            linkPrevicon.childComponents.add(leftarrow);

                            //left commandlink
                            Component.Apex.CommandLink linkPrev = new Component.Apex.CommandLink(onComplete='hideLoading();',reRender='opInquiry,IdLog',style='text-decoration: none;');
                            linkPrev.value = 'Previous    ';
                            linkPrev.expressions.action='{!navigatePrevious}';                           

                            if(sindex == 1 )
                            {
                                linkprev.onclick = 'return false;';
                                linkprev.style ='color: grey;pointer-events: none;cursor: default;';
                                linkprev.title='No previous records available';    
                            }
                            else
                            {
                                linkprev.onclick = 'showLoading();';
                                linkprev.title='';                                  
                            }

                            //right commandlink
                            Component.Apex.CommandLink linkNext= new   Component.Apex.CommandLink(onComplete='hideLoading();',reRender='opInquiry,IdLog',style='text-decoration: none;');
                            linkNext.value = '  Next';     
                            linkNext.expressions.action='{!navigateNext}';

                            if(endindex >= retcount )
                            {
                                linkNext.onclick = 'return false;';
                                linkNext.style ='color: grey;pointer-events: none;cursor: default;';
                                linkNext.title='No more records available';  
                            }
                            else
                            {
                                linkNext.onclick = 'showLoading();';
                                linkNext.title='';                                  
                            }

                            //right commandlinkarrow
                            Component.Apex.CommandLink linkNexticon = new Component.Apex.CommandLink(onComplete='hideLoading();', reRender='opInquiry,IdLog', style = 'align: center;width: 10px !important;text-decoration: none;');
                            linkNexticon.value = '';
                            linkNexticon.expressions.action='{!navigateNext}';
                            Component.Apex.Image rightarrow = new Component.Apex.Image(style = 'width: 10px !important;');
                            if(endindex >= retcount )
                            {
                                rightarrow.expressions.value = '{!URLFOR($Resource.IntegrationResources,"/Images/Other/RightArrowGrey.gif")}';
                                linkNexticon.title='No more records available';
                                linkNexticon.onclick = 'return false;';
                            }
                            else
                            {
                                linkNexticon.onclick = 'showLoading();';
                                rightarrow.expressions.value = '{!URLFOR($Resource.IntegrationResources,"/Images/Other/RightArrowBlack.gif")}';  
                            }

                            linkNexticon.childComponents.add(rightarrow);   
                            Component.Apex.OutputText statusmsg= new Component.Apex.OutputText(styleClass='left');   
                            statusmsg.expressions.value = '{!status}';
                            paginator.childComponents.add(statusmsg);
                            paginator.childComponents.add(linkPrevicon);
                            paginator.childComponents.add(linkPrev);
                            paginator.childComponents.add(linkNext);
                            paginator.childComponents.add(linkNexticon);
                            paginator.childComponents.add(pagesize);
                            paginator.childComponents.add(outTitle);
                            paginator.childComponents.add(outTitle);
                            navigation.childComponents.add(paginator);
                            dnyPageBlockSec.childComponents.add(navigation);

                        }                         
                        continue;
                    }           
                } 
                else if(pagecomponents[i].ComponentType == 'Detail')
                {
                    dnyPageBlockSecItm = new Component.Apex.PageBlockSectionItem();
                    Component.Apex.OutputLabel outputlbl = new Component.Apex.OutputLabel();
                    Component.Apex.OutputLabel outputlblval = new Component.Apex.OutputLabel();
                    outputlbl.value = pagecomponents[i].ComponentName;
                    string datatype= pagecomponents[i].DataType;
                    dnyPageBlockSecItm.childComponents.add(outputlbl); 
                    //ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:pagecomponents: '+ jSon.serialize(pagecomponents)));         
                    if (datatype == 'CHECKBOX' || datatype == 'Checkbox') 
                    {
                    	//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:pagecomponents: '+ jSon.serialize(pagecomponents)));
                        Component.Apex.InputCheckbox checkbox = new Component.Apex.InputCheckbox();
                        checkbox.id = pagecomponents[i].APIName;
                        for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                        {
                            if(pagecomponents[i].Value[0] =='2' ||pagecomponents[i].Value[0] =='true' ||pagecomponents[i].Value[0] =='Yes' ||pagecomponents[i].Value[0] =='Y')//
                                checkbox.value = true;
                             else
                                checkbox.value = false;
                            //checkbox.value = ERPCustomerDetailCntlr_TEST1.checkval;
                        }
                        checkbox.disabled = true;
                        dnyPageBlockSecItm.childComponents.add(checkbox);
                    } 
                    else 
                    {           
                        if (datatype == 'Date')
                        {
                            for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                            {
                                
                                string strdate= string.valueof(pagecomponents[i].Value[0]);
                                //String[] tokens = strdate.split('-');
                                string tokens = strdate.replace('-','');
                                string newDate ;
                                
                                if (tokens.length()==8)
                                {
                                    newDate = tokens.subString(4,6) +'/'+tokens.subString(6,8)+'/'+tokens.subString(0,4);
                                }
                                else
                                {
                                    newDate = Utility.dateFormat(tokens);//tokens;
                                }
                               // ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:newDate: '+ newDate));
                                 
                                 if(newDate == '01/01/0001')
                                 {
                                 	//ApexPages.addmessage(new ApexPages.message(ApexPages.Severity.Info, 'DEBUG:efault  : '+ newDate));
                                  	outputlblval = new Component.Apex.OutputLabel();
                                  	outputlblval.value = '';
                                 }
                                 else
                                  	outputlblval.value = newDate;
                          
                            }

                        }
                        else if (datatype == 'Decimal')
                        {
                            for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                            {
                                decimal decdata=0.00;
                                decdata= double.valueof(pagecomponents[i].Value[0]);                                                            
                                outputlblval.value = decdata.setscale(2);
                            }
                        }
                        else
                        {
                            for(integer j=0; j< pagecomponents[i].Value.size(); j++)    
                            {
                                String data= string.valueof(pagecomponents[i].Value[0]);                                                            
                                outputlblval.value = data;
                            }
                        }
                        dnyPageBlockSecItm.childComponents.add(outputlblval);
                    }
                    dnyPageBlockSec.childComponents.add(dnyPageBlockSecItm);
                }
            }
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException(className,'prepareTabPage',ex);
            throw ex;
        }      
        return dnyPageBlock; 
    }


    //Method to display Customer's all Enquiries
    public static Helper.GUMU_UIResponse getCustomerEnquiryPage(string DataPageName,String CustId,string KeyName,
            string KeyValue,integer startindex,integer endindex,string selectedPagesize) 
    {

        string ERPSystemName='';
        string IntegrationId='';
        string IntegrationKey='';
        string UniqueKey='';
        string AccountType='';
        BaseIntegrationFramework oFramework;
        Helper.GUMU_UIResponse CustomerEnquiryPage=new Helper.GUMU_UIResponse ();
        string Include='';
        string DetailDataPage=DataPageName;
        try
        {   
            if (CustId != null ) 
            {     
                //Get the current account 
                Account oAcc = [SELECT Integration_Key__c,ERP_Customer_Number__c,Type, id from Account where id = : CustId];
                
                system.debug('oAcc '+oAcc);
                IntegrationKey=oAcc.Integration_Key__c;
                UniqueKey=oAcc.ERP_Customer_Number__c;
                AccountType=oAcc.Type;
                
                if(Test.isRunningTest())
                {
                	list<ERP_Config__c> Integration = [select Id from ERP_Config__c where ERP_System__c ='Sage300ERP'];
                	IntegrationId= Integration[0].Id;
                }
                                    
                //Get configration data
                ERP_Config__c oIntegration = [SELECT ERP_System__c, Web_Service_URL__c, Integration_Information__c, Integration_Information_2__c, Integration_Information_3__c FROM ERP_Config__c WHERE ID = : oAcc.Integration_Key__c];
                ERPSystemName= oIntegration.ERP_System__c;
                IntegrationId= oIntegration.Id;  //oIntegration.Id

                String index= String.valueOf('1');
                String maxcount= String.valueOf('200');

                //get the data page information 
                list<Data_Page__c>          Data_Page= [select Id,Type__c,Name from Data_Page__c where Name =: DataPageName and Integration_Key__c = : IntegrationId ];//and Integration_Key__c = : IntegrationId
                list<Data_Page_Detail__c>   Data_Page_Detail ; 
                list<Data_Page_Section__c>  Data_Page_Section ; 
               
               system.debug('DataPageName :'+DataPageName +'IntegrationId :'+IntegrationId);
               system.debug('Data_Page :' +Data_Page);
                //if list use the Pagination
                if (Data_Page[0].Type__c =='List')//TODO:Use ?cons/enum  //List
                {
                    index= String.valueOf(startIndex);
                    maxcount= String.valueOf(selectedPagesize);
                }
                else 
                {
                    DetailDataPage = Data_Page[0].Name;
                    Data_Page_Section = [select Related_List_Name__c  from Data_Page_Section__c where Related_List_Name__c !=null 
                    						and Data_Page_Id__c =: Data_Page[0].Id and Data_Page_Id__r.Integration_Key__c = : IntegrationId ];
                    if (Data_Page_Section.size()>0)
                        Include=Data_Page_Section[0].Related_List_Name__c;
                }
                
                //Prepapre attribute list 
                map<string,list<object>> AttribParams= Utility.getAttribParameters(index,maxcount,IntegrationId, DataPageName , Include ,Helper.MappingPurpose.DISPLAY);
                
                IF(oIntegration.ERP_System__c =='SageERPX3')
                {
                    list<object> obj = new list<object>();
                    obj.add(AccountType) ;
                    AttribParams.put('AccountType',obj);
                }
                //prepare where clause
                map<string,map<string,list<string>>> fieldParameters = new map<string,map<string,list<string>>> ();
                map<string,list<string>> parameter = new map<string,list<string>>();
                list<string> listParams=new list<string> ();
                listParams.add(KeyValue.toUpperCase());
                parameter.put(string.valueOf(Helper.Operator.EQUAL),listParams);
                fieldParameters.put(KeyName,parameter);
                
                //writing code for AR invoices. adding extra filter for Invoices to fetch BP invoices only. 26/10/2015.
                if(DataPageName =='ARInquiry')
                {
                   parameter = new map<string,list<string>>();
                    listParams=new list<string> ();
                    listParams.add('3');
                    parameter.put(string.valueOf(Helper.Operator.NOT_EQUAL),listParams);
                    fieldParameters.put('ORIMOD',parameter);
                }
                
                
                //Get the data for filtered condition                                 
                baseIntegrationFramework integrationFramework= IntegrationFactory.getIntegrationFramework(IntegrationKey);
                Helper.GUMU_Response resGUMU_Response = new Helper.GUMU_Response(); 
                if (Test.isRunningTest())
                {
                    list<map<string,string>>ERPDataMapList = new list<map<string,string>>();
                    map<string,string>ERPDataMap = new map<string,string>();
                    ERPDataMap.put('AMTCRLIMT','10000.000');
                    ERPDataMap.put('CODECTRY','AM');
                    ERPDataMap.put('CODECURN','USD');
                    ERPDataMap.put('CODEPSTL','10052');
                    ERPDataMapList.add(ERPDataMap);
                    resGUMU_Response.ERPDataMap=ERPDataMapList;
                    resGUMU_Response.responseERPData = string.valueOf('ABC Message Dispaly');
                    resGUMU_Response.totalRecord = '1';
                }
                else
                    resGUMU_Response =integrationFramework.getData(fieldParameters,AttribParams);
                               
                 //return CustomerEnquiryPage;
               // ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'responseERPData '+json.serialize(resGUMU_Response.ERPDataMap)));
                if(resGUMU_Response.statusCode =='100')
                {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Unable to connect ERP System. please check the connection'));          
                    return CustomerEnquiryPage;
                }
                else if(resGUMU_Response.statusCode =='0')
                {   
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, resGUMU_Response.statusMessage));           
                    return CustomerEnquiryPage;
                }
                //this method will return list of components to be created for AR Inquiry page
                oFramework = IntegrationFactory.getIntegrationFramework(IntegrationKey);    
				
				//ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error, 'totalRecord '+resGUMU_Response));
				
                if (string.isBlank(resGUMU_Response.totalRecord))
                    CustomerEnquiryPage.TotalRecordsCount=0;    
                else     
                {
                    List<Utility.PageComponent> pagecomponents= oFramework.getPageComponent(IntegrationKey,DetailDataPage, resGUMU_Response);
                    CustomerEnquiryPage.TotalRecordsCount=Integer.valueOf(resGUMU_Response.totalRecord);
                    CustomerEnquiryPage.UIContent=Helper.prepareTabPage(pagecomponents, resGUMU_Response, endindex);
                }   
            }   

        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getCustomerEnquiryPage',ex,false);
            throw ex;
        }

       return CustomerEnquiryPage;
       return null;
       
    }

    ////////////////////Wrapper Class////////////////////
    public class GUMU_Response
    {
        public  GUMU_Response()
        {
        }
        public string statusCode;
        public string statusMessage;
        public list<object> responseSFData;
        public map<string,list<object>> responseRelSFData; 
        public string responseERPData; 
        public string totalRecord; 
        public string startIndex;
        public string itemPerPage;
        public string hasNext; 
        public list<map<string,string>> ERPDataMap;
        public list<map<string,string>> ERPDataMapDetail;
        public map<string,string> SFDataMap;                 
        public map<string,list<map<string,string>>> ERPDataMapRelSection;
    }

    public class GUMU_UIResponse
    {
        public  GUMU_UIResponse()
        {
        }
        public integer TotalRecordsCount;
        public Component.Apex.PageBlock UIContent; 
    }
    
    public class Customer
    {
        public string UniqueKey {get;set;}
        public string CategoryCode {get;set;}
        public string CustomerName {get;set;}
    }

}
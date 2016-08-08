//This is used for returning integration objects
public class IntegrationFactory
{
    //ClassName
    private static final string className='IntegrationFactory';
    
    //This returns the provider based on the ERP
    public static BaseERPProvider getERPProvider()
    {
        // Object and variable Declaration
        Helper oHelper = new Helper();

        // Base Class Object    
        BaseERPProvider oERPProvider;
 
        try 
        {  
            // Get ERP based on the License record 
            String strERP  =(String) oHelper.getERP('');

            // Defining the ERP Class with Base object
            if(strERP =='Sage300ERP') 
            { 
                oERPProvider= new Sage300ERPProvider();
            }
            else if(strERP =='Sage100ERP')
            {
                oERPProvider= new Sage100ERPProvider();
            }
            else if(strERP =='SageERPX3')
            {
                oERPProvider= new SageX3ERPProvider();
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getERPProvider',ex,false);
        }       
        return oERPProvider;
    }  
  
    //This returns the integration framework based on the ERP
    public static BaseIntegrationFramework getIntegrationFramework()
    {  
        
        // Object and variable Declaration
        Helper oHelper = new Helper();

        // Base Class Object    
        BaseIntegrationFramework oIntegrationFramework;
        try
        {
            String strERP = (String) oHelper.getERP('');

            // Defining the ERP Class with Base object
            if(strERP =='Sage300ERP')
            {
                 oIntegrationFramework= new Sage300IntegrationFramework();
            }
            else if(strERP =='Sage100ERP')
            {
                oIntegrationFramework= new  Sage100IntegrationFramework();
            }
            else if(strERP =='SageERPX3')
            {
                oIntegrationFramework= new SageX3IntegrationFramework(); 
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getIntegrationFramework',ex,false);
        }   
        // Get ERP based on the License record  
        return oIntegrationFramework; 
    }
    
    //This returns the integration framework based on the Integration Id
    public static BaseIntegrationFramework getIntegrationFramework(string Integration_Id)
    {  
        
        // Object and variable Declaration 
        Helper oHelper = new Helper();

        // Base Class Object    
        BaseIntegrationFramework oIntegrationFramework;
        try
        {   
            ERP_Config__c oConfig= [ select ERP_System__c from ERP_Config__c where Id=: Integration_Id ]; 
            
            String strERP = oConfig.ERP_System__c;

            // Defining the ERP Class with Base object
            if(strERP =='Sage300ERP')
            {
                 oIntegrationFramework= new Sage300IntegrationFramework();
            }
            else if(strERP =='Sage100ERP')
            {
                oIntegrationFramework= new  Sage100IntegrationFramework();
            }
            else if(strERP =='SageERPX3')
            {
                oIntegrationFramework= new SageX3IntegrationFramework(); 
            }
        }
        catch(Exception ex)
        {
            CustomException exc= new CustomException (className,'getIntegrationFramework',ex,false);
        }   
        // Get ERP based on the License record  
        return oIntegrationFramework; 
    }
    
    public static String getERPSystem(string IntegrationKey) 
    { 
        // Object and variable Declaration
        Helper oHelper = new Helper();

        // Get ERP based on the License record 
        String strERP = (String) oHelper.getERP(IntegrationKey);

        return strERP;
    }
}
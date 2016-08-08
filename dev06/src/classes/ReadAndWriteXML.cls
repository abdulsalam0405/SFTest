/*************The class to read and write xml string*************/
public with sharing class ReadAndWriteXML 
{
    public XmlNode TrialXmlNode {get;set;}

    public ReadAndWriteXML()
    {

    }

    // Get XML Nodes
    @RemoteAction
    public static List<XmlNode> getXmlNode()
    {
        XmlNode objXmlNode = new XmlNode();
        try
        {
            objXmlNode.NodeName = 'Root';

            XmlNode objXmlNode_1 = new XmlNode();
            objXmlNode_1.NodeName = 'Level_2';
            objXmlNode_1.Attributes.put('Attr2','val2');
            objXmlNode_1.Attributes.put('Attr3','val3'); 
            objXmlNode_1.NodeValue = 'ABC';
            objXmlNode.ChildXmlNodes.add(objXmlNode_1);

            XmlNode objXmlNode1 = new XmlNode();
            objXmlNode1.NodeName = 'Level_1';
            objXmlNode1.Attributes.put('Attr4','val4');

            objXmlNode_1 = new XmlNode();
            objXmlNode_1.NodeName = 'Level_2';
            objXmlNode_1.Attributes.put('Attr5','val5');
            objXmlNode_1.Attributes.put('Attr6','val6'); 
            objXmlNode_1.NodeValue = 'XYZ';
            objXmlNode1.ChildXmlNodes.add(objXmlNode_1);

            objXmlNode.ChildXmlNodes.add(objXmlNode1);

            string xmlString = '<Households><Household isPrimary="False" MailFlag="False" ID="4265447-PR"><Address1>33080 THUNDERBIRD DR</Address1><Address2>M G Road</Address2><Address3></Address3><City>HAYES</City><State>KANSAS</State><Country>UNITED STATES OF AMERICA</Country><Zip>00000-0000</Zip></Household><Household isPrimary="False" MailFlag="False" ID="4265447-S1"><Address1>test</Address1><Address2>test</Address2><Address3>test</Address3><City>test</City><State>test</State><Country>test</Country><Zip>test</Zip></Household><Household isPrimary="True" MailFlag="False" ID="4265447-S2"><Address1>fdsfds</Address1><Address2>fdsfdsf</Address2><Address3>fdsf</Address3><City>fdsfds</City><State>Florida</State><Country>fdsfds</Country><Zip>fdsfds</Zip></Household></Households>';
            objXmlNode = ParseXmlString(xmlString);        
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','getXmlNode',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
        return objXmlNode.ChildXmlNodes; 
    }

    //This class represents the non-leaf node
    public class XmlNode
    {
        public String NodeName {get;set;}
        public Map<string,string> Attributes {get;set;}
        public List<XmlNode> ChildXmlNodes {get;set;}
        public String NodeValue {get;set;}

        public XmlNode()
        {
            NodeName = '';
            Attributes = new Map<string,string>();
            ChildXmlNodes = new List<XmlNode>();
            NodeValue = '';
        }
    }

    //Retrive a node for editing
    public static XmlNode GetOneNode(XmlNode rootXmlNode,string strIdPkValue,string strIdPkName)
    {
        try
        {
            List<XmlNode> lstXmlNode = rootXmlNode.ChildXmlNodes;
            for(XmlNode curXmlNode:lstXmlNode)
            {
                if(curXmlNode.Attributes.get(strIdPkName) == strIdPkValue)
                    return curXmlNode;
            }
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','GetOneNode',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
        }
        return null; 
    }

    //Delete one node
    public static string DeleteOneNode(string xmlString,string strIdPkValue,string strIdPkName)
    {
        XmlNode parentXmlNode = ParseXmlString(xmlString);
        List<XmlNode> lstXmlNode = parentXmlNode.ChildXmlNodes;
        Integer counter = 0;
        try
        {
            for(XmlNode curXmlNode:lstXmlNode)
            {
                if(curXmlNode.Attributes.get(strIdPkName) == strIdPkValue)
                    break;                      

                counter++;
            }
            if(counter == lstXmlNode.size())
                return '';
            lstXmlNode.remove(counter); 
            xmlString = GenerateXmlString(parentXmlNode);
            return xmlString; 
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','DeleteOneNode',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
            xmlString= ''; 
            return xmlString; 
        }
    }

    //Add one XmlNode 
    public static string AddOneNode(string xmlString,XmlNode objXmlNode)
    {
        try
        {
            XmlNode parentXmlNode = ParseXmlString(xmlString);
            List<XmlNode> lstXmlNode = parentXmlNode.ChildXmlNodes;
            if(lstXmlNode == null || lstXmlNode.size() == 0)
                lstXmlNode = new List<XmlNode>();
            lstXmlNode.add(objXmlNode);
            xmlString = GenerateXmlString(parentXmlNode);
            return xmlString; 
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','AddOneNode',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
            xmlString= ''; 
            return xmlString; 
        }       
    }

    // this is the funcion that reads a xml string and
    // returns a non leaf node object
    public static XmlNode ParseXmlString(String xmlString)
    {
        XmlNode objXmlNode = new XmlNode();
        try
        {
            if(String.isBlank(xmlString))
                return objXmlNode;
            XmlStreamReader reader = new XmlStreamReader(xmlString);
            Integer counter = 0; 

            while(reader.hasNext())
            {
                if(reader.getEventType() == XMLTag.START_ELEMENT)
                {
                    counter++;
                    if(counter > 1)
                        ParseXmlNode(reader,objXmlNode);
                    else
                        objXmlNode.NodeName = reader.getLocalName();
                }
                reader.next();
            }
            return objXmlNode;
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','ParseXmlString',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));  
            return objXmlNode;
        }             
    }

    //Parse XML Node
    public static void ParseXmlNode(XmlStreamReader reader,XmlNode objParentXmlNode)
    {
        try
        {
            XmlNode objXmlNode = new XmlNode();

            objParentXmlNode.ChildXmlNodes.add(objXmlNode);
            objXmlNode.NodeName = reader.getLocalName();  
            Integer attrCount = reader.getAttributeCount();

            for(Integer i = 0;i < attrCount;i++)
            {
                string strAttrName = reader.getAttributeLocalName(i);
                string strAttrValue = reader.getAttributeValueAt(i);
                objXmlNode.Attributes.put(strAttrName,strAttrValue);
            }
            reader.next();

            while(reader.hasNext())
            {
                if(reader.getEventType() == XMLTag.END_ELEMENT)
                    break;              
                if(reader.getEventType() == XMLTag.START_ELEMENT)
                    ParseXmlNode(reader,objXmlNode);
                if(reader.getEventType() == XMLTag.CHARACTERS)
                {              
                    String value = reader.getText();
                    value = value.replace('&quot;','"');
                    value = value.replace('&gt;','>');
                    value = value.replace('&lt;','<');
                    value = value.replace('&amp;','&');

                    objXmlNode.NodeValue +=value;               
                }
                reader.next();
            }
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','ParseXmlNode',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));             
        }   
    }

    //This function writes the non leaf xml (the root node with all sub nodes)
    //into a xml string
    public static string GenerateXmlString(XmlNode objXmlNode)
    {
        String strXmlString = '';

        strXmlString = GenerateXmlForXmlNode(objXmlNode);

        return strXmlString;        
    }

    //This function returns the xml string for a non leaf node
    private static string GenerateXmlForXmlNode(XmlNode objXmlNode)
    {
        String strXmlString = '';
        try
        {
            //start the node
            strXmlString = strXmlString+'<'+objXmlNode.NodeName;
            //Get the list of attribute names

            Set<string> setAttrName = objXmlNode.Attributes.keySet();
            for(String curAttr:setAttrName)
            {
                strXmlString = strXmlString+' '+curAttr+'="'+objXmlNode.Attributes.get(curAttr)+'"';                  
            }

            //close the starting node
            strXmlString = strXmlString+'>';
            //add inner value to node
            objXmlNode.NodeValue = objXmlNode.NodeValue.replace('&','&amp;');
            objXmlNode.NodeValue = objXmlNode.NodeValue.replace('<','&lt;');
            objXmlNode.NodeValue = objXmlNode.NodeValue.replace('>','&gt;');
            objXmlNode.NodeValue = objXmlNode.NodeValue.replace('\"','&quot;');
            strXmlString = strXmlString+objXmlNode.NodeValue;
            //add all the leaf nodes xml
            for(XmlNode curXmlNode:objXmlNode.ChildXmlNodes)
            {
                strXmlString = strXmlString+GenerateXmlForXmlNode(curXmlNode);        
            }

            //add the closing node
            strXmlString = strXmlString+'</'+objXmlNode.NodeName+'>';

            return strXmlString;    
        }
        catch(Exception ex)
        {
            GUMUException exc= new GUMUException('ReadAndWriteXML','GenerateXmlForXmlNode',ex);
            ApexPages.addmessage(new ApexPages.message(exc.severity, exc.message));
            strXmlString='';    
            return strXmlString;    
        }

    }   

}
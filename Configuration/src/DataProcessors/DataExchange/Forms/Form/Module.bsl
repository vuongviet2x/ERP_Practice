
&AtServerNoContext
Procedure StartDataExchangeAtServer() 
	
	NodeSelection = ExchangePlans.Branches.Select();
	While NodeSelection.Next() Do
		// Exchanging data with all nodes, except for the current
		// node (ThisNode)
		If NodeSelection.Ref <> ExchangePlans.Branches.ThisNode() Then
			NodeObject = NodeSelection.GetObject();
			// Receiving message
			NodeObject.ReadMessageWithChanges();
			// Generating message
			NodeObject.WriteMessageWithChanges();
		EndIf;
	EndDo;                      
	
EndProcedure
	
&AtClient
Procedure StartDataExchange(Command)    
	
	StartDataExchangeAtServer();        
	
EndProcedure

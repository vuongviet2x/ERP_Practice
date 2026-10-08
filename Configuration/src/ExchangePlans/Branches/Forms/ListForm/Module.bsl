
&AtServerNoContext
Procedure WriteChangesAtServer(Node)
	ExchangePlans.RecordChanges(Node);
EndProcedure

&AtClient
Procedure WriteChanges(Command)
	Node = Items.List.CurrentRow;
	If Node = Undefined Or PredefinedNode(Node) Then
		Return;
	EndIf;
	WriteChangesAtServer(Node);
	ShowUserNotification("Changes registered", , String(Node));
EndProcedure

&AtServerNoContext
Function PredefinedNode(Node)
	Return Node = ExchangePlans.Branches.ThisNode();
EndFunction

&AtClient
Procedure ListOnActivateRow(Item)
	If PredefinedNode(Item.CurrentRow) Then
		Items.FormWriteChanges.Enabled = False;
	Else
		Items.FormWriteChanges.Enabled = True;
	EndIf;
EndProcedure

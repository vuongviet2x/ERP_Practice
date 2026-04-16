
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Object.Ref = ExchangePlans.Branches.ThisNode() Then
		Items.Main.Enabled = False;
	EndIf;
EndProcedure

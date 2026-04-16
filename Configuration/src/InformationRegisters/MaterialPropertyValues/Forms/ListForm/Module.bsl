
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Filter.Property("PropertySet") Then
		Items.PropertySet.Visible = False;
	EndIf;
EndProcedure

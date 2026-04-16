
&AtServer
Procedure OnCreateAtServer(Cancel, StandardProcessing)
	If Parameters.Filter.Property("Owner") Then
		Items.Code.Visible = False;
	EndIf;
EndProcedure

Procedure PresentationFieldsGetProcessing(Fields, StandardProcessing)
	StandardProcessing = False;
	Fields.Add("Description");
	Fields.Add("MaterialServiceType");
EndProcedure     

Procedure PresentationGetProcessing(Data, Presentation,
	StandardProcessing)
	StandardProcessing = False;
	If ValueIsFilled(Data.MaterialServiceType) Then
		Presentation = Data.Description + " (" + Lower(String(Data.MaterialServiceType)) + ")";
	Else
		Presentation = Data.Description;
	EndIf;
EndProcedure
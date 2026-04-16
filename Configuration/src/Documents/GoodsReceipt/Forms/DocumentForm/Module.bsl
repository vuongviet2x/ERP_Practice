
&AtClient
Procedure MaterialsQuantityOnChange(Item)
	TabularSectionRow = Items.Materials.CurrentData;
	DocumentProcessing.CalculateTotal(TabularSectionRow);
EndProcedure

&AtClient
Procedure MaterialsPriceOnChange(Item)
	TabularSectionRow = Items.Materials.CurrentData;
	DocumentProcessing.CalculateTotal(TabularSectionRow);
EndProcedure

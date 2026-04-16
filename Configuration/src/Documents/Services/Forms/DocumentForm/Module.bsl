&AtClient
Procedure MaterialsAndServicesQuantityOnChange(Item)
	TabularSectionRow = Items.MaterialsAndServices.CurrentData;
	DocumentProcessing.CalculateTotal(TabularSectionRow);
EndProcedure

&AtClient
Procedure MaterialsAndServicesPriceOnChange(Item)
	TabularSectionRow = Items.MaterialsAndServices.CurrentData;
	DocumentProcessing.CalculateTotal(TabularSectionRow);
EndProcedure

&AtClient
Procedure MaterialsAndServicesMaterialOrServiceOnChange(Item)
	// Getting current tabular section row
	TabularSectionRow = Items.MaterialsAndServices.CurrentData;
	// Setting price
	TabularSectionRow.Price = CatalogProcessing.RetailPrice(Object.Date,
	TabularSectionRow.MaterialOrService);
	//Recalculating row total
	DocumentProcessing.CalculateTotal(TabularSectionRow);
EndProcedure

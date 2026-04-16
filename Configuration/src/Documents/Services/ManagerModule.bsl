
Procedure Print(Spreadsheet, Ref) Export
	//{{_PRINT_WIZARD(Print)
	Template = Documents.Services.GetTemplate("Print");
	Query = New Query;
	Query.Text =
	"SELECT
	|	Services.Customer,
	|	Services.Date,
	|	Services.Number,
	|	Services.Technician,
	|	Services.Warehouse,
	|	Services.MaterialsAndServices.(
	|		LineNumber,
	|		MaterialOrService,
	|		Quantity,
	|		Price,
	|		Total
	|	)
	|FROM
	|	Document.Services AS Services
	|WHERE
	|	Services.Ref IN (&Ref)";
	Query.Parameters.Insert("Ref", Ref);
	Selection = Query.Execute().Select();

	AreaCaption = Template.GetArea("Caption");
	Header = Template.GetArea("Header");
	AreaMaterialsAndServicesHeader = Template.GetArea("MaterialsAndServicesHeader");
	AreaMaterialsAndServices = Template.GetArea("MaterialsAndServices");   
	AreaTotal = Template.GetArea("Total"); // New line
	Spreadsheet.Clear();

	InsertPageBreak = False;
	While Selection.Next() Do
		If InsertPageBreak Then
			Spreadsheet.PutHorizontalPageBreak();
		EndIf;

		Spreadsheet.Put(AreaCaption);

		Header.Parameters.Fill(Selection);
		Spreadsheet.Put(Header, Selection.Level());

		Spreadsheet.Put(AreaMaterialsAndServicesHeader);
		SelectionMaterialsAndServices = Selection.MaterialsAndServices.Select();   
		
		TotalSum = 0; // New line
		
		
		While SelectionMaterialsAndServices.Next() Do
			AreaMaterialsAndServices.Parameters.Fill(SelectionMaterialsAndServices);
			Spreadsheet.Put(AreaMaterialsAndServices, SelectionMaterialsAndServices.Level());  
			
			TotalSum = TotalSum + SelectionMaterialsAndServices.Total; // New line                   
			
		EndDo;
		
		AreaTotal.Parameters.DocumentTotal = TotalSum; // New line    
		
		Spreadsheet.Put(AreaTotal); // New line           
		
		InsertPageBreak = True;
	EndDo;
	//}}
EndProcedure

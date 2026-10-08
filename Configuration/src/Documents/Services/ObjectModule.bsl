
Procedure Posting(Cancel, Mode)
	RegisterRecords.BalanceOfMaterials.Write = True; 
	RegisterRecords.CostOfMaterials.Write = True;    
	RegisterRecords.Sales.Write = True;   
	RegisterRecords.Primary.Write = True;
	
	
	// Creating temporary tables manager
	TTManager = New TempTablesManager;    
	#Region DocumentMaterialAndServices
	Query = New Query;
	// Specifying the temporary tables manager used by the query
	Query.TempTablesManager = TTManager;    
	
	Query.Text = 
	"SELECT
	|	ServicesMaterialsAndServices.MaterialOrService AS MaterialOrService,
	|	ServicesMaterialsAndServices.MaterialOrService.MaterialServiceType AS MaterialServiceType,
	|	SUM(ServicesMaterialsAndServices.Quantity) AS QuantityInDocument,
	|	SUM(ServicesMaterialsAndServices.Total) AS TotalInDocument,
	|	ServicesMaterialsAndServices.PropertySet AS PropertySet
	|INTO DocumentMaterialsAndServices
	|FROM
	|	Document.Services.MaterialsAndServices AS ServicesMaterialsAndServices
	|WHERE
	|	ServicesMaterialsAndServices.Ref = &Ref
	|
	|GROUP BY
	|	ServicesMaterialsAndServices.MaterialOrService,
	|	ServicesMaterialsAndServices.MaterialOrService.MaterialServiceType,
	|	ServicesMaterialsAndServices.PropertySet";
	
	Query.SetParameter("Ref", Ref);
	
	QueryResult = Query.Execute(); 
	#EndRegion
	#Region RegisterRecords
	Query2 = New Query;
	Query2.TempTablesManager = TTManager;
	Query2.Text = "SELECT
	|	DocumentMaterialsAndServices.MaterialOrService AS MaterialOrService,
	|	DocumentMaterialsAndServices.MaterialServiceType AS MaterialServiceType,
	|	DocumentMaterialsAndServices.QuantityInDocument AS QuantityInDocument,
	|	DocumentMaterialsAndServices.TotalInDocument AS TotalInDocument,
	|	ISNULL(CostOfMaterialsBalance.CostBalance, 0) AS Cost,
	|	ISNULL(BalanceOfMaterialsBalance.QuantityBalance, 0) AS Quantity,
	|	DocumentMaterialsAndServices.PropertySet AS PropertySet
	|FROM
	|	DocumentMaterialsAndServices AS DocumentMaterialsAndServices
	|		LEFT JOIN AccumulationRegister.CostOfMaterials.Balance(
	|				&BalancePeriod,
	|				Material IN
	|					(SELECT
	|						DocumentMaterialsAndServices.MaterialOrService
	|					FROM
	|						DocumentMaterialsAndServices)) AS CostOfMaterialsBalance
	|		ON DocumentMaterialsAndServices.MaterialOrService = CostOfMaterialsBalance.Material
	|		LEFT JOIN AccumulationRegister.BalanceOfMaterials.Balance(
	|				&BalancePeriod,
	|				Material IN
	|					(SELECT
	|						DocumentMaterialsAndServices.MaterialOrService
	|					FROM
	|						DocumentMaterialsAndServices)) AS BalanceOfMaterialsBalance
	|		ON DocumentMaterialsAndServices.MaterialOrService = BalanceOfMaterialsBalance.Material";
	
	
	// Real-time posting: current balances (as in the book). Regular posting of a past document:
	// balances at the moment of the document, without its own records and later documents.
	If Mode = DocumentPostingMode.RealTime Then
		Query2.SetParameter("BalancePeriod", Undefined);
	Else
		Query2.SetParameter("BalancePeriod", New Boundary(PointInTime(), BoundaryType.Excluding));
	EndIf;
	
	// Managed lock mode: lock the materials of the document before reading their balances
	DataLock = New DataLock;
	LockItem = DataLock.Add("AccumulationRegister.BalanceOfMaterials");
	LockItem.Mode = DataLockMode.Exclusive;
	LockItem.DataSource = MaterialsAndServices.Unload(, "MaterialOrService");
	LockItem.UseFromDataSource("Material", "MaterialOrService");
	LockItem = DataLock.Add("AccumulationRegister.CostOfMaterials");
	LockItem.Mode = DataLockMode.Exclusive;
	LockItem.DataSource = MaterialsAndServices.Unload(, "MaterialOrService");
	LockItem.UseFromDataSource("Material", "MaterialOrService");
	DataLock.Lock();
	
	// Setting data locks for the CostOfMaterials and BalanceOfMaterials registers
	RegisterRecords.CostOfMaterials.LockForUpdate = True;
	RegisterRecords.BalanceOfMaterials.LockForUpdate = True;
	// Writing empty record sets to read balances without the data added by this document
	RegisterRecords.CostOfMaterials.Write();
	RegisterRecords.BalanceOfMaterials.Write();
	
	QueryResult = Query2.Execute();     
	SelectionDetailRecords = QueryResult.Select();
	
	While SelectionDetailRecords.Next() Do   
		If SelectionDetailRecords.Quantity = 0 Then
			MaterialCost = 0;
		Else
			MaterialCost = SelectionDetailRecords.Cost / SelectionDetailRecords.Quantity;
		EndIf;
		// register Primary
		// First posting: Dr 2000 (AccountsReceivable) – Cr 9000 (Income) — revenue of EVERY row, materials and services
		Record = RegisterRecords.Primary.Add();
		Record.AccountDr = ChartsOfAccounts.Main.AccountsReceivable;
		Record.AccountCr = ChartsOfAccounts.Main.Income;
		Record.Period = Date;
		Record.Sum = SelectionDetailRecords.TotalInDocument;
		Record.ExtDimensionsDr[ChartsOfCharacteristicTypes.ExtraDimensionTypes.Customers] = Customer;
		
		If SelectionDetailRecords.MaterialServiceType = Enums.MaterialServiceTypes.Material Then    
			// register BalanceOfMaterials Expense
			
			Record = RegisterRecords.BalanceOfMaterials.Add();
			Record.RecordType = AccumulationRecordType.Expense;
			Record.Period = Date;
			Record.Material = SelectionDetailRecords.MaterialOrService;
			Record.Warehouse = Warehouse;
			Record.Quantity = SelectionDetailRecords.QuantityInDocument;   
			Record.PropertySet = SelectionDetailRecords.PropertySet;
			
			
			// register CostOfMaterials Expense
			
			Record = RegisterRecords.CostOfMaterials.Add();
			Record.RecordType = AccumulationRecordType.Expense;
			Record.Period = Date;
			Record.Material = SelectionDetailRecords.MaterialOrService;
			Record.Cost = SelectionDetailRecords.QuantityInDocument * MaterialCost;        
			
			// Second posting: Dr 9000 (Income) – Cr 5000 (Inventory) Cost
			Record = RegisterRecords.Primary.Add();
			Record.AccountDr = ChartsOfAccounts.Main.Income;
			Record.AccountCr = ChartsOfAccounts.Main.Inventory;
			Record.Period = Date;
			Record.Sum = MaterialCost * SelectionDetailRecords.QuantityInDocument;
			Record.QuantityCr = SelectionDetailRecords.QuantityInDocument;
			Record.ExtDimensionsCr[ChartsOfCharacteristicTypes.ExtraDimensionTypes.Materials] = SelectionDetailRecords.MaterialOrservice;
		EndIf;   
		// register Sales
		Record = RegisterRecords.Sales.Add();
		Record.Period = Date;
		Record.MaterialOrService =
		SelectionDetailRecords.MaterialOrService;
		Record.Customer = Customer;
		Record.Technician = Technician;
		Record.Quantity = SelectionDetailRecords.QuantityInDocument;
		Record.Revenue = SelectionDetailRecords.TotalInDocument;
		Record.Cost = SelectionDetailRecords.QuantityInDocument
		* MaterialCost;
	EndDo;            
	
	RegisterRecords.Write();
	#EndRegion
	#Region BalanceCheck
	
	If Mode = DocumentPostingMode.RealTime Then
		Query3 = New Query;
		Query3.TempTablesManager = TTManager;
		Query3.Text = "SELECT
		|	BalanceOfMaterialsBalance.Material AS Material,
		|	BalanceOfMaterialsBalance.QuantityBalance AS QuantityBalance,
		|	BalanceOfMaterialsBalance.PropertySet AS PropertySet
		|FROM
		|	AccumulationRegister.BalanceOfMaterials.Balance(
		|			,
		|			Material IN
		|					(SELECT
		|						DocumentMaterialsAndServices.MaterialOrService
		|					FROM
		|						DocumentMaterialsAndServices)
		|				AND Warehouse = &Warehouse) AS BalanceOfMaterialsBalance
		|WHERE
		|	BalanceOfMaterialsBalance.QuantityBalance < 0";   
		Query3.SetParameter("Warehouse", Warehouse);
		QueryResult = Query3.Execute();
		SelectionDetailRecords = QueryResult.Select();  
		While SelectionDetailRecords.Next() Do
			Message = New UserMessage();
			Message.Text = String(- SelectionDetailRecords.QuantityBalance)
			+ " units shortage for """ + SelectionDetailRecords.Material
			+ """ with """ + SelectionDetailRecords.PropertySet
			+ """ property set.";  
			Message.Message();
			
			Cancel = True;
		EndDo;
	EndIf;
	
	#EndRegion
	
EndProcedure

Procedure OnSetNewNumber(StandardProcessing, Prefix)
	Prefix = Exchange.GetNumberingPrefix();
EndProcedure

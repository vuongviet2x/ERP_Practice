
Procedure Posting(Cancel, Mode)
	//{{__REGISTER_REGISTERRECORDS_WIZARD
	// This fragment was built by the wizard.
	// Warning! All manually made changes will be lost next time you use the wizard.
	
	RegisterRecords.BalanceOfMaterials.Write = True;  
	
	RegisterRecords.CostOfMaterials.Write = True;
	
	RegisterRecords.Primary.Write = True;
	
	For Each CurRowMaterials In Materials Do 
		// register BalanceOfMaterials Receipt
		
		Record = RegisterRecords.BalanceOfMaterials.Add();
		Record.RecordType = AccumulationRecordType.Receipt;
		Record.Period = Date;
		Record.Material = CurRowMaterials.Material;
		Record.Warehouse = Warehouse;
		Record.Quantity = CurRowMaterials.Quantity; 
		Record.PropertySet = CurRowMaterials.PropertySet;
		
		
		// register CostOfMaterials Receipt
		
		Record = RegisterRecords.CostOfMaterials.Add();
		Record.RecordType = AccumulationRecordType.Receipt;
		Record.Period = Date;
		Record.Material = CurRowMaterials.Material;
		Record.Cost = CurRowMaterials.Total;     
		
		// register Primary
		Record = RegisterRecords.Primary.Add();
		Record.AccountDr = ChartsOfAccounts.Main.Inventory;
		Record.AccountCr = ChartsOfAccounts.Main.AccountsPayable;
		Record.Period = Date;
		Record.Sum = CurRowMaterials.Total;  
		Record.QuantityDr = CurRowMaterials.Quantity;
		Record.ExtDimensionsDr[ChartsOfCharacteristicTypes.ExtraDimensionTypes.Materials] = CurRowMaterials.Material;
	EndDo;
	
	//}}__REGISTER_REGISTERRECORDS_WIZARD
EndProcedure

Procedure OnSetNewNumber(StandardProcessing, Prefix)
	Prefix = Exchange.GetNumberingPrefix();
EndProcedure

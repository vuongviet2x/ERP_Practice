Procedure BeforeWrite(Cancel, WriteMode, PostingMode)
	If DataExchange.Load Then
		Return; // data received by exchange is written as is
	EndIf;
	// Determining whether updating register record dates is required
	UpdateRegisterRecordsDate = IsNew() Or RegisterRecords.BalanceOfMaterials.Modified();
	If Not UpdateRegisterRecordsDate Then
		// Verifying that the date changed
		Query = New Query;
		Query.SetParameter("CurDocument", Ref);
		Query.Text =
		"SELECT
		| Date
		|FROM
		| Document.InputOpeningMaterialBalances
		|WHERE
		| Ref = &CurDocument";
		Selection = Query.Execute().Select();
		Selection.Next();
		UpdateRegisterRecordsDate = Selection.Date <> Date;
	EndIf;
	// Assigning the new date to all records, if required
	If UpdateRegisterRecordsDate Then
		If Not RegisterRecords.BalanceOfMaterials.Selected() And Not RegisterRecords.BalanceOfMaterials.Modified() Then
			RegisterRecords.BalanceOfMaterials.Read();
		EndIf;
		For Each RegisterRecord In RegisterRecords.BalanceOfMaterials Do
			RegisterRecord.Period = Date;
		EndDo;
	EndIf;
EndProcedure
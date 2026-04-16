 Function RetailPrice(EffectiveDate, MaterialOrServiceItem) Export
	 //Creating auxiliary Filter object
	 Filter = New Structure("MaterialOrService",
	 MaterialOrServiceItem);
	 //Getting effective register resource values
	 ResourceValues =
	 InformationRegisters.Prices.GetLast(EffectiveDate, Filter);
	 Return ResourceValues.Price;
 EndFunction
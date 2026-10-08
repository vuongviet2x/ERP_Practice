// Exchange messages of the Branches plan (book "Practical Developer's Guide", Lesson 24).
// Called from DataProcessor.DataExchange for every node except ThisNode.
// Illustrative code — compare with the original listing in the book and test (file names / exchange directory).

#Region Public

// Writes all changes registered for this node into an XML message file
Procedure WriteMessageWithChanges() Export

	Message("---------------- Exporting to node " + ThisObject + " ----------------");

	XMLWriter = New XMLWriter;
	XMLWriter.OpenFile(MessageFileName(ExchangePlans.Branches.ThisNode().Code, Code));
	XMLWriter.WriteXMLDeclaration();

	MessageWriter = ExchangePlans.CreateMessageWriter();
	MessageWriter.BeginWrite(XMLWriter, Ref);
	Message("Message number: " + MessageWriter.MessageNo);

	ChangeSelection = ExchangePlans.SelectChanges(MessageWriter.Recipient, MessageWriter.MessageNo);
	While ChangeSelection.Next() Do
		WriteXML(XMLWriter, ChangeSelection.Get());
	EndDo;

	MessageWriter.EndWrite();
	XMLWriter.Close();

	Message("---------------- End of export ----------------");

EndProcedure

// Reads the message file received from this node and writes its data
Procedure ReadMessageWithChanges() Export

	FileName = MessageFileName(Code, ExchangePlans.Branches.ThisNode().Code);
	If Not New File(FileName).Exist() Then
		Return;
	EndIf;

	Message("---------------- Importing from node " + ThisObject + " ----------------");

	XMLReader = New XMLReader;
	XMLReader.OpenFile(FileName);

	MessageReader = ExchangePlans.CreateMessageReader();
	MessageReader.BeginRead(XMLReader);
	Message("Message number: " + MessageReader.MessageNo);

	// Changes the other node has confirmed by this message are no longer needed
	ExchangePlans.DeleteChangeRecords(MessageReader.Sender, MessageReader.ReceivedNo);

	BeginTransaction();
	Try
		While CanReadXML(XMLReader) Do
			Data = ReadXML(XMLReader);
			// Do not register the received data back for the sender
			Data.DataExchange.Sender = MessageReader.Sender;
			Data.DataExchange.Load = True;
			Data.Write();
		EndDo;
		MessageReader.EndRead();
		CommitTransaction();
	Except
		RollbackTransaction();
		XMLReader.Close();
		WriteLogEvent("DataExchange.Read", EventLogLevel.Error, , Ref,
			DetailErrorDescription(ErrorInfo()));
		Raise;
	EndTry;

	XMLReader.Close();
	DeleteFiles(FileName);

	Message("---------------- End of import ----------------");

EndProcedure

#EndRegion

#Region Private

// Message from node FromCode to node ToCode, in the temporary files directory of the server
Function MessageFileName(FromCode, ToCode)
	Return TempFilesDir() + "Message" + TrimAll(FromCode) + "_" + TrimAll(ToCode) + ".xml";
EndFunction

#EndRegion


Procedure UpdateIndex() Export
	If FullTextSearch.GetFullTextSearchMode() = FullTextSearchMode.Enable
		Then
		If Not FullTextSearch.IndexTrue()Then
			FullTextSearch.UpdateIndex( , True);
		EndIf;
	EndIf;
EndProcedure


Procedure MergeIndexes() Export
	If FullTextSearch.GetFullTextSearchMode() = FullTextSearchMode.Enable
		Then
		If Not FullTextSearch.IndexTrue()Then
			FullTextSearch.UpdateIndex(True);
		EndIf;
	EndIf;
EndProcedure


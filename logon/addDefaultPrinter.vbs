'addDefaultPrinter script - J. Greg Mackinnon, 2014-06-11
'  Adds the network printer specified in the script argument "/share".
'  Sets this printer as the default printer for the current user.

option explicit

'Declare Variables
Dim bBadArg,bNoArgs
Dim cScrArgs
Dim iReturn
Dim sBadArg,sLog,sPrintShare,sScrArg,sScrArgs,sTemp,sTextsLog

Dim oFS,oLog,oShell
Dim WshNetwork

'Set initial values:
bBadArg = False
bNoArgs = False

'Instantiate Global Objects:
Set oShell = CreateObject("WScript.Shell")
Set oFS  = CreateObject("Scripting.FileSystemObject")

Set WshNetwork = CreateObject("WScript.Network")    


'''''''''''''''''''''''''''''''''''''''''''''''''''
' Define Functions
Sub subHelp
	echoAndLog "addDefaultPrinter.vbs Script"
	echoAndLog "by J. Greg Mackinnon, University of Vermont"
	echoAndLog ""
	echoAndLog "Installs a printer from a named network share, and sets this"
	echoAndLog "as the default printer for the current user."
	echoAndLog ""
	echoAndLog "Logs output to 'addDefaultPrinter.log' in the %temp% directory."
	echoAndLog ""
	echoAndLog "Required arguments and syntax:"
	echoAndLog "/share:""\\[server]\[share]"""
	echoAndLog "     Specify the UNC of the print share to be set as default."
End Sub

function echoAndLog(sText)
'EchoAndLog Function:
' Writes string data provided by "sText" to the console and to Log file
' Requires: 
'     sText - a string containing text to write
'     oLog - a pre-existing Scripting.FileSystemObject.OpenTextFile object
	'If we are in cscript, then echo output to the command line:
	If LCase( Right( WScript.FullName, 12 ) ) = "\cscript.exe" Then
		wscript.echo sText
	end if
	'Write output to log either way:
	oLog.writeLine sText
end function
'''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''
' Initialize Logging
sTemp = oShell.ExpandEnvironmentStrings("%TEMP%")
sLog = "addDefaultPrinter.log"
Set oLog = oFS.OpenTextFile(sTemp & "\" & sLog, 2, True)
' End Initialize Logging
'''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''
' Parse Arguments
If WScript.Arguments.Named.Count > 0 Then
	Set cScrArgs = WScript.Arguments.Named
	For Each sScrArg in cScrArgs
		Select Case LCase(sScrArg)
			Case "share"
				sPrintShare = cScrArgs.Item(sScrArg)
			Case Else
				bBadArg = True
				sBadArg = sScrArg
		End Select
	Next
ElseIf WScript.Arguments.Named.Count = 0 Then 'Detect if required args are not defined.
	bNoArgs = True
End If 
'''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''
' Process Arguments
if bBadArg then
	echoAndLog vbCrLf & "Unknown switch or argument: " & sBadArg & "."
	echoAndLog "**********************************" & vbCrLf
	subHelp
	WScript.Quit(100)
elseif bNoArgs then
	echoAndLog vbCrLf & "Required arguments were not specified."
	echoAndLog "**********************************" & vbCrLf
	subHelp
	WScript.Quit(100)
end if
echoAndLog "Printer share to set to default: " 
echoAndLog sPrintShare & vbCrLf
' End Process Arguments
'''''''''''''''''''''''''''''''''''''''''''''''''''

'''''''''''''''''''''''''''''''''''''''''''''''''''
'Begin Main
'
on error resume next
'Add Printer
iReturn = 0
iReturn = WshNetwork.AddWindowsPrinterConnection(sPrintShare)
if err.number <> 0 then 'Gather error data if AddWindowsPrinterConnection failed.
	echoAndLog "Error: " & Err.Number
	echoAndLog "Error (Hex): " & Hex(Err.Number)
	echoAndLog "Source: " &  Err.Source
	echoAndLog "Description: " &  Err.Description
	iReturn = Err.Number
	Err.Clear
	wscript.quit(iReturn)
end if
if iReturn <> 0 then
	echoAndLog "Non-zero return code when attempting to set default printer."
	echoAndLog "Return Code was: " & iReturn
end if

'Set Default Printer
iReturn = 0
iReturn = WshNetwork.SetDefaultPrinter(sPrintShare)
if err.number <> 0 then 'Gather error data if SetDefaultPrinter failed.
	echoAndLog "Error: " & Err.Number
	echoAndLog "Error (Hex): " & Hex(Err.Number)
	echoAndLog "Source: " &  Err.Source
	echoAndLog "Description: " &  Err.Description
	iReturn = Err.Number
	Err.Clear
	wscript.quit(iReturn)
end if
on error goto 0
'echoAndLog "Return code from the command: " & iReturn
if iReturn <> 0 then
	echoAndLog "Non-zero return code when attempting to set default printer."
	echoAndLog "Return Code was: " & iReturn
end if

oLog.Close
wscript.quit(iReturn)

' End Main
'''''''''''''''''''''''''''''''''''''''''''''''''''
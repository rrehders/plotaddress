(* ::Package:: *)

(************************************************************************)
(* This file was generated automatically by the Mathematica front end.  *)
(* It contains Initialization cells from a Notebook file, which         *)
(* typically will have the same name as this file except ending in      *)
(* ".nb" instead of ".m".                                               *)
(*                                                                      *)
(* This file is intended to be loaded into the Mathematica kernel using *)
(* the package loading commands Get or Needs.  Doing so is equivalent   *)
(* to using the Evaluate Initialization Cells menu command in the front *)
(* end.                                                                 *)
(*                                                                      *)
(* DO NOT EDIT THIS FILE.  This entire file is regenerated              *)
(* automatically each time the parent Notebook file is saved in the     *)
(* Mathematica front end.  Any changes you make to this file will be    *)
(* overwritten.                                                         *)
(************************************************************************)



(* Initialization *)
Needs ["JLink`"]
(* Load Java functionality *)
If[JavaLink[] === Null, InstallJava[];];
LoadJavaClass["java.net.URLEncoder"];

(* Private API key from google *)
$key = "AIzaSyBufb92UiWaK5WRqZF_PeUloidrgn4OUw8";

ToWebString[s_String] := URLEncoder`encode[s, "UTF-8"]

iapi[address_String, key_String] := 
 "https://maps.googleapis.com/maps/api/geocode/json?address=" <> 
  ToWebString[address] <> "&key=" <> key
  
api[address_String] :=
	With[{res = {"lat", "lng"} /. ("location" /. ("geometry" /. ("results" /. 
		ImportString[Import[iapi[address, $key], "String"], "JSon"])))},
		Switch[res,{{_Real, _Real}}, First@res, _, Missing["NotAvailable"]]
	]


(* Handle Command line arguments *)
(* If ScriptCommandline is completely blank, the script is being debugged in Mathematica *)
If[Length[$ScriptCommandLine]==0,
	ifile = FileNameJoin[{NotebookDirectory[],"test","address.csv"}];
	ofile = FileNameJoin[{NotebookDirectory[],"test","address.jpg"}];,
	(* ELSE, Script is live, check if no arguments are passed *)
	If[Length[$ScriptCommandLine]>1,
		args = Rest[$ScriptCommandLine];
		ifile = First[$ScriptCommandLine];
		ofile = FileBaseName[ifile]<>".jpg";,
		(* ELSE Scipt is live but no argument passed, use a default filename of "address.csv" *)
		ifile = "address.csv";
		ofile = FileBaseName[ifile]<>".jpg";
	]
]


(* Read file of addresses *)
Switch[FileExtension[ifile],
	"csv",tblInput=Import[ifile],
	"xls",tblInput=Import[ifile,{"data",1}],
	"xlsx",tblInput=Import[ifile,{"data",1}]
]


(* Geolocate Addresses from Google Maps *)
Module[
 	{colAddresses, colLocations, colLat, ColLong, tmp},	
 	(* Merge address components into a single string *)
 	
 colAddresses = StringJoin[Riffle[#, " "]] & /@ tblInput;
 	(* Geolocate the address on Google *)
 	
 colLocations = api[#] & /@ colAddresses;
 	(* flip the table and add the latitude and longitude as rows *)
 	
 tmp = Transpose[tblInput];
 	tmp = Append[tmp, First@# & /@ colLocations]; 
 tmp = Append[tmp, Last@# & /@ colLocations];
 	tblInput = Transpose[tmp];
 ]


(* Convert the information to a list of GeoPosition Objects *)
geopos = GeoPosition[#]&/@tblInput[[All,{6,7}]]
(* Plot the locations *)
imgGeoPlot = GeoListPlot[geopos,ImageSize->1000,PlotStyle->{Blue}]


(* Save Graphic *)
Export[ofile,imgGeoPlot]

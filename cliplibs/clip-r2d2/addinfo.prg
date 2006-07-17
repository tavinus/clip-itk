#include "r2d2lib.ch"

function r2d2_addinfo_xml(_queryStr)

local err,_query,_queryArr
local i,j,k,m,obj,id:=""
local aTree:={}, aRefs:={}
local connect_id:="", connect_data
local lang:="", sDict:="", sDep:=""
local oDict,oDep, tmp,tmp1,tmp2, classDesc
local columns,col,mas:={},objs:={}
local err_desc:="",keyValue
local urn,a,b,xmlitem

local p_list,pdoc_del:=map()
local sprname:=""

//#define NEW_ACCPOST

	errorblock({|err|error2html(err)})

	_queryArr := cgi_split(_queryStr,.t.)
	_query    := d2ArrToMap(_queryArr)
	outlog(__FILE__,__LINE__, _query)

	if "CONNECT_ID" $ _query
		connect_id := _query:connect_id
	endif
	if "SPR" $ _query
		sprname := _query:spr
	endif
	if "LANG" $ _query
		lang := _query:lang
	endif
	if "ID" $ _query
		id := _query:id
	endif
	if "URN" $ _query
		URN := _query:URN
	endif
	if "XMLITEM" $ _query
		XMLITEM := _query:xmlitem
	endif
	if !empty(connect_id)
		connect_data := cgi_connect_data(connect_id)
	endif
    /*
	if !empty(connect_data)
		beg_date := connect_data:beg_date
		end_date := connect_data:end_date
	endif
    */
	if "ACC01" $ _query .and. !empty(_query:acc01)
		set("ACC01",_query:acc01)
	endif
	if "ACC00" $ _query .and. !empty(_query:acc00)
		set("ACC00",_query:acc00)
	endif

	lang := cgi_choice_lang(lang)
	sDep := cgi_choice_sDep(lang)
	//sprname := lower(sprname)
	sDict:= cgi_choice_sDict(@sprname)

	if !empty(id)
		sDict := left(id,codb_info("DICT_ID_LEN"))
		sDep  := substr(id,codb_info("DICT_ID_LEN")+1,codb_info("DEPOSIT_ID_LEN"))
	endif


	if empty(sprname) .or. empty(sDep) .or. empty(sDict)
		?? "Content-type: text/html"
		?
		?
		? "Error: bad parameters ! "
		if empty (sdep)
			?? "Depository not defined "
		endif
		if empty (sdict)
			?? "DICTIONARY not defined "
		endif
		? "Usage:"
		? "    addinfo?spr=<spr_name>&id=<id_object>&data_object....."
		?
		return
	endif

	cgi_xml_header()

	if empty(id)
		oDep := cgi_needDepository(sDict,sDep)
	else
		oDep := codb_needDepository(sDict+sDep)
	endif
	if empty(oDep)
		cgi_xml_error( "Depository not found: "+sDict+sDep )
		return
	endif
	oDict := oDep:dictionary()
	classDesc := oDict:classBodyByName(sprname)

	if empty(classDesc)
		cgi_xml_error("Not found class description for "+sprname)
		return
	endif

	columns := cgi_make_columns(oDict,sprname)

	if classDesc:name == "accpost"
		r2d2_accpost_log(oDep,"CGIADD","",_queryStr)
	endif

	if "};" $ _queryStr
		while !empty(_queryStr)
			i := at("{",_queryStr)
			j := at("};",_queryStr)
			k := substr(_queryStr,i+1,j-i-1)
			_queryStr := substr(_queryStr,j+2)
			aadd(mas,k)
		end
	else
		aadd(mas,_queryStr)
	endif
	if !oDict:lockID(classDesc:id,10000)
		return
	endif


	for m=1 to len(mas)
		outlog(__FILE__,__LINE__, mas[m])
		_query:=cgi_split(mas[m])
		if "ID" $ _query
			id := _query:id
		else
			id := ""
		endif
		obj:=map()
		for i=1 to len(classDesc:attr_list)
			col:=oDict:getValue(classDesc:attr_list[i])
			if empty(col)
				loop
			endif
			tmp1 := upper(col:name)
			if ! (tmp1 $ _query)
				loop
			endif
			do switch col:type
				case "C"
					obj[tmp1] := _query[tmp1]
				case "M"
					obj[tmp1] := _query[tmp1]
				case "L"
					obj[tmp1] := (upper(left(_query[tmp1],1))=='T')
				case "N"
					obj[tmp1] := val(_query[tmp1],col:len,col:dec)
				case "D"
					obj[tmp1] := ctod(_query[tmp1],"dd.mm.yyyy")
				case "A"
					//obj[tmp1] := &(_query[tmp1])
					if empty(_query[tmp1])
						obj[tmp1] := {}
					else
						obj[tmp1] := split(_query[tmp1],",")
					endif
				otherwise
					obj[tmp1] := _query[tmp1]
			endswitch
		next
		if "AN_DEBET" $ obj .and. "AN_KREDIT" $ obj
			for i=1 to len(obj:an_debet)
				if empty(obj:an_debet[i])
					adel(obj:an_debet,i)
					asize(obj:an_debet,len(obj:an_debet)-1)
					i --
					loop
				endif
				col:=obj:an_debet[i]
				tmp1 := cgi_getValue(col)
				if empty(tmp1)
					outlog("Object not readable:",col)
					adel(obj:an_debet,i)
					asize(obj:an_debet,len(obj:an_debet)-1)
					i --
					loop
				endif
				obj:an_debet[i] := NIL
				obj:an_debet[i] := {tmp1:class_id,tmp1:id}
			next
			for i=1 to len(obj:an_kredit)
				if empty(obj:an_kredit[i])
					adel(obj:an_kredit,i)
					asize(obj:an_kredit,len(obj:an_kredit)-1)
					i --
					loop
				endif
				col:=obj:an_kredit[i]
				tmp1 := cgi_getValue(col)
				if empty(tmp1)
					outlog("Object not readable:",col)
					adel(obj:an_kredit,i)
					asize(obj:an_kredit,len(obj:an_kredit)-1)
					i --
					loop
				endif
				obj:an_kredit[i] := NIL
				obj:an_kredit[i] := {tmp1:class_id,tmp1:id}
			next
		endif

		if classDesc:name == "accpost"
			a:=b:=space(codb_info("CODB_ID_LEN"))
			if  "PRIMARY_DOCUMENT" $ obj
				a := obj:primary_document
			else
				obj:primary_document := a
			endif
			if  "DOCUMENT_RECORD" $ obj
				b := obj:document_record
			else
				obj:document_record := b
			endif
			id :=""
			if !empty(a+b) .and. !(a+b $ pdoc_del)
				p_list := oDep:select(classDesc:id,,,'primary_document=="'+a+'" .and. document_record=="'+b+'"')
				for i=1 to len(p_list)
					oDep:delete(p_list[i])
				next
				/* �� ������� ������ ���*/
				pdoc_del[a+b] := a+b
			endif
		endif
		if "CLASS_ID" $ obj
		else
			obj:class_id := classDesc:id
		endif
		if !empty(id)
			obj:id := id
			if .f. //classDesc:name == "accpost"
				oDep:error := r2d2_mt_oper("update_accpost",oDep,obj)
				//oDep:update(obj)
			else
				oDep:update(obj)
			endif
		else
			if .f. //classDesc:name == "accpost"
				oDep:error := r2d2_mt_oper("append_accpost",oDep,obj)
				//id := oDep:append(obj,classDesc:id)
			else
				id := oDep:append(obj,classDesc:id)
			endif
		endif
		if !empty(oDep:error)

			if val(oDep:error) != 1143 /* non unique value */
				outlog(__FILE__,__LINE__, odep:error)
			cgi_xml_error(odep:error) //�� ���� �������� xml ��� ��������� ����!!!!!!!
			//	return
			endif
			err_desc := oDep:error
			if "UNIQUE_KEY" $ classDesc .and. !empty(classDesc:unique_key)
			/* seek unique value */
				keyValue:=oDep:eval(classDesc:unique_key,obj)
				if empty(keyValue)
				outlog(__FILE__,__LINE__, odep:error)				
					cgi_xml_error(err_desc+":"+oDep:error)
			//		return
				endif
				tmp := oDep:id4PrimaryKey(classDesc:name,classDesc:unique_key,keyValue,.t.)
				for i=1 to len(tmp)
					k := oDep:getValue(tmp[i])
					if !empty(k)
						aadd(aRefs,{k:id,"",.f.,k})
						aadd(objs,k)
					endif
				next
			endif
		else
			if classDesc:name == "accpost"
				objs := {}
				p_list := oDep:select(classDesc:id,,,'primary_document=="'+obj:primary_document+'" .and. document_record=="'+obj:document_record+'"')
				for i=1 to len(p_list)
					k := oDep:getValue(p_list[i])
					if !empty(k)
						aadd(aRefs,{k:id,"",.f.,k})
						aadd(objs,k)
					endif
				next
			else
				obj := oDep:getValue(id)
				aadd(aRefs,{obj:id,"",.f.,obj})
				aadd(objs,obj)
			endif
		endif
	next
	oDict:unLockID(classDesc:id)

	if set("XML_OUT")=="NO"
	else
	    if xmlitem=='yes'
		? '<xmlitems>'
		cgi_fillTreeRdf(aRefs,aTree,"",1)
		if empty(urn)
			urn := 'urn:'+sprname
		endif
		cgi_putArefs2Rdf(aTree,oDep,0,urn,columns,"")
		? '</xmlitems>'
	    else
		? '<RDF:RDF xmlns:RDF="http://www.w3.org/1999/02/22-rdf-syntax-ns#"'
		? 'xmlns:DOCUM="http://last/cbt_new/rdf#">'
		?
		cgi_fillTreeRdf(aRefs,aTree,"",1)

		if empty(urn)
			urn := 'urn:'+sprname
		endif
		cgi_putArefs2Rdf1(aTree,oDep,0,urn,columns,"")
		? '</RDF:RDF>'
	    endif
	endif

?
return

/************************************************/
static function put_object(obj,oDep,columns,_queryArr,err_desc)
	local level:=1,s:=replicate("   ",level),col
	local i,j, oOut,sout
	if "ID" $ obj
		sOut:=s+' <treeitem id="'+obj:id+'" '
	else
		sOut:=s+' <treeitem '
	endif
	if !empty(err_desc)
		sOut += ' error="true" errmsg="'+err_desc+'"'
	endif
	sOut += ' >'
	? cgi_dataTran(sOut,_queryArr)
	sOut := s+"   <treerow>"
	? cgi_dataTran(sOut,_queryArr)

	for j=1 to len(columns)
		col := columns[j]
		oOut := cgi_objDesc(obj,col)
		? s+"      "+'<treecell label="'+oOut:label+'" '
		if !empty(oOut:obj_id)
			?? 'obj_id="'+oOut:obj_id+'" '
		endif
		if !empty(oOut:obj_name)
			?? 'obj_name="'+oOut:obj_name+'" '
		endif
		if !empty(oOut:Out)
			?? oOut:out
		endif
		?? '/>'
	next

	? s,"  </treerow>"
	? s,' </treeitem>'
return

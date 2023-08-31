// Programa   : NMNOMTXT
// Fecha/Hora : 29/04/2004 12:44:44
// Prop®sito  : Presentar opciones luego de procesar N®mina
// Creado Por : Juan Navas
// Llamado por: ACTUALIZA
// Aplicaci®n : N®mina
// Tabla      : Todas

#INCLUDE "DPXBASE.CH"

PROCE MAIN(dDesde,dHasta,cTipoNom,cOtraNom)
  LOCAL aBancos :={} // GETOPTIONS("DPBANCOS","BAN_BCOTXT")
  local nAt:=0,cFile,aData,cSql
  LOCAL oData 

/*
  IF !Empty(aBancos)
     EJECUTAR("NMCAMPOSOPCSETCOLOR")
     aBancos :=GETOPTIONS("DPBANCOS","BAN_BCOTXT")
  ENDIF
*/

  EJECUTAR("NMTIPNOM")

  cSql:=[ SELECT BAN_NOMBRE FROM DPBANCODIR ]+;
        [ INNER JOIN NMTRABAJADOR ON BANCO=BAN_CODIGO ]+;
        [ GROUP BY BAN_NOMBRE ]

  aBancos:=ATABLE(cSql,.T.)

  nAt:=ASCAN(aBancos,"Ninguno")

  IF nAt>0
    ADEL(aBancos,nAt)
    ASIZE(aBancos,Len(aBancos)-1)
  ENDIF

  oData     :=DATASET("NOMINA","ALL")

  oDp:cBanco:=oData:Get("cBancoTxt",aBancos[1])   // Modelo de Banco    
  cFile     :=oData:Get("cFileBco" ,Padr(oDp:cPath+"nominatxt.txt",90))

  DEFAULT oDp:dFchpago:=oDp:dFecha

  oData:End(.F.)

  oFrmTxt:=DPEDIT():New("Nómina Electrónica Para el Banco","NOMTXTBCO.edt","oFrmTxt",.T.)
  oFrmTxt:cFileChm     :="CAPITULO2.CHM"

  oFrmTxt:cTipoNom     :=oDp:cTipoNom
  oFrmTxt:cOtraNom     :=oDp:cOtraNom
  oFrmTxt:cBanco       :=oDp:cBanco  
  oFrmTxt:dDesde       :=oDp:dDesde 
  oFrmTxt:dHasta       :=oDp:dHasta
  oFrmTxt:oMeter       :=NIL
  oFrmTxt:nTrabajadores:=0
  oFrmTxt:oSayTrab     :=NIL
  oFrmTxt:lCancel      :=.F.
  oFrmTxt:oNm          :=NIL
  oFrmTxt:lCancel      :=.T. // No Solicita Cancelar
  oFrmTxt:cCodGru      :=oDp:cCodGru
  oFrmTxt:oCodGru      :=NIL
  oFrmTxt:nSalida      :=2
  oFrmTxt:lCodigo      :=.T.           // Requiere Rango del Trabajador
  oFrmTxt:lFecha       :=.F.           // Rango de Fecha
  oFrmTxt:lEditar      :=.T.           // Proceso Optimizado                       
  oFrmTxt:dFecha       :=oDp:dFecha    // Toma la Fecha del Sistema
  oFrmTxt:cFileBco     :=cFile
  oFrmTxt:cFileOld     :=oFrmTxt:cFileBco
  oFrmTxt:cSql         :=""
  oFrmTxt:cOtraNom     :=oDp:cOtraNom 
  oFrmTxt:lEscClose    :=.T.

  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Nómina"
  @ 2,1 GROUP oGrp TO 4, 21.5 PROMPT "Periodo"

  @ 1,2 SAY "Tipo de Nómina"
  @ 3,2 SAY  GetFromVar("{oDp:XNMGRUPO}")
  @ 4,2 SAY "Otra Nómina"
  @ 5,2 SAY "Banco"
  @ 6,2 SAY "Archivo Destino"

  @ 1,12 COMBOBOX oFrmTxt:oTipoNom  VAR oFrmTxt:cTipoNom  ITEMS oDp:aTipoNom;
         ON CHANGE oFrmTxt:GetFecha(oFrmTxt)

  @ 2,12 COMBOBOX oFrmTxt:oOTraNom  VAR oFrmTxt:cOtraNom  ITEMS oDp:aOTraNom;
         WHEN oFrmTxt:cTipoNom="O";
         ON CHANGE oFrmTxt:GetFecha(oFrmTxt)

  @ 3,12 COMBOBOX oFrmTxt:oBanco  VAR oFrmTxt:cBanco  ITEMS aBancos  

  @ 4,12 BMPGET oFrmTxt:oCodGru VAR oFrmTxt:cCodGru;
         NAME   "BITMAPS\FIND.bmp";
         VALID  oFrmTxt:ValGrupo(oFrmTxt,oFrmTxt:cCodGru);
         WHEN   oDp:nGrupos>0;
         ACTION oFrmTxt:LISTGRU(oFrmTxt,"cCodGru","oCodGru")

  // RANGO DE FECHA

  @ 4,12 BMPGET oFrmTxt:oDesde VAR oFrmTxt:dDesde PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN oFrmTxt:lFecha;
         ACTION LbxDate(oFrmTxt:oDesde,oFrmTxt:dDesde)

  @ 5,12 BMPGET oFrmTxt:oHasta VAR oFrmTxt:dHasta PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         WHEN oFrmTxt:lFecha;
         VALID (Igualar(oFrmTxt:oDesde,oFrmTxt:oHasta).AND.oFrmTxt:dHasta>=oFrmTxt:dDesde.AND.!EMPTY(oFrmTxt:dHasta));
         ACTION LbxDate(oFrmTxt:oHasta,oFrmTxt:dHasta)


  @ 8,12 BMPGET oFrmTxt:oFileBco  VAR oFrmTxt:cFileBco;
         NAME "BITMAPS\FIND.bmp";
         VALID 1=1;
         ACTION (oFrmTxt:FileOld:= cGetFile32(MI("Fichero ")+"TXT (*.txt) |*.txt| "+MI("Seleccionar Fichero ")+" DBF (*.txt) |*.txt|",;
                 MI("Seleccionar Fichero ")+"TXT ", 1, oFrmTxt:cFileBco , .t.),;
                 oFrmTxt:oFileBco:VarPut(IIF(Empty(oFrmTxt:FileOld),oFrmTxt:FileTxt,oFrmTxt:FileOld),.t.),;
                 DpFocus(oFrmTxt:oFileBco))


  @ 4,12 BMPGET oDp:oFchPago VAR oDp:dFchPago PICTURE "99/99/9999";
         NAME "BITMAPS\Calendar.bmp";
         ACTION LbxDate(oDp:oFchPago,oFrmTxt:dFchPago)


  // RANGO DE TRABAJADOR 

  @ 3,12 CHECKBOX oFrmTxt:lEditar PROMPT "Editar Archivo"

  @ 08,01 METER oFrmTxt:oMeter VAR oFrmTxt:nTrabajadores

  @ 08,01 SAY oFrmTxt:oSayTrab  PROMPT "Trabajador:"+SPACE(30)

  @ 08,01 SAY oFrmTxt:oGrupo PROMPT ""+SPACE(30)

  oFrmTxt:ValGrupo(oFrmTxt,oFrmTxt:cCodGru,.T.)

  @ 08,10 SAY "Fecha de Pago:" 

/*
  @ 6,07 BUTTON oFrmTxt:oBtnIniciar PROMPT "Iniciar " ACTION  (CursorWait(),;
                                    oFrmTxt:SetMsg("Ejecutar Actualizaci®n"),;
                                    oFrmTxt:EJECUTAR(oFrmTxt,.F.))

  @ 6,07 BUTTON oFrmTxt:oBtnIniciar PROMPT "Listar " ACTION  (CursorWait(),;
                                    oFrmTxt:SetMsg("Generando Listado"),;
                                    oFrmTxt:EJECUTAR(oFrmTxt,.T.))

  @ 6,10 BUTTON oFrmTxt:oBtnCerrar PROMPT "Cerrar  " ACTION oFrmTxt:Detener(oFrmTxt) CANCEL

  @ 4,20 BUTTON "Opciones de Bancos" ACTION  EJECUTAR("DPCAMPOSOPC",3,"BAN_BCOTXT","DPBANCODIR")
*/

// EJECUTAR("CAMPOSOPC","NMBANCOS",GetFromVar("{oDp:NMBANCOS}"))

  oFrmTxt:Activate({||oFrmTxt:ViewDatBar()})

RETURN NIL

/*
// Barra de Botones
*/
FUNCTION ViewDatBar()
   LOCAL oCursor,oBar,oBtn,oFont
   LOCAL oDlg:=oFrmTxt:oDlg

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 60,60 OF oDlg 3D CURSOR oCursor

   DEFINE FONT oFont NAME "Tahoma"   SIZE 0, -12 BOLD 


   DEFINE BUTTON oFrmTxt:oBtnIniciar;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Calcular";
          FILENAME "BITMAPS\RUN.BMP",NIL,"BITMAPS\RUNG.BMP";
          ACTION (CursorWait(),;
                  oFrmTxt:SetMsg("Generando TXT"),;
                  oFrmTxt:EJECUTAR(oFrmTxt,.F.))

                  
   oFrmTxt:oBtnIniciar:cToolTip:="Generar TXT"

   DEFINE BUTTON oFrmTxt:oBtnPreview;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Preview";
          FILENAME "BITMAPS\PREVIEW.BMP",NIL,"BITMAPS\RECIBOG.BMP";
          ACTION  (CursorWait(),;
                   oFrmTxt:SetMsg("Generando Listado"),;
                   oFrmTxt:EJECUTAR(oFrmTxt,.T.))

   oFrmTxt:oBtnPreview:cToolTip:="Previsualización"


   DEFINE BUTTON oFrmTxt:oBtnBrowse;
          OF oBar;
          NOBORDER;
          FONT oFont;
          TOP PROMPT "Recibos";
          FILENAME "BITMAPS\RECIBO.BMP",NIL,"BITMAPS\RECIBOG.BMP";
          ACTION (CursorWait(),;
                  oFrmTxt:BRRECIBOS())

   oFrmTxt:oBtnBrowse:cToolTip:="Ver Recibos del Banco"


   DEFINE BUTTON oFrmTxt:oBtnCerrar;
          OF oBar;
          FONT oFont;
          TOP PROMPT "Cerrar";
          NOBORDER;
          FILENAME "BITMAPS\XSALIR.BMP";
          ACTION;
          oFrmTxt:Detener(oFrmTxt);
          CANCEL

   oFrmTxt:oBtnCerrar:cToolTip:="Salir"

   @ 2,50 CHECKBOX oFrmTxt:lEditar PROMPT "Editar Archivo" OF oBar SIZE 140,20 FONT oFont

   oBar:SetColor(CLR_BLACK,oDp:nGris)
   AEVAL(oBar:aControls,{|o,n|o:SetColor(CLR_BLACK,oDp:nGris)})


RETURN .T.


FUNCTION EJECUTAR(oFrmTxt,lListar)
   LOCAL aNomina,cTitle1,cTitle2,lHubo:=.F.,I,nCuantos:=0,nCuantosT:=0
   LOCAL oTable,oTrabj,oNomina
   LOCAL nTrabj  :=0 // Cantidad de Trabajadores
   LOCAL cTipoNom:=LEFT(oFrmTxt:cTipoNom,1)
   LOCAL cOtraNom:=IIF(cTipoNom!="O","",LEFT(oFrmTxt:cOtraNom,2))
   LOCAL cSql:="",oData,nZero:=0,cPrg

   LOCAL cWhereGru:=EJECUTAR("NMWHEREGRU",oFrmTxt:cCodGru)

   oData  :=DATASET("NOMINA","ALL")
   oData:Set("cBancoTxt",oFrmTxt:cBanco)
   oData:Set("cFileBco" ,oFrmTxt:cFileBco)
   oData:Save()
   oData:End()

//   nTrabj:=COUNT("NMTRABAJADOR","INNER JOIN NMBANCOS ON NMTRABAJADOR.BANCO=NMBANCOS.BAN_CODIGO "+;
//         " WHERE NMBANCOS.BAN_BCOTXT"+GetWhere("=",oFrmTxt:cBanco))

   nTrabj:=COUNT("NMTRABAJADOR","INNER JOIN DPBANCODIR ON NMTRABAJADOR.BANCO=DPBANCODIR.BAN_CODIGO "+;
         " WHERE DPBANCODIR.BAN_NOMBRE"+GetWhere("=",oFrmTxt:cBanco))

   IF nTrabj=0

      MensajeErr("No hay Trabajadores Asociados con el Banco: "+CRLF+;
                 oFrmTxt:cBanco,;
                 "Información no Encontrada")

      RETURN .F.

   ENDIF

   // Cuantos Recibos con Forma de Pago TRANSFERENCIA

   cSql:= " SELECT COUNT(*) AS CUANTOS, "+;
          " SUM(IF(REC_FORMAP='T',  1, IF(1=0,0,0))) AS CUANTOST "+;
          " FROM NMRECIBOS "+;
          " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
          " INNER JOIN NMTRABAJADOR ON REC_CODTRA=CODIGO     "+;
          " LEFT  JOIN NMGRUPO      ON GRUPO     =GTR_CODIGO "+;
          " WHERE "+;
          " FCH_DESDE "+GetWhere("=",oFrmTxt:dDesde  )+" AND "+;
          " FCH_HASTA "+GetWhere("=",oFrmTxt:dHasta  )+" AND "+;
          " FCH_TIPNOM"+GetWhere("=",cTipoNom)+" AND "+;
          " FCH_OTRNOM"+GetWhere("=",cOtraNom)+;
          IIF( Empty(cWhereGru) , "" , " AND " )+;
            cWhereGru 	

   oTable   :=OpenTable(cSql,.T.)
   nCuantos :=oTable:FieldGet(1)
   nCuantosT:=oTable:FieldGet(2)
   oTable:End()

   IF !EMPTY(nCuantos) .AND. Empty(nCuantosT)
      MensajeErr(LSTR(nCuantos)+" Recibos Encontrados "+CRLF+;
                 "Es necesario que posean Forma de Pago Transferencia","No hay Recibos con Forma de Pago Transferencia")
      RETURN .F.
   ENDIF

   cSql:= " SELECT CODIGO,APELLIDO,NOMBRE,SALARIO,BANCO_CTA,TIPO_CED,TIPCTABCO,CEDULA,SUM(HIS_MONTO) AS REC_MONTO, "+;
          " FCH_DESDE,FCH_HASTA "+;
          " FROM NMRECIBOS "+;
          " INNER JOIN NMTRABAJADOR ON NMTRABAJADOR.CODIGO   =NMRECIBOS.REC_CODTRA "+;
          " LEFT  JOIN NMGRUPO      ON GRUPO     =GTR_CODIGO "+;
          " INNER JOIN NMHISTORICO  ON NMHISTORICO.HIS_NUMREC=NMRECIBOS.REC_NUMERO "+;
          " INNER JOIN DPBANCODIR   ON NMTRABAJADOR.BANCO=DPBANCODIR.BAN_CODIGO "+;
          " INNER JOIN NMFECHAS     ON REC_NUMFCH=FCH_NUMERO "+;
          " WHERE HIS_CODCON<='DZZZ' AND "+;
          " FCH_DESDE "+GetWhere("=",oFrmTxt:dDesde  )+" AND "+;
          " FCH_HASTA "+GetWhere("=",oFrmTxt:dHasta  )+" AND "+;
          " FCH_TIPNOM"+GetWhere("=",cTipoNom)+" AND "+;
          " FCH_OTRNOM"+GetWhere("=",cOtraNom)+" AND "+;
          " BANCO_CTA<>'' AND REC_FORMAP='T' "+;
          IIF( Empty(cWhereGru) , "" , " AND " )+;
            cWhereGru +" AND "+;
          " DPBANCODIR.BAN_NOMBRE"+GetWhere("=",oFrmTxt:cBanco)+;
          " GROUP BY CODIGO,APELLIDO,NOMBRE,BANCO_CTA,TIPO_CED,TIPCTABCO,CEDULA"

    oTable:=OpenTable(cSql,.T.)

    // CLPCOPY(cSql)

    FOR I=1 TO oTable:RecCount()
       IF oTable:REC_MONTO=0 
          ADEL(oTable:aDataFill,I)
          ASIZE(oTable:aDataFill,LEN(oTable:aDataFill)-1)
          I=I-1
          nZero++
       ENDIF
    NEXT I

    If Empty(oTable:RecCount())

      MensajeErr("Recibos no Encontrados"+CRLF+;
                 "Asegúrese que los trabajadores esten Asociados al Banco:"+oFrmTxt:cBanco+CRLF+;
                 "Los recibos de deben poseer forma de Pago [Transferencia]"+CRLF+;
                 "("+LSTR(nZero,5)+")Recibo(s) con Valor Cero "+CRLF+;
                 "Trabajadores Asociados "+ALLTRIM(STR(nTrabj))+" con el Banco "+oFrmTxt:cBanco,;
                 "Información no Encontrada")
      
      oTable:End()

      RETURN .F.

    Endif

    IF lListar

      oFrmTxt:TXTIMPRIME(oFrmTxt,oTable)

    ELSE

      cPrg:=SQLGET("DPBANCOS","BAN_DEFNOM","BAN_BCOTXT"+GetWhere("=",oFrmTxt:cBanco))

      // AQUI SE AGREGAR LOS NUEVOS BANCOS CON SU NOMBRE Y RESPECTIVO PROGRAMA
      DO CASE

         CASE !Empty(cPrg)
            // 30/08/2023
            oFrmTxt:RUNTXTPRG(cPrg,oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar)
 
         CASE "BANESCO"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOBANESCO",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar)

         CASE "BANPLUS"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOBANP",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "BOLIVAR"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOBOLIVARDESC",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)
         
         CASE "CANARIAS"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOCANARIAS",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "CARIBE"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOCARIBE",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "CORPBANCA"$UPPE(oFrmTxt:cBanco)
		  EJECUTAR("BCOCORPBANCA",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "EXTERIOR"$UPPE(oFrmTxt:cBanco)
		  EJECUTAR("BCOEXT",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "FEDERAL"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOFEDERAL",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "FONDO"$UPPE(oFrmTxt:cBanco)
		  EJECUTAR("BCOFONDOCOMUN",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "INDUSTRIAL DE VE"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOIND",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar)

         CASE "MERCANTIL"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOMERC",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         CASE "NACIONAL"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCONDC",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)
 
         CASE "OCCIDENTAL"$UPPE(oFrmTxt:cBanco)
		  EJECUTAR("BCOBOD",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)
      
         CASE "PROVINCIAL"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOPROV",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar)
                
         CASE "VENEZOLANO"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOVCRE",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)
         
         CASE "VENEZUELA"$UPPE(oFrmTxt:cBanco)
            EJECUTAR("BCOVENEZUELA",oTable,ALLTRIM(oFrmTxt:cFileBco),oFrmTxt:oMeter,oFrmTxt:oSayTrab,oFrmTxt:lEditar,oFrmTxt:cBanco)

         OTHER
  
            
            MsgMemo("Banco ["+oFrmTxt:cBanco+"] no Tiene Programa para Generar Archivo TXT")

      ENDCASE

    ENDIF

    oTable:End()

RETURN .T.

//
// DETIENE EL PROCESO DE ACTUALIZACION
//
FUNCTION DETENER(oFrmTxt)

    IF oFrmTxt:oNm=NIL
       oFrmTxt:Close()
       RETURN .T.
    ENDIF

    SysRefresh(.T.)

RETURN .T.

/*
// Determina las Fecha de Proceso
*/
FUNCTION GetFecha(oFrmTxt)
  LOCAL nLen    :=LEN(oFrmTxt:oOtraNom:aItems)
  LOCAL cTipoNom:=UPPE(Left(oFrmTxt:cTipoNom,1))
  LOCAL cOtraNom:=UPPE(Left(oFrmTxt:cOtraNom,2))
  LOCAL oDesde  :=oFrmTxt:oDesde
  LOCAL oTabla 

  IF cTipoNom!="O"
     // Otra N÷mina debe Ser Ninguna
     EVAL(oFrmTxt:oOtraNom:bSetGet,oFrmTxt:oOtraNom:aItems[nLen])
     oFrmTxt:lFecha :=.F.
     oFrmTxt:oOtraNom:Refresh(.T.)
  ELSE
    oTabla:=OpenTable("SELECT OTR_PERIOD FROM NMOTRASNM WHERE OTR_CODIGO"+GetWhere("=",cOtraNom),.T.)
    oFrmTxt:lFecha :=(oTabla:OTR_PERIOD="I")
    oTabla:End()
  ENDIF

  EJECUTAR("FCH_RANGO",cTipoNom,oFrmTxt:dFecha,cOtraNom)

  oFrmTxt:dDesde:=oDp:dDesde // Toma las Fechas generadas por FCH_RANGO
  oFrmTxt:dHasta:=oDp:dHasta

  DpSetVar(oFrmTxt:oDesde,oDp:dDesde)
  DpSetVar(oFrmTxt:oHasta,oDp:dHasta)

  IF EMPTY(oDp:dDesde)
    oFrmTxt:lFecha:=.T. // Si Puede Editar la Fecha
  ENDIF

  oFrmTxt:oOtraNom:ForWhen(.T.)

RETURN .T.

/*
// Determina los Datos de Otras N÷minas
*/
FUNCTION GetOtraNm(oFrmTxt)
  LOCAL oTable
  LOCAL cOtra

  IF LEFT(oFrmTxt:cTipoNom,1)!="O" // Semanal
     oFrmTxt:lFecha :=.F.
     RETURN .T.
  ENDIF

RETURN .T.

FUNCTION LISTTRAB(oFrmTxt,cVarName,cVarGet)
     LOCAL uValue,lResp,oGet,cWhere:=""

     uValue:=oFrmTxt:Get(cVarName)
     oGet  :=oFrmTxt:Get(cVarGet)

     IF LEFT(oFrmTxt:cTipoNom,1)!="O"
       cWhere:="TIPO_NOM"+GetWhere("=",LEFT(oFrmTxt:cTipoNom,1))
     ENDIF

     lResp:=DPBRWPAG("NMTRABAJADOR.BRW",0,@uValue,NIL,.T.,cWhere)

     IF !Empty(uValue)
       oFrmTxt:Set(UPPE(cVarName),uValue)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .T.

/*
// Listar Grupos
*/
FUNCTION LISTGRU(oFrmTxt,cVarName,cVarGet)
     LOCAL cTable :="NMGRUPO"
     LOCAL aFields:={"GTR_CODIGO","GTR_DESCRI"}
     LOCAL cWhere :=""
     LOCAL uValue,lResp,oGet
     LOCAL lGroup :=.F.

     DEFAULT cWhere:=""

     oGet  :=oFrmTxt:Get(cVarGet)
     uValue:=EJECUTAR("REPBDLIST",cTable,aFields,lGroup,cWhere)

     IF !Empty(uValue)
       oGet:VarPut(uValue,.T.)
       oGet:SetFocus()
       oGet:Keyboard(13)
     ENDIF

RETURN .F.

/*
// Validar Grupo
*/
FUNCTION VALGRUPO(oFrmAct,cCodGru,lView,lIni)

   LOCAL oTable,lFound:=.T.
   LOCAL cTipoNom:=Left(oFrmAct:cTipoNom,1)

   DEFAULT lView:=.F.,lIni:=.F.

   IF Empty(cCodGru)
     oFrmAct:oGrupo:SetText("Todos")
     RETURN .T.
   ENDIF

   oTable:=OpenTable("SELECT GTR_DESCRI FROM NMGRUPO WHERE GTR_CODIGO"+GetWhere("=",cCodGru),.T.)
   lFound:=(oTable:RecCount()>0)

   IIF(lFound,oFrmAct:oGrupo:SetText(oTable:GTR_DESCRI),NIL)

   oTable:End()

   IF lView
     RETURN .T.
   ENDIF

   IF !lFound
      MensajeErr(GetFromVar("{oDp:XNMGRUPO}")+" : "+cCodGru+" no Existe ")
   ENDIF

   IF lFound

     oTable:=OpenTable("SELECT COUNT(*) FROM NMTRABAJADOR WHERE GRUPO"+;
                       GetWhere("=",oFrmAct:cCodGru)+;
                       IIF(cTipoNom="O",""," AND TIPO_NOM"+GetWhere("=",cTipoNom)),;
                        .T.)

     IF Empty(oTable:FieldGet(1))

         MensajeErr("No Hay Trabajadores Asociados "+CRLF+;
                    "en el Grupo ["+oFrmAct:cCodGru+"]"+;
                    IIF(cTipoNom="O",""," para N©mina ["+ALLTRIM(SAYOPTIONS("NMTRABAJADOR","TIPO_NOM",cTipoNom))+"]"))
         lFound:=.F.

         oFrmAct:oCodGru:VarPut(SPACE(LEN(cCodGru)),.T.)


     ENDIF

     oTable:End()

   ENDIF

RETURN lFound

/*
// Listado
*/

#include "include\REPORT.ch"

FUNCTION TXTIMPRIME(oFrmTxt,oCursor)
     LOCAL nLineas:=0

     PRIVATE oReport

     oCursor:=OpenTable(cSql,.T.)

     oCursor:GoTop()
     nLineas:=oCursor:RecCount()

     REPORT oReport TITLE  "N®mina para: "+ALLTRIM(oFrmTxt:cBanco),;
            ALLTRIM(oDp:cEmpresa),;
            "Periodo <"+DTOC(oFrmTxt:dDesde)+" - "+DTOC(oFrmTxt:dHasta)+">",;
            "Fecha: "+dtoc(Date())+" Hora: "+TIME();
            CAPTION "N®mina para "+oFrmTxt:cBanco  ;
            FOOTER "P~gina: "+str(oReport:nPage,3)+" Registros: "+alltrim(str(nLineas,5)) CENTER ;
            PREVIEW

     COLUMN TITLE "CODIGO";
            DATA oCursor:CODIGO;
            SIZE 10;
            LEFT 

     COLUMN TITLE "Trabajador";
            DATA ALLTRIM(oCursor:APELLIDO)+","+oCursor:NOMBRE;
            SIZE 30;
            LEFT 

     COLUMN TITLE "CUENTA";
            DATA oCursor:BANCO_CTA;
            SIZE 20;
            LEFT 

     COLUMN TITLE "Monto";
            DATA oCursor:REC_MONTO;
            PICTURE "9,999,999,999,999.99";
            TOTAL ;
            SIZE 14;
            RIGHT  
     
     END REPORT

     oReport:bSkip:={||oCursor:DbSkip()}

     ACTIVATE REPORT oReport ;
              WHILE !oCursor:Eof();

     oTable:End()

RETURN NIL


FUNCTION BRRECIBOS()
  LOCAL cWhere:=NIL,cCodSuc:=NIL,nPeriodo:=NIL,dDesde:=oFrmTxt:dDesde,dHasta:=oFrmTxt:dHasta,cTitle:=NIL

  cWhere:="FCH_DESDE"+GetWhere("=",dDesde)+" AND "+;
          "FCH_HASTA"+GetWhere("=",dHasta)+" AND "+;
          "DPBANCODIR.BAN_NOMBRE"+GetWhere("=",oFrmTxt:cBanco)

  cTitle:=" Banco "+oFrmTxt:cBanco

RETURN EJECUTAR("BRRECIBOS",cWhere,cCodSuc,nPeriodo,dDesde,dHasta,cTitle)


/*
// Ejecutar Programa Definible
// cBanco Directorio Bancario, busca el Codigo de Banco
// 31/08/2023
*/

FUNCTION RUNTXTPRG(cPrg,p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)
   LOCAL oScript := NIL,lRet

   oScript:=TScript():New(cPrg) // oMemo:GetText())
   oScript:Reset()
   oScript:cClpFlags  := "/i"+Alltrim(oDp:cPathInc)
   oScript:lPreProcess:= .T.
   oScript:cProgram   :="TXTNOMINA"
   oScript:Compile(cPrg)

   IF ValType(oScript)="O" .AND. !EMPTY(oScript:cError)

      oDp:lScrError:=.T.
      oDp:cScriptErr:=oScript:cError
      oScript:MsgError() // oScript:cError) // cProgram,cFunction)
      lRet:=.F.

   ELSE

      lRet:=oScript:Run(NIL, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10,p11,p12,p13,p14,p15,p16,p17,p18,p19,p20)

   ENDIF

// ? "lRet",lRet

RETURN lRet


// EOF


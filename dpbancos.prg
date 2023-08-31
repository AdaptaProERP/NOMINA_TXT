// Programa   : DPBANCOS
// Fecha/Hora : 31/07/2005 16:44:03
// Propósito  : Incluir/Modificar DPBANCOS
// Creado Por : DpXbase
// Llamado por: DPBANCOS.LBX
// Aplicación : Bancos y Caja                           
// Tabla      : DPBANCOS

#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"
#INCLUDE "IMAGE.CH"

FUNCTION MAIN(nOption,cCodigo)
  LOCAL oBtn,oTable,oGet,oFont,oFontB,oFontG
  LOCAL cTitle,cSql,cFile,cExcluye:=""
  LOCAL nClrText
  LOCAL cTitle:="Bancos"
  LOCAL aDirBco:=ATABLE("SELECT BAN_NOMBRE FROM DPBANCODIR")

  AADD(aDirBco,"Ninguno")

  cExcluye:=""
  DEFAULT cCodigo:="1234"

  DEFAULT nOption:=1

   nOption:=IIF(nOption=2,0,nOption) 

  DEFINE FONT oFont  NAME "Tahoma"  SIZE 0, -10 BOLD
  DEFINE FONT oFontB NAME "Tahoma"  SIZE 0, -12 BOLD 
  DEFINE FONT oFontG NAME "Tahoma"  SIZE 0, -12

  nClrText:=10485760 // Color del texto

  IF nOption=1 // Incluir
    cSql     :=[SELECT * FROM DPBANCOS WHERE ]+BuildConcat("BAN_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=" Incluir {oDp:DPBANCOS}"
  ELSE // Modificar o Consultar
    cSql     :=[SELECT * FROM DPBANCOS WHERE ]+BuildConcat("BAN_CODIGO")+GetWhere("=",cCodigo)+[]
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" Bancos                                  "
    cTitle   :=IIF(nOption=2,"Consultar","Modificar")+" {oDp:DPBANCOS}"
  ENDIF

  oTable   :=OpenTable(cSql,"WHERE"$cSql) // nOption!=1)

  IF nOption=1 .AND. oTable:RecCount()=0 // Genera Cursor Vacio
     oTable:End()
     cSql     :=[SELECT * FROM DPBANCOS]
     oTable   :=OpenTable(cSql,.F.) // nOption!=1)
  ENDIF

  oTable:cPrimary:="BAN_CODIGO" // Clave de Validación de Registro

  oBANCOS:=DPEDIT():New(cTitle,"DPBANCOS.edt","oBANCOS" , .F. )

  oBANCOS:nOption  :=nOption
  oBANCOS:SetTable( oTable , .F. ) // Asocia la tabla <cTabla> con el formulario oBANCOS
  oBANCOS:SetScript()        // Asigna Funciones DpXbase como Metodos de oBANCOS
  oBANCOS:SetDefault()       // Asume valores standar por Defecto, CANCEL,PRESAVE,POSTSAVE,ORDERBY
  oBANCOS:nClrPane:=oDp:nGris
  oBANCOS:cCodBco:=oBANCOS:BAN_CODIGO

  oBANCOS:BAN_COMENT:=ALLTRIM(oBANCOS:BAN_COMENT)

  IF oBANCOS:nOption=1 // Incluir en caso de ser Incremental
     // oBANCOS:RepeatGet(NIL,"BAN_CODIGO") // Repetir Valores
     
     oBANCOS:BAN_CODIGO:=oBANCOS:Incremental("BAN_CODIGO",.T.)

     oBANCOS:BAN_BCOTXT:="Ninguno"

  ENDIF
  //Tablas Relacionadas con los Controles del Formulario

  oBANCOS:CreateWindow()       // Presenta la Ventana

  // Opciones del Formulario

  
  //
  // Campo : BAN_CODIGO
  // Uso   : Código                                  
  //
  @ 1.0, 1.0 GET oBANCOS:oBAN_CODIGO  VAR oBANCOS:BAN_CODIGO  VALID CERO(oBANCOS:BAN_CODIGO) .AND.; 
                 oBANCOS:ValUnique(oBANCOS:BAN_CODIGO);
                   .AND. !VACIO(oBANCOS:BAN_CODIGO,NIL);
                    WHEN (AccessField("DPBANCOS","BAN_CODIGO",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 24,10

    oBANCOS:oBAN_CODIGO:cMsg    :="Código"
    oBANCOS:oBAN_CODIGO:cToolTip:="Código"

  @ oBANCOS:oBAN_CODIGO:nTop-08,oBANCOS:oBAN_CODIGO:nLeft SAY "Código" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BCO_ACTIVA
  // Uso   : Cuenta Activa
  //
  @ 2, 0.0 CHECKBOX oBANCOS:oBAN_ACTIVO  VAR oBANCOS:BAN_ACTIVO  PROMPT ANSITOOEM("Activo");
                    WHEN (AccessField("DPCTABANCO","BAN_ACTIVO",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                     FONT oFont COLOR nClrText,NIL SIZE 166,10;
                    SIZE 4,10

    oBANCOS:oBAN_ACTIVO:cMsg    :="Cuenta Activa"
    oBANCOS:oBAN_ACTIVO:cToolTip:="Cuenta Activa"



  //
  // Campo : BAN_NOMBRE
  // Uso   : Nombre                                  
  //
  @ 2.8, 1.0 GET oBANCOS:oBAN_NOMBRE  VAR oBANCOS:BAN_NOMBRE ;
                    WHEN (AccessField("DPBANCOS","BAN_NOMBRE",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oBANCOS:oBAN_NOMBRE:cMsg    :="Nombre"
    oBANCOS:oBAN_NOMBRE:cToolTip:="Nombre"

  @ oBANCOS:oBAN_NOMBRE:nTop-08,oBANCOS:oBAN_NOMBRE:nLeft SAY "Nombre" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BAN_BCOTXT
  // Uso   : Directorio Bancario (Necesario para vincular trabajadores)                      
  //
  @ 4, 5 COMBOBOX oBANCOS:oBAN_BCOTXT VAR oBANCOS:BAN_BCOTXT ITEMS aDirBco;
                      WHEN (AccessField("DPBANCOS","BAN_BCOTXT",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                      FONT oFontG;


  ComboIni(oBANCOS:oBAN_BCOTXT)

  oBANCOS:oBAN_BCOTXT:cMsg    :="Directorio Bancario"
  oBANCOS:oBAN_BCOTXT:cToolTip:="Directorio Bancario"+CRLF+"Vincula Trabajadores"

  @ oBANCOS:oBAN_BCOTXT:nTop-08,oBANCOS:oBAN_BCOTXT:nLeft SAY "Directorio Bancario" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris



  @ 4.6, 1.0 FOLDER oBANCOS:oFolder ITEMS "Datos Básicos","Datos Adicionales","Observaciones";
                      FONT oFontG

     SETFOLDER( 1)
  //
  // Campo : BAN_CONTAC
  // Uso   : Persona Contacto                        
  //
  @ 1.1, 0.0 GET oBANCOS:oBAN_CONTAC  VAR oBANCOS:BAN_CONTAC ;
                    WHEN (AccessField("DPBANCOS","BAN_CONTAC",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oBANCOS:oBAN_CONTAC:cMsg    :="Persona Contacto"
    oBANCOS:oBAN_CONTAC:cToolTip:="Persona Contacto"

  @ oBANCOS:oBAN_CONTAC:nTop-08,oBANCOS:oBAN_CONTAC:nLeft SAY "Persona Contacto" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BAN_WEB   
  // Uso   : Página Web                              
  //
  @ 2.9, 0.0 GET oBANCOS:oBAN_WEB     VAR oBANCOS:BAN_WEB    ;
                    WHEN (AccessField("DPBANCOS","BAN_WEB",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 160,10

    oBANCOS:oBAN_WEB   :cMsg    :="Página Web"
    oBANCOS:oBAN_WEB   :cToolTip:="Página Web"

  @ oBANCOS:oBAN_WEB   :nTop-08,oBANCOS:oBAN_WEB   :nLeft SAY "Página Web" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BAN_LOGIN 
  // Uso   : Login de Acceso                         
  //
  @ 4.7, 0.0 GET oBANCOS:oBAN_LOGIN   VAR oBANCOS:BAN_LOGIN  ;
                    WHEN (AccessField("DPBANCOS","BAN_LOGIN",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oBANCOS:oBAN_LOGIN :cMsg    :="Login de Acceso"
    oBANCOS:oBAN_LOGIN :cToolTip:="Login de Acceso"

  @ oBANCOS:oBAN_LOGIN :nTop-08,oBANCOS:oBAN_LOGIN :nLeft SAY "Login de Acceso" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BAN_CLAVE 
  // Uso   : Clave de Acceso                         
  //
  @ 6.5, 0.0 GET oBANCOS:oBAN_CLAVE   VAR oBANCOS:BAN_CLAVE  ;
                    WHEN (AccessField("DPBANCOS","BAN_CLAVE",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 80,10

    oBANCOS:oBAN_CLAVE :cMsg    :="Clave de Acceso"
    oBANCOS:oBAN_CLAVE :cToolTip:="Clave de Acceso"

  @ oBANCOS:oBAN_CLAVE :nTop-08,oBANCOS:oBAN_CLAVE :nLeft SAY "Clave de Acceso" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BAN_TEL1  
  // Uso   : Teléfono 1                              
  //
  @ 8.3, 0.0 GET oBANCOS:oBAN_TEL1    VAR oBANCOS:BAN_TEL1   ;
                    WHEN (AccessField("DPBANCOS","BAN_TEL1",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 48,10

    oBANCOS:oBAN_TEL1  :cMsg    :="Teléfono 1"
    oBANCOS:oBAN_TEL1  :cToolTip:="Teléfono 1"

  @ oBANCOS:oBAN_TEL1  :nTop-08,oBANCOS:oBAN_TEL1  :nLeft SAY "Teléfonos" PIXEL;
                            SIZE NIL,7 FONT oFont COLOR nClrText,oDp:nGris


  //
  // Campo : BAN_TEL2  
  // Uso   : Teléfono 2                              
  //
  @ 10.1, 0.0 GET oBANCOS:oBAN_TEL2    VAR oBANCOS:BAN_TEL2   ;
                    WHEN (AccessField("DPBANCOS","BAN_TEL2",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 48,10

    oBANCOS:oBAN_TEL2  :cMsg    :="Teléfono 2"
    oBANCOS:oBAN_TEL2  :cToolTip:="Teléfono 2"


  //
  // Campo : BAN_TEL3  
  // Uso   : Teléfono 3                              
  //
  @ 1.0,14.0 GET oBANCOS:oBAN_TEL3    VAR oBANCOS:BAN_TEL3   ;
                    WHEN (AccessField("DPBANCOS","BAN_TEL3",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 48,10

    oBANCOS:oBAN_TEL3  :cMsg    :="Teléfono 3"
    oBANCOS:oBAN_TEL3  :cToolTip:="Teléfono 3"

    SETFOLDER( 2)

    oBANCOS:oScroll:=oBANCOS:SCROLLGET("DPBANCOS","DPBANCOS.SCG",cExcluye)

    oBancos:oScroll:SetColSize(200,318,200)
    oBancos:oScroll:SetColorHead(0,oDp:nLbxClrHeaderPane,oFont) 
    oBancos:oScroll:SetColor(16773862 , CLR_BLUE  , 1 , 16771538 , oFontB) 
    oBancos:oScroll:SetColor(16773862 , CLR_BLACK , 2 , 16771538 , oFont ) 
    oBancos:oScroll:SetColor(16773862 , CLR_GRAY  , 3 , 16771538 , oFont ) 

    SETFOLDER( 3)

    oBANCOS:BAN_COMENT:=ALLTRIM(oBANCOS:BAN_COMENT)  //
  // Campo : BAN_COMENT
  // Uso   : Comentario                              
  //
  @ 1.1, 0.0 GET oBANCOS:oBAN_COMENT  VAR oBANCOS:BAN_COMENT;
           MEMO SIZE 80,80; 
      ON CHANGE 1=1;
                    WHEN (AccessField("DPBANCOS","BAN_COMENT",oBANCOS:nOption);
                    .AND. oBANCOS:nOption!=0);
                    FONT oFontG;
                    SIZE 40,10

    oBANCOS:oBAN_COMENT:cMsg    :="Comentario"
    oBANCOS:oBAN_COMENT:cToolTip:="Comentario"



     SETFOLDER(0)

/*
  IF nOption!=0

    @09, 33  SBUTTON oBtn ;
             SIZE 45, 20 FONT oFont;
             FILE "BITMAPS\XSAVE.BMP" NOBORDER;
             LEFT PROMPT "Grabar";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oBANCOS:Save())

    oBtn:cToolTip:="Grabar Registro"
    oBtn:cMsg    :=oBtn:cToolTip

    @09, 43 SBUTTON oBtn ;
            SIZE 45, 20 FONT oFont;
            FILE "BITMAPS\XCANCEL.BMP" NOBORDER;
            LEFT PROMPT "Cancelar";
            COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
            ACTION (oBANCOS:Cancel()) CANCEL

    oBtn:lCancel :=.T.
    oBtn:cToolTip:="Cancelar y Cerrar Formulario "
    oBtn:cMsg    :=oBtn:cToolTip

  ELSE


     @09, 43 SBUTTON oBtn ;
             SIZE 42, 23 FONT oFontB;
             FILE "BITMAPS\XSALIR.BMP" NOBORDER;
             LEFT PROMPT "Salir";
             COLORS CLR_BLACK, { CLR_WHITE, CLR_HGRAY, 1 };
             ACTION (oBANCOS:Cancel()) CANCEL

             oBtn:lCancel:=.T.
             oBtn:cToolTip:="Cerrar Formulario"
             oBtn:cMsg    :=oBtn:cToolTip

  ENDIF
*/

//  oBANCOS:Activate(NIL)

  oBANCOS:Activate({||oBANCOS:INICIO()})


 // IF oBancos:IsDef("oScroll")
 //    oBancos:oScroll:SetEdit()
 // ENDIF


  STORE NIL TO oTable,oGet,oFont,oGetB,oFontG

RETURN oBANCOS

/*
// Carga de Datos, para Incluir
*/
FUNCTION LOAD()

  IF oBANCOS:nOption=1 // Incluir en caso de ser Incremental

     oBANCOS:BAN_COMENT:=""
     oBANCOS:BAN_CODIGO:=oBANCOS:Incremental("BAN_CODIGO",.T.)

  ENDIF

RETURN .T.
/*
// Ejecuta Cancelar
*/
FUNCTION CANCEL()
RETURN .T.

/*
// Ejecución PreGrabar
*/
FUNCTION PRESAVE()
  LOCAL lResp:=.T.

  lResp:=oBANCOS:ValUnique(oBANCOS:BAN_CODIGO)

  IF !lResp
       MsgAlert("Registro "+CTOO(oBANCOS:BAN_CODIGO),"Ya Existe")
  ENDIF

  oBANCOS:BAN_COMENT:=ALLTRIM(oBANCOS:BAN_COMENT)

  IF EMPTY(oBANCOS:BAN_CODIGO)
     MensajeErr("Código no Puede estar Vacio")
     RETURN .F.
  ENDIF

  oBANCOS:BAN_FECHA:=DPFECHA()
  oBANCOS:BAN_HORA :=DPHORA()

RETURN lResp


FUNCTION INICIO()
   LOCAL oCursor,oBar,oBtn,oFont,oCol
   LOCAL oDlg:=oBANCOS:oDlg
   LOCAL nLin:=0

   DEFINE CURSOR oCursor HAND
   DEFINE BUTTONBAR oBar SIZE 52-15,60-15 OF oDlg 3D CURSOR oCursor
   DEFINE FONT oFont  NAME "Arial"   SIZE 0, -14 BOLD


   IF oBANCOS:nOption!=2

     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSAVE.BMP",NIL,"BITMAPS\XSAVEG.BMP";
            ACTION (oBANCOS:Save())

     oBtn:cToolTip:="Guardar"

     oBANCOS:oBtnSave:=oBtn


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XCANCEL.BMP";
            ACTION (oBANCOS:Cancel()) CANCEL


   
   ELSE


     DEFINE BUTTON oBtn;
            OF oBar;
            NOBORDER;
            FONT oFont;
            FILENAME "BITMAPS\XSALIR.BMP";
            ACTION (oBANCOS:Cancel()) CANCEL

   ENDIF

   oBar:SetColor(CLR_BLACK,oDp:nGris)

   AEVAL(oBar:aControls,{|o,n| o:SetColor(CLR_BLACK,oDp:nGris) })


 
RETURN .T.


/*
// Ejecución despues de Grabar
*/
FUNCTION POSTSAVE()
  LOCAL cWhere

  IF oBANCOS:nOption=3 // Cambia los Depósitos Bancarios
     SQLUPDATE("DPCAJAMOV","CAJ_CODBCO",oBANCOS:BAN_CODIGO,"CAJ_CODBCO"+GetWhere("=",oBANCOS:cCodBco)+" AND CAJ_ORIGEN='DEP'")
  ENDIF

  IF oBANCOS:nOption=3 .AND. oBANCOS:BAN_CODIGO<>oBANCOS:BAN_CODIGO_

    cWhere:="MOC_DOCPAG"+GetWhere("=",oBANCOS:BAN_CODIGO_)+" AND "+;
            "MOC_ORIGEN"+GetWhere("=","BCO" )

    SQLUPDATE("DPASIENTOS","MOC_DOCPAG",oBANCOS:BAN_CODIGO,cWhere)

  ENDIF

RETURN .T.

/*
<LISTA:BAN_CODIGO:Y:GET:Y:N:N:Código,BAN_NOMBRE:N:GET:N:N:Y:Nombre,Pestaña02:N:Pestaña02:N:N:N:Datos Básicos,BAN_CONTAC:N:GET:N:N:Y:Persona Contacto
,BAN_WEB:N:GET:N:N:Y:Página Web,BAN_LOGIN:N:GET:N:N:Y:Login de Acceso,BAN_CLAVE:N:GET:N:N:Y:Clave de Acceso,BAN_TEL1:N:GET:N:N:Y:Teléfonos
,BAN_TEL2:N:GET:N:N:Y:,BAN_TEL3:N:GET:N:N:Y:,Pestaña03:N:GET:N:N:N:Datos Adicionales,SCROLLGET:N:GET:N:N:N:Para Diversos Campos,Pestaña01:N:GET:N:N:N:Observaciones,BAN_COMENT:N:MGET:N:N:Y:>
*/

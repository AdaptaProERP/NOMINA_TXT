// Programa   : DPBANCOSMNU
// Fecha/Hora : 24/09/2014 02:02:44
// Propósito  : Menú DPBANCOS
// Creado Por : DpXbase
// Llamado por: DPBAMCOS.LBX
// Aplicación : Cuentas Bancarias
// Tabla      : DPDPBANCOS


#INCLUDE "DPXBASE.CH"
#INCLUDE "TSBUTTON.CH"

FUNCTION MAIN(cCodBco)
  LOCAL cNombre,aBtn:={},I,cIdBco
  LOCAL oFont,oFontB,oBtn
  LOCAL cWhere,bAction,nGroup,cDefXls
  LOCAL aCoors:=GetCoors( GetDesktopWindow() )

  DEFAULT cCodBco:=SQLGET("DPBANCOS","BAN_CODIGO")

  cNombre:=SQLGET("DPBANCOS","BAN_NOMBRE,BAN_DEFXLS","BAN_CODIGO"+GetWhere("=",cCodBco))
  cDefXls:=DPSQLROW(2,"")

  cIdBco:=SQLGET("DPCTABANCO","BCO_CTABAN","BCO_CODIGO"+GetWhere("=",cCodBco))
  cIdBco:=LEFT(cIdBco,4)


  DEFINE FONT oFont    NAME "Tahoma" SIZE 0,-14
  DEFINE FONT oFontB   NAME "Tahoma" SIZE 0,-14 BOLD

  DpMdi(GetFromVar("{oDp:DPBANCOS}"),"oBanMnu","TEST.EDT")

  oBanMnu:cCodBco :=cCodBco
  oBanMnu:cNombre :=cNombre
  oBanMnu:lSalir  :=.F.
  oBanMnu:nHeightD:=45
  oBanMnu:lMsgBar :=.F.
  oBanMnu:oGrp    :=NIL
  oBanMnu:cDefXls :=cDefXls
  oBanMnu:cIdBco  :=cIdBco

  SetScript("DPBANCOMNU")

  AADD(aBtn,{"Consultar"                        ,"VIEW.BMP"        ,"CONSULTAR"    })

// JN 10/02/2014, Definición reemplazada por las Nuevas Funcionalidades
  AADD(aBtn,{"Definir Vinculos para Conciliación" ,"LINK.BMP"        ,"TEXTOS"       })

  AADD(aBtn,{"Acceder Pagina Web"               ,"EXPLORER.BMP"    ,"WEB"          })


  IF COUNT("DPCTABANCO","BCO_CODIGO"+GetWhere("=",oBanMnu:cCodBco))>0
    AADD(aBtn,{"Cuentas Bancarias"                ,"CONCILIACION.BMP","CTABANCARIA"  })
  ENDIF


  AADD(aBtn,{"Texto Delimitdo [.CSV]"   ,"CSV.BMP"   ,"CSV"})
  AADD(aBtn,{"Excel [.XLS]"             ,"EXCEL.BMP" ,"XLS"})
  AADD(aBtn,{"lenguaje de marcas [.XML]","XML.BMP"   ,"XML"})

  IF ISRELEASE("16.04")
    AADD(aBtn,{"Proveedores Afiliados","PROVEEDORES.BMP"   ,"PRO"})
//  AADD(aBtn,{"Proveedores Afiliados Otros Bancos","directoriobancario.BMP"   ,"OTRO"})
  ENDIF

  IF !Empty(oBanMnu:cDefXls)
     AADD(aBtn,{"Vincular Definiciones con Instrumentos Bancarios" ,"MATH.BMP"   ,"MATH"    })
     AADD(aBtn,{"Exportar Definiciones de Conciliación"            ,"EXPORTS.BMP","EXPORT"  })
  ENDIF

  IF !Empty(oBanMnu:cIdBco)
     AADD(aBtn,{"Importar Definiciones de Conciliación" ,"IMPORTAR.BMP","IMPORT"  })
  ENDIF
  AADD(aBtn,{"Salir"                    ,"XSALIR.BMP","EXIT"  })

 // oBanMnu:Windows(0,0,530+50,415)
 //  oBanMnu:Windows(0,0,MIN(530+80,aCoors[3]-160),415) 
  oBanMnu:Windows(0,0,aCoors[3]-160,415)  
 


  @ 48, -1 OUTLOOK oBanMnu:oOut ;
     SIZE 150+250, oBanMnu:oWnd:nHeight()-90;
     PIXEL ;
     FONT oFont ;
     OF oBanMnu:oWnd;
     COLOR CLR_BLACK,oDp:nGris

   DEFINE GROUP OF OUTLOOK oBanMnu:oOut PROMPT "&Vinculos del "+oDp:xDPBANCOS

   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oBanMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oBanMnu:oOut:aGroup)
      oBtn:=ATAIL(oBanMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oBanMnu:BTNACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oBanMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction


   NEXT I

 IF ISRELEASE("21.09","Generar TXT") .OR. oDp:cType="NOM"

   DEFINE GROUP OF OUTLOOK oBanMnu:oOut PROMPT "&Programar Archivos TXT "

   aBtn:={}
   AADD(aBtn,{"Afiliacion de Cuenta"       ,"PROVEEDORES.BMP"        ,"AFILIADOS"    })

   IF oDp:cType="SGE"
      AADD(aBtn,{"Pagos hacia Proveedores"    ,"PAGOXTRANSFERENCIA.BMP" ,"PAGOS"        })
   ENDIF

   AADD(aBtn,{"Pagos hacia Trabajador"     ,"TRABAJADOR.BMP"         ,"TRABAJADOR"   })
   AADD(aBtn,{"Desincorporación de Cuentas","XCANCEL.BMP"            ,"DESINCORPORAR"})
 
   FOR I=1 TO LEN(aBtn)

      DEFINE BITMAP OF OUTLOOK oBanMnu:oOut ;
             BITMAP "BITMAPS\"+aBtn[I,2];
             PROMPT aBtn[I,1];
             ACTION 1=1

      nGroup:=LEN(oBanMnu:oOut:aGroup)
      oBtn:=ATAIL(oBanMnu:oOut:aGroup[ nGroup, 2 ])

      bAction:=BloqueCod("oBanMnu:BTNACTION(["+aBtn[I,3]+"])")

      oBtn:bAction:=bAction

      oBtn:=ATAIL(oBanMnu:oOut:aGroup[ nGroup, 3 ])
      oBtn:bLButtonUp:=bAction

   NEXT I

ENDIF

   @ 0, 100 SPLITTER oBanMnu:oSpl ;
            VERTICAL ;
            PREVIOUS CONTROLS oBanMnu:oOut ;
            LEFT MARGIN 70 ;
            RIGHT MARGIN 200 ;
            SIZE 40, 10  PIXEL ;
            OF oBanMnu:oWnd ;
             _3DLOOK ;
            UPDATE

   DEFINE DIALOG oBanMnu:oDlg FROM 0,oBanMnu:oOut:nWidth() TO oBanMnu:nHeightD,700;
          TITLE "" STYLE WS_CHILD OF oBanMnu:oWnd;
          PIXEL COLOR NIL,oDp:nGris FONT oFontB

   @ .1,.2 GROUP oBanMnu:oGrp TO 10,10 PROMPT "["+oBanMnu:cNombre+"]"

   @ .5,.5 SAY "Cuenta :["+oBanMnu:cCodBco+"]" SIZE 190,10;
           COLOR CLR_WHITE,12615680;
           FONT oFontB

   ACTIVATE DIALOG oBanMnu:oDlg NOWAIT VALID .F.

   oBanMnu:Activate("oBanMnu:FRMINIT()",,"oBanMnu:oSpl:AdjRight()")

   EJECUTAR("DPSUBMENUCREAREG",oBanMnu,NIL,"M","DPBANCOS")

RETURN .T.

FUNCTION FRMINIT()

   oBanMnu:oWnd:bResized:={||oBanMnu:oDlg:Move(0,0,oBanMnu:oWnd:nWidth(),50,.T.),;
                             oBanMnu:oGrp:Move(0,0,oBanMnu:oWnd:nWidth()-15,oBanMnu:nHeightD,.T.)}

   EVal(oBanMnu:oWnd:bResized)

RETURN .T.

// Ejecutar
FUNCTION BTNACTION(cAction)
  LOCAL oRep,nNumMain,cWhere,cWeb,aTipMob,bRun,cMemo,cWhere,cField:="",cFile:="",cPrg:=""

  IF cAction="EXIT"
     oBanMnu:Close()
  ENDIF


  cPrg  :="/"+"*"+CRLF+;
          "*"+"/"+CRLF+;
          [#INCLUDE "DPXBASE.CH" ]+CRLF+;
          []+CRLF+;
          [PROCE MAIN(cPar1,cPar2,cPar3) ]+CRLF+;
          [  LOCAL oTable,cSql,cFile:="TEMP\FILE.TXT" ]+;
          [  ]+CRLF+;
          [RETURN cFile ]


  IF cAction="CONSULTAR"
    EJECUTAR("DPBANCOS",2,oBanMnu:cCodBco)
    RETURN .T.
  ENDIF

  IF cAction="LECTURA" 
     EJECUTAR("DPBCOLEEEDOCTA",oBanMnu:cCodBco,oBanMnu:cCodCta,oBanMnu:cNumero)
  ENDIF

  IF cAction="TEXTOS" 
    aTipMob:=ATABLE("SELECT ECB_TIPO FROM dpbcoctaregcon WHERE ECB_CODBCO"+GetWhere("=",oBanMnu:cCodBco)+" GROUP BY ECB_TIPO ")
    EJECUTAR("DPBCODEFCONC",oBanMnu:cCodBco,aTipMob)
  ENDIF

  IF cAction="WEB" 
    cWeb:=SQLGET("DPBANCOS","BAN_WEB","BAN_CODIGO"+GetWhere("=",oBanMnu:cCodBco))
    EJECUTAR("WEBRUN",cWeb)
  ENDIF

  IF cAction="CSV" .OR. cAction="XLS" .OR. cAction="XML"
    EJECUTAR("DPBCODEFEDOCTA",oBanMnu:cCodBco,cAction)
  ENDIF

  IF cAction="CTABANCARIA"
     DPLBX("DPCTABANCO.LBX",NIL,"BCO_CODIGO"+GetWhere("=",oBanMnu:cCodBco))
  ENDIF

  IF cAction="PRO"
     EJECUTAR("DPBCOXPROVEEDOR",oBanMnu:cCodBco,oBanMnu:cNombre)
  ENDIF

  IF cAction="EXPORT"
     EJECUTAR("DPBCOEXPORTDEF",oBanMnu:cCodBco)
  ENDIF

  IF cAction="IMPORT"
     EJECUTAR("DPBCOIMPORTDEF",oBanMnu:cIdBco)
  ENDIF

  IF cAction="PAGOS"
     cField:="BAN_DEFPAG"
  ENDIF

  IF cAction="TRABAJADOR"

     cField:="BAN_DEFNOM"
     cPrg  :=MemoRead("DP\NMBANCOSTXT.TXT")
/*
     cPrg  :="/"+"*"+CRLF+;
            " BANCO "+oBanMnu:cCodBco+" "+oBanMnu:cNombre+CRLF+;
            "*"+"/"+CRLF+;
            [#INCLUDE "DPXBASE.CH" ]+CRLF+;
            []+CRLF+;
            [PROCE MAIN(cTipNom,cOtra,dDesde,dHasta,cBanco) ]+CRLF+;
            [  LOCAL cFile :="TEMP\BCOTXT_]+oBanMnu:cCodBco+[.TXT"]+CRLF+;
            [  LOCAL oTable,cSql ]+;
            [  ]+CRLF+;
            [  cSql  :="SELECT CEDULA FROM NMTRABAJADOR " ]+CRLF+;
            [  oTable:=OpenTable(cSql,.T.) ]+CRLF+;
            [  oTable:End() ]+CRLF+;
            [RETURN cFile ]
*/
  ENDIF


  IF !Empty(cField)

     HrbLoad("DPXBASE.HRB") // Carga M?dulo DpXbase

     bRun  :={||MensajeErr("FINAL")}
     cWhere:="BAN_CODIGO"+GetWhere("=",oBanMnu:cCodBco)
     cMemo :=SQLGET("DPBANCOS",cField,cWhere)
     
     cMemo :=IF(Empty(cMemo),cPrg,cMemo)
     cFile :="DP\DPBANCOS_"+cField+".TXT"

// ? cFile,FILE(cFile)

     DPXBASEEDIT(3,NIL,bRun,NIL,cMemo,"DPBANCOS",cField,cWhere)

  ENDIF
  
RETURN .T.

FUNCTION TOTALIZAR()
RETURN .T.


FUNCTION CLOSE()
  // oBanMnu:Close()
RETURN .T.



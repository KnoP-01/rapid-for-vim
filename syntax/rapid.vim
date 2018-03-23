" Vim syntax file
" Language: ABB Rapid Command
" Maintainer: Patrick Meiser-Knosowski <knosowski@graeff.de>
" Version: 1.5.5
" Last Change: 23. Mar 2018
" Credits: 
"
" Suggestions of improvement are very welcome. Please email me!
"

" Remove any old syntax stuff that was loaded (5.x) or quit when a syntax file
" was already loaded (6.x).
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

"Rapid does ignore case
syn case ignore

if bufname("%") =~ '\c\.cfg$'
  " highlighting for *.cfg

  " Constant values
  " Boolean
  syn keyword rapidBoolean TRUE FALSE Edge High Low
  highlight default link rapidBoolean Boolean
  " Float (num)
  syn match rapidFloat /\(\W\|_\)\@1<=[+-]\?\d\+\.\?\d*\([eE][+-]\?\d\+\)\?/
  highlight default link rapidFloat Float
  " character code in string
  syn match rapidCharCode '\\\d\d' contained
  highlight default link rapidCharCode Special
  " String. Note: Don't rename group rapidString. Indent depend on this
  syn region rapidString start=/"/ end=/"/ contains=rapidCharCode
  highlight default link rapidString String
  " ---

  " special chars
  syn match rapidOperator /:\|[+-]\|\*\|\/\|\\/
  syn match rapidOperator /^#/
  highlight default link rapidOperator Operator
  " ---

  " sections
  syn match rapidException /^\w\+/
  syn match rapidException /CFG\ze_/
  highlight default link rapidException Exception
  " ---
else
  " highlighting for *.mod, *.sys and *.prg

  " Comment
  " TODO Comment
  syn match rapidTodoComment contained /\<todo\>\|\<fixme\>\|\<xxx\>/
  highlight default link rapidTodoComment Todo
  " Debug comment
  syn match rapidDebugComment contained /\<debug\>/
  highlight default link rapidDebugComment Debug
  " Line comment
  syn match rapidComment /\!.*$/ contains=rapidTodoComment,rapidDebugComment
  highlight default link rapidComment Comment
  " ---

  " Header
  syn match rapidHeader /^%%%/
  highlight default link rapidHeader PreProc
  " ---

  " Constant values
  " Boolean
  syn keyword rapidBoolean TRUE FALSE Edge High Low
  highlight default link rapidBoolean Boolean
  " Float (num)
  syn match rapidFloat /\W\@1<=[+-]\?\d\+\.\?\d*\([eE][+-]\?\d\+\)\?/
  highlight default link rapidFloat Float
  " character code in string
  syn match rapidCharCode '\\\d\d' contained
  highlight default link rapidCharCode Special
  " String. Note: Don't rename group rapidString. Indent depend on this
  syn region rapidString start=/"/ end=/"/ contains=rapidCharCode
  highlight default link rapidString String
  " ---

  " anytype (preceded by 'alias|pers|var|const|func'
  " TODO: still missing are userdefined types which are part of a parameter:
  " proc message( mystring msMessagePart1{},
  "               mystring msMessagePart2{},  
  "               mystring msMsg3{} 
  "               \ mystring msMsg4{})
  " syn match rapidAnyType /\v^\s*(global\s+|task\s+|local\s+)?(alias|pers|var|const|func)\s+\w+>/ contains=rapidStorageClass,rapidType,rapidTypeDef
  " highlight default link rapidAnyType Type
  " Type
  syn keyword rapidType aiotrigg bool btnres busstate buttondata byte
  syn keyword rapidType cameradev cameratarget capdata caplatrackdata capspeeddata captrackdata capweavedata cfgdomain clock confdata corrdescr datapos dionum dir dnum
  syn keyword rapidType egmframetype egmident egm_minmax egmstate egmstopmode errdomain errnum errstr errtype event_type exec_level extjoint flypointdata handler_type
  syn keyword rapidType icondata identno intnum iodev iounit_state jointtarget
  syn keyword rapidType listitem loaddata loadidnum loadsession mecunit motsetdata
  " num, siehe unten
  syn keyword rapidType opcalc opnum orient paridnum paridvalidnum pathrecid pos pose processtimes progdisp
  syn keyword rapidType rawbytes restartblkdata restartdata rmqheader rmqmessage rmqslot robjoint robtarget
  syn keyword rapidType sensor sensorstate shapedata signalorigin signalai signalao signaldi signaldo signalgi signalgo socketdev socketstatus speeddata stoppointdata string stringdig supervtimeouts switch symnum syncident 
  syn keyword rapidType taskid tasks testsignal tooldata tpnum trapdata triggdata triggios triggiosdnum triggmode triggstrgo tunetype
  syn keyword rapidType uishownum weavestartdata wobjdata wzstationary wztemporary zonedata
  " arc data types
  syn keyword rapidType seamdata weavedata trackdata welddata arcdata Multidata Adaptdata
  " spot weld
  syn keyword rapidType spotdata gundata forcedata simdata smeqdata
  highlight default link rapidType Type
  " Storage class
  syn keyword rapidStorageClass LOCAL TASK GLOBAL VAR PERS CONST ALIAS NOVIEW NOSTEPIN VIEWONLY READONLY SYSMODULE INOUT
  highlight default link rapidStorageClass StorageClass
  " Not a typedef but I like to have those highlighted different then types,
  " structures or strorage classes
  syn keyword rapidTypeDef MODULE ENDMODULE PROC ERROR UNDO BACKWARD ENDPROC RECORD ENDRECORD TRAP ENDTRAP FUNC ENDFUNC
  highlight default link rapidTypeDef TypeDef
  " ---

  " Statement
  " syn keyword rapidStatement
  " highlight default link rapidStatement Statement
  " Conditional
  syn keyword rapidConditional IF THEN ELSEIF ELSE ENDIF TEST CASE DEFAULT ENDTEST
  highlight default link rapidConditional Conditional
  " Repeat
  syn keyword rapidRepeat FOR FROM TO STEP ENDFOR WHILE ENDWHILE DO
  highlight default link rapidRepeat Repeat
  " Label
  syn keyword rapidLabel GOTO
  syn match rapidLabel /\c\v^\s*\a\w*\:\ze([^=]|$)/ contains=rapidConditional,rapidOperator
  highlight default link rapidLabel Label
  " Keyword
  syn keyword rapidKeyword AccSet ActEventBuffer ActUnit Add AliasIO AliasIOReset BitClear BitSet BookErrNo
  syn keyword rapidKeyword CallByVar CamFlush CamGetParameter CamGetResult CamLoadJob CamReqImage CamSetExposure CamSetParameter CamSetProgramMode CamSetRunMode CamStartLoadJob CamWaitLoadJob CancelLoad CapAPTrSetup CapCondSetDO CapEquiDist CapLATrSetup CapNoProcess CapRefresh CapWeaveSync CheckProgRef CirPathMode Clear ClearIOBuff ClearPath ClearRawBytes ClkReset ClkStart ClkStop Close CloseDir ConfJ ConfL CONNECT CopyFile CopyRawBytes CorrClear CorrCon CorrDiscon CorrWrite
  syn keyword rapidKeyword DeactEventBuffer DeactUnit Decr DitherAct DitherDeact DropSensor DropWObj 
  syn keyword rapidKeyword EGMActJoint EGMActMove EGMActPose EGMGetId EGMReset EGMSetupAI EGMSetupAO EGMSetupGI EGMSetupLTAPP EGMSetupUC EOffsOff EOffsOn EOffsSet EraseModule ErrLog ErrWrite
  syn keyword rapidKeyword FricIdInit FricIdEvaluate FricIdSetFricLevels 
  syn keyword rapidKeyword GetDataVal GetSysData GetTrapData GripLoad HollowWristReset ICap IDelete IDisable IEnable IError Incr IndReset InitSuperv InvertDO IOBusStart IOBusState IODisable IOEnable IPathPos IPers IRMQMessage ISignalAI ISignalAO ISignalDI ISignalDO ISignalGI ISignalGO ISleep ITimer IVarValue IWatch
  syn keyword rapidKeyword Load LoadId MakeDir ManLoadIdProc MechUnitLoad MotionProcessModeSet MotionSup MToolRotCalib MToolTCPCalib Open OpenDir
  syn keyword rapidKeyword PackDNHeader PackRawBytes PathAccLim PathRecStart PathRecStop PathResol PDispOff PDispOn PDispSet ProcerrRecovery PrxActivAndStoreRecord PrxActivRecord PrxDbgStoreRecord PrxDeactRecord PrxResetPos PrxResetRecords PrxSetPosOffset PrxSetRecordSampleTime PrxSetSyncalarm PrxStartRecord PrxStopRecord PrxStoreRecord PrxUseFileRecord PulseDO
  syn keyword rapidKeyword ReadAnyBin ReadBlock ReadCfgData ReadErrData ReadRawBytes RemoveAllCyclicBool RemoveCyclicBool RemoveDir RemoveFile RemoveSuperv RenameFile Reset ResetPPMoved ResetRetryCount RestoPath Rewind RMQEmptyQueue RMQFindSlot RMQGetMessage RMQGetMsgData RMQGetMsgHeader RMQReadWait RMQSendMessage RMQSendWait
  syn keyword rapidKeyword SafetyControllerSyncRequest Save SaveCfgData SCWrite SenDevice Set SetAllDataVal SetAO SetDataSearch SetDataVal SetDO SetGO SetLeadThrough SetSysData SetupCyclicBool SetupSuperv SiConnect SiClose SiGetCyclic SingArea SiSetCyclic SkipWarn SocketAccept SocketBind SocketClose SocketConnect SocketCreate SocketListen SocketReceive SocketReceiveFrom SocketSend SocketSendTo SoftAct SoftDeact SpeedLimAxis SpeedLimCheckPoint SpeedRefresh SpyStart SpyStop StartLoad STCalib STClose STIndGun STIndGunReset SToolRotCalib SToolTCPCalib STOpen StorePath STTune STTuneReset SupSyncSensorOff SupSyncSensorOn SyncMoveOff SyncMoveOn SyncMoveResume SyncMoveSuspend SyncMoveUndo SyncToSensor SystemStopAction
  syn keyword rapidKeyword TestSignDefine TestSignReset TextTabInstall TPErase TPReadDnum TPReadFK TPReadNum TPShow TPWrite TriggCheckIO TriggDataCopy TriggDataReset TriggEquip TriggInt TriggIO TriggRampAO TriggSpeed TriggStopProc TryInt TuneReset TuneServo
  syn keyword rapidKeyword UIMsgBox UIMsgWrite UIMsgWriteAbort UIShow UnLoad UnpackRawBytes VelSet WaitAI WaitAO WaitDI WaitDO WaitGI WaitGO WaitLoad WaitRob WaitSensor WaitSyncTask WaitTestAndSet WaitTime WaitUntil WaitWObj WarmStart WITH WorldAccLim Write WriteAnyBin WriteBin WriteBlock WriteCfgData WriteRawBytes WriteStrBin WriteVar WZBoxDef WZCylDef WZDisable WZDOSet WZEnable WZFree WZHomeJointDef WZLimJointDef WZLimSup WZSphDef
  " arc instructions
  syn keyword rapidKeyword MPSavePath MPLoadPath MPReadInPath MPOffsEaxOnPath ArcRefresh 
  " spot instructions
  syn keyword rapidKeyword SetForce Calibrate ReCalcTCP IndGunMoveReset OpenHighLift CloseHighLift IndGunMove SwSetIntSpotData SwSetIntForceData SwSetIntGunData SwSetIntSimData
  highlight default link rapidKeyword Keyword
  " Exception
  syn keyword rapidException EXIT ErrRaise ExitCycle RAISE RaiseToUser RETRY RETURN TRYNEXT
  syn match rapidException /^\s*Stop\s*[\\;]/me=e-1
  highlight default link rapidException Exception
  " ---

  " special keyword for move command
  syn keyword rapidMovement ArcLStart ArcL1Start ArcL2Start ArcCStart ArcC1Start ArcC2Start ArcL ArcL1 ArcL2 ArcC ArcC1 ArcC2 ArcLEnd ArcL1End ArcL2End ArcCEnd ArcC1End ArcC2End ArcRepL ArcAdaptLStart ArcAdaptL ArcAdaptC ArcAdaptLEnd ArcAdaptCEnd ArcCalcLStart ArcCalcL ArcCalcC ArcCalcLEnd ArcCalcCEnd ArcAdaptRepL ArcMoveExtJ 
  syn keyword rapidMovement Break 
  syn keyword rapidMovement CapC CapL CSSDeactMoveL ContactL
  syn keyword rapidMovement DispL DispC DispJ
  syn keyword rapidMovement EGMMoveC EGMMoveL EGMRunJoint EGMRunPose EGMStop
  syn keyword rapidMovement IndAMove IndCMove IndDMove IndRMove 
  syn keyword rapidMovement MoveAbsJ MoveC MoveExtJ MoveJ MoveL 
  syn keyword rapidMovement MoveCAO MoveCDO MoveCGO MoveCSync MoveJAO MoveJDO MoveJGO MoveJSync MoveLAO MoveLDO MoveLGO MoveLSync 
  syn keyword rapidMovement NutL NutJ
  syn keyword rapidMovement PathRecMoveBwd PathRecMoveFwd 
  syn keyword rapidMovement PaintL PaintC
  syn keyword rapidMovement StartMove StartMoveRetry StepBwdPath StopMove StopMoveReset
  syn keyword rapidMovement SpotL SpotJ SpotML SpotMJ CalibL CalibJ MeasureWearL 
  syn keyword rapidMovement SMoveJ SMoveJDO SMoveJGO SMoveJSync SMoveL SMoveLDO SMoveLGO SMoveLSync SSearchL STriggJ STriggL
  syn keyword rapidMovement SearchC SearchExtJ SearchL
  syn keyword rapidMovement TriggC TriggJ TriggL TriggJIOs TriggLIOs
  if exists("g:rapidNoHighlight") && g:rapidNoHighlight==1
        \|| exists("g:rapidNoHighLink") && g:rapidNoHighLink==1
    highlight default link rapidMovement Movement
  else
    highlight default link rapidMovement Special
  endif
  " ---

  " Operator
  syn keyword rapidOperator and or xor not Div Mod
  " syn match rapidOperator /[+-]\|\*\|\/\|\([<>:][>=]\)\|[<>=]/
  syn match rapidOperator /[-+*/<>:=]/
  highlight default link rapidOperator Operator
  " ---

  " Delimiter
  " syn match rapidDelimiter /\\\||\|\[\|\]\|[(){}]\|[,;]/
  syn match rapidDelimiter /[\\(){},;|\[\]]/
  highlight default link rapidDelimiter Delimiter
  " ---

  syn match rapidNames /[a-zA-Z_][.a-zA-Z0-9_]*/
  highlight default link rapidNames None
  " Function
  syn match rapidFunction contains=rapidBuildInFunction /\c\(\s*\(proc\|module\)\s\+\)\@<![a-zA-Z_]\w\+ *(/me=e-1
  highlight default link rapidFunction Function
  " call by var: %"product"+NumToStr(nProductNumber)%;
  " call by var: if bBool %stString%;
  syn match rapidCallByVar /%\ze[^%]/
  highlight default link rapidCallByVar Function
  " ---

  " nicht schoen, aber num muss nach rapidNames folgen
  " TODO optimier das (nicht gefolgt von : und nicht vorneangestellter \
  syn match rapidType /\c\<num\>\s\+\ze\w\+/ " avoid false highlighting if its a \num:= argument
  highlight default link rapidType Type

  " BuildInFunction
  syn keyword rapidBuildInFunction contained Abs AbsDnum ACos ACosDnum AInput AOutput ArgName ASin ASinDnum ATan ATanDnum ATan2 ATan2Dnum
  syn keyword rapidBuildInFunction contained BitAnd BitAndDnum BitCheck BitCheckDnum BitLSh BitLShDnum BitNeg BitNegDnum BitOr BitOrDnum BitRSh BitRShDnum BitXOr BitXOrDnum ByteToStr
  syn keyword rapidBuildInFunction contained CalcJointT CalcRobT CalcRotAxFrameZ CalcRotAxisFrame CamGetExposure CamGetLoadedJob CamGetName CamNumberOfResults CapGetFailSigs CDate CJointT ClkRead CorrRead Cos CosDnum CPos CRobT CSpeedOverride CTime CTool CWObj
  syn keyword rapidBuildInFunction contained DecToHex DefAccFrame DefDFrame DefFrame Dim DInput Distance DnumToNum DnumToStr DotProd DOutput 
  syn keyword rapidBuildInFunction contained EGMGetState EulerZYX EventType ExecHandler ExecLevel Exp
  syn keyword rapidBuildInFunction contained FileSize FileTime FileTimeDnum FSSize
  syn keyword rapidBuildInFunction contained GetMaxNumberOfCyclicBool GetMecUnitName GetModalPayLoadMode GetMotorTorque GetNextCyclicBool GetNextMechUnit GetNextSym GetNumberOfCyclicBool GetServiceInfo GetSignalOrigin GetSysInfo GetTaskName GetTime GInput GInputDnum GOutput GOutputDnum
  syn keyword rapidBuildInFunction contained HexToDec
  syn keyword rapidBuildInFunction contained IndInpos IndSpeed IOUnitState IsCyclicBool IsFile IsLeadThrough IsMechUnitActive IsPers IsStopMoveAct IsStopStateEvent IsSyncMoveOn IsSysId IsVar
  syn keyword rapidBuildInFunction contained MaxRobSpeed MirPos ModExist ModTime ModTimeDnum MotionPlannerNo
  syn keyword rapidBuildInFunction contained NonMotionMode NOrient NumToDnum NumToStr
  syn keyword rapidBuildInFunction contained Offs OpMode OrientZYX ORobT
  syn keyword rapidBuildInFunction contained ParIdPosValid ParIdRobValid PathLevel PathRecValidBwd PathRecValidFwd PFRestart PoseInv PoseMult PoseVect Pow PowDnum PPMovedInManMode Present ProgMemFree PrxGetMaxRecordpos
  syn keyword rapidBuildInFunction contained RawBytesLen ReadBin ReadDir ReadMotor ReadNum ReadStr ReadStrBin ReadVar RelTool RemainingRetries RMQGetSlotName RobName RobOS Round RoundDnum RunMode
  syn keyword rapidBuildInFunction contained SafetyControllerGetChecksum SafetyControllerGetOpModePinCode SafetyControllerGetSWVersion SafetyControllerGetUserChecksum Sin SinDnum SocketGetStatus SocketPeek Sqrt SqrtDnum STCalcForce STCalcTorque STIsCalib STIsClosed STIsIndGun STIsOpen StrDigCalc StrDigCmp StrFind StrLen StrMap StrMatch StrMemb StrOrder StrPart StrToByte StrToVal
  syn keyword rapidBuildInFunction contained Tan TanDnum TaskRunMec TaskRunRob TasksInSync TestAndSet TestDI TestSignRead TextGet TextTabFreeToUse TextTabGet TriggDataValid Trunc TruncDnum Type
  syn keyword rapidBuildInFunction contained UIAlphaEntry UIClientExist UIDnumEntry UIDnumTune UIListView UIMessageBox UINumEntry UINumTune
  syn keyword rapidBuildInFunction contained ValidIO ValToStr Vectmagn
  " spot functions
  syn keyword rapidBuildInFunction contained SwGetCurrTargetName SwGetCurrSpotName 
  if exists("g:rapidNoHighlight") && g:rapidNoHighlight==1
        \|| exists("g:rapidNoHighLink") && g:rapidNoHighLink==1
    highlight default link rapidBuildInFunction BuildInFunction
  else
    highlight default link rapidBuildInFunction Function
  endif
  " ---

  " rapid structrure values. added to be able to conceal them
  syn region rapidStructVal matchgroup=rapidDelimiter start=/\[/ end=/\]/ contains=ALL keepend extend conceal cchar=* 
  highlight default link rapidStructVal None

  " Error
  if exists("g:rapidShowError") && g:rapidShowError==1
    " some more or less common typos
    "
    " vars or funcs >32 chars are not possible in rapid. a234567890123456789012345
    syn match rapidError /\w\{33,}/ containedin=rapidFunction,rapidNames,rapidLabel
    "
    syn match rapidError /\c\v^\s*\zs(esle>|endfi>|ednif>|ednwhile>|ednfor>)/
    "
    " WaitUntil a==b ok
    "            ||
    syn match rapidError /\c\v(^\s*(return|waituntil)>[^!\\]+[^!<>])@<=(\=|:)\=/
    syn match rapidError /\c\v(^\s*if>[^!\\]+[^!<>])@<=(\=|:)\=\ze[^!]*then/
    syn match rapidError /\c\v(^\s*while>[^!\\]+[^!<>])@<=(\=|:)\=\ze[^!]*do/
    "
    " WaitUntil a=>b ok
    "            ||
    syn match rapidError /\c\v(^\s*(return|waituntil|if|while)>[^!]+[^!<>])@<=\=[><]/
    "
    " wait for a><b ok
    "           ||
    syn match rapidError /\c\v(^\s*(return|waituntil|if|while)[^!]+)@<=\>\s*\</
    "
    " if (a==5) (b==6) ok
    "         |||
    syn match rapidError /\c\v(^\s*(return|wait\s+for|if|while)[^!]+[^!])@<=\)\s*\(/
    "
    " a == b + 1 ok
    "   ||
    syn match rapidError /\c\v(^\s*((global\s+|task\s+|local\s+)?(var|pers|const)\s+\w+\s+)?\w+(\w|\{|,|\}|\+|\-|\*|\/|\.)*\s*)@<=\=/
    "
    " this one is tricky. Make sure this does not match trigger instructions
    " a = b and c or (int1=int2)
    "                     |
    " syn match rapidError /\c\v(^\s*\$?[^=;]+\s*\=[^=;][^;]+[^;<>=])@<=\=[^=]/
    " syn match rapidError /\c\v^\s*(trigger\swhen\s)@<!(\$?[^=;]+\s*\=[^=;][^;]+[^;<>=])@<=\=[^=]/
    "
    highlight default link rapidError Error
  endif
  " ---
endif

let b:current_syntax = "rapid"

" vim:sw=2 sts=2 et

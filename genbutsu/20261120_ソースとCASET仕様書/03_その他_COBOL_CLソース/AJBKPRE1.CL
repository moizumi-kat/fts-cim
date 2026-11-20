/.                                               FTS-CIM <ASP E@@>
  *
  * ＣＬ－ＩＤ称   ＝   ＡＪＢＫＰＲＥ１
  *
  * サブシステム名 ＝   ＩＴ管理室サブシステム
  * ＣＬ処理概要   ＝   情報物件ファイル（項目）を
  *                     オフライン同期するための準備処理を行う
  *                     受注項目に紐づいているデータのみを抽出し
  *                     同期用ファイルＲＪＢＫＦＰ．ＦＣＤＬＩＢに
  *                     データを書き込む。（ＩＴ管理室　村上）
  *
  *                                              作成日付 15.03.14
  *                                              修正日付
  *
  *            ALL RIGHT RESERVED COPYRIGHT  FUJITSU LIMITED 1993
./

    PGM    (S-?SP)
    PARA   ?SP,NAME,IN,RESTART
    VAR    ?SAVEEC,INTEGER
    VAR    ?MSGAREA,STRING*99
    VAR    ?LABEL,STRING*8
    VAR    ?NAME, STRING*8
    VAR    ?MSG0, STRING*37,VALUE-'***********************************'
    VAR    ?MSG1, STRING*37
    VAR    ?MSG2, STRING*37
    VAR    ?WSNAME,STRING*8
    VAR    ?GYOM, STRING*24,VALUE-'情報物件同期事前準備'
    VAR    ?START,STRING*11,VALUE-'<<START>> *'
    VAR    ?END,  STRING*11,VALUE-'<< END >> *'
    VAR    ?ABEND,STRING*11,VALUE-'<<ABEND>> *'
    VAR    ?CLID ,STRING*19,VALUE-'*  (AJBKPRE1)      '

   INIT
    ?MSG1  := '* ' && ?GYOM && ?START
    ?MSG2  := ?CLID && ' ' && @JOBDATE && ' ' && @STIME && ' *'

    SNDMSG  MSG-?MSG0,TO-XCTL
    SNDMSG  MSG-?MSG1,TO-XCTL
    SNDMSG  MSG-?MSG2,TO-XCTL
    SNDMSG  MSG-?MSG0,TO-XCTL
    END

STEP1:

    CLRFILE FILE-RJBKFP.FCDLIB

STEP2:

    OVRF FILE-AJBKFL1,TOFILE-AJBKFL1.@LIBL
    OVRF FILE-RJBKFP ,TOFILE-RJBKFP.@LIBL

    CALL AJBKSEL1.KANPLIB1

    DLTOVRF FILE-AJBKFL1
    DLTOVRF FILE-RJBKFP

OWARI:
    ?MSG1  := '* ' && ?GYOM  && ?END
    ?MSG2  := ?CLID && ' '  && @JOBDATE && ' ' && @STIME && ' *'
    SNDMSG  MSG-?MSG0,TO-XCTL
    SNDMSG  MSG-?MSG1,TO-XCTL
    SNDMSG  MSG-?MSG2,TO-XCTL
    SNDMSG  MSG-?MSG0,TO-XCTL
    RETURN  PGMEC-@PGMEC

CHECK:
  WHEN ABNORMAL
    ?LABEL   := %LAST(LABEL)
    ?NAME    := %LAST(COMMAND)
    ?SAVEEC  := @PGMEC
    ?MSGAREA := 'LABEL='    &&  ?LABEL
                &&   ',NAMF '     &&  ?NAME
                &&   ',COD='      &&  @PGMES
                &&   ',INF='      &&  @PGMEM
    ?MSG1 :=    '* '        &&  ?GYOM
                &&  ?ABEND
    ?MSG2 :=    ?CLID         &&  ' '
                && @JOBDATE   &&  ' '
                && @STIME     &&  ' *'
    SNDMSG  MSG-?MSG0,TO-XCTL
    SNDMSG  MSG-?MSG1,TO-XCTL
    SNDMSG  MSG-?MSG2,TO-XCTL
    SNDMSG  MSG-?MSG0,TO-XCTL
    SNDMSG  MSG-?MSGAREA,TO-XCTL
    RETURN   PGMEC-?SAVEEC
  END

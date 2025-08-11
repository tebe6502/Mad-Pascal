;  fujinet tiny web client by bocianu
;
;  This file must be assembled to "http_client.obj" and is used in "webclient.rc"

CLIENT_ADDRESS = $5C00;

_R = $40;  // Read - predefined values for data transfer direction (to be set in DSTATS)
_W = $80;  // Write
_NO = $00; // No data transfer

METHOD_GET = 4;             // http method
METHOD_PROPFIND = 6;        // to be set in AUX1 on Open
METHOD_PUT = 8;
METHOD_GET_WITH_HEADERS = 12;
METHOD_PUT_WITH_HEADERS = 14;
METHOD_POST = 13;

CR2EOL = 1;                 // EOL auto translation
LF2EOL = 2;                 // to be set in AUX2 on Open
CRLF2EOL = 3;

MODE_BODY = 0;              // HTTP Channel Mode
MODE_COLLECT_HEADERS = 1;   // to be set in AUX2 on Command "M" - Set Channel Mode
MODE_GET_HEADERS = 2;
MODE_SET_HEADERS = 3;
MODE_SET_POST_DATA = 4;

MODE_DIR_R = 4;
MODE_DIR_W = 8;

TCP_TIMEOUT = $0f;
JSIOINT = $E459; // SIO OS procedure vector
DCB = $300;      // DCB struct address

ZPW = $f0;

    org CLIENT_ADDRESS

request
                        ;; open HTTP connection
    lda #<openConnectionDCB
    jsr loadDCB_execSIO
                        ;; exit on error
    cpy #1
    jne error

    ;lda open_aux1       ;; on PUT method skip headers
    ;cmp #METHOD_PUT
    ;beq skip_headers

    lda headers         ;; check if custom headers defined
    ora headers+1
    beq skip_headers    

prepare_headers         ;; set custom headers
    lda #MODE_SET_HEADERS 
    jsr setModeA

readHeaderLoop          
    ldy #0
    mwa headers ZPW 
    lda (ZPW),y         ;; if first char = char(0)
    beq skip_headers    ;; end reading

    mwa headers DCB_headerStart  ;; set header
    lda #<writeHeaderDCB         ;; one line at a time
    jsr loadDCB_execSIO   
@
    iny
    lda (ZPW),y                  ;; find next char(0)
    bne @-
    tya 
    adc headers                  ;; add to headers pointer
    sta headers                  ;; to move forward to next header
    scc
    inc headers+1
    jmp readHeaderLoop           ;; ^^^ header loop

  
skip_headers
                               ;; check HTTP method selected
    lda open_aux1
    cmp #12
    beq get_req    
    cmp #4
    beq get_req    

post_req                ;; write POST DATA
put_req
    lda #MODE_SET_POST_DATA
    jsr setModeA
 
putBlock

    mwa DCB_srcLen DCB_srcLen+2 
    lda #<writeDataDCB
    jsr loadDCB_execSIO     ;; POST data is stored in output buffer 
                            ;; until next http transaction (GET / GET HEADERS)  
    cpy #1
    jne error           
    
get_req                 
                        ;; init GET
    lda #0  
    sta shouldRun+1
    lda #MODE_BODY
    jsr setModeA 
    mva #3 timeout

waitForData
    dec timeout
    jsr checkForData    ;; read status and wait for data
    bne dataWaits
    lda timeout 
    bne waitForData
    jeq error

dataWaits
    lda DCB_destStart   ;; if DCB_destStart specified read to this addres raw data block 
    ora DCB_destStart + 1
    bne oneBlockOnly    ;; if DCB_destStart = 0 -> no vector specified, read block header

blockLoop
    lda #<readHeaderDCB
    jsr loadDCB_execSIO   ;; read first word
    cpw #$FFFF tmp_address  ;; if $ffff (com header)
    beq blockLoop ;; drop and read again 
    mwa tmp_address DCB_destStart ;; store at DCB struct
    lda #<readHeaderDCB
    jsr loadDCB_execSIO ;; second word (blockEnd)

    inw tmp_address ;; calculate data length
    sec               
    lda tmp_address
    sbc DCB_destStart
    sta bytesWaiting       
    lda tmp_address + 1
    sbc DCB_destStart + 1
    sta bytesWaiting + 1

oneBlockOnly
    lda bytesWaiting 
    sta DCB_destLen
    sta DCB_destLen + 2
    lda bytesWaiting + 1
    sta DCB_destLen + 1
    sta DCB_destLen + 3

getBlock
    lda #<readDataDCB
    jsr loadDCB_execSIO

endOfData
    lda DCB_destStart + 1
    cmp #$02  ;; check if saved on $02 page
    bne endOfBlock
    lda DCB_destStart
    cmp #$E0 ;; RUNAD modified
    sne 
    inc shouldRun + 1
    cmp #$E2 ;; INITAD modified
    bne endOfBlock
    mwa $02E2 initjsr+1
initjsr    
    jsr $FFFF ;; <- jump address gets replaced by command above

endOfBlock
    jsr checkForData
    jne blockLoop
                        ;; close connection
closeConnection
    lda #<closeConnectionDCB
    jsr loadDCB_execSIO

shouldRun
    lda #0  ;; <- self modified code. byte value gets updated somewhere else
    beq clearEnd
    mwa $02E0 runjump+1
runjump
    jmp $FFFF ;; <- jump address gets replaced by command above

clearEnd
    ldy #1
    rts
    
error
    ;; errorcode in Y register
    sty reqresult
    lda #<closeConnectionDCB
    jsr loadDCB_execSIO
    ldy reqresult
    rts

setModeA                ;; set http mode
    sta HttpMode
    lda #<setModeDCB
    jsr loadDCB_execSIO   
    rts

checkForData            ;; 
    lda #<getStatusDCB
    jsr loadDCB_execSIO
    cpy #1
    beq @+
    lda #0
    rts
@
    lda bytesWaiting
    ora bytesWaiting + 1
    rts
    
    ;; copies struct to DCB
loadDCB_execSIO
    sta loadDCBloop + 1 ;; updates loop address
    ldy #11 
loadDCBloop 
    lda openConnectionDCB,y  ;; <- self modyfing code here
    sta DCB,y
    dey
    bpl loadDCBloop 
execSio
    jsr JSIOINT 
    rts

;;;;;;;;;;;;;;; VARS
timeout 
    dta 0
status
    dta a(0)    ;; size
tmp_address
    dta a(0)
errorcode = tmp_address + 1
reqresult
    dta 0
bytesWaiting = status
headers
    dta a(0)
;; DCB structs  

openConnectionDCB           ;;;;;;;;; OPEN
    dta $71,1,'O',_W
connection_string_address
        dta a(0),TCP_TIMEOUT,0,a(256)
open_aux1
        dta METHOD_GET
open_aux2
        dta 0 // no EOL translation

getStatusDCB                ;;;;;;;;; STATUS
    dta $71,1,'S',_R,a(status),TCP_TIMEOUT,0,a(4),0,0 

readDataDCB                 ;;;;;;;;; READ DATA
    dta $71,1,'R',_R
DCB_destStart
        dta a(0),TCP_TIMEOUT,0
DCB_destLen 
        dta a(0),a(0) 

writeDataDCB                ;;;;;;;;; WRITE DATA
    dta $71,1,'W',_W
DCB_srcStart
        dta a(0),TCP_TIMEOUT,0
DCB_srcLen 
        dta a(0),a(0)         

writeHeaderDCB              ;;;;;;;;; WRITE HEADER
    dta $71,1,'W',_W
DCB_headerStart
        dta a(0),TCP_TIMEOUT,0,a(40),a(40)         

readHeaderDCB               ;;;;;;;;; READ SINGLE WORD (2 bytes)
    dta $71,1,'R',_R,a(tmp_address),TCP_TIMEOUT,0,a(2),a(2) 

setModeDCB                  ;;;;;;;;; SET HTTP MODE
    dta $71,1,'M',_NO,a(0),TCP_TIMEOUT,0,a(0)
modeDir
    dta MODE_DIR_W + MODE_DIR_R
HttpMode
    dta MODE_BODY

closeConnectionDCB          ;;;;;;;;; CLOSE
    dta $71,1,'C',_NO,a(0),0,0,a(0),0,0   
structsEnd

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; end of code

.IF [>structsEnd <> >openConnectionDCB] 
    .PRINT "structsEnd: ", structsEnd
    .ERROR "DBA structs splited on two memory pages!"
.ENDIF
   
.PRINT "LOADER_SIZE = ", *-CLIENT_ADDRESS, ";"
.PRINT "REQUEST_VECTOR = ", request, ";"
.PRINT "URI_ADDRESS = ", connection_string_address, ";"
.PRINT "METHOD_BYTE = ", open_aux1, ";"
.PRINT "HEADERS_ADDRESS = ", headers, ";"
.PRINT "RESPONSE_BODY_ADDRESS = ", DCB_destStart, ";"
.PRINT "LAST_BLOCK_SIZE = ", DCB_destLen, ";"
.PRINT "REQUEST_BODY_ADDRESS = ", DCB_srcStart, ";"
.PRINT "REQUEST_BODY_SIZE = ", DCB_srcLen, ";"
.PRINT "REQUEST_ERROR_CODE = ", errorcode, ";"

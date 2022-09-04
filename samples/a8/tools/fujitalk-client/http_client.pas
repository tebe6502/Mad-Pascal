unit http_client;
(*
* @type: unit
* @author: bocianu <bocianu@gmail.com>
* @name: HTTP request library for #FujiNet interface.
* @version: 0.4.4

* @description:
* Set of procedures to send http requests and fetch responses. <https://fujinet.online/>
* 
* This library allows you to handle almost any Web API. It can do GET, POST and PUT requests, 
* set custom http headers, fetch data using GET directly to atari memory. 
* 
* It can fetch multiblock DOS binaries and initializes INI and/or runs RUN blocks.
* 
* 
* This library is a part of 'blibs' - set of custom Mad-Pascal libraries.
*
* <https://gitlab.com/bocianu/blibs>
*)
interface
const
{$i 'http_client.inc'}

METHOD_GET = 4;             
METHOD_PROPFIND = 6;        
METHOD_PUT = 8;
METHOD_GET_WITH_HEADERS = 12;
METHOD_PUT_WITH_HEADERS = 14;
METHOD_POST = 13;

var 
    HTTP_uri: pointer absolute URI_ADDRESS;
    HTTP_method: byte absolute METHOD_BYTE;
    HTTP_headers: pointer absolute HEADERS_ADDRESS;
    HTTP_resp: pointer absolute RESPONSE_BODY_ADDRESS;
    HTTP_respSize: word absolute LAST_BLOCK_SIZE;
    HTTP_req: pointer absolute REQUEST_BODY_ADDRESS;
    HTTP_reqSize: word absolute REQUEST_BODY_SIZE;
    HTTP_errorCode: byte absolute REQUEST_ERROR_CODE;
    HTTP_error: byte;
    
procedure HTTP_SetDefaults;
procedure HTTP_MakeRequest(url, resp: pointer);
procedure HTTP_Get(url, resp: pointer);
procedure HTTP_GetWithHeaders(url, resp: pointer);
procedure HTTP_Put(url, resp, req: pointer;reqSize:word);
procedure HTTP_Post(url, resp, req: pointer; reqSize:word); 
implementation


procedure HTTP_SetDefaults;
begin
    HTTP_resp := pointer(0);
    HTTP_req := pointer(0);
    HTTP_headers := pointer(0);
    HTTP_reqSize := 0;
    HTTP_error := 1;
    
    HTTP_method := METHOD_GET;  
end;

procedure HTTP_MakeRequest(url, resp: pointer);
begin
    HTTP_uri := url;
    HTTP_resp := resp;
    asm 
        jsr REQUEST_VECTOR 
        sty HTTP_error
    end;
end;

procedure HTTP_SetData(req: pointer; reqSize:word);
begin
    HTTP_req := req;
    HTTP_reqSize := reqSize;
end;

procedure HTTP_Get(url, resp: pointer);
begin
    HTTP_method := METHOD_GET;
    HTTP_MakeRequest(url, resp);
end;

procedure HTTP_GetWithHeaders(url, resp: pointer);
begin
    HTTP_method := METHOD_GET_WITH_HEADERS;
    HTTP_MakeRequest(url, resp);
end;

procedure HTTP_Put(url, resp, req: pointer; reqSize:word);
begin
    HTTP_method := METHOD_PUT_WITH_HEADERS;
    HTTP_setData(req, reqSize);
    HTTP_MakeRequest(url, resp);
end;

procedure HTTP_Post(url, resp, req: pointer; reqSize:word);
begin
    HTTP_method := METHOD_POST;
    HTTP_setData(req, reqSize);
    HTTP_MakeRequest(url, resp);
end;


{$r 'webclient.rc'}

end.

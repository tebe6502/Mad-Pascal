const
{$i 'http_client.inc'}

METHOD_GET = 4;             
METHOD_PROPFIND = 6;        
METHOD_PUT = 8;
METHOD_GET_WITH_HEADERS = 12;
METHOD_POST = 13;

var 
    HTTP_uri: pointer absolute URI_ADDRESS;
    HTTP_method: byte absolute METHOD_BYTE;
    HTTP_headers: pointer absolute HEADERS_ADDRESS;
    HTTP_resp: pointer absolute RESPONSE_BODY_ADDRESS;
    HTTP_respSize: word absolute LAST_BLOCK_SIZE;
    HTTP_req: pointer absolute REQUEST_BODY_ADDRESS;
    HTTP_reqSize: word absolute REQUEST_BODY_SIZE;
    HTTP_error: byte;

procedure HTTP_default;
begin
    HTTP_resp := pointer(0);
    HTTP_req := pointer(0);
    HTTP_headers := pointer(0);
    HTTP_reqSize := 0;
    HTTP_method := METHOD_GET;  
end;

procedure HTTP_request(url, resp: pointer);
begin
    HTTP_uri := url;
    HTTP_resp := resp;
    asm 
        jsr REQUEST_VECTOR 
        sty HTTP_error
    end;
end;

procedure HTTP_setData(req: pointer;reqSize:word);
begin
    HTTP_req := req;
    HTTP_reqSize := reqSize;
end;

procedure HTTP_Get(url, resp: pointer);
begin
    HTTP_method := METHOD_GET;
    HTTP_request(url, resp);
end;

procedure HTTP_GetWithHeaders(url, resp: pointer);
begin
    HTTP_method := METHOD_GET_WITH_HEADERS;
    HTTP_request(url, resp);
end;

function HTTP_Put(url, resp, req: pointer;reqSize:word):byte;
begin
    HTTP_method := METHOD_PUT;
    HTTP_setData(req, reqSize);
    HTTP_request(url, resp);
end;

function HTTP_Post(url, resp, req: pointer; reqSize:word):byte;
begin
    HTTP_method := METHOD_POST;
    HTTP_setData(req, reqSize);
    HTTP_request(url, resp);
end;


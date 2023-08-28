# app/core/error_handler.py
import json, time
from fastapi import HTTPException, Request, status
from fastapi.responses import Response, JSONResponse
from .logger import log

## HTTP Exception
async def http_exception_handler(request: Request, exc: HTTPException):
    ## Calculate the request processing time of http exception
    process_time = (time.time() - request.state.start_time) * 1000
    ## Check HTTP status code and return appropriate response
    if exc.status_code == status.HTTP_501_NOT_IMPLEMENTED:
        return JSONResponse(
            status_code=status.HTTP_501_NOT_IMPLEMENTED, 
            content={"detail": exc.detail}
        )
    elif exc.status_code == status.HTTP_502_BAD_GATEWAY:
        return JSONResponse(
            status_code=status.HTTP_502_BAD_GATEWAY, 
            content={"detail": exc.detail}
        )
    elif exc.status_code == status.HTTP_503_SERVICE_UNAVAILABLE:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_504_GATEWAY_TIMEOUT:
        return JSONResponse(
            status_code=status.HTTP_504_GATEWAY_TIMEOUT,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_400_BAD_REQUEST:
        return JSONResponse(
            status_code=status.HTTP_400_BAD_REQUEST,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_401_UNAUTHORIZED:
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_403_FORBIDDEN:
        return JSONResponse(
            status_code=status.HTTP_403_FORBIDDEN,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_404_NOT_FOUND:
        return JSONResponse(
            status_code=status.HTTP_404_NOT_FOUND,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_405_METHOD_NOT_ALLOWED:
        return JSONResponse(
            status_code=status.HTTP_405_METHOD_NOT_ALLOWED,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_406_NOT_ACCEPTABLE:
        return JSONResponse(
            status_code=status.HTTP_406_NOT_ACCEPTABLE,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_409_CONFLICT:
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_422_UNPROCESSABLE_ENTITY:
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={"detail": exc.detail},
        )
    elif exc.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR:
        ## Print stack trace
        log.debug("print stack trace for status code 500: ")
        import traceback
        log.debug(traceback.format_exc())
        ## Exception response header
        response_header = {
            "Content-Type": "text/plain",
            "Content-Length": "21",
        }
        ## Exception response body
        response_body = {
            "detail": exc.detail
        }
        structured_log = {
            "method": request.method,
            "status_code": exc.status_code,
            "path": request.url.path,
            "latency": f"{process_time:.2f}ms",
            "request": {
                "headers": dict(request.headers),
                # "body": dict(request.body()),
            },
            "response": {
                "headers": response_header,
                "message": response_body,
            }    
        }
        log.fatal(json.dumps(structured_log))
        return Response(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content="Internal Server Error",
        )
    else:
        ## Print stack trace
        log.debug("print stack trace for unhandler http error: ")
        import traceback
        log.debug(traceback.format_exc())
        return Response(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content="Internal Server Error",
        )

## Error handler for general Exception
async def server_error_exception_handler(request: Request, exc: Exception):
    ### Error message
    error_message = str(exc)
    ### Print stack trace
    log.debug("print stack trace for unhandler server error 2: ")
    import traceback
    log.debug(traceback.format_exc())
    return Response(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content="Internal Server Error",
    )
"""Simplest example."""

import asyncio
import datetime
import os
from contextlib import asynccontextmanager
from pathlib import Path
from typing import Annotated

from fastapi import Depends, FastAPI, Request, WebSocket
from fastapi.responses import HTMLResponse, JSONResponse
from nc_py_api import NextcloudApp
from nc_py_api.ex_app import AppAPIAuthMiddleware, LogLvl, nc_app, run_app, set_handlers


@asynccontextmanager
async def lifespan(app: FastAPI):
    set_handlers(app, enabled_handler)
    yield


APP = FastAPI(lifespan=lifespan)
APP.add_middleware(AppAPIAuthMiddleware)  # set global AppAPI authentication middleware

# Build the WebSocket URL dynamically using the NextcloudApp configuration.
WS_URL = NextcloudApp().app_cfg.endpoint + "/exapps/app-skeleton-python/ws"

# HTML content served at the root URL.
# This page opens a WebSocket connection, displays incoming messages,
# and allows you to send messages back to the server.
HTML = f"""
<!DOCTYPE html>
<html>
    <head>
        <title>FastAPI WebSocket Demo</title>
    </head>
    <body>
        <h1>FastAPI WebSocket Demo</h1>
        <p>Type a message and click "Send", or simply watch the server send cool updates!</p>
        <input type="text" id="messageText" placeholder="Enter message here...">
        <button onclick="sendMessage()">Send</button>
        <ul id="messages"></ul>
        <script>
            // Create a WebSocket connection using the dynamic URL.
            var ws = new WebSocket("{WS_URL}");

            // When a message is received from the server, add it to the list.
            ws.onmessage = function(event) {{
                var messages = document.getElementById('messages');
                var message = document.createElement('li');
                message.textContent = event.data;
                messages.appendChild(message);
            }};

            // Function to send a message to the server.
            function sendMessage() {{
                var input = document.getElementById("messageText");
                ws.send(input.value);
                input.value = '';
            }}
        </script>
    </body>
</html>
"""


@APP.get("/")
async def get():
    # WebSockets works only in Nextcloud 32 when `HaRP` is used instead of `DSP`
    return HTMLResponse(HTML)


@APP.get("/public")
async def public_get(request: Request):
    print(f"public_get: {request.headers}", flush=True)
    return "Public page!"


@APP.get("/user")
async def user_get(request: Request, status: int = 200):
    print(f"user_get: {request.headers}", flush=True)
    return JSONResponse(content="Page for the registered users only!", status_code=status)


@APP.get("/admin")
async def admin_get(request: Request):
    print(f"admin_get: {request.headers}", flush=True)
    return "Admin page!"


@APP.websocket("/ws")
async def websocket_endpoint(
    websocket: WebSocket,
    nc: Annotated[NextcloudApp, Depends(nc_app)],
):
    # WebSockets works only in Nextcloud 32 when `HaRP` is used instead of `DSP`
    print(nc.user)  # if you need user_id that initiated WebSocket connection
    print(f"websocket_endpoint: {websocket.headers}", flush=True)
    await websocket.accept()

    # This background task sends a periodic message (the current time) every 2 seconds.
    async def send_periodic_messages():
        while True:
            try:
                message = f"Server time: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
                await websocket.send_text(message)
                await asyncio.sleep(2)
            except Exception as exc:
                NextcloudApp().log(LogLvl.ERROR, str(exc))
                break

    # Start the periodic sender in the background.
    periodic_task = asyncio.create_task(send_periodic_messages())

    try:
        # Continuously listen for messages from the client.
        while True:
            data = await websocket.receive_text()
            # Echo the received message back to the client.
            await websocket.send_text(f"Echo: {data}")
    except Exception as e:
        NextcloudApp().log(LogLvl.ERROR, str(e))
    finally:
        # Cancel the periodic message task when the connection is closed.
        periodic_task.cancel()


def enabled_handler(enabled: bool, nc: NextcloudApp) -> str:
    # This will be called each time application is `enabled` or `disabled`
    # NOTE: `user` is unavailable on this step, so all NC API calls that require it will fail as unauthorized.
    print(f"enabled={enabled}", flush=True)
    if enabled:
        nc.log(LogLvl.WARNING, f"Hello from {nc.app_cfg.app_name} :)")
    else:
        nc.log(LogLvl.WARNING, f"Bye bye from {nc.app_cfg.app_name} :(")
    # In case of an error, a non-empty short string should be returned, which will be shown to the NC administrator.
    return ""


if __name__ == "__main__":
    # Wrapper around `uvicorn.run`.
    # You are free to call it directly, with just using the `APP_HOST` and `APP_PORT` variables from the environment.
    os.chdir(Path(__file__).parent)
    run_app("main:APP", log_level="trace")

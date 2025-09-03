import asyncio
import websockets

async def echo(websocket):
    async for message in websocket:
        print(f"Received: {message}")
        await websocket.send(message)

async def main():
    async with websockets.serve(echo, "localhost", 8765):
        print("WebSocket server running on ws://localhost:8765")
        await asyncio.Future()  # run forever

asyncio.run(main())

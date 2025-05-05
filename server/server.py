# server.py
import asyncio
import websockets
import base64
import cv2
import numpy as np
import mediapipe as mp

mp_hands = mp.solutions.hands
hands = mp_hands.Hands(static_image_mode=False, max_num_hands=2)
mp_draw = mp.solutions.drawing_utils

async def handle_connection(websocket):
    print("Client connected")
    try:
        async for message in websocket:
            img_data = base64.b64decode(message)
            nparr = np.frombuffer(img_data, np.uint8)
            frame = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

            # Обработка через MediaPipe
            rgb_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
            results = hands.process(rgb_frame)

            gesture_detected = False
            if results.multi_hand_landmarks:
                gesture_detected = True
                for hand_landmarks in results.multi_hand_landmarks:
                    mp_draw.draw_landmarks(frame, hand_landmarks, mp_hands.HAND_CONNECTIONS)

            # Отправляем результат клиенту
            await websocket.send("Gesture detected" if gesture_detected else "No gesture")

    except websockets.ConnectionClosed:
        print("Connection closed")

async def main():
    async with websockets.serve(handle_connection, "localhost", 8765):
        print("Server started on ws://localhost:8765")
        await asyncio.Future()  # run forever

if __name__ == "__main__":
    asyncio.run(main())

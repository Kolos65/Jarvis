
from src.recognizer import Recognizer
from src.detector import Detector
from src.event_handler import EventHandler
from threading import Thread
import face_recognition
import numpy as np
import time
import cv2
import os

class Camera:
    _instance = None
    @staticmethod
    def shared():
        if not Camera._instance:
            Camera._instance = Camera('cam1','./media')
        return Camera._instance
    
    def __init__(self, name, media_dir):
        self.name = name
        self.media_dir = media_dir
        self.root = self.media_dir + '/' + self.name
        self.streaming = False
        self.event_handler = EventHandler()
        self.recognizer = Recognizer(self.event_handler)
        self.detector = Detector(self.event_handler)
        self.cap = cv2.VideoCapture(0)
        self.previous = []
        self.detector_is_on = True
        self.recognizer_is_on = True
        self.running = False
    
    # Start observing on a new thread
    def run(self):
        if self.running:
            return
        self.running = True
        Thread(target=self.observe, args=()).start()
    
    # Run detection on captured stream and draw frames
    def observe(self):
        while self.running:
            ret, frame = self.cap.read()
            self.frame = frame.copy()
            if self.detector_is_on:
                self.detector.process(frame)
            if self.recognizer_is_on:
                self.recognizer.process(frame)
            if self.recognizer_is_on:
                frame = self.recognizer.draw(frame)
            if self.detector_is_on:
                frame = self.detector.draw(frame)
            self.drawn = frame

    # Open a window and show frames
    def show(self):
        while self.running:
            if cv2.waitKey(1) & 0xFF == ord('q'):
                cv2.destroyAllWindows()
            frame = self.drawn
            if np.array_equal(frame, self.previous):
                time.sleep(0.1)
                continue
            self.previous = frame.copy()
            cv2.imshow('frame', self.drawn)

    # Send every new frame to the client
    def stream(self, draw = True):
        while self.running:
            frame = self.drawn if draw else self.frame
            if np.array_equal(frame, self.previous):
                time.sleep(0.1)
                continue
            self.previous = frame.copy()
            ret, jpeg = cv2.imencode('.jpg', frame)
            data = self.create_response(jpeg)
            yield(data)
    
    # Send newest frame
    def snapshot(self):
        frame = self.drawn
        ret, jpeg = cv2.imencode('.jpg', frame)
        return jpeg.tobytes()

    # Reset motion detector
    def reset_motion_detector(self):
        self.detector.reset(self.frame)

    # Helper to generate x-mixed-replace boundaries
    def create_response(self, frame):
        return b'--frame\r\n' b'Content-Type: image/jpg\r\n\r\n' + frame.tobytes() + b'\r\n\r\n'


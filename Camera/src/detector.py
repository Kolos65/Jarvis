import time
import cv2

class Detector:
    def __init__(self, event_handler):
        self.event_handler = event_handler
        self.first_frame = None
        self.time = time.time()
        self.reset_interval = 60 # Reset every minute
        self.contours = None

    def process(self, frame):
        frame = cv2.resize(frame, (0, 0), fx=0.5, fy=0.5)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (25, 25), 0)
        
        if self.first_frame is None or time.time() - self.time > self.reset_interval:
            self.first_frame = gray
            self.time = time.time()
        
        delta = cv2.absdiff(self.first_frame, gray)
        thres = cv2.threshold(delta, 25, 255, cv2.THRESH_BINARY)[1]
        thres = cv2.dilate(thres, None, iterations=2)
        
        contours = cv2.findContours(thres.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)[0]
        self.contours = [x for x in contours if cv2.contourArea(x) > 3000]
        if len(self.contours) > 0:
            self.event_handler.movement_detected()

    def reset(self, frame):
        frame = cv2.resize(frame, (0, 0), fx=0.5, fy=0.5)
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        gray = cv2.GaussianBlur(gray, (25, 25), 0)
        self.first_frame = gray

    def draw(self, frame):
        if self.contours is None:
            return frame

        for c in self.contours:
            (x, y, w, h) = cv2.boundingRect(c)
            x *= 2
            y *= 2
            w *= 2
            h *= 2
            cv2.rectangle(frame, (x, y), (x + w, y + h), (255, 0, 0), 2)
        return frame

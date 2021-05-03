
import cv2
import time
import face_recognition
from threading import Thread

class Recognizer:
    def __init__(self, event_handler):
        # init
        self.event_handler = event_handler

        # load faces
        self.load_faces(["Obama"], ["./assets/obama.jpg"])
        
        # initialize detector
        self.detector = cv2.CascadeClassifier('./models/haarcascade_frontalface_alt2.xml')
        
        # init variables
        self.names_seen = []
        self.face_locations = []
        
        # optimization
        self.FRAME_PER_CALC = 10
        self.SCALE = 0.5
        self.frame_counter = 0
        
        self.thread_running = False
        

    def load_faces(self, names, images):
        self.face_encodings = []
        self.face_names = []
        for name, image in zip(names, images):
            img = face_recognition.load_image_file(image)
            enc = face_recognition.face_encodings(img)[0]
            self.face_encodings.append(enc)
            self.face_names.append(name)
    
    def process(self, frame):
        self.detect(frame)
        if not self.thread_running:
            self.thread_running = True
            Thread(target=self.recognize, args=(frame,)).start() # TODO
        
    def detect(self, frame):
        #self.face_locations = face_recognition.face_locations(frame) #dlib detector
        gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        rects = self.detector.detectMultiScale(gray,
            scaleFactor=1.1,
            minNeighbors=5,
            minSize=(30, 30)
        )
              
        self.face_locations = [(
            int(y * self.SCALE), 
            int((x + w) * self.SCALE), 
            int((y + h) * self.SCALE), 
            int(x * self.SCALE)
        ) for (x, y, w, h) in rects]
        
    def recognize(self, frame):
        self.frame_counter += 1
        if self.frame_counter == self.FRAME_PER_CALC:
            self.frame_counter = 0
            small_frame = cv2.resize(frame, (0, 0), fx=self.SCALE, fy=self.SCALE)
            rgb = cv2.cvtColor(small_frame, cv2.COLOR_BGR2RGB)
            encodings = face_recognition.face_encodings(rgb, self.face_locations)
            self.names_seen = []
            for encoding in encodings:
                matches = face_recognition.compare_faces(self.face_encodings, encoding)
                name = "Unknown"
                if True in matches:
                    index = matches.index(True)
                    name = self.face_names[index]
                self.event_handler.face_detected(name)
                self.names_seen.append(name)
        self.thread_running = False
        
    def draw(self, frame):
        for (top, right, bottom, left), name in zip(self.face_locations, self.names_seen):
            # scale back up
            top = int(top/self.SCALE)
            right = int(right/self.SCALE)
            bottom = int(bottom/self.SCALE)
            left = int(left/self.SCALE)
            
            # draw the predicted face name on the image
            cv2.rectangle(frame, (left, top), (right, bottom),(0, 255, 0), 2)
            y = top - 15 if top - 15 > 15 else top + 15
            if len(self.face_locations) == len(self.names_seen):
                cv2.putText(frame, name, (left, y), cv2.FONT_HERSHEY_SIMPLEX, 0.75, (0, 255, 0), 2)
        return frame

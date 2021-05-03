from threading import Timer
from tinydb import TinyDB
import requests
import time
import json
import os

class EventHandler:
    def __init__(self):
        self.last_motion_event = None
        self.pause_motion_until = time.time()
        self.pause_name_until = {
            "Obama": time.time(),
            "Unknown": time.time()
        }
        self.known_name_seen = True
        self.push_sent = 0
        self.events_db = TinyDB("events.json")
        self.user_db = TinyDB("user.json")

    def face_detected(self, name):
        now = time.time()
        # Update flag to eliminate false negative predictions
        if name != "Unknown":
            self.known_name_seen = True
        # If detection is paused for the face, do nothing
        if now < self.pause_name_until[name]:
            return
        # If unknown face is seen, pause unknown for 5 min, wait for 8s 
        # to see if a known face is detected
        if name == "Unknown":
            self.pause_name_until["Unknown"] = time.time() + 5 * 60
            self.known_name_seen = False
            Timer(7, self.unkown_detected).start()
            return
        # If known face is detected, send push, pause it for 60 minutes, 
        # pause motion for 60 minutes, pause unknown for 5 sec
        self.process_face_event(name)
        self.pause_name_until[name] = time.time() + 60 * 60
        self.pause_name_until["Unknown"] = time.time() + 1 * 60
        self.pause_motion_until = time.time() + 60 * 60

    def unkown_detected(self):
        if not self.known_name_seen:
            self.process_face_event("Unknown")

    def movement_detected(self):
        now = time.time()
        # If motion is paused, dont do anything
        if now < self.pause_motion_until:
            return
        # If motion is recognized after cooldown interval passed, 
        # we should react to it as normal
        self.process_motion_event()
        self.pause_motion_until = now + 5 * 60 # Pause motion for 5 minutes

    def process_motion_event(self):
        title = "‼️ Movement Detected 😧"
        message = "Click to reset detector or watch live feed"
        self.send_push(title, message)
        self.save_event(title)

    def process_face_event(self, name):
        if name == "Obama":
            title = "✅ Welcome Mr. President! 😌"
            message = "Click to disable alert system"
        elif name == "Unknown":
            title = "🆘 Unknown face detected 😧"
            message = "Click to watch live feed"
        else:
            title = "✅ You have a new visitor 😏"
            message = f'Say hi to {name} for me'
        self.send_push(title, message)
        self.save_event(title, name)

    def send_push(self, title, message):
        info = self.user_db.all()
        if len(info) == 0:
            return
        user_id = info[0]['user_id']

        url = "https://onesignal.com/api/v1/notifications"
        header = {
            "Content-Type": "application/json; charset=utf-8",
            "Authorization": "Basic " + os.getenv("ONE_SIGNAL_API_KEY")
        }
        payload = {
            "app_id": os.getenv("ONE_SIGNAL_APP_ID"),
            "include_external_user_ids": [user_id],
            "channel_for_external_user_ids": "push",
            "headings": { "en": title },
            "contents": { "en": message }
        }
        req = requests.post(url, headers=header, data=json.dumps(payload))
        print(req.status_code, req.reason)

    def save_event(self, title, face = None):
        type = "face" if face else "motion"
        document = {
            "type": type,
            "name": face,
            "title": title,
            "time": int(time.time())
        }
        self.events_db.insert(document)
        self.purge_db_if_needed()

    def purge_db_if_needed(self):
        if len(self.events_db) > 300:
            all = self.events_db.all()
            first20 = all[-20:]
            self.events_db.truncate()
            self.events_db.insert_multiple(first20)
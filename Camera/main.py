from helpers.apple import AppleAuth
from helpers.errors import Errors
from helpers.token import Token
from flask import request, session
from flask import Flask, Response
from dotenv import load_dotenv
from src.camera import Camera
from threading import Thread
from tinydb import TinyDB, Query
import secrets
import time
import os

# Start camera here if debug server is used:
# Camera.shared().run()
# time.sleep(2)

load_dotenv()
###### Environment Variables: ######
# ONLY_VALID_EMAIL: The apple id, that can access the camera
# APP_BUNDLE_ID: The Bundle ID of the iOS app
# ISSUER: Issuer used in the token (i.e.: jarvis)
# JWT_SECRET_KEY: Secret key used to sign JWT token.
# ONE_SIGNAL_APP_ID: App ID of the OneSignal project.
# ONE_SIGNAL_API_KEY: OneSignal API key to send notifications.

app = Flask(__name__)
app.secret_key = secrets.token_urlsafe(128)

@app.route('/hello')
def hello():
    nonce = secrets.token_urlsafe(128)
    expires = int(time.time()) + (10 * 60)
    session['auth-nonce'] = nonce
    session['auth-nonce-exipres'] = expires
    return {"nonce": nonce}

@app.route('/login', methods=['POST'])
def login():
    body = request.json
    if not body or not 'identityToken' in body:
        return Errors.bad_request, 400
    # Get identity token from request
    idToken = request.json['identityToken']
    # Verify identity token
    try:
        aud = os.getenv("APP_BUNDLE_ID")
        token = AppleAuth().verifyIdentityToken(idToken, aud)
    except Exception as e:
        return Errors.invalid_token, 403
    if session["auth-nonce"] != token["nonce"] or session["auth-nonce-exipres"] < time.time():
        return Errors.invalid_session, 403
    if token["email"] != os.getenv("ONLY_VALID_EMAIL"):
        return Errors.unauthorized, 403
    # Save user id for one signal
    user_db = TinyDB("user.json")
    user_db.truncate()
    user_db.insert({'user_id': token['sub']})
    # Create auth token
    try:
        jwt_auth_token = Token.create(sub=token["email"])
    except Exception as e:
        return Errors.server_error, 500
    return {"token": jwt_auth_token}

@app.route('/stream')
def stream():
    if not Token.authenticate(request):
        return Errors.unauthorized, 403
    draw = request.args.get('draw', default=True, type=bool)
    mime = 'multipart/x-mixed-replace; boundary=frame'
    return Response(Camera.shared().stream(draw), mimetype=mime)

@app.route('/snapshot')
def snapshot():
    if not Token.authenticate(request):
        return Errors.unauthorized, 403
    mime = 'image/jpg'
    return Response(Camera.shared().snapshot(), mimetype=mime)

@app.route('/recognizer', methods=['GET', 'POST'])
def recognizer():
    if not Token.authenticate(request):
        return Errors.unauthorized, 403
    if request.method == 'POST':
        body = request.json
        if body and 'recognizer' in body:
            Camera.shared().recognizer_is_on = body['recognizer']
            return body
        else:
            return Errors.bad_request, 400
    else:
        return {"recognizer": Camera.shared().recognizer_is_on}

@app.route('/detector', methods=['GET', 'POST'])
def detector():
    if not Token.authenticate(request):
        return Errors.unauthorized, 403
    if request.method == 'POST':
        body = request.json
        if body and 'detector' in body:
            Camera.shared().detector_is_on = body['detector']
            return body
        else:
            return Errors.bad_request, 400
    else:
        return {"detector": Camera.shared().detector_is_on}

@app.route('/detector/reset')
def reset():
    if not Token.authenticate(request):
        return Errors.unauthorized, 403
    Camera.shared().reset_motion_detector()
    return {"resetTime": int(time.time())}

@app.route('/events')
def events():
    if not Token.authenticate(request):
        return Errors.unauthorized, 403
    events_db = TinyDB("events.json")
    fromTime = request.args.get('from', default=0, type=int)
    toTime = request.args.get('to', default=64092211200, type=int)
    limit  = request.args.get('limit', default=100, type=int)
    offset = request.args.get('offset', default=0, type=int)
    Event = Query()
    query = (fromTime <= Event.time) and (Event.time <= toTime)
    results = events_db.search(query)
    results.reverse()
    return { "events": results[offset:limit] }
    
# Debug Server:
# app.run(host='0.0.0.0', port=3000, debug=False, threaded=True)


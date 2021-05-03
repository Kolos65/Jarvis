import time
import jwt
import os

class Token:
    @staticmethod
    def create(sub):
        payload = {
            "iss": os.getenv("ISSUER"),
            "exp": int(time.time()) + 60 * 60 * 24 * 7,
            "iat": int(time.time()),
            "sub": sub,
        }
        token = jwt.encode(
            payload,
            os.getenv("JWT_SECRET_KEY"),
            algorithm="HS256"
        )
        return token

    @staticmethod
    def decode(token):
        payload = jwt.decode(
            token,
            os.getenv("JWT_SECRET_KEY"),
            issuer=os.getenv("ISSUER"), 
            algorithms="HS256"
        )
        return payload

    @staticmethod
    def authorize(token):
        try:
            payload = Token.decode(token)
        except Exception as e:
            return False
        return payload["sub"] == os.getenv("ONLY_VALID_EMAIL")

    @staticmethod
    def authenticate(request):
        token = request.headers.get('Authorization')
        return Token.authorize(token)
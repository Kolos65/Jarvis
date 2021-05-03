import jwt
import time
import secrets
import requests

class AppleAuth:
    def __init__(self):
        self.nonce = None
        self.KEY_URL = "https://appleid.apple.com/auth/keys"
        self.ISSUER = "https://appleid.apple.com"
        self.ALG = "RS256"

    def get_apple_public_key(self, kid):
        data = requests.get(self.KEY_URL).json()
        keys = data['keys']
        jwk_key = [x for x in keys if x["kid"] == kid][0]
        public_key = jwt.algorithms.RSAAlgorithm.from_jwk(jwk_key)
        return public_key

    def verifyIdentityToken(self, idToken, aud):
        header = jwt.get_unverified_header(idToken)
        kid = header["kid"]
        public_key = self.get_apple_public_key(kid)
        token = jwt.decode(
            idToken, 
            public_key, 
            audience=aud, 
            issuer=self.ISSUER, 
            algorithms=[self.ALG]
        )
        return token
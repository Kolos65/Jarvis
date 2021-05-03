from main import app
from src.camera import Camera

Camera.shared().run()

if __name__ == "main":
    app.run(debug=False)

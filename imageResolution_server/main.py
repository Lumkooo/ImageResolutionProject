import base64
import json
import cv2
from cv2 import dnn_superres

# from Server import Server
# Server.run()

from flask import Flask, request
app = Flask(__name__)

@app.route('/custom')
def some():
    return "Hello world!"

@app.route('/', methods=['POST'])
def result():
    print("RECEIVED POST")
    image_data = request.form['image_data']
    with open("imageToSave.png", "wb") as imgFile:
        imgFile.write(base64.b64decode(image_data))

    sr = dnn_superres.DnnSuperResImpl_create()
    image = cv2.imread("./imageToSave.png")
    path = "EDSR_x3.pb"
    sr.readModel(path)
    sr.setModel("edsr", 3)
    result = sr.upsample(image)
    cv2.imwrite("./upscaled_image_result.png", result)

    with open("upscaled_image_result.png", "rb") as readed_image:
        im_bytes = readed_image.read()
        im_b64 = base64.b64encode(im_bytes).decode("utf8")
        payload = json.dumps({"image": im_b64})
        return payload

if __name__ == '__main__':
    app.run(port=8080)

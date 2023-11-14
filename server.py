import numpy as np
from . import ImageTransferService

if __name__ == "__main__":
    host = "192.168.0.8"
    RemoteDisplay = ImageTransferService(host)

    # Check remote display is up
    print(RemoteDisplay.ping())

    # Create video caption from webcam
    cap = cv2.VideoCapture(0)
    while True:
        ret, im = cap.read()
        if not ret:
            break
        RemoteDisplay.sendImage(im)

    cap.release()
    cv2.destroyAllWindows()

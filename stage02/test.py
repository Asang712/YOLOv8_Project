from ultralytics import YOLO
model = YOLO('yolov8n.pt')

results = model('bus.jpg')

results[0].show()

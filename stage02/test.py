from ultralytics import YOLO
model = YOLO('yolov8n.pt')

results = model('')

results[0].show()

from ultralytics import YOLO
model = YOLO('yolov8n.pt')

results = model('/home/asang/下载/bus.jpg')

results[0].show()

from pathlib import Path
from ultralytics import YOLO

BASE_DIR = Path(__file__).resolve().parent  # 脚本所在目录，与运行时的当前目录无关
model = YOLO(str(BASE_DIR / 'yolov8n.pt'))

results = model('/home/asang/图片/粘贴的图像.png')

results[0].save(str(BASE_DIR / 'result1.jpg'))  # 保存带检测框的图片到 stage02/
print(f'结果已保存到 {BASE_DIR / "result1.jpg"}')

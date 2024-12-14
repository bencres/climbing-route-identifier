import cv2
import matplotlib.pyplot as plt
from detectron2.config import get_cfg
from detectron2.engine import DefaultPredictor
from detectron2.utils.visualizer import Visualizer
from detectron2.data import MetadataCatalog
from PIL import Image
import os

def detect_climbing_holds(image: Image.Image) -> Image.Image:
    # Get config and weigths for model
    cfg = get_cfg()
    cfg.merge_from_file("api/utils/config/experiment_config.yml")
    cfg.MODEL.WEIGHTS = "api/utils/config/model_final.pth"
    cfg.MODEL.DEVICE='cpu'
    # Set metadata, in this case only the class names for plotting
    MetadataCatalog.get("meta").thing_classes = ["hold", "volume"]
    metadata = MetadataCatalog.get("meta")

    predictor = DefaultPredictor(cfg)

    # img = cv2.imread(image)
    img = image
    outputs = predictor(img)
    v = Visualizer(
        img[:, :, ::-1],
        metadata=metadata
    )

    out_predictions = v.draw_instance_predictions(outputs["instances"].to("cpu"))
    img_holds = out_predictions.get_image()
    return Image.fromarray(img_holds, mode="RGB")

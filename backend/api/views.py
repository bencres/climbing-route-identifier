from django.shortcuts import render
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status
from PIL import Image
import io
from django.http import FileResponse
from .utils.detect_holds import detect_climbing_holds
import cv2
import numpy as np

class ImageProcessingView(APIView):
    parser_classes = (MultiPartParser, FormParser)

    def post(self, request, *args, **kwargs):
        # Check if an image was uploaded
        if 'image' not in request.FILES:
            return Response({"error": "No image file provided"}, status=status.HTTP_400_BAD_REQUEST)

        # Retrieve the uploaded image
        image_file = request.FILES['image']

        try:
            # Open the image using PIL
            with Image.open(image_file) as img:
                # img_bytes = np.asarray(bytearray(img.read()), dtype=np.uint8)
                img_byte_arr = io.BytesIO()
                img.save(img_byte_arr, format='JPEG')
                img_byte_arr = img_byte_arr.getvalue()
                img_array = np.frombuffer(img_byte_arr, dtype=np.uint8)
                cv_img = cv2.imdecode(img_array, cv2.IMREAD_COLOR)
                out_img = detect_climbing_holds(cv_img)
                out_img_io = io.BytesIO()
                out_img.save(out_img_io, format='PNG')
                out_img_io.seek(0)
                return FileResponse(out_img_io, content_type='image/png', filename='detected_holds.png')
                
                
            # img = Image.open(image_file)

            # # Run your image processing script here
            # img = img.convert("L")  # Example: convert to grayscale

            # # Save the modified image to an in-memory file
            # modified_image_io = io.BytesIO()
            # img.save(modified_image_io, format='PNG')
            # modified_image_io.seek(0)

            # # Return the modified image as a response
            # return FileResponse(modified_image_io, content_type='image/png', filename='modified_image.png')
        except Exception as e:
            return Response({"error": str(e)}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

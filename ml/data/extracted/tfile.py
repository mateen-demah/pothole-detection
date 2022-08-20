from os import listdir
import tensorflow as tf

converter = tf.lite.TFLiteConverter.from_saved_model("models/v1")
lite_model = converter.convert()
with open(f"models/v1.tflite", 'wb') as lite_model_file:
    lite_model_file.write(lite_model)
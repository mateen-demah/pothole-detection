import csv
from os import listdir
import numpy as np
import tensorflow as tf
from keras.models import Sequential
from keras.layers import Dense
from numpy.random import shuffle
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score

# def input_func():
#     the_input = {'id':tf.constant(data[1:,0])}
#     for column in len(headers):
#         feature = data[1:, column]
#         the_input[headers[column]] = tf.constant(np.reshape(feature, [np.shape(feature)[0], 1]))
#     return the_input, tf.constant(data[1:, -1])

with open("data/extracted/real1.csv", 'r', newline='') as f:
    # f.readline() # skip headers
    data = csv.reader(f, quoting=csv.QUOTE_NONNUMERIC)
    l = list(data)
    # data = np.array(list(data))
    print(type(l[0][0]))
    print(type(l[1][0]))
# tf.estimator.
# headers = data[0,3:32]
# features = []
# assignment = ""
# for header in len(headers):
#     assignment += f"{'feature'+str(header+1)} = "
data = np.array(l[1:])

# print(type(data[1][0]))
# print(data[1][0])
shuffle(data)
x = data[:, 3:-1]
y = data[:, -1]
# print([type(d) for d in x[2]])


x += abs(np.min(x))
x -= x.mean(axis=0)
x /= x.std(axis=0)
model = Sequential()
model.add(Dense(8, activation='relu', input_shape=(None, np.shape(x)[1])))
model.add(Dense(4, activation='relu'))
model.add(Dense(1, activation='sigmoid'))
# model.build()

# model.summary()
model.compile(loss='binary_crossentropy', optimizer='rmsprop', metrics=['accuracy'])
model.fit(x=x, y=y, epochs=500)
model.save(f"models/v{len(listdir('models/'))+1}.h5")

converter = tf.lite.TFLiteConverter.from_keras_model(model)
lite_model = converter.convert()
with open(f"models/v{len(listdir('models/'))}.tflite", 'wb') as lite_model_file:
    lite_model_file.write(lite_model)


shuffle(data)
x = data[:, 3:-1]
y = data[:, -1]

prediction = model.predict(x)
print(prediction[:5].round())
print(y[:5])
print(f"accuracy: {accuracy_score(y, prediction.round())}")
print(f"precision: {precision_score(y, prediction.round())}")
print(f"recall: {recall_score(y, prediction.round())}")
print(f"f score: {f1_score(y, prediction.round())}")
prediction = prediction.round()
print("a  p")
for i in range(len(y)):
    if y[i] != prediction[i]: print(f"{y[i]}  {prediction[i]}")

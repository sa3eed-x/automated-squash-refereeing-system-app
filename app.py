from flask import Flask, request, jsonify
from keras.models import load_model
import cv2
import random
import numpy as np
import tensorflow as tf
from keras.layers import Dense, Flatten, TimeDistributed, Input, GlobalAveragePooling2D, GlobalAveragePooling1D, \
    MaxPooling3D, Dropout, ConvLSTM2D, Conv2D, MaxPooling2D, LSTM
from keras.models import Sequential, Model




# Specify the height and width to which each video frame will be resized in our dataset.
IMAGE_HEIGHT, IMAGE_WIDTH = 255, 255

# Specify the number of frames of a video that will be fed to the model as one sequence.
SEQUENCE_LENGTH = 20

# Specify the list containing the names of the classes used for training. Feel free to choose any set of classes.
CLASSES_LIST = ["yes_let", "stroke", "no_let"]

# In case of Selecting specific classes
# Define a global variable
global global_var
global_var = CLASSES_LIST


# Function to set the global variable
def set_global_variable(value):
    global global_var
    global_var = value


# Function to get the global variable
def get_global_variable():
    return global_var


seed_constant = 27
np.random.seed(seed_constant)
random.seed(seed_constant)
tf.random.set_seed(seed_constant)


def process_data():
    # Access the global variable from default_module and use it for processing
    global_var = get_global_variable()
    print("Global variable value from process_module:", global_var)
    # Use the global variable for processing...


def create_convlstm_model():
    '''
    This function will construct the required convlstm model.
    Returns:
        model: It is the required constructed convlstm model.
    '''
    global_var = get_global_variable()
    # We will use a Sequential model for model construction
    model = Sequential()

    # Define the Model Architecture.
    ########################################################################################################################

    model.add(ConvLSTM2D(filters=4, kernel_size=(3, 3), activation='tanh', data_format="channels_last",
                         recurrent_dropout=0.2, return_sequences=True, input_shape=(SEQUENCE_LENGTH,
                                                                                    IMAGE_HEIGHT, IMAGE_WIDTH, 3)))

    model.add(MaxPooling3D(pool_size=(1, 2, 2), padding='same', data_format='channels_last'))
    model.add(TimeDistributed(Dropout(0.2)))

    model.add(ConvLSTM2D(filters=8, kernel_size=(3, 3), activation='tanh', data_format="channels_last",
                         recurrent_dropout=0.2, return_sequences=True))

    model.add(MaxPooling3D(pool_size=(1, 2, 2), padding='same', data_format='channels_last'))
    model.add(TimeDistributed(Dropout(0.2)))

    model.add(ConvLSTM2D(filters=14, kernel_size=(3, 3), activation='tanh', data_format="channels_last",
                         recurrent_dropout=0.2, return_sequences=True))

    model.add(MaxPooling3D(pool_size=(1, 2, 2), padding='same', data_format='channels_last'))
    model.add(TimeDistributed(Dropout(0.2)))

    model.add(ConvLSTM2D(filters=16, kernel_size=(3, 3), activation='tanh', data_format="channels_last",
                         recurrent_dropout=0.2, return_sequences=True))

    model.add(MaxPooling3D(pool_size=(1, 2, 2), padding='same', data_format='channels_last'))
    # model.add(TimeDistributed(Dropout(0.2)))

    model.add(Flatten())

    model.add(Dense(len(global_var), activation="softmax"))

    ########################################################################################################################

    # Display the models summary.
    model.summary()
    model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=["accuracy"])
    # Return the constructed convlstm model.
    return model


def create_LRCN_model():
    '''
    This function will construct the required LRCN model.
    Returns:
        model: It is the required constructed LRCN model.
    '''
    global_var = get_global_variable()

    # We will use a Sequential model for model construction.
    model = Sequential()

    # Define the Model Architecture.
    ########################################################################################################################

    model.add(TimeDistributed(Conv2D(16, (3, 3), padding='same', activation='relu'),
                              input_shape=(SEQUENCE_LENGTH, IMAGE_HEIGHT, IMAGE_WIDTH, 3)))

    model.add(TimeDistributed(MaxPooling2D((4, 4))))
    model.add(TimeDistributed(Dropout(0.25)))

    model.add(TimeDistributed(Conv2D(32, (3, 3), padding='same', activation='relu')))
    model.add(TimeDistributed(MaxPooling2D((4, 4))))
    model.add(TimeDistributed(Dropout(0.25)))

    model.add(TimeDistributed(Conv2D(64, (3, 3), padding='same', activation='relu')))
    model.add(TimeDistributed(MaxPooling2D((2, 2))))
    model.add(TimeDistributed(Dropout(0.25)))

    model.add(TimeDistributed(Conv2D(64, (3, 3), padding='same', activation='relu')))
    model.add(TimeDistributed(MaxPooling2D((2, 2))))
    # model.add(TimeDistributed(Dropout(0.25)))

    model.add(TimeDistributed(Flatten()))

    model.add(LSTM(32))

    model.add(Dense(len(global_var), activation='softmax'))

    ########################################################################################################################

    # Display the models summary.
    model.summary()
    # Compile the model.
    model.compile(optimizer='Adam', loss='categorical_crossentropy', metrics=["accuracy"])
    # Return the constructed LRCN model.
    return model


def load_video(video_path, frame_count=SEQUENCE_LENGTH, frame_shape=(255, 255)):
    cap = cv2.VideoCapture(video_path)
    frames = []
    while (len(frames) < frame_count and cap.isOpened()):
        ret, frame = cap.read()
        if not ret:
            break
        # Resize frame to match the expected input shape
        frame = cv2.resize(frame, frame_shape)
        frames.append(frame)
    cap.release()

    # If the video is shorter than frame_count, repeat frames
    while len(frames) < frame_count:
        frames.append(frames[-1])

    # Reshape frames to create a sequence
    video_data = np.array(frames)
    video_data = np.expand_dims(video_data, axis=0)  # Add batch dimension
    return video_data


convlstm_model = create_convlstm_model()
# Display the success message.
print("Convlstm Created Successfully!")


convlstm_model.load_weights("D:/college/grad. project/convlstm_model.h5")

vid = 'D:/college/Mobile/flutter_application_4/assets/NoLet (4).mp4'
video = load_video(vid)

cnn_lstm_predictions1 = convlstm_model.predict(video)[0]



app = Flask(__name__)



@app.route('/')
def predict():
    convlstm_model = create_convlstm_model()
    # Display the success message.
    print("Convlstm Created Successfully!")

    convlstm_model.load_weights("D:/college/grad. project/convlstm_model.h5")

    vid = 'D:/college/Mobile/flutter_application_4/assets/NoLet (3).mp4'
    video = load_video(vid)

    cnn_lstm_predictions1 = convlstm_model.predict(video)[0]
    print(cnn_lstm_predictions1)
    print(np.argmax(cnn_lstm_predictions1))
    arr=cnn_lstm_predictions1.flatten().tolist()
    return jsonify({'predictions': arr[0]})


if __name__ == '__main__':
    app.run(debug=True)

from os import listdir
import csv

from datapoint_classes import PotholeData, RawDataPoint, ExtractedDataPoint

raw_data_dir = './data/raw/'
extracted_data_dir = './data/extracted/'

def next_phole(pothole_data):
    phole = pothole_data.next_phole()
    if phole != "empty": phole = float(phole)
    return phole

with open('extracted_sessions.txt', 'r', encoding='utf-8') as extracted_sessions:
    extracted_sessions = extracted_sessions.readlines()
 
raw_data_files = listdir(raw_data_dir)    
for filename in raw_data_files:
    session_id = filename.split('_')[0]
    potholes_data_exist = (session_id + "_potholes.csv") in raw_data_files
    ramps_data_exist = (session_id + "_ramps.csv") in raw_data_files
    
    if session_id not in extracted_sessions:  
        data_window = []
        
        # if potholes_data_exist:
        pothole_data = PotholeData(session_id)
        phole = next_phole(pothole_data)
            
        with open(raw_data_dir + session_id + '_sensordata.csv', 'r', encoding='utf-8', newline='') as sensordata_file:
            sensordata_file.readline() # skip headers
            sensordata = csv.reader(sensordata_file)
            extracted_file = open(extracted_data_dir + session_id + '.csv', 'w', encoding='utf-8', newline='')
            extracted_data = csv.writer(extracted_file, quoting=csv.QUOTE_NONNUMERIC)
            
            extracted_data.writerow(('timestamp', 'latitude', 'longitude',
                    'avg_acc_x', 'avg_acc_y', 'avg_acc_z',
                    'avg_gyro_x', 'avg_gyro_y', 'avg_gyro_z',
                    'avg_speed',
                    'std_acc_x', 'std_acc_y', 'std_acc_z',
                    'std_gyro_x', 'std_gyro_y', 'std_gyro_z',
                    'std_speed',
                    'max_acc_x', 'max_acc_y', 'max_acc_z',
                    'max_gyro_x', 'max_gyro_y', 'max_gyro_z',
                    'max_speed',
                    'min_acc_x', 'min_acc_y', 'min_acc_z',
                    'min_gyro_x', 'min_gyro_y', 'min_gyro_z',
                    'min_speed',
                    'label'))
            for row in sensordata:
                data_window.append(RawDataPoint(list(map(lambda x: float(x), row[:-2]))))
                if len(data_window) < 5: continue
                else:
                    extracted_data_point = ExtractedDataPoint(data_window, phole)
                    extracted_data.writerow(extracted_data_point.toList())
                    data_window = data_window[3:]
                    if extracted_data_point.phole_success: phole = next_phole(pothole_data)
                        
            pothole_data.close_file()
            extracted_file.close()
    raw_data_files.remove(session_id + "_sensordata.csv")
    if potholes_data_exist: raw_data_files.remove(session_id + "_potholes.csv")
    if ramps_data_exist: raw_data_files.remove(session_id + "_ramps.csv")
    with open('extracted_sessions.txt', 'w', encoding='utf-8') as extracted_sessions:
        extracted_sessions.write(session_id+'\n')
        
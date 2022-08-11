from typing import List
from statistics import pstdev

class RawDataPoint:
    def __init__(self, data_row:list) -> None:
        self.timestamp = data_row[0]
        self.latitue, self.longitude = data_row[1], data_row[2]
        self.accelerometer_x = data_row[3]
        self.accelerometer_y = data_row[4]
        self.accelerometer_z = data_row[5]
        self.gyroscope_x = data_row[6]
        self.gyroscope_y = data_row[7]
        self.gyroscope_z = data_row[8]
        self.speed = data_row[9]
        self.speed_accuracy = data_row[10]
         
class ExtractedDataPoint:
    def __init__(self, raw_datapoints:List[RawDataPoint], phole) -> None:
        accelerometer_x_values = tuple(map(lambda x: x.accelerometer_x, raw_datapoints))
        accelerometer_y_values = tuple(map(lambda x: x.accelerometer_y, raw_datapoints))
        accelerometer_z_values = tuple(map(lambda x: x.accelerometer_z, raw_datapoints))
        gyroscope_x_values = tuple(map(lambda x: x.gyroscope_x, raw_datapoints))
        gyroscope_y_values = tuple(map(lambda x: x.gyroscope_y, raw_datapoints))
        gyroscope_z_values = tuple(map(lambda x: x.gyroscope_z, raw_datapoints))
        speed_values = tuple(map(lambda x: x.speed, raw_datapoints))
        
        self.timestamp = raw_datapoints[-1].timestamp
        self.latitude = raw_datapoints[2].latitue
        self.longitude = raw_datapoints[2].longitude
        if phole != "empty" and (self.timestamp - 400) <= phole <= (self.timestamp+400): self.label = 1
        else: self.label = 0
        self.phole_success = bool(self.label)
        
        self.avg_acc_x = sum(accelerometer_x_values)/5
        self.avg_acc_y = sum(accelerometer_y_values)/5
        self.avg_acc_z = sum(accelerometer_z_values)/5
        self.avg_gyro_x = sum(gyroscope_x_values)/5
        self.avg_gyro_y = sum(gyroscope_y_values)/5
        self.avg_gyro_z = sum(gyroscope_z_values)/5
        self.avg_speed = sum(speed_values)/5

        self.std_acc_x = pstdev(accelerometer_x_values)
        self.std_acc_y = pstdev(accelerometer_y_values)
        self.std_acc_z = pstdev(accelerometer_z_values)
        self.std_gyro_x = pstdev(gyroscope_x_values)
        self.std_gyro_y = pstdev(gyroscope_y_values)
        self.std_gyro_z = pstdev(gyroscope_z_values)
        self.std_speed = pstdev(speed_values)
        
        self.max_acc_x = max(accelerometer_x_values)
        self.max_acc_y = max(accelerometer_y_values)
        self.max_acc_z = max(accelerometer_z_values)
        self.max_gyro_x = max(gyroscope_x_values)
        self.max_gyro_y = max(gyroscope_y_values)
        self.max_gyro_z = max(gyroscope_z_values)
        self.max_speed = max(speed_values)
        
        self.min_acc_x = min(accelerometer_x_values)
        self.min_acc_y = min(accelerometer_y_values)
        self.min_acc_z = min(accelerometer_z_values)
        self.min_gyro_x = min(gyroscope_x_values)
        self.min_gyro_y = min(gyroscope_y_values)
        self.min_gyro_z = min(gyroscope_z_values)
        self.min_speed = min(speed_values)
        
    def toList(self):
        return (self.timestamp, self.latitude, self.longitude,
                self.avg_acc_x, self.avg_acc_y, self.avg_acc_z,
                self.avg_gyro_x, self.avg_gyro_y, self.avg_gyro_z,
                self.avg_speed,
                self.std_acc_x, self.std_acc_y, self.std_acc_z,
                self.std_gyro_x, self.std_gyro_y, self.std_gyro_z,
                self.std_speed,
                self.max_acc_x, self.max_acc_y, self.max_acc_z,
                self.max_gyro_x, self.max_gyro_y, self.max_gyro_z,
                self.max_speed,
                self.min_acc_x, self.min_acc_y, self.min_acc_z,
                self.min_gyro_x, self.min_gyro_y, self.min_gyro_z,
                self.min_speed,
                self.label)
        
class PotholeData:
    def __init__(self, session_id) -> None:
        self.potholes_file = open('./data/raw/' + session_id + "_potholes.csv", 'r', encoding='utf-8', newline='')
        self.potholes_file.readline() # skip headers
        # self.phole = self.next_phole
        
    def next_phole(self):
        return next(self.potholes_file, "empty").split(',')[0]
    
    def close_file(self):
        self.potholes_file.close()
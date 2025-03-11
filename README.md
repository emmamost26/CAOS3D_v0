# CAOS3D_v0
Code for calibrating a robot to a camera system and registering a scene with high precision.  
This project includes modules for camera calibration, scene registration and various utility functions.
The code was used to acquire a pilot ground truth dataset of a pig spine that can be used to train and evaluate 3D reconstruction methods.
The link and download instructions to the pilot dataset are provided under the section Pilot Dataset.

## Table of Contents
- Overview
- Features
- Installation
- Usage
- Dependencies
- Pilot dataset
- Contributing

## Overview
This repository provides MATLAB functions and scripts to calibrate a robot to a camera mounted on its end effector and register images to a scanned scene with accuracy. 
The code was developed with high-resolution and high-precision requirements in mind, aiming to support surgical robotics applications. More precisely, the code was written
with the intention of acquiring datasets to develop, train and evaluate 3D reconstruction datasets for orthopedic surgery.

## Features
Calibration: Intrinsics and extrinsics calibration for the camera as well as solving the robot-camera calibration problem.  
Registration: Tools for registering scene images together with a scan of the scene containing spherical markers.  
utils: Helper scripts to streamline tasks, such as conversions, data transformation and visualization.  

## Installation
Clone the repository:
```bash
git clone https://github.com/emmamost26/CAOS3D_v0.git 
cd CAOS3D_v0
```

Open MATLAB and add the repository folder to your MATLAB path.

## Usage
### Robot-Camera Calibration:
Run calibration_main.m in the Calibration folder to perform camera calibration.
### Scene Registration:
Use registration_main.m in the Registration folder to align determine the relative pose between the local scene reference frame and the camera pose reference frame.

Before running the code, the folders should have following structure:  
CamSceneRegistration/  
├── Calibration/  
│   ├── calibration_main.m  
│   ├── calibration_functions/  
│   │   ├── functions used in calibration_main.m   
│   ├── calibration_data/  
│   │   ├── images/  
│   │   └── robot_poses.csv  
│   └── calibration_output/  
├── Registration/  
│   ├── registration_main.m  
│   ├── registration_functions/  
│   │   ├── functions used in registration_main.m  
│   ├── registration_data/  
│   │   ├── images/  
│   │   ├── ellipse_params.mat  
│   │   ├── sfm_poses.csv  
│   │   └── robot_poses.csv  
│   └── registration_output/  
├── utils/  
│   ├── all the utility functions  
└── README.md  

## Dependencies
- MATLAB (R2024a or later)
- MATLAB Computer Vision Toolbox version 24.1 (for camera calibration)
- MATLAB Image Processing Toolbox version 24.1
- Robotic Systems Toolbox version 24.1
- Statistics and Machine Learning Toolbox version 24.1

## Pilot Dataset
- The dataset can be downloaded following the instructions in the "Azure_storage_explorer" using the following link (including BlobEndPoint):
  BlobEndpoint=https://rocs4.blob.core.windows.net/;QueueEndpoint=https://rocs4.queue.core.windows.net/;FileEndpoint=https://rocs4.file.core.windows.net/;TableEndpoint=https://rocs4.table.core.windows.net/;SharedAccessSignature=sv=2022-11-02&ss=bfqt&srt=sco&sp=rlx&se=2030-01-29T21:09:56Z&st=2025-01-29T13:09:56Z&spr=https&sig=c7ijclakri52SXDtc%2FKmlCjcotFQ9qTmxN%2Brz4zHMYs%3D

## Contributing
Contributions are welcome! Please fork the repository, make changes, and submit a pull request. Ensure that you update the documentation for any new features or changes.

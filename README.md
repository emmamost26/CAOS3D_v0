# CAOS3D_v0: Acquiring submillimeter-accurate multi-task vision datasets for computer-assisted orthopedic surgery

**Authors:** Emma Most · Jonas Hein · Frédéric Giraud · Nicola A. Cavalcanti · Lukas Zingg · Baptiste Brument · Nino Louman · Fabio Carrillo · Philipp Fürnstahl · Lilian Calvet  
**Conference:** IPCAI 2025

<p align="left">
  <a href="https://doi.org/10.1007/s11548-025-03385-2"><img src="https://img.shields.io/badge/📄%20Read%20the%20paper-10.1007/s11548--025--03385--2-blue" alt="Paper"></a>
  <a href="#citation"><img src="https://img.shields.io/badge/📚%20Citation-Refer%20Below-orange" alt="Citation"></a>
</p>

---

## Table of Contents

- [Introduction](#introduction)
- [Dataset](#dataset)
- [Acquisition Setup](#acquisition-setup)
- [Citation](#citation)

---

## Introduction

Brief overview of the dataset and goals of the paper...

## Dataset

Insert a few dataset sample images like this:

```html
<img src="images/sample1.jpg" width="300"/> <img src="images/sample2.jpg" width="300"/>


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

## Citation
<h2 id="citation">Citation</h2> <pre><code>@article{Most2025, author = {Emma Most and Jonas Hein and Frédéric Giraud and Nicola A. Cavalcanti and Lukas Zingg and Baptiste Brument and Nino Louman and Fabio Carrillo and Philipp Fürnstahl and Lilian Calvet}, title = {Acquiring submillimeter-accurate multi-task vision datasets for computer-assisted orthopedic surgery}, journal = {International Journal of Computer Assisted Radiology and Surgery}, volume = {20}, number = {6}, pages = {1293--1300}, year = {2025}, doi = {10.1007/s11548-025-03385-2}, url = {https://doi.org/10.1007/s11548-025-03385-2} }</code></pre>

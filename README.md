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
- [Installation](#installation)
- [Dataset](#dataset)
- [Acquisition Setup](#acquisition-setup)
- [Citation](#citation)

---

## Introduction

Advances in computer vision, particularly in optical image-based 3D reconstruction and feature matching, enable applications like marker-less surgical navigation and digitization of surgery. However, their development is hindered by a lack of suitable datasets with 3D ground truth. This work explores an approach to generating realistic and accurate ex vivo datasets tailored for 3D reconstruction and feature matching in open orthopedic surgery.

This repository contains the code used for registering the scanned 3D mesh of the visible anatomy and the posed images, as described in the paper. It also includes code for calibrating a robot with a camera system mounted on its end effector and evaluating the proposed method. The code was developped with high-resolution and high-precision requirements in mind and was used to acquire a pilot ground truth dataset of a pig spine that can be used to train and evaluate 3D reconstruction methods. The link and download instructions to the pilot dataset are provided under the section Pilot Dataset.

### Features
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

### Dependencies
- MATLAB (R2024a or later)
- MATLAB Computer Vision Toolbox version 24.1 (for camera calibration)
- MATLAB Image Processing Toolbox version 24.1
- Robotic Systems Toolbox version 24.1
- Statistics and Machine Learning Toolbox version 24.1

## Pilot Dataset
- The dataset can be downloaded following the instructions in the "Azure_storage_explorer" using the following link (including BlobEndPoint):
  BlobEndpoint=https://rocs4.blob.core.windows.net/;QueueEndpoint=https://rocs4.queue.core.windows.net/;FileEndpoint=https://rocs4.file.core.windows.net/;TableEndpoint=https://rocs4.table.core.windows.net/;SharedAccessSignature=sv=2022-11-02&ss=bfqt&srt=sco&sp=rlx&se=2030-01-29T21:09:56Z&st=2025-01-29T13:09:56Z&spr=https&sig=c7ijclakri52SXDtc%2FKmlCjcotFQ9qTmxN%2Brz4zHMYs%3D

## Citation
<h2 id="citation">Citation</h2> <pre><code>@article{Most2025, author = {Emma Most and Jonas Hein and Frédéric Giraud and Nicola A. Cavalcanti and Lukas Zingg and Baptiste Brument and Nino Louman and Fabio Carrillo and Philipp Fürnstahl and Lilian Calvet}, title = {Acquiring submillimeter-accurate multi-task vision datasets for computer-assisted orthopedic surgery}, journal = {International Journal of Computer Assisted Radiology and Surgery}, volume = {20}, number = {6}, pages = {1293--1300}, year = {2025}, doi = {10.1007/s11548-025-03385-2}, url = {https://doi.org/10.1007/s11548-025-03385-2} }</code></pre>

### Contributing
Contributions are welcome! Please fork the repository, make changes, and submit a pull request. Ensure that you update the documentation for any new features or changes.

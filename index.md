# Acquiring submillimeter-accurate multi-task vision datasets for computer-assisted orthopedic surgery

**Authors:** Emma Most, Jonas Hein, Frédéric Giraud, Nicola A. Cavalcanti, Lukas Zingg, Baptiste Brument, Nino Louman, Fabio Carrillo, Philipp Fürnstahl and Lilian Calvet
**Conference:** IPCAI 2025

[📄 Read the paper](https://rdcu.be/el5Jj)  
[💻 Code on GitHub](https://github.com/emmamost26/CAOS3D_v0)  
[📚 Citation](#citation)

---

## Abstract

Advances in computer vision, particularly in optical image-based 3D reconstruction and feature matching, enable applications like marker-less surgical navigation and digitization of surgery. However, their development is hindered by a lack of suitable datasets with 3D ground truth. This work explores an approach to generating realistic and accurate ex vivo datasets tailored for 3D reconstruction and feature matching in open orthopedic surgery. A set of posed images and an accurately registered ground truth surface mesh of the scene are required to develop vision-based 3D reconstruction and matching methods suitable for surgery. We propose a framework consisting of three core steps and compare different methods for each step: 3D scanning, calibration of viewpoints for a set of high-resolution RGB images, and an optical method for scene registration. We evaluate each step of this framework on an ex vivo scoliosis surgery using a pig spine, conducted under real operating room conditions. A mean 3D Euclidean error of 0.35 mm is achieved with respect to the 3D ground truth. The proposed method results in submillimeter-accurate 3D ground truths and surgical images with a spatial resolution of 0.1 mm. This opens the door to acquiring future surgical datasets for high-precision applications.

---

## Introduction

Advances in computer vision, especially in 3D reconstruction and feature matching are opening the door to various applications in computer assisted orthopedic surgery like marker-less surgical navigation, surgical digital twins and robotic assisted surgery. Evaluating and training these methods motivates the need to acquire large, accurate, and real datasets with 3D ground truth. While suitable datasets exist for indoor and outdoor scenes, there currently does not exist a dataset with posed images and 3D ground truth of real surgical scenes with submillimeter accuracy.

---

### 📊 Dataset Samples

<img src="assets/rgb_and_depth.jpg" alt="RGB image sample and depth map" width="600">

> This figure presents a sample from our dataset and the corresponding depth map obtained from our submillimeter accurate 3D ground truth.

---

### 🛠️ Acquisition Setup

Our setup consists of a specimen fixated onto a wooden board, placed on an operating table, along with a set of 10 spherical registration markers. A clinician makes an incision that is kept open with k- wires. Experiments were made in a fully equipped operating room replica (https://or-x.ch/) to allow for realistic illumination conditions.

<img src="assets/setup.jpg" alt="Acquisition setup" width="600">

---

<video width="600" controls>
  <source src="assets/acquisition.mp4" type="video/mp4">
  Your browser does not support the video tag.
</video>

---

<h2 id="citation">Citation</h2>

<pre><code>@article{Most2025,
  author  = {Emma Most and Jonas Hein and Frédéric Giraud and Nicola A. Cavalcanti and Lukas Zingg and Baptiste Brument and Nino Louman and Fabio Carrillo and Philipp Fürnstahl and Lilian Calvet},
  title   = {Acquiring submillimeter-accurate multi-task vision datasets for computer-assisted orthopedic surgery},
  journal = {International Journal of Computer Assisted Radiology and Surgery},
  volume  = {20},
  number  = {6},
  pages   = {1293--1300},
  year    = {2025},
  doi     = {10.1007/s11548-025-03385-2},
  url     = {https://doi.org/10.1007/s11548-025-03385-2}
}</code></pre>

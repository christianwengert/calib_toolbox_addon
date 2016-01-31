Paper: Fully Automatic Endoscope Calibration for Intraoperative Use
===
Christian Wengert, Mireille Reeff, Philippe C. Cattin, Gabor Székely

Bildverarbeitung für die Medizin

Hamburg, March 2006
Abstract
---
As of today endoscopes have been only used as a keyhole to look inside the human body. Our goal is to enhance the endoscope to a full imaging device providing better quantitative and qualitative data. Possible applications for such an enhanced endoscope are referencing, navigation and 3D visualization during endoscopic surgery. To obtain accurate results, a reliable and fully automatic calibration method for the endoscopic camera has been developed which can be used within the operating room (OR). Special care has been taken to ensure robustness against inevitable distortions and inhomogeneous illumination.

[Download in pdf format](http://www.vision.ee.ethz.ch/en/publications/papers/proceedings/eth_biwi_00381.pdf)


```latex

@InProceedings{eth_biwi_00381,
  author = {Christian Wengert and Mireille Reeff and Philippe C. Cattin and Gabor Székely},
  title = {Fully Automatic Endoscope Calibration for Intraoperative Use},
  booktitle = {Bildverarbeitung für die Medizin},
  year = {2006},
  month = {March},
  pages = {419-23},
  publisher = {Springer-Verlag},
  keywords = {Camera calibration, endoscope}
}
```



Code: A fully automatic camera and hand eye calibration 
---

Unluckily the original documentation got lost, so I refer the reader/user to the source code

This is two add-ons for this camera calibration toolbox for Matlab. The first part covers a fully automatic calibration procedure and the second covers the calibration of the camera to a robot-arm or an external marker (known as Hand-Eye claibration). 


Entry points are:

* autocalib.m
* handeye.m
 



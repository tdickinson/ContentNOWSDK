# ContentNOWSDK
ContentNOW SDK Installation Instructions

This repository contains an iOS framework that can be used with 1WorldSync's ContentNOW API.  In order to deploy as a framework, iOS8 is required.
The source code is included as part of this repository as well should you want to repurpose it. 

1.	Download the source from this repository.
2.	This SDK leverages RestKit, which can be installed using Cocoapods, found at https://cocoapods.org.   
	a.	You will need to install RestKit to your existing application.  Downloads and instructions can be found at:  http://restkit.tumblr.com.
	b.	Alternatively, once you have installed cocoapods you can copy the podfile included here into the root directory of your application and run it from the command line using “pod install.” 
3.	In the Target for your compiled project, under “Build Settings” make sure that “Allow Non-modular includes in Framework Modules” is set to “Yes”.  This will allow the Framework to access RestKit.
4.	In the Target for your compiled project, under “General,” add ContentNOWSDK.framework as an Embedded Binary.  
5.	You should now be able compile the application.  

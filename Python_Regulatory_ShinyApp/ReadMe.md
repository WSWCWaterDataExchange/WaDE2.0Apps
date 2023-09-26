# Shiny with Python Documentation

## Libraries Used:

Library | Use | Install Link
--- | --- | ---
Shiny | Library to build and run the app  | https://shiny.posit.co/py/docs/install.html 
Ipyleaflet | Library to include maps and display data | https://ipyleaflet.readthedocs.io/en/latest/installation/index.html 
Geopandas | Library to read in shapefile data and contains geometry data | https://pypi.org/project/geopandas/ 
Pandas | Library to more easily organize database | https://pandas.pydata.org/docs/getting_started/install.html 
Numpy | Library to run basic command functions | https://numpy.org/install/ 
Rsconnect-python | Library used to connect to shiny.io server and deploy app | https://docs.posit.co/shinyapps.io/getting-started.html#working-with-shiny-for-python 

## How it is Built
The Shiny app in python has two parts: a “ui” portion and a “server” portion. Each of the two parts must be defined separately and the corresponding code will need to be separated into the different defined sections.  

### UI:
The ui portion of the code determines the front-end portion of the app and how the users will see the page. It includes the which items will appear where on the page. Any text to include with its corresponding fonts, colors, and text sizes are included here. Additionally, interactive tools can be inserted such as sliders, selection boxes, check boxes, etc. It is also here that the map can be inserted.  
https://shiny.posit.co/py/docs/overview.html 

The basic code in the ui section can split up the page into different sections. The start of the code generally begins with `ui.page_fluid()` and will contain the code for the entire page within the parentheses. Once the page has been created with `ui.page_fluid()`, the page can be broken up into sections using `ui.row()` and `ui.column()` to insert different items and create the desired layout. Each row or column does not need to look like all of the others. For example, the first row could have 2 columns while the second row could have 3 or more.  
https://shiny.posit.co/py/docs/ui-page-layouts.html 

Once the layout of the page has been created, items can be included by using various different operators. The most important operators of note are the interactive operators. Selection tabs, check boxes, sliders, and much more can be included here using operators such as `ui.input_slider()`, or `ui.input_select()`. 
https://shiny.posit.co/py/docs/inputs.html 

It is important to note that all the items included in the ui portion of the code will not have any interactive functionality. Instead, this portion of the code is more of a layout of what the user will see when they use the tool.  

### Server:
The server portion of the app defines the back-end elements and determines interactions on the ui. The server links the interactions between the various ui items and tells each item what to do when the user clicks on an interactive item.  

In the ui portion, the interactive items use operators such as `ui.input_slider()` and the first argument in each of these items will be the name that is given to that operator. Using `@reactive.Effect` and then defining that effect will start any interaction that is being created. Within this function that is being defined, the ui input item must be referenced. This is done using the code input.title, where “title” is the name that was given as the first argument of the item in the ui section. Using that as a reference, the interactions can then be built. 
https://shiny.posit.co/py/docs/reactive-programming.html 

## Data:
When creating the app, the app must be contained within a directory. Inside of that same directory, the data must be included in another directory. It is important that the data directory can be found inside of the same directory as the app.  

## Posting the App to shinyapps.io Web Service:
https://docs.posit.co/shinyapps.io/getting-started.html#working-with-shiny-for-python 
To deploy the app, the library rsconnect-python will need to be installed. In the link provided above, section 2.2 has more information on installing that package. Additionally, the username and password for WSWC’s shiny.io account will be needed. To link the app to the shiny.io server, follow the steps in 2.2.2.1 method 1 in the documentation. Make sure to copy the code for Shiny with Python and not for R.  

Copy and paste the code into a new terminal. Make sure it is run in a separate terminal from the terminal that runs the app, since that app terminal is busy (it will not be able to run both at the same time). Once the code has been run successfully, proceed to step 2.2.2.2 and copy the code provided. Make sure that for `<NAME>`, the name provided by copying the code in 2.2.2.1 is used. In this case, the code should look like:  

`rsconnect deploy shiny /path/to/app --name waterdataexchangewswc --title my-app` 

Include the correct path and create a title for the app as well and include those in that line of code. Run this in the terminal and wait for it to post to the Shiny server. 

One important error possibility is that it is being run through a version of anaconda that is too recent. The Shiny.io server cannot support apps that are being run through any version of anaconda that is not version 1.1.1 or 1.2.2. To get around this, make sure that the app is being run on the local machine through python alone and not through anaconda. 
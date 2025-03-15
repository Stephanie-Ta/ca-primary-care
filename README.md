# Canadian Primary Care Tracker
Author/Developer: Stephanie Ta

Explore the trends and demographics of Canadian primary care workers from 2019-2023!
Visit the dashboard [here](https://stephanie-ta.shinyapps.io/ca-primary-care/).

## Motivation


## App Description


## Local Usage
This project uses a `renv` virtual environment to manage packages and dependencies!
Please have `renv` installed (`install.packages("renv")`) if you wish to run the app locally.

1. Clone this GitHub repository to your local machine:
   - Click the green `<> Code` button and copy the url.
   - Navigate to where you'd like the cloned repository to reside in your local machine via the terminal.
   - Run the command `git clone <url>` in the terminal.

2. Open RStudio and navigate to the project directory in RStudio. Open the project by clicking the `Project` dropdown, selecting `Open Project...`, navigating to the project directory in the pop up, and selecting the `ca-primary-care` R Project file.

> ![](img/open-project.png | width=30%)
> ![](img/select-project.png | width=30%)

1. Create a `renv` virtual environment by running `renv::restore()` in the R console of RStudio. This will install the packages listed in the `renv.lock` file in a `renv` virtual environment.

2. Navigate to and open `src/app.py` in RStudio. Run the app locally by clicking the `▶ Run App` button.

> ![](img/run-app-button.png | width=75%)
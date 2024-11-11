## Call for Contributions: Data Quality Tools

We are inviting contributions to enhance learning resources and tools focused on data quality. Our goal is to gather, curate, and share scripts, metrics, and other relevant tools that are currently lying around in your projects, waiting to be made available to a broader audience.

### Contribution Process

We have a simple 3-step process to guide you through the contribution process. Follow the steps below to get started.

:::: { .panel-tabset }

### Step 1: Identify Your Project

Identify any scripts, metrics, or other learning resources that are related to data quality but have not been published yet. This could be:

- Tools or scripts lying around in your projects that need publishing
- Data quality resources or libraries that need better marketing
- Method you would like to share within GESIS and beyond
- You should reflect whether you are willing to make the project public and open source!

Consider any projects where these resources could help others enhance their understanding or application of data quality metrics.

### Step 2: Contact Us

Once you have identified your project, reach out to a contact at GESIS to determine if your project can be supported by the **KODAQS Toolbox**.

- Contact: Fabienne Krämer
- Email: fabienne.kraemer@gesis.org
- Phone: +49(621)1246-580

The GESIS team will provide information on how your project can benefit from the visibility of the KODAQS Toolbox.

### Step 3: Set Up Your Repository

After receiving confirmation from GESIS, it's time to set up a GitHub repository based on one of the following example templates:

- [Quarto File](https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats-units) (recommended): the newer version of R-Markdown can be used easily with renaming your .rmd to .qmd
  - entrypoint file should be called index.qmd
  - install.R (add your install.packages("package")) code here
  - runtime.txt (add your R-version here, i.e. r-4.3.1-2023-06-16)
  - add this [file](https://github.com/GESIS-Methods-Hub/minimal-example-qmd-rstats-units/blob/main/postBuild) for some technical reasons you don't want to know. Don't have Windows add .txt to it!
  - add author, image and image-alt fields to your [quarto metadata](https://quarto.org/docs/authoring/front-matter.html)
- [Jupyter Notebooks](https://github.com/GESIS-Methods-Hub/minimal-example-ipynb-python-gpt2): you have some practical code that you want to publish on GESIS binder for handsOn work?
- [Many More Input Templates](https://github.com/GESIS-Methods-Hub): have a look at GESIS Methods-Hub templates for what is possible

Customize the repository as needed, adding your tools, scripts, or resources using our [guidelines](https://github.com/GESIS-Methods-Hub/method-guidelines/blob/main/tutorial-template.md). Once the repository is ready:

- Email **fabienne.kraemer@gesis.org** with the subject line: "Repository Ready for Integration"
- Include the link to your GitHub repository in the email.

The KODAQs team will take care of the rest, ensuring your contribution is integrated into the Toolbox.

::::

### Ready to Contribute?

If you’re ready to contribute or need more information, feel free to reach out to the contact information provided in Step 2. We look forward to collaborating with you to enhance data quality learning resources!


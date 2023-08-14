# GitHub -> MotherDuck pipeline  
  
This is a repo accompanying [this](link-to-blog) blog.  
  
The GitHub API exists as a [verified source for dlt](https://dlthub.com/docs/dlt-ecosystem/verified-sources/github). Using the GitHub verified source, you can load data on issues, pull requests, reactions, and comments from any GitHub repository. 
  
This repository contains a modified version of the existing source: in addition to the above data, it can also load data on stargazers for the specified GitHub repository.

## How to run this pipeline:  
  
1. Clone this repo.  
2. Inside the folder `.dlt`, create a file called `secrets.toml` and add your GitHub access token as below:  
    ```toml
    [sources.github]
    access_token = "add your access token" # please set me up!
    ```
    See [here](https://dlthub.com/docs/dlt-ecosystem/verified-sources/github#setup-guide) for more details.  
3. By default, the existing code loads data from the `dlt` GitHub repo. To change this to instead load data for a different repo, modify `github_pipeline.py` as follows:  
    Inside `load_dlthub_all_data` change `data = github_reactions("dlt-hub", "dlt")` by replacing `"dlt-hub"` and `"dlt"` with the owner and repository name of your GitHub repo.

4. Install requirements:  
```pip install -r requirements.txt```
5. Run the pipeline:  
```python github_pipeline.py```  
  
This will load all data on issues, comments, reactions, pull requests, and stargazers for your GitHub repo into MotherDuck and perform all the specified dbt transformations. 
  
### Deploying this pipeline  
  
After running this pipeline successfully, you can deploy this pipeline as follows:  
1. Create a GitHub repository for your `dlt` project if not already created.  
2. Run `dlt deploy --schedule "0 0 1 * *" github_pipeline.py github action`  
    This will schedule your pipeline to run on the first day of every month. 
3. Finally add and commit your files and push them to GitHub  
    `git add . && git commit -m 'pipeline deployed with github action'`  
    `git push origin`

See [here](https://dlthub.com/docs/walkthroughs/deploy-a-pipeline/deploy-with-github-actions) for details.  
  
## How this pipeline was created  

This pipeline was created using the GitHub -> DuckDB pipeline: see [here](https://github.com/dlt-hub/github-motherduck/tree/master/github_duckdb) for full details. 
  
To create a GitHub -> MotherDuck pipeline, follow all the steps detailed in the link, but instead of passing 'duckdb' as a destination, pass 'motherduck' as a destination. Also add MotherDuck credentials inside `.dlt/secrets.toml` as above.  

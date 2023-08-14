# GitHub -> DuckDB pipeline  

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
```python bigquery.py```  
  
This will create a file called `github.duckdb` in your working directory which will contain the loaded and transformed data.

## How this pipeline was created:

This pipeline was created by modifying the existing GitHub verified source and adding some dbt transformations.  

1. Install `dlt`:  
    ```pip install dlt```  
2. Create a `dlt` project using `dlt init github duckdb`. This will create a directory with the structure: 
    ```
    ├── .dlt
    │   ├── config.toml
    │   └── secrets.toml
    ├── github
    │   ├── __init__.py
    │   ├── helpers.py
    │   ├── queries.py
    │   ├── README.md
    │   └── settings.py
    ├── github_pipeline.py
    └── requirements.txt
    ```  
3. Inside the folder `.dlt/secrets.toml` add your GitHub access token as below:  
    ```
    [sources.github]
    access_token = "add your access token" # please set me up!
    ```
    See [here](https://dlthub.com/docs/dlt-ecosystem/verified-sources/github#setup-guide) for more details.  
4. Modify `github/__init__.py`:  
    1. Add a resource function to fetch data on stargazers. The following python function will request data on stargazers from the GitHub API and return the output:  
    ```
    @dlt.resource(write_disposition="replace")
    def stargazers(owner, repo):
        url = f"https://api.github.com/repos/{owner}/{repo}/stargazers"
        headers = {"Accept": "application/vnd.github.v3.star+json"}

        while url:
            response = requests.get(url, headers=headers)
            response.raise_for_status()  # raise exception if invalid response
            users = response.json()
            for user in users:

                row = {'starred_at': user['starred_at'],
                    'user': user['user']['login'],
                    }
                yield row

            if 'link' in response.headers:
                if 'rel="next"' not in response.headers['link']:
                    break

                url = response.links['next']['url']  # fetch next page of stargazers
            else:
                break
            time.sleep(2)  # sleep for 2 seconds to respect rate limits
    ```
    2. The main script will be calling the source function `github_reactions`. This function returns all data on issues and pull requests. Simply configure this function to also return stargazers data by adding `dlt.resource(stargazers(owner,name))` (defined above) to the return statement.  
5. Modify `github_pipeline.py`:  
    The function `load_dlthub_dlt_all_data` fetches all data on issues and pull requests from the specified directory. With the modification made above, it will also fetch data on stargazers. Simply uncomment this function in the main block of the script:  
    ```
    if __name__ == "__main__":

    # load all data on issues, comments, PRs, reactions, and stargazers
    load_dlthub_dlt_all_data()
    ```

6. Finally, run the pipeline using `python github_pipeline.py`. This will create a file `github.duckdb` in your working directory containing the data fetched from the GitHub API.

### Creating a dbt project  
  
You can integrate dbt directly into the pipeline created above:  
  
1. Install dbt using `pip install dbt-duckdb`  
2. Create a dbt project inside the `dlt` project using `dbt init dbt_github`  
3. Add your model inside the dbt project as usual. The transformations are going to be done on the data loaded by `dlt`, and hence the dataset and table names should match those of the .duckdb file created above.  
4. Add the `dlt` dbt runner inside `github_pipeline.py` (See [here](https://dlthub.com/docs/dlt-ecosystem/transformations/dbt#how-to-use-the-dbt-runner) for details)  
5. Running `python github_pipeline.py` will first load data from the GitHub API into a DuckDB dataset, perform transformations, and store the data in the same dataset.
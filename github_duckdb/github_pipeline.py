import dlt

from github import github_reactions, github_repo_events, stargazers


def load_duckdb_repo_reactions_issues_only() -> None:
    """Loads issues, their comments and reactions for duckdb"""
    pipeline = dlt.pipeline(
        "github_reactions",
        destination='duckdb',
        dataset_name="duckdb_issues",
        full_refresh=True,
    )
    # get only 100 items (for issues and pull request)
    data = github_reactions(
        "duckdb", "duckdb", items_per_page=100, max_items=100
    ).with_resources("issues")
    print(pipeline.run(data))


def load_airflow_events() -> None:
    """Loads airflow events. Shows incremental loading. Forces anonymous access token"""
    pipeline = dlt.pipeline(
        "github_events", destination='duckdb', dataset_name="airflow_events"
    )
    data = github_repo_events("apache", "airflow", access_token="")
    print(pipeline.run(data))
    # does not load same events again
    data = github_repo_events("apache", "airflow", access_token="")
    print(pipeline.run(data))


def load_dlthub_dlt_all_data() -> None:
    """Loads all issues, pull requests and comments for dlthub dlt repo"""
    pipeline = dlt.pipeline(
        "github",
        destination='duckdb',
        dataset_name="github_data",
        full_refresh=True,
    )
    pipeline.dataset_name = 'github_data'

    data = github_reactions("dlt-hub", "dlt")
    print(pipeline.run(data))


if __name__ == "__main__":

    # load all data on issues, comments, PRs, reactions, and stargazers
    load_dlthub_dlt_all_data()

    # perform transformations on the data loaded by dlt
    # store the transformed data in the dataset 'github_aggregated'
    pipeline = dlt.pipeline(
        pipeline_name='github',
        destination='duckdb',
        dataset_name='github_aggregated'
    )

    # get venv for dbt
    venv = dlt.dbt.get_venv(pipeline)

    # get runner
    dbt = dlt.dbt.package(
        pipeline,
        "dbt_github",
        venv=venv
    )

    # run the dbt models
    models = dbt.run_all()

    for m in models:
        print(
            f"Model {m.model_name} materialized" +
            f"in {m.time}" +
            f"with status {m.status}" +
            f"and message {m.message}"
        )
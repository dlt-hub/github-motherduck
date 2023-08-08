{{ config(materialized='table') }}

with 
    q_number_issues as (
        select count(*) as count, author__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.issues
            group by author__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_issues_comments as (
        select count(*) as count, author__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.issues__comments
            group by author__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_issues_comments_reactions as (
        select count(*) as count, user__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.issues__comments__reactions
            group by user__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_issues_reactions as (
        select count(*) as count, user__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.issues__reactions
            group by user__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_pull_requests as (
        select count(*) as count, author__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.pull_requests
            group by author__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_pull_requests_comments as (
        select count(*) as count, author__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.pull_requests__comments
            group by author__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_pull_requests_comments_reactions as (
        select count(*) as count, user__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.pull_requests__comments__reactions
            group by user__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_number_pull_requests_reactions as (
        select count(*) as count, user__login as user, DAY(created_at) as day, MONTH(created_at) as month, YEAR(created_at) as year
            from github.github_data.pull_requests__reactions
            group by user__login, DAY(created_at), MONTH(created_at), YEAR(created_at)
        ),

    q_combined as (
        select * from q_number_issues
            union all select * from q_number_issues_comments
            union all select * from q_number_issues_comments_reactions
            union all select * from q_number_issues_reactions
            union all select * from q_number_pull_requests
            union all select * from q_number_pull_requests_comments
            union all select * from q_number_pull_requests_comments_reactions
            union all select * from q_number_pull_requests_reactions
        )
    
select year, month, day, user, sum(count) as activity 
    from q_combined
    group by year, month, day, user
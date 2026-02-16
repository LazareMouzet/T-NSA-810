# Project Management

The team chose to use the GitHub Project ticketing system. It allows creating
a roadmap to plan the tasks in time.

This roadmap is exported in the following Gantt : [See gantt.md](gantt.md)

> This Gantt has been generated with the tool
> [ndesgranges/gantt-exporter](https://github.com/ndesgranges/gantt-exporter)
> Using the following command :
> ```
>   $env:GITHUB_TOKEN="<my_token>"
>   python tools/gantt-exporter/export_gantt.py \
>       --login LazareMouzet --project 4 \
>       --repo LazareMouzet/T-NSA-810 \
>       --include-undated  > docs/project_management/gantt.md
> ```
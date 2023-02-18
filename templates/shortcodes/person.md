{% import "macros/data_links.html" as linker %}
{% set data = load_data(path="data/people.json") %}
{{- linker::data_link(key=key, data=data, attr="short_name") -}}
